From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Fri, 6 Jun 2003 11:48:36 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306052009580.32033-100000@rhea.tcs.hut.fi>
References: <20030605.191224.68706097.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <ajtuomin@morphine.tml.hut.fi>, <lpetande@morphine.tml.hut.fi>,
   <jagana@us.ibm.com>, <kumarkr@us.ibm.com>, <nakam@linux-ipv6.org>,
   <usagi-core@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030605.191224.68706097.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> In article <20030531.000319.114704530.yoshfuji@linux-ipv6.org> (at Sat, 31 May 2003 00:03:19 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
>
> > In article <Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi> (at Fri, 30 May 2003 17:34:40 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> >
> > > here is a patch that fixes CONFIG_IPV6_SUBTREES and allows overriding
> > > normal routes with source address specific ones. This is for example
> > > needed in MIPv6 for handling the traffic to and from a mobile node's home
> > > address correctly.
> >
> > Let us test the patch.  It seemed buggy when USAGI tested before.
>
> I've re-tested your latest CONFIG_IPV6_SUBTREE patch.
> The results of the restesting seems fine.

Great! :)

> However, I won't accept your patch as-is for now.
>
> The patch consists of several parts:
>
>  1. fixing bugs in IPv6 code
>  2. fixing bugs in CONFIG_IPV6_SUBTREE code
>  3. changing majority of keys of routing table.
>
> There's no problems with 1 and 2.
> However, We need to discuss on 3.

I have of course no objections against 1. :)

However 2 and 3 are in my view quite interrelated.

> As I said in other thread, the policy routing should be done in the
> other way.  And, it is not good to change the semantics of
> CONFIG_IPV6_SUBTREE.

Even if the semantics are flawed? I'll try to explain my reasoning below.

> In original, routing is looked up by destination address, and then,
> looked up by the source address; destination takes precedence over source.
> Your patch changes this. Source address takes precedence over destination
> address.

The main problem with the original destination,source lookup are the
cached host routes created by ip6_route_{input,output} (or actually
rt6_cow).

Since these routes have destination prefix length 128, they will override
all source routes, unless they also are host routes.

This happens because the (non-host) source route ends up in the subtree of
a node higher up in the destination tree, which will never be reached
because the cached host route already matches the destination address.

Since the initial mode of communication between a mobile node (using its
home address) and any correspondent node is reverse tunneling we at least
need something like a default (i.e. a non-host) route through the tunnel
for the MN's home address.

Not until route optimization is set up between the MN and the CN do we
actually get host routes for the traffic between the two.

If we switch the order of keys to source,destination we don't get this
problem since the cached host routes end up at the bottom of the subtrees
and wont interfere with the normal routing.

Prefix routes also cause problems with the destination,source key order,
since we must create a duplicate route for each prefix and home address.

Hope I explained it clearly enough :)

> From the point of the policy routing, both (and other attributes) should be
> considered equally, and this is what IPv4 routing table does.

This of course seems like the optimal solution.

> Well, I won't hurry intorducing IPv6 policy routing just because of MIP6.
> The reason why I won't hurry is because I still believe it is not
> required for MIP6.  Nakamura, one of our member, will describe the details.
> It takes precedence over "limited" policy(?) routing to introcuce generic
> policy routing.

I still think _some_ routing changes are necessary, but I guess we need to
discuss what the changes are. I'm btw willing to help with the IPv6 policy
routing if that helps getting it into the kernel sooner.

> Anyway, will you split up your patch (into 1-3 above) first, please?

I'll check if there still is anything to do in 1 after the patch you
already submitted, but let's please discuss 3 before I split it into 2 and
3.

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
