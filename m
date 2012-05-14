From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] netfilter: ipset: fix timeout value overflow bug
Date: Mon, 14 May 2012 16:36:35 +0200
Message-ID: <20120514143635.GA12992@1984>
References: <1336996023-20249-2-git-send-email-pablo@netfilter.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F0B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="WYTEVAkct0FjGQmd"
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48988 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755331Ab2ENOgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 10:36:43 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F0B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--WYTEVAkct0FjGQmd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 14, 2012 at 03:19:49PM +0100, David Laight wrote:
>  
> > --- a/include/linux/netfilter/ipset/ip_set_timeout.h
> > +++ b/include/linux/netfilter/ipset/ip_set_timeout.h
> > @@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
> >  {
> >  	unsigned int timeout = ip_set_get_h32(tb);
> >  
> > +	/* Normalize to fit into jiffies */
> > +	if (timeout > UINT_MAX/1000)
> > +		timeout = UINT_MAX/1000;
> > +
> 
> Doesn't that rather assume that HZ is 1000 ?

Indeed. I overlooked that. Thanks David.

New patch attached fixing this. I've rebased my tree.

@Jozsef: BTW, why do we have

include/linux/netfilter/ipset/ip_set_timeout.h

living under include/linux ?

All definitions are private to the kernel. Why not moving that header
(and other similar) to include/net ?

--WYTEVAkct0FjGQmd
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-ipset-fix-timeout-value-overflow-bug.patch"

>From bcb0e955ae5ea5acb1b59fb59e4fcb1c8364994d Mon Sep 17 00:00:00 2001
From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Mon, 7 May 2012 02:35:44 +0000
Subject: [PATCH] netfilter: ipset: fix timeout value overflow bug

Large timeout parameters could result wrong timeout values due to
an overflow at msec to jiffies conversion (reported by Andreas Herz)

[ This patch was mangled by Pablo Neira Ayuso since David Laight notices
  that we were using hardcode 1000 instead of HZ to calculate the timeout ]

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set_timeout.h |    4 ++++
 net/netfilter/xt_set.c                         |   15 +++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 4792320..40a85b1 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
 {
 	unsigned int timeout = ip_set_get_h32(tb);
 
+	/* Normalize to fit into jiffies */
+	if (timeout > UINT_MAX/HZ)
+		timeout = UINT_MAX/HZ;
+
 	/* Userspace supplied TIMEOUT parameter: adjust crazy size */
 	return timeout == IPSET_NO_TIMEOUT ? IPSET_NO_TIMEOUT - 1 : timeout;
 }
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 0ec8138..15275e9 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -44,6 +44,14 @@ const struct ip_set_adt_opt n = {	\
 	.cmdflags = cfs,		\
 	.timeout = t,			\
 }
+#define ADT_MOPT(n, f, d, fs, cfs, t)	\
+struct ip_set_adt_opt n = {		\
+	.family	= f,			\
+	.dim = d,			\
+	.flags = fs,			\
+	.cmdflags = cfs,		\
+	.timeout = t,			\
+}
 
 /* Revision 0 interface: backward compatible with netfilter/iptables */
 
@@ -296,11 +304,14 @@ static unsigned int
 set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_set_info_target_v2 *info = par->targinfo;
-	ADT_OPT(add_opt, par->family, info->add_set.dim,
-		info->add_set.flags, info->flags, info->timeout);
+	ADT_MOPT(add_opt, par->family, info->add_set.dim,
+		 info->add_set.flags, info->flags, info->timeout);
 	ADT_OPT(del_opt, par->family, info->del_set.dim,
 		info->del_set.flags, 0, UINT_MAX);
 
+	/* Normalize to fit into jiffies */
+	if (add_opt.timeout > UINT_MAX/HZ)
+		add_opt.timeout = UINT_MAX/HZ;
 	if (info->add_set.index != IPSET_INVALID_ID)
 		ip_set_add(info->add_set.index, skb, par, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-- 
1.7.10


--WYTEVAkct0FjGQmd--
