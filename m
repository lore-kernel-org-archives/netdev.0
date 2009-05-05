From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/04: ctnetlink: fix wrong message type in user updates
Date: Tue,  5 May 2009 18:47:48 +0200 (MEST)
Message-ID: <20090505164747.19290.59909.sendpatchset@x2.localnet>
References: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46584 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbZEEQrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 12:47:48 -0400
In-Reply-To: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fecc1133b66af6e0cd49115a248f34bbb01f180a
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue May 5 17:48:26 2009 +0200

    netfilter: ctnetlink: fix wrong message type in user updates
    
    This patch fixes the wrong message type that are triggered by
    user updates, the following commands:
    
    (term1)# conntrack -I -p tcp -s 1.1.1.1 -d 2.2.2.2 -t 10 --sport 10 --dport 20 --state LISTEN
    (term1)# conntrack -U -p tcp -s 1.1.1.1 -d 2.2.2.2 -t 10 --sport 10 --dport 20 --state SYN_SENT
    (term1)# conntrack -U -p tcp -s 1.1.1.1 -d 2.2.2.2 -t 10 --sport 10 --dport 20 --state SYN_RECV
    
    only trigger event message of type NEW, when only the first is NEW
    while others should be UPDATE.
    
    (term2)# conntrack -E
        [NEW] tcp      6 10 LISTEN src=1.1.1.1 dst=2.2.2.2 sport=10 dport=20 [UNREPLIED] src=2.2.2.2 dst=1.1.1.1 sport=20 dport=10 mark=0
        [NEW] tcp      6 10 SYN_SENT src=1.1.1.1 dst=2.2.2.2 sport=10 dport=20 [UNREPLIED] src=2.2.2.2 dst=1.1.1.1 sport=20 dport=10 mark=0
        [NEW] tcp      6 10 SYN_RECV src=1.1.1.1 dst=2.2.2.2 sport=10 dport=20 [UNREPLIED] src=2.2.2.2 dst=1.1.1.1 sport=20 dport=10 mark=0
    
    This patch also removes IPCT_REFRESH from the bitmask since it is
    not of any use.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 0ea36e0..fd77619 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1186,28 +1186,6 @@ ctnetlink_change_conntrack(struct nf_conn *ct, struct nlattr *cda[])
 	return 0;
 }
 
-static inline void
-ctnetlink_event_report(struct nf_conn *ct, u32 pid, int report)
-{
-	unsigned int events = 0;
-
-	if (test_bit(IPS_EXPECTED_BIT, &ct->status))
-		events |= IPCT_RELATED;
-	else
-		events |= IPCT_NEW;
-
-	nf_conntrack_event_report(IPCT_STATUS |
-				  IPCT_HELPER |
-				  IPCT_REFRESH |
-				  IPCT_PROTOINFO |
-				  IPCT_NATSEQADJ |
-				  IPCT_MARK |
-				  events,
-				  ct,
-				  pid,
-				  report);
-}
-
 static struct nf_conn *
 ctnetlink_create_conntrack(struct nlattr *cda[],
 			   struct nf_conntrack_tuple *otuple,
@@ -1373,6 +1351,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
 			struct nf_conn *ct;
+			enum ip_conntrack_events events;
 
 			ct = ctnetlink_create_conntrack(cda, &otuple,
 							&rtuple, u3);
@@ -1383,9 +1362,18 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			err = 0;
 			nf_conntrack_get(&ct->ct_general);
 			spin_unlock_bh(&nf_conntrack_lock);
-			ctnetlink_event_report(ct,
-					       NETLINK_CB(skb).pid,
-					       nlmsg_report(nlh));
+			if (test_bit(IPS_EXPECTED_BIT, &ct->status))
+				events = IPCT_RELATED;
+			else
+				events = IPCT_NEW;
+
+			nf_conntrack_event_report(IPCT_STATUS |
+						  IPCT_HELPER |
+						  IPCT_PROTOINFO |
+						  IPCT_NATSEQADJ |
+						  IPCT_MARK | events,
+						  ct, NETLINK_CB(skb).pid,
+						  nlmsg_report(nlh));
 			nf_ct_put(ct);
 		} else
 			spin_unlock_bh(&nf_conntrack_lock);
@@ -1404,9 +1392,13 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		if (err == 0) {
 			nf_conntrack_get(&ct->ct_general);
 			spin_unlock_bh(&nf_conntrack_lock);
-			ctnetlink_event_report(ct,
-					       NETLINK_CB(skb).pid,
-					       nlmsg_report(nlh));
+			nf_conntrack_event_report(IPCT_STATUS |
+						  IPCT_HELPER |
+						  IPCT_PROTOINFO |
+						  IPCT_NATSEQADJ |
+						  IPCT_MARK,
+						  ct, NETLINK_CB(skb).pid,
+						  nlmsg_report(nlh));
 			nf_ct_put(ct);
 		} else
 			spin_unlock_bh(&nf_conntrack_lock);
