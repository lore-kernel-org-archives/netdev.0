From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Fri, 30 Nov 2012 18:39:36 +0100
Message-ID: <20121130173936.GA11668@shrek.podlesie.net>
References: <201211300138.qAU1c8sE003388@thirdoffive.cmf.nrl.navy.mil>
 <1354240620.21562.256.camel@shinybook.infradead.org>
 <1354263922.21562.270.camel@shinybook.infradead.org>
 <20121130095354.GA15126@shrek.podlesie.net>
 <1354277415.21562.284.camel@shinybook.infradead.org>
 <1354292626.21562.298.camel@shinybook.infradead.org>
 <20121130121256.77685fef@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121130121256.77685fef@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2012 at 12:12:56PM -0500, chas williams - CONTRACTOR wrote:
> >Really, what we're saying is that *one* of the driver or protocol close
> >functions needs to be split, and we need to do DPD or PDP. Since the
> >device driver *can* abort/flush the TX queue and also any pending RX
> >being handled by a tasklet, I think it makes most sense to keep it in
> >the middle, with the protocol being handled first and last... which is
> >the current order, as long as we consider setting ATM_VF_CLOSE to be the
> >first part.
> 
> i believe this is essentially already done with the release_cb()
> implementation right?  that is splitting the protocol detach/shutdown
> into two parts.

partially, release_cb() is about ATM socket locking. To avoid some races
we need to take the ATM socket lock in protocol send function
(br2684_start_xmit, pppoatm_send, ...). That functions are executed
in bh context and we cannot sleep and wait for releasing the ATM socket
lock, so we just block sending and when the ATM socket is unlocked
release_cb() is called and we re-enabling sending.


Currently the first part of detach is just:

	lock_sock(sk)

	(without latest "br2684: don't send frames on not-ready vcc"
	the first part was

	set_bit(ATM_VF_CLOSE, &vcc->flags);
	clear_bit(ATM_VF_READY, &vcc->flags);

	for br2684)

After that the protocol stops sending new packets so the vcc may be
fully closed by ATM driver. The protocol is still ready to process
received packets. After vcc is closed the protocol can safely detach
knowing that no new packets will be received.

Krzysiek
