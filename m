From: XU Tianwen <evan.xu.tianwen@gmail.com>
Subject: [PATCH] Netfilter: Fix an ICMPv6 bug which caused by a latter ICMPv6 NA packet to inherit the mark of previous NS packet.
Date: Fri, 21 Oct 2016 16:23:50 +0800
Message-ID: <1477038230-17288-1-git-send-email-evan.xu.tianwen@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        XU Tianwen <evan.xu.tianwen@gmail.com>
To: yasuyuki.kozakai@toshiba.co.jp, pablo@netfilter.org,
        kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32849 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753838AbcJUIRM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 04:17:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The root cause is an ICMPv6 packet hits an untracked connection and inherits a mark from the previous packet to which it is not related, IMO it doesn't make sense to inherit mark for nf_conntrack_untracked.

Signed-off-by: XU Tianwen <evan.xu.tianwen@gmail.com>
---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index f5a61bc..1be9000 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -223,6 +223,9 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	if (type >= 0 && type < sizeof(noct_valid_new) &&
 	    noct_valid_new[type]) {
 		skb->nfct = &nf_ct_untracked_get()->ct_general;
+#ifdef CONFIG_NF_CONNTRACK_MARK
+		((struct nf_conn *)skb->nfct)->mark = 0;
+#endif
 		skb->nfctinfo = IP_CT_NEW;
 		nf_conntrack_get(skb->nfct);
 		return NF_ACCEPT;
-- 
2.1.2
