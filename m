From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tg3 locking update (with NAPI overtones)
Date: Tue, 26 Nov 2002 19:53:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE41779.9030804@pobox.com>
References: <3DE406AE.2000908@pobox.com> <20021126.155144.43008660.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3DE406AE.2000908@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Looks good to me on first glance, testing will confirm
> further :-)

yeppers :)

> Probably, to kill the long delays with locks held, we just
> need to add a PHY config semaphore.  Interrupts that want to
> try and program the PHY just do a down_trylock() on that semaphore
> and defer their work if it cannot be acquired.


I was thinking along similar lines, and you just gave me an idea as well 
:)  Hopefully I can present a patch later on tonight showing these ideas.

For now, just responding to the above, I think there are further needs: 
  even if you acquire that semaphore, you can still wind up a full 
tg3_halt + tg3_init_hw in interrupt context, which means you could be 
there a while.  MAC/firmware init can be expensive, even ignoring the 
phy init.  Also consider the general argument that once you are 
resetting the MAC or phy, you aren't really doing useful RX/TX work; you 
can concentrate on making the slow path simple and safe while knowing 
that the fast path is idle.

So...   I prefer to simply always defer MAC/phy reset if in interrupt 
context.  This allows us to sleep as long as we want during phy and MAC 
init.  If the manual says "poll each block max of 2ms", we can do it 
easily with yield() in a loop or schedule_timeout(), the way God 
intended drivers to sleep :)

	Jeff
