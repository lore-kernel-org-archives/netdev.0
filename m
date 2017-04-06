From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [Outreachy kernel] [PATCH v3] net: netfilter: Add
 nfnl_msg_type() helper function
Date: Fri, 7 Apr 2017 00:06:33 +0200
Message-ID: <20170406220633.GA1762@salvia>
References: <20170328165732.GA11602@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Cc: outreachy-kernel@googlegroups.com,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        davem@davemloft.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60528 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753391AbdDFWGp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 18:06:45 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 158BB137B84
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 00:06:41 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 289D4DA86F
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 00:06:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 912DDDA848
        for <netdev@vger.kernel.org>; Fri,  7 Apr 2017 00:06:42 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170328165732.GA11602@arushi-HP-Pavilion-Notebook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Tue, Mar 28, 2017 at 10:27:32PM +0530, Arushi Singhal wrote:
> To remove complexity of code the function is added in nfnetlink.h
> to make code more clear and readable.
> This is opencoded in a way that makes it error prone for future
> netfilter netlink subsystems.
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
> changes in v3
>  -make the subject more clear.
> 
>  include/linux/netfilter/nfnetlink.h  |  6 ++++++
>  net/netfilter/nf_conntrack_netlink.c | 12 +++++++-----
>  net/netfilter/nfnetlink_acct.c       |  2 +-
>  net/netfilter/nfnetlink_cthelper.c   |  2 +-
>  net/netfilter/nfnetlink_cttimeout.c  |  4 ++--
>  5 files changed, 17 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
> index 1b49209dd5c7..9a36a7c3145d 100644
> --- a/include/linux/netfilter/nfnetlink.h
> +++ b/include/linux/netfilter/nfnetlink.h
> @@ -50,6 +50,12 @@ static inline bool lockdep_nfnl_is_held(__u8 subsys_id)
>  {
>  	return true;
>  }
> +
> +static inline u16 nfnl_msg_type(u8 subsys, u8 msg_type)
> +{
> +	return subsys << 8 | msg_type;
> +}

This is not right. You have placed this new function definition inside
the CONFIG_PROVE_LOCKING.

So this is only defined iff CONFIG_PROVE_LOCKING is set on.

