From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 02 Mar 2010 07:11:45 -0500
Message-ID: <1267531905.21749.21.camel@bigi>
References: <1267017564.3973.790.camel@bigi>
	 <20100302112754.GA1513@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, yoshfuji@linux-ipv6.org,
	nakam@linux-ipv6.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59462 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab0CBMLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 07:11:55 -0500
Received: by vws9 with SMTP id 9so57112vws.19
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 04:11:54 -0800 (PST)
In-Reply-To: <20100302112754.GA1513@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-02 at 19:27 +0800, Herbert Xu wrote:
> On Wed, Feb 24, 2010 at 08:19:24AM -0500, jamal wrote:

> > 1)In the connect() stage, in the slow path a route cache is
> > created with the rth->fl.fl4_src of 0.0.0.0...
> > ==> policy->bundles is empty, so we do a lookup, fail, create
> > one.. (remember rth->fl.fl4_src of 0.0.0.0 at this stage and
> > thats what we end storing in the bundle/xdst for later comparison
> > instead of the skb's fl)
> 
> So this is root number 1.  When this stuff was first written this
> case simply wasn't possible.  So I think the question we need to
> ask here is can we get a valid address there at the connect stage?

fl->fl4_src is valid non-zero. But in xfrm4_fill_dst()
we do wholesale copy of xdst->u.rt.fl = rt->fl; and rt->fl.fl4_src is
0.0.0.0.


> After all, for non-IPsec connect(2)s, you do get a valid IP address.
> So I don't see why the IPsec case should be different.
>
> Creating a bundle with a zero source address is just a hack to
> make connect(2) succeed immediately.  AFAICS getting a valid IP
> address can also be done without waiting for the whole IPsec state
> to be created.
> 

I did try to "fix it" above via:
+               if (!xdst->u.rt.fl.fl4_src) {
+                       xdst->u.rt.fl.fl4_src = fl->fl4_src;
+               }

But this breaks again later in sendmsg bundle lookup because of 
XFRM_SUB_POLICY. If i turned off config XFRM_SUB_POLICY, then
all works. I didnt look closely, but SUB_POLICY does do a memcpy
or two off the dst passed in connect() - which has the wrong src.
So i would have to "fix" a few more spots for it to work. This is
where i gave up concluding that i was just plugging with band-aids.

> Of course if anybody is still interested we could also revisit
> the neighbouresque queueing idea.

not plugged into that discussion..

> > 2)ping sends a packet (does a sendmsg) 
> > ==> xfrm_find_bundle() ends up comparing skb's->fl (non-zero
> > fl->fl4_src) with what we stored from #1b. Fails.
> > ==> we create a new bundle at attach the old one at the end of it.
> > ...and now policy->bundles has two xdst entries
> 
> This is the way it's supposed to work.

> > 3) Repeat #2, and now we have 3 xdsts in policy bundles
> 
> This is what I don't understand.  The code is supposed to look
> at every bundle attached to the policy.  So why doesn't it find
> the one we created at step #2?

The issue is that the comparison is between xdst->u.rt.fl.fl4_src and
fl->fl4_src. fl->fl4_src is always non-zero. stored
xdst->u.rt.fl.fl4_src is always zero 

> In conclusion, I think we have two problems, with the second
> one being the most immediate cause of your symptoms.

Remember the route cache (refer to dst copying above) is created at
connect time;->

So Steffen (on CC) tried to "fix it" by fixing at route cache creation
time. His approach:

--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2778,15 +2778,26 @@ int ip_route_output_flow(struct net *net, struct
rtable **rp, struct flowi *flp,
                         struct sock *sk, int flags)
 {
        int err;
+       int update_route = 0;
 
        if ((err = __ip_route_output_key(net, rp, flp)) != 0)
                return err;
 
        if (flp->proto) {
-               if (!flp->fl4_src)
+               if (!flp->fl4_src) {
                        flp->fl4_src = (*rp)->rt_src;
-               if (!flp->fl4_dst)
+                       update_route = 1;
+               }
+               if (!flp->fl4_dst) {
                        flp->fl4_dst = (*rp)->rt_dst;
+                       update_route = 1;
+               }
+               if (update_route) {
+                       dst_release(&(*rp)->u.dst);
+                       if ((err = __ip_route_output_key(net, rp,
flp)) != 0)
+                               return err;
+               }
+
                err = __xfrm_lookup(net, (struct dst_entry **)rp, flp,
sk,
                                    flags ? XFRM_LOOKUP_WAIT : 0);
                if (err == -EREMOTE)
--

I was worried about the impact of this on something else that expects
the behavior.

cheers,
jamal

