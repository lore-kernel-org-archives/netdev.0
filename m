From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] netfilter: ipset: fix timeout value overflow bug
Date: Mon, 14 May 2012 22:10:43 +0200
Message-ID: <20120514201043.GA15485@1984>
References: <1336996023-20249-2-git-send-email-pablo@netfilter.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F0B@saturn3.aculab.com>
 <20120514143635.GA12992@1984>
 <1337006844.8512.491.camel@edumazet-glaptop>
 <alpine.DEB.2.00.1205141943240.28291@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205141943240.28291@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 14, 2012 at 07:45:07PM +0200, Jozsef Kadlecsik wrote:
> On Mon, 14 May 2012, Eric Dumazet wrote:
> 
> > On Mon, 2012-05-14 at 16:36 +0200, Pablo Neira Ayuso wrote:
> > > On Mon, May 14, 2012 at 03:19:49PM +0100, David Laight wrote:
> > > >  
> > > > > --- a/include/linux/netfilter/ipset/ip_set_timeout.h
> > > > > +++ b/include/linux/netfilter/ipset/ip_set_timeout.h
> > > > > @@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
> > > > >  {
> > > > >  	unsigned int timeout = ip_set_get_h32(tb);
> > > > >  
> > > > > +	/* Normalize to fit into jiffies */
> > > > > +	if (timeout > UINT_MAX/1000)
> > > > > +		timeout = UINT_MAX/1000;
> > > > > +
> > > > 
> > > > Doesn't that rather assume that HZ is 1000 ?
> > > 
> > > Indeed. I overlooked that. Thanks David.
> > 
> > I dont think so.
> > 
> > 1000 here is really MSEC_PER_SEC
> > 
> > (All occurrences should be changed in this file)
> 
> Yes, exactly. Pablo, shall I produce a little patch or could you change 
> 1000 to MSEC_PER_SEC?

New patch attached.

I have rebase my tree again.

--lrZ03NoBR/3+SXJZ
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-ipset-fix-timeout-value-overflow-bug.patch"

>From 9fdc90b2d00ecf98797c147d58cfe324fc92c9ed Mon Sep 17 00:00:00 2001
From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Mon, 7 May 2012 02:35:44 +0000
Subject: [PATCH] netfilter: ipset: fix timeout value overflow bug

Large timeout parameters could result wrong timeout values due to
an overflow at msec to jiffies conversion (reported by Andreas Herz)

[ This patch was mangled by Pablo Neira Ayuso since David Laight and
  Eric Dumazet noticed that we were using hardcoded 1000 instead of
  MSEC_PER_SEC to calculate the timeout ]

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set_timeout.h |    4 ++++
 net/netfilter/xt_set.c                         |   15 +++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 4792320..41d9cfa 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
 {
 	unsigned int timeout = ip_set_get_h32(tb);
 
+	/* Normalize to fit into jiffies */
+	if (timeout > UINT_MAX/MSEC_PER_SEC)
+		timeout = UINT_MAX/MSEC_PER_SEC;
+
 	/* Userspace supplied TIMEOUT parameter: adjust crazy size */
 	return timeout == IPSET_NO_TIMEOUT ? IPSET_NO_TIMEOUT - 1 : timeout;
 }
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 0ec8138..035960e 100644
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
+	if (add_opt.timeout > UINT_MAX/MSEC_PER_SEC)
+		add_opt.timeout = UINT_MAX/MSEC_PER_SEC;
 	if (info->add_set.index != IPSET_INVALID_ID)
 		ip_set_add(info->add_set.index, skb, par, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-- 
1.7.10


--lrZ03NoBR/3+SXJZ--
