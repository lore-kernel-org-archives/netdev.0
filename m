From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 29 Sep 2004 13:27:24 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929032724.GA26959@gondor.apana.org.au>
References: <20040928024614.GA9911@gondor.apana.org.au> <1096340772.8659.51.camel@jzny.localdomain> <20040928032321.GB10116@gondor.apana.org.au> <1096343125.8661.96.camel@jzny.localdomain> <20040928035921.GA10675@gondor.apana.org.au> <1096367787.8662.146.camel@jzny.localdomain> <20040928111159.GA18421@gondor.apana.org.au> <1096374736.8663.217.camel@jzny.localdomain> <20040929001327.GB25293@gondor.apana.org.au> <1096426324.1044.129.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096426324.1044.129.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 28, 2004 at 10:52:05PM -0400, jamal wrote:
>
> > You're right.  rtmsg_info() is using GOODISZE unnecessarily.  I'll
> > write up a patch.
> 
> But why? ;->

So that the alloc_skb() is slightly less likely to fail.  The dumpers
gain a lot by using GOODSIZE since they can fill it up.  As rtmsg_info
has no chance of getting anywhere near GOODSIZE we should provide a
more accruate estimate.

It also means that with netlink_trim() you'll save a realloc/copy.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Dave, you can stop reading now :)
 
> Well, if you are gonna overrun the socket anyways, is there a point
> in delivering all that incomplete info?
>
> If you go ahead and deliver it anyways, you will be crossing
> kernel->userspace. Its a worthy cause to do so.

Hang on a second, if we're going to overrun anyway, then we *can't*
deliver it to user-space.  If we could deliver then we wouldn't be
having an overrun.

> > Can you please elaborate on "crossing into user space"? I don't think
> > I understand where these cycles are being wasted.
> 
> delivering messages which get obsoleted by an overun from kernel to user
> space for uses up unnecessary cycles.

You'll have to spell it out for me I'm afraid :)

If we're overrunning then we can't deliver the message at hand.  If you
are referring to the messages afterwards then the only way we can deliver
them is if the appliation lets us by clearing the queue.  If you are
referring to the messages that are already on the queue then we've done
the work already so why shouldn't they stay?

> A dump may be harder given it keeps state. A get item which generates
> a huge dataset (dont ask me to give you an example) is going to cause
> overruns. Think a multi message formated data.

That's a completely different story.  For that problem I'd suggest that
we extend the dump paradigm to cover get as well.  However, to design the
interface, we need to look at potential users of this.  So please give
me an example :)

> > Not quite.  Overrun errors are reported immediately.  
> 
> Yes, except they get reported sooner (by virtue of queue getting filled
> sooner) if you have a 4K sock buffer vs 1M if you are registered for the
> same events. I Know its a digression - just making a point.

The one with the 1M buffer may not overrun at all if it can process the
events fast enough.

> congestion - especially in a local scenario. Of course such queues have 
> finite buffers - you just engineer it so the queue doesnt overflow and
> head of line blocking is tolerable. Either of those concerns not
> addressed, shit will hit the fan.

I don't see how you can engineer it so that it doesn't overflow.  In
the example that you gave with interface address, the number of messages
generated is practically unbounded.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/rtnetlink.c 1.28 vs edited =====
--- 1.28/net/core/rtnetlink.c	2004-09-22 12:16:43 +10:00
+++ edited/net/core/rtnetlink.c	2004-09-29 13:23:43 +10:00
@@ -412,7 +412,9 @@
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 {
 	struct sk_buff *skb;
-	int size = NLMSG_GOODSIZE;
+	int size = NLMSG_SPACE(sizeof(struct ifinfomsg) +
+			       sizeof(struct rtnl_link_ifmap) +
+			       sizeof(struct rtnl_link_stats) + 128);
 
 	skb = alloc_skb(size, GFP_KERNEL);
 	if (!skb)

--UlVJffcvxoiEqYs2--
