From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Wed, 30 Mar 2005 18:15:22 +0200
Message-ID: <20050330161522.GH32111@g5.random>
References: <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de> <20050330153313.GD32111@g5.random> <20050330153948.GE12672@muc.de> <20050330154418.GE32111@g5.random> <20050330160255.GG12672@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050330160255.GG12672@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 06:02:55PM +0200, Andi Kleen wrote:
> On Wed, Mar 30, 2005 at 05:44:18PM +0200, Andrea Arcangeli wrote:
> > On Wed, Mar 30, 2005 at 05:39:48PM +0200, Andi Kleen wrote:
> > > An unsolveable one IMHO. You can just try to be good enough. For that
> > 
> > I think it's solvable with an algorithm I outlined several emails ago.
> 
> The problem with you algorithm is that you cannot control
> how to NIC puts incoming packets into RX rings (and then 
> actually if the packets you are interested in do actually arrive from
> the net ,-)

All I care about is to assign a mempool ID to the skb (ID being unique
identifier for the tcp connection I don't care how the implementation
is). If while moving up the stack the skb data doesn't match to the
sock->mempool id, we'll just free the packet and put it back in the
mempool.

This of course only triggers with skb marked with a mempool ID, all
skb allocated with GFP_ATOMIC will have a Null ID and they won't check
anything and nothing will change for them.

After GFP fails you pick the skb from a random mempool everytime, so you
need all mempools belonging to sockets that routes somehow thorugh a
certain NIC driver instance, quickly reacheable from the NIC device
driver.

I don't see any problem with this algo. I don't need to control how NIC
process the incoming packets, after GFP fails I allocate from a 
random mempool, I set the skb mempool ID to the ID of the mempool we
picked from, and I let the stack process it. Then you need a check as
soon as you finished processing the TCP header, to release the skb back
in its originating mempool immediatly if the sock mempool ID doesn't
match the skb mempool ID but that's easy.

All it matters is that this skb can't get stuck in the middle of nowhere
in unfreeable state, but I don't see how could it get stuck in between
the netfix_rx and the sock identification via tcp and ip headers. It
just can't get stuck, either it's freed prematurely, or it's freed by us
with the new mempool id check. It could get stuck if we would let it go
ahead into some out of order queues, but not before our new check for
mempool ID after tcp header decode.

This is all going to be complex to code, but I think it's technically
doable.

> While some NICs have hardware support to get high priority
> packets into different queues these tend to add nasty limits
> on the max number of connections. Which IMHO is not acceptable.
> 
> "We have an enterprise class OS with iSCSI which can only
> support four swap devices"

;) I agree the hardware solution isn't appealing.
