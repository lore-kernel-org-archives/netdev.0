From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Fri, 30 Nov 2012 10:53:54 +0100
Message-ID: <20121130095354.GA15126@shrek.podlesie.net>
References: <201211300138.qAU1c8sE003388@thirdoffive.cmf.nrl.navy.mil>
 <1354240620.21562.256.camel@shinybook.infradead.org>
 <1354263922.21562.270.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354263922.21562.270.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2012 at 08:25:22AM +0000, David Woodhouse wrote:
> On Fri, 2012-11-30 at 01:57 +0000, David Woodhouse wrote:
> > I think it's actually fixed for pppoatm by the bh_lock_sock() and the
> > sock_owned_by_user() check. As soon as vcc_release() calls lock_sock(),
> > pppoatm stops accepting packets.
> > 
> > It should be simple enough to do the same in br2684.
> 
> Um... but now I come to look at it... Krzysztof, doesn't your 'pppoatm:
> take ATM socket lock in pppoatm_send()' patch actually *break* the case
> of sending via vcc_sendmsg()?

no, in case of

	pppoatm_send()
			vcc_sendmsg()

the vcc_sendmsg() will just wait for releasing sk->sk_lock.slock.

When the vcc_sendmsg() gets lock first

			vcc_sendmsg()
	pppoatm_send()

The pppoatm_send() might spin for a while for sk->sk_lock.slock, but
after lock_sock() the vcc_sendmsg() releases that lock and
pppoatm_send() will acquire it and notice that locked is locked
(sock_owned_by_user() returns true) and will just block pppoatm,
and will be woken up in release_sock() (fix was fixed by your 10/17
patch).

> 
> Why did you include the sock_owned_by_user() check in there and not just
> use bh_lock_sock()?

because bh_lock_sock() will succeeds even with concurrent vcc_sendmsg()
and will have some races in that case.

> 
> With the sock_owned_by_user() check, it'll *always* drop packets
> submitted through vcc_sendmsg(), won't it?

No, sock_owned_by_user() is just in pppoatm_send() and instead of
dropping packets we block pppd.

> 
> Admittedly, for PPPoATM and BR2684 we never do want to have packets
> submitted directly from userspace that way; they should all come via the
> PPP channel or the netdev respectively. So we might want to keep the
> sock_owned_by_user() check because it fixes the close race, and
> explicitly document it.

It fixes also races with vcc_sendmsg(). If we really don't wont
vcc_sendmsg() with pppoatm and br2684 we must do some protection
than vcc_sendmsg() will fail instead of racing with pppoatm_send()
and crashing with some drivers that does not support concurent
->send().

> 
> But it doesn't necessarily work for other protocols, so we may need a
> better solution for the general case. Perhaps drop the
> sock_owned_by_user() check, and put bh_lock_sock() around the beginning
> of vcc_destroy_socket() where it clears ATM_VF_READY? That'll ensure
> that no ->push() is *currently* operating on a skb having seen that the
> VCC is still open.
> 
> Or maybe we just make the *devices* check the ATM_VF_CLOSE flag and
> refuse to send the skb? Put the entire thing into their domain. Although
> that may involve extra locking in the driver to synchronise send() and
> close() sufficiently.

We need some additional synchronizization with pppoatm_send(), now
we use:

	tasklet_kill(&pvcc->wakeup_tasklet);
	ppp_unregister_channel(&pvcc->chan);

In ppp_unregister_channel() we will synchronize with the function
calling pppoatm_send() using "downl" lock.

And this must be done in pppoatm.

> 
> I'm still reluctant to swap the order of the device/protocol close in
> vcc_destroy_socket(). I think that'll just swap one set of problems
> which is now fairly well-understood and mostly solved, for another set.
> In particular, I think the device needs to see the close first, because
> *it* can actually abort or flush any pending TX and RX (including
> synchronising with its tasklet as solos-pci does, etc.). Only then does
> the protocol tear its data structures down. But I suppose the new set of
> problems could be found and overcome, if Chas wants to propose an
> alternative patch set...
> 

I think that the current order is good, now we have:

	1. stop_sending_fames	to protocol
		now TX is shut down
		(currently done by
			set_bit(ATM_VF_CLOSE, &vcc->flags);
			clear_bit(ATM_VF_READY, &vcc->flags);
		)
	2. close_device		to device
		now RX is shut down
	3. device_was_closed	to protocol
		ugly push(NULL), but we can add some other callback.

we also can do:

	1. disable RX		to device
		now RX is shut down
	2. detach	to protocol
		now TX is shut down
		(now protocol can fully detach because RX is disabled)
	3. close_device		to device
		(device is not used anymore)

Krzysiek
