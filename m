From: Jan Engelhardt <jengelh@medozas.de>
Subject: [patch] Re: genetlink misinterprets NEW as GET
Date: Fri, 7 Jan 2011 14:15:05 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101071357420.27454@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr> <4D25C82F.4010306@netfilter.org> <878vyyvtci.fsf@benpfaff.org> <4D266CE5.4000309@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Aysuo <pablo@netfilter.org>,
	Ben Pfaff <blp@nicira.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D266CE5.4000309@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 2011-01-07 02:31, Pablo Neira Ayuso wrote:
>>> On 04/01/11 03:14, Jan Engelhardt wrote:
>>>> 	/* Modifiers to GET request */
>>>> 	#define NLM_F_ROOT      0x100
>>>> 	#define NLM_F_MATCH     0x200
>>>> 	#define NLM_F_ATOMIC    0x400
>>>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
>> [...]
>>>> [N.B.: I am also wondering whether
>>>> 	(nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP
>>>> may have been desired, because NLM_F_DUMP is composed of two bits.]
>>>
>>> Someone may include NLM_F_ATOMIC to a dump operation, in that case the
>>> checking that you propose is not valid.
>> 
>> Are you saying that NLM_F_MATCH and NLM_F_ATOMIC are mutually
>> exclusive, and that NLM_F_ROOT|NLM_F_ATOMIC would also signal a
>> dump operation?  Otherwise the test that Jan proposes looks valid
>> to me.
>
>Indeed, Jan's test is fine to fix this. Please, send a patch to Davem asap.

Turns out genetlink isn't the only place where &NLM_F_DUMP is used 
without ==NLM_F_DUMP.
Thus I am adding it to other spots in net/ too.



parent c235848c5a76520b90cf31bfbcc17720b24745a2 (v2.6.37-rc1-230-gc235848)
commit eaab9042b29931730d6785bb3f27b174fb2f5518
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jan 7 13:53:49 2011 +0100

netlink: test for all flags of the NLM_F_DUMP composite

Due to NLM_F_DUMP is composed of two bits, NLM_F_ROOT | NLM_F_MATCH,
when doing "if (x & NLM_F_DUMP)", it tests for _either_ of the bits
being set. Because NLM_F_MATCH's value overlaps with NLM_F_EXCL,
non-dump requests with NLM_F_EXCL set are mistaken as dump requests.

Substitute the condition to test for _all_ bits being set.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/core/rtnetlink.c                 |    2 +-
 net/ipv4/inet_diag.c                 |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    4 ++--
 net/netlink/genetlink.c              |    2 +-
 net/xfrm/xfrm_user.c                 |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8121268..14dcb43 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1657,7 +1657,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
+	if (kind == 2 && (nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
 		struct sock *rtnl;
 		rtnl_dumpit_func dumpit;
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 2ada171..2746c1f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -858,7 +858,7 @@ static int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	    nlmsg_len(nlh) < hdrlen)
 		return -EINVAL;
 
-	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
 		if (nlmsg_attrlen(nlh, hdrlen)) {
 			struct nlattr *attr;
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 7f59be8..edc737e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -925,7 +925,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	u16 zone;
 	int err;
 
-	if (nlh->nlmsg_flags & NLM_F_DUMP)
+	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP)
 		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
 					  ctnetlink_done);
 
@@ -1788,7 +1788,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	u16 zone;
 	int err;
 
-	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
 		return netlink_dump_start(ctnl, skb, nlh,
 					  ctnetlink_exp_dump_table,
 					  ctnetlink_exp_done);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 1781d99..f83cb37 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -519,7 +519,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	    security_netlink_recv(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
 		if (ops->dumpit == NULL)
 			return -EOPNOTSUPP;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8bae6b2..6770895 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2174,7 +2174,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
 	     type == (XFRM_MSG_GETPOLICY - XFRM_MSG_BASE)) &&
-	    (nlh->nlmsg_flags & NLM_F_DUMP)) {
+	    (nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
 		if (link->dump == NULL)
 			return -EINVAL;
 
-- 
# Created with git-export-patch