>  #endif /* CONFIG_PROVE_LOCKING */
>  
>  /*
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> index aa344c5868c5..67f6f88a3e92 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -467,7 +467,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
>  	struct nlattr *nest_parms;
>  	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
>  
> -	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW;

I can find many more spots to be replaced via:

git grep NFNL_SUBSYS_ net/netfilter/

Patch attached.

--6TrnltStXW4iwmi0
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-Add-nfnl_msg_type-helper-function.patch"

>From 1f03a770eb030480968c9cb29be85e3d1cbadf3e Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 28 Mar 2017 22:27:32 +0530
Subject: [PATCH] netfilter: Add nfnl_msg_type() helper function

Add and use nfnl_msg_type() function to replace opencoded nfnetlink
message type. I suggested this change, Arushi Singhal made an initial
patch to address this but was missing several spots.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h  |  5 +++++
 net/netfilter/ipset/ip_set_core.c    |  2 +-
 net/netfilter/nf_conntrack_netlink.c | 16 +++++++++-------
 net/netfilter/nf_tables_api.c        | 17 ++++++++---------
 net/netfilter/nf_tables_trace.c      |  3 ++-
 net/netfilter/nfnetlink_acct.c       |  2 +-
 net/netfilter/nfnetlink_cthelper.c   |  2 +-
 net/netfilter/nfnetlink_cttimeout.c  |  4 ++--
 net/netfilter/nfnetlink_log.c        |  2 +-
 net/netfilter/nfnetlink_queue.c      |  2 +-
 net/netfilter/nft_compat.c           |  2 +-
 11 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 1b49209dd5c7..996711d8a7b4 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -41,6 +41,11 @@ int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
 int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 		      int flags);
 
+static inline u16 nfnl_msg_type(u8 subsys, u8 msg_type)
+{
+	return subsys << 8 | msg_type;
+}
+
 void nfnl_lock(__u8 subsys_id);
 void nfnl_unlock(__u8 subsys_id);
 #ifdef CONFIG_PROVE_LOCKING
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c296f9b606d4..731ba9c0cf9b 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -769,7 +769,7 @@ start_msg(struct sk_buff *skb, u32 portid, u32 seq, unsigned int flags,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 
-	nlh = nlmsg_put(skb, portid, seq, cmd | (NFNL_SUBSYS_IPSET << 8),
+	nlh = nlmsg_put(skb, portid, seq, nfnl_msg_type(NFNL_SUBSYS_IPSET, cmd),
 			sizeof(*nfmsg), flags);
 	if (!nlh)
 		return NULL;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index cd0a6d270ebe..773d2187a5ea 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -467,7 +467,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	struct nlattr *nest_parms;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW);
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK, IPCTNL_MSG_CT_NEW);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -652,7 +652,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	if (skb == NULL)
 		goto errout;
 
-	type |= NFNL_SUBSYS_CTNETLINK << 8;
+	type = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK, type);
 	nlh = nlmsg_put(skb, item->portid, 0, type, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -1983,7 +1983,8 @@ ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU);
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK,
+			      IPCTNL_MSG_CT_GET_STATS_CPU);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2066,7 +2067,7 @@ ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 	unsigned int nr_conntracks = atomic_read(&net->ct.count);
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS);
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK, IPCTNL_MSG_CT_GET_STATS);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2576,7 +2577,7 @@ ctnetlink_exp_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 
-	event |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_EXP, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2627,7 +2628,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	if (skb == NULL)
 		goto errout;
 
-	type |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
+	type = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_EXP, type);
 	nlh = nlmsg_put(skb, item->portid, 0, type, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -3212,7 +3213,8 @@ ctnetlink_exp_stat_fill_info(struct sk_buff *skb, u32 portid, u32 seq, int cpu,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_EXP_GET_STATS_CPU);
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK,
+			      IPCTNL_MSG_EXP_GET_STATS_CPU);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index bf52acfe4eff..b23f52a40b93 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -438,7 +438,7 @@ static int nf_tables_fill_table_info(struct sk_buff *skb, struct net *net,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 
-	event |= NFNL_SUBSYS_NFTABLES << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg), flags);
 	if (nlh == NULL)
 		goto nla_put_failure;
@@ -989,7 +989,7 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, struct net *net,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 
-	event |= NFNL_SUBSYS_NFTABLES << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg), flags);
 	if (nlh == NULL)
 		goto nla_put_failure;
@@ -1885,7 +1885,7 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, struct net *net,
 	const struct nft_expr *expr, *next;
 	struct nlattr *list;
 	const struct nft_rule *prule;
-	int type = event | NFNL_SUBSYS_NFTABLES << 8;
+	int type = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, event);
 
 	nlh = nlmsg_put(skb, portid, seq, type, sizeof(struct nfgenmsg),
 			flags);
@@ -2645,7 +2645,7 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 	u32 portid = ctx->portid;
 	u32 seq = ctx->seq;
 
-	event |= NFNL_SUBSYS_NFTABLES << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg),
 			flags);
 	if (nlh == NULL)
@@ -3395,8 +3395,7 @@ static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
 	if (IS_ERR(set))
 		return PTR_ERR(set);
 
-	event  = NFT_MSG_NEWSETELEM;
-	event |= NFNL_SUBSYS_NFTABLES << 8;
+	event  = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, NFT_MSG_NEWSETELEM);
 	portid = NETLINK_CB(cb->skb).portid;
 	seq    = cb->nlh->nlmsg_seq;
 
@@ -3481,7 +3480,7 @@ static int nf_tables_fill_setelem_info(struct sk_buff *skb,
 	struct nlattr *nest;
 	int err;
 
-	event |= NFNL_SUBSYS_NFTABLES << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg),
 			flags);
 	if (nlh == NULL)
@@ -4253,7 +4252,7 @@ static int nf_tables_fill_obj_info(struct sk_buff *skb, struct net *net,
 	struct nfgenmsg *nfmsg;
 	struct nlmsghdr *nlh;
 
-	event |= NFNL_SUBSYS_NFTABLES << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg), flags);
 	if (nlh == NULL)
 		goto nla_put_failure;
@@ -4526,7 +4525,7 @@ static int nf_tables_fill_gen_info(struct sk_buff *skb, struct net *net,
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	int event = (NFNL_SUBSYS_NFTABLES << 8) | NFT_MSG_NEWGEN;
+	int event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, NFT_MSG_NEWGEN);
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg), 0);
 	if (nlh == NULL)
diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
index 12eb9041dca2..d0d226ab64cd 100644
--- a/net/netfilter/nf_tables_trace.c
+++ b/net/netfilter/nf_tables_trace.c
@@ -169,7 +169,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	unsigned int size;
-	int event = (NFNL_SUBSYS_NFTABLES << 8) | NFT_MSG_TRACE;
+	int event;
 
 	if (!nfnetlink_has_listeners(nft_net(pkt), NFNLGRP_NFTRACE))
 		return;
@@ -198,6 +198,7 @@ void nft_trace_notify(struct nft_traceinfo *info)
 	if (!skb)
 		return;
 
+	event = nfnl_msg_type(NFNL_SUBSYS_NFTABLES, NFT_MSG_TRACE);
 	nlh = nlmsg_put(skb, 0, 0, event, sizeof(struct nfgenmsg), 0);
 	if (!nlh)
 		goto nla_put_failure;
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index c86da174a5fc..1b9a5d6099dc 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -139,7 +139,7 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	u64 pkts, bytes;
 	u32 old_flags;
 
-	event |= NFNL_SUBSYS_ACCT << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_ACCT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index d5025cc25df3..9a50bf93dd16 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -507,7 +507,7 @@ nfnl_cthelper_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	int status;
 
-	event |= NFNL_SUBSYS_CTHELPER << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTHELPER, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 57c2cdf7b691..0927a6ae6177 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -158,7 +158,7 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	struct nf_conntrack_l4proto *l4proto = timeout->l4proto;
 
-	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_TIMEOUT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -431,7 +431,7 @@ cttimeout_default_fill_info(struct net *net, struct sk_buff *skb, u32 portid,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 
-	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_TIMEOUT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index ecd857b75ffe..e7648e90d162 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -411,7 +411,7 @@ __build_packet_message(struct nfnl_log_net *log,
 	const unsigned char *hwhdrp;
 
 	nlh = nlmsg_put(inst->skb, 0, 0,
-			NFNL_SUBSYS_ULOG << 8 | NFULNL_MSG_PACKET,
+			nfnl_msg_type(NFNL_SUBSYS_ULOG, NFULNL_MSG_PACKET),
 			sizeof(struct nfgenmsg), 0);
 	if (!nlh)
 		return -1;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 933509ebf3d3..05e82004ab62 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -447,7 +447,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	}
 
 	nlh = nlmsg_put(skb, 0, 0,
-			NFNL_SUBSYS_QUEUE << 8 | NFQNL_MSG_PACKET,
+			nfnl_msg_type(NFNL_SUBSYS_QUEUE, NFQNL_MSG_PACKET),
 			sizeof(struct nfgenmsg), 0);
 	if (!nlh) {
 		skb_tx_error(entskb);
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index f443f9d22faf..ed969caf01be 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -504,7 +504,7 @@ nfnl_compat_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 
-	event |= NFNL_SUBSYS_NFT_COMPAT << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_NFT_COMPAT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
-- 
2.1.4


--6TrnltStXW4iwmi0--
