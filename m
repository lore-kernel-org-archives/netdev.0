From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 18:22:54 +0100
Message-ID: <20110118172254.GA1843@del.dom.local>
References: <4D336050.9030602@netfilter.org>
 <20110118093811.GA7520@ff.dom.local>
 <20110118.020702.115924992.davem@davemloft.net>
 <20110118102437.GB7520@ff.dom.local>
 <1295359503.2066.10.camel@mojatatu>
 <1295359653.2066.11.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Alessandro Suardi <alessandro.suardi@gmail.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47508 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab1ARRXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 12:23:01 -0500
Received: by fxm20 with SMTP id 20so7441644fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 09:23:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1295359653.2066.11.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 09:07:33AM -0500, jamal wrote:
> On Tue, 2011-01-18 at 09:05 -0500, jamal wrote:
> > On Tue, 2011-01-18 at 10:24 +0000, Jarek Poplawski wrote:
> > 
> > > Do you all expect all users manage to upgrade avahi app before
> > > changing their stable kernel? I mean "own distro" users especially.
> > 
> > Unfortunately if that app is widely deployed, it is not pragmatic
> > to break it in the name of pedanticity. 
> 
> And to complete that thought - if avahi continues to work and merely
> whines, i dont see why this patch should be reverted..

Alas it looks like more than whines ;-)
Cheers,
Jarek P.

[PATCH] netlink: Revert test for all flags of the NLM_F_DUMP composite

Arthur Marsh reported:
> With kernel 2.6.37-git9 and later inbound telnetd-ssl connections
> failed, and on machine shut-down, there were warning messages about
> daemons not return status.
and bisected the bug.
 
After looking at net/core/rtnetlink.c:

static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
{
	...
        kind = type&3;

        if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
                return -EPERM;

        if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {

I'm sure the fix in commit 0ab03c2b1478f24 is simply wrong. NLM_F_DUMP
flags can't be mistaken with NLM_F_EXCL if there is a check for GET
request like above (ie. kind == 2). So there is no reason to limit 3
various dump cases from the RFC (not counting the atomic flag) to one
and only NLM_F_DUMP.

That's why I propose this reverting patch here and a separate fix to
genetlink (soon).

Reverts commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf

Reported-by: Alessandro Suardi <alessandro.suardi@gmail.com>
Reported-by: Arthur Marsh <arthur.marsh@internode.on.net>
Bisected-by: Arthur Marsh <arthur.marsh@internode.on.net>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Jan Engelhardt <jengelh@medozas.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
---

 net/core/rtnetlink.c                 |    2 +-
 net/ipv4/inet_diag.c                 |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    4 ++--
 net/netlink/genetlink.c              |    2 +-
 net/xfrm/xfrm_user.c                 |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a5f7535..750db57 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1820,7 +1820,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (kind == 2 && (nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
+	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
 		struct sock *rtnl;
 		rtnl_dumpit_func dumpit;
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 2746c1f..2ada171 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -858,7 +858,7 @@ static int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	    nlmsg_len(nlh) < hdrlen)
 		return -EINVAL;
 
-	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		if (nlmsg_attrlen(nlh, hdrlen)) {
 			struct nlattr *attr;
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2b7eef3..93297aa 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -924,7 +924,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	u16 zone;
 	int err;
 
-	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP)
+	if (nlh->nlmsg_flags & NLM_F_DUMP)
 		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
 					  ctnetlink_done);
 
@@ -1787,7 +1787,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	u16 zone;
 	int err;
 
-	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		return netlink_dump_start(ctnl, skb, nlh,
 					  ctnetlink_exp_dump_table,
 					  ctnetlink_exp_done);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f83cb37..1781d99 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -519,7 +519,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	    security_netlink_recv(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		if (ops->dumpit == NULL)
 			return -EOPNOTSUPP;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d5e1e0b..6129196 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2189,7 +2189,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
 	     type == (XFRM_MSG_GETPOLICY - XFRM_MSG_BASE)) &&
-	    (nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
+	    (nlh->nlmsg_flags & NLM_F_DUMP)) {
 		if (link->dump == NULL)
 			return -EINVAL;
 
