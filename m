From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3 v2] net: ipv4 sysctl option to ignore routes
 when nexthop link is down
Date: Wed, 10 Jun 2015 15:04:03 -0400
Message-ID: <20150610190402.GS588@gospo.home.greyhouse.net>
References: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com>
 <1433918841-15576-3-git-send-email-gospo@cumulusnetworks.com>
 <5578630F.9070602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35605 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623AbbFJTEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 15:04:08 -0400
Received: by qgg3 with SMTP id 3so19553395qgg.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 12:04:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5578630F.9070602@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 09:17:19AM -0700, Alexander Duyck wrote:
> 
> 
> On 06/09/2015 11:47 PM, Andy Gospodarek wrote:
> >This feature is only enabled with the new per-interface or ipv4 global
> >sysctls called 'ignore_routes_with_linkdown'.
> >
> >net.ipv4.conf.all.ignore_routes_with_linkdown = 0
> >net.ipv4.conf.default.ignore_routes_with_linkdown = 0
> >net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
> >...
> >
> >When the above sysctls are set, will report to userspace that a route is
> >dead and will no longer resolve to this nexthop when performing a fib
> >lookup.  This will signal to userspace that the route will not be
> >selected.  The signalling of a RTNH_F_DEAD is only passed to userspace
> >if the sysctl is enabled and link is down.  This was done as without it the
> >netlink listeners would have no idea whether or not a nexthop would be
> >selected.   The kernel only sets RTNH_F_DEAD internally if the inteface has
> >IFF_UP cleared.
> >
> >With the new sysctl set, the following behavior can be observed
> >(interface p8p1 is link-down):
> >
> ># ip route show
> >default via 10.0.5.2 dev p9p1
> >10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> >70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> >80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead linkdown
> >90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 dead linkdown
> >90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> ># ip route get 90.0.0.1
> >90.0.0.1 via 70.0.0.2 dev p7p1  src 70.0.0.1
> >     cache
> ># ip route get 80.0.0.1
> >local 80.0.0.1 dev lo  src 80.0.0.1
> >     cache <local>
> ># ip route get 80.0.0.2
> >80.0.0.2 via 10.0.5.2 dev p9p1  src 10.0.5.15
> >     cache
> >
> >While the route does remain in the table (so it can be modified if
> >needed rather than being wiped away as it would be if IFF_UP was
> >cleared), the proper next-hop is chosen automatically when the link is
> >down.  Now interface p8p1 is linked-up:
> >
> ># ip route show
> >default via 10.0.5.2 dev p9p1
> >10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> >70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> >80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1
> >90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1
> >90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> >192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2
> ># ip route get 90.0.0.1
> >90.0.0.1 via 80.0.0.2 dev p8p1  src 80.0.0.1
> >     cache
> ># ip route get 80.0.0.1
> >local 80.0.0.1 dev lo  src 80.0.0.1
> >     cache <local>
> ># ip route get 80.0.0.2
> >80.0.0.2 dev p8p1  src 80.0.0.1
> >     cache
> >
> >and the output changes to what one would expect.
> >
> >If the sysctl is not set, the following output would be expected when
> >p8p1 is down:
> >
> ># ip route show
> >default via 10.0.5.2 dev p9p1
> >10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> >70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> >80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 linkdown
> >90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 linkdown
> >90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> >
> >Since the dead flag does not appear, there should be no expectation that
> >the kernel would skip using this route due to link being down.
> >
> >v2: Split kernel changes into 2 patches, this actually makes a
> >behavioral change if the sysctl is set.  Also took suggestion from Alex
> >to simplify code by only checking sysctl during fib lookup and
> >suggestion from Scott to add a per-interface sysctl.
> >
> >Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> >Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> >---
> >  include/linux/inetdevice.h        |  3 +++
> >  include/net/fib_rules.h           |  3 ++-
> >  include/net/ip_fib.h              | 17 ++++++++++-------
> >  include/uapi/linux/ip.h           |  1 +
> >  include/uapi/linux/sysctl.h       |  1 +
> >  kernel/sysctl_binary.c            |  1 +
> >  net/ipv4/devinet.c                |  2 ++
> >  net/ipv4/fib_frontend.c           |  6 +++---
> >  net/ipv4/fib_rules.c              |  5 +++--
> >  net/ipv4/fib_semantics.c          | 28 ++++++++++++++++++++++------
> >  net/ipv4/fib_trie.c               |  7 +++++++
> >  net/ipv4/netfilter/ipt_rpfilter.c |  2 +-
> >  net/ipv4/route.c                  | 10 +++++-----
> >  13 files changed, 61 insertions(+), 25 deletions(-)
[...]
> >diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> >index d1de1b7..854d790 100644
> >--- a/include/net/ip_fib.h
> >+++ b/include/net/ip_fib.h
> >@@ -266,11 +267,13 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
> >
> >  	for (err = 0; !err; err = -ENETUNREACH) {
> >  		tb = rcu_dereference_rtnl(net->ipv4.fib_main);
> >-		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
> >+		if (tb && !fib_table_lookup(tb, flp, res,
> >+					    flags | FIB_LOOKUP_NOREF))
> >  			break;
> >
> >  		tb = rcu_dereference_rtnl(net->ipv4.fib_default);
> >-		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
> >+		if (tb && !fib_table_lookup(tb, flp, res,
> >+					    flags | FIB_LOOKUP_NOREF))
> >  			break;
> >  	}
> >
> 
> Instead of 3 lines w/ flags | FIB_LOOKUP_NOREF you could probably just do a
> flags |= FIB_LOOKUP_NOREF once and save yourself some trouble.
Sure.  But I get credit for less lines that way.  ;-)

[...]
> >@@ -319,7 +319,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
> >  	fl4.flowi4_mark = IN_DEV_SRC_VMARK(idev) ? skb->mark : 0;
> >
> >  	net = dev_net(dev);
> >-	if (fib_lookup(net, &fl4, &res))
> >+	if (fib_lookup(net, &fl4, &res, 0))
> >  		goto last_resort;
> >  	if (res.type != RTN_UNICAST &&
> >  	    (res.type != RTN_LOCAL || !IN_DEV_ACCEPT_LOCAL(idev)))
> >@@ -354,7 +354,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
> >  	fl4.flowi4_oif = dev->ifindex;
> >
> >  	ret = 0;
> >-	if (fib_lookup(net, &fl4, &res) == 0) {
> >+	if (fib_lookup(net, &fl4, &res, 0) == 0) {
> >  		if (res.type == RTN_UNICAST)
> >  			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
> >  	}
> 
> The code for validating a source could probably ignore the LINKDOWN message.
> Otherwise we run the risk of a link flapping and confusing the source since
> the link is down but any Rx packets in the rings are being flushed.
Excellent point.  After thinking about this a bit, I think you are
correct that we would want to consider a dead link or an alive link as a
valid interface for receiving traffic.  Flag added for v3.

[...]
> >@@ -1057,11 +1062,16 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
> >  			goto nla_put_failure;
> >
> >  		for_nexthops(fi) {
> >+			struct in_device *in_dev = __in_dev_get_rcu(nh->nh_dev);
> >  			rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
> >  			if (!rtnh)
> >  				goto nla_put_failure;
> >
> >-			rtnh->rtnh_flags = nh->nh_flags & 0xFF;
> >+			if (in_dev && IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> >+			    nh->nh_flags & RTNH_F_LINKDOWN)
> >+				rtnh->rtnh_flags = (nh->nh_flags | RTNH_F_DEAD) & 0xFF;
> >+			else
> >+				rtnh->rtnh_flags = nh->nh_flags & 0xFF;
> >  			rtnh->rtnh_hops = nh->nh_weight - 1;
> >  			rtnh->rtnh_ifindex = nh->nh_oif;
> >
> 
> Why not just split this if into two seperate statments? One taking care of
> the first setting of rtnh_flags and then a second one ORing in the
> RTNH_F_DEAD.
If that seems easier to maintain, I can do that for v3.

[...]
> >diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> >index 3c699c4..f75ca20 100644
> >--- a/net/ipv4/fib_trie.c
> >+++ b/net/ipv4/fib_trie.c
> >@@ -1407,11 +1407,18 @@ found:
> >  		}
> >  		if (fi->fib_flags & RTNH_F_DEAD)
> >  			continue;
> >+
> >  		for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
> >  			const struct fib_nh *nh = &fi->fib_nh[nhsel];
> >+			struct in_device *in_dev = __in_dev_get_rcu(nh->nh_dev);
> >
> >  			if (nh->nh_flags & RTNH_F_DEAD)
> >  				continue;
> >+			if (in_dev &&
> >+			    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> >+			    nh->nh_flags & RTNH_F_LINKDOWN &&
> >+			    !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
> >+				continue;
> >  			if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
> >  				continue;
> >
> 
> The order of checks should be:
> 	1.  (nh->nh_flags & RTNH_F_LINKDOWN)
> 	2.  !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE)
This one is not needed as we will not have this flag set anywhere but 1,
3, and 4 in that order seems cleaner.

> 	3.  in_dev
> 	4. IGNORE_ROUTES_WITH_LINKDOWN
> 
> That way we don't waste time checking the in_dev if the link isn't reported
> as being down.  Also I would probably move the whole block inside an if
> statement based off of the first 2 checks since nothing else is making use
> of in_dev.
This seems like a nice optimization.  I'll do it here and above outside
the nh loop.

> 
> >diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
> >index 4bfaedf..250c633 100644
> >--- a/net/ipv4/netfilter/ipt_rpfilter.c
> >+++ b/net/ipv4/netfilter/ipt_rpfilter.c
> >@@ -40,7 +40,7 @@ static bool rpfilter_lookup_reverse(struct flowi4 *fl4,
> >  	struct net *net = dev_net(dev);
> >  	int ret __maybe_unused;
> >
> >-	if (fib_lookup(net, fl4, &res))
> >+	if (fib_lookup(net, fl4, &res, 0))
> >  		return false;
> >
> >  	if (res.type != RTN_UNICAST) {
> 
> Any rpfilter stuff can probably ignore the linkdown check since it is
> possible that a driver could be flushing data just after a link went down.
Agreed based on thoughts from __fib_validate_source.

Thanks for this review, too.
