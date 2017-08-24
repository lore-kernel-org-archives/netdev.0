From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: check for seqadj ext existence before adding it in nf_nat_setup_info
Date: Thu, 24 Aug 2017 16:43:30 +0200
Message-ID: <1503585811-13447-5-git-send-email-pablo@netfilter.org>
References: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50426 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753328AbdHXOns (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 10:43:48 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 849181BFA89
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:43:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 77324DA4C8
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:43:30 +0200 (CEST)
In-Reply-To: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>

Commit 4440a2ab3b9f ("netfilter: synproxy: Check oom when adding synproxy
and seqadj ct extensions") wanted to drop the packet when it fails to add
seqadj ext due to no memory by checking if nfct_seqadj_ext_add returns
NULL.

But that nfct_seqadj_ext_add returns NULL can also happen when seqadj ext
already exists in a nf_conn. It will cause that userspace protocol doesn't
work when both dnat and snat are configured.

Li Shuang found this issue in the case:

Topo:
   ftp client                   router                  ftp server
  10.167.131.2  <-> 10.167.131.254  10.167.141.254 <-> 10.167.141.1

Rules:
  # iptables -t nat -A PREROUTING -i eth1 -p tcp -m tcp --dport 21 -j \
    DNAT --to-destination 10.167.141.1
  # iptables -t nat -A POSTROUTING -o eth2 -p tcp -m tcp --dport 21 -j \
    SNAT --to-source 10.167.141.254

In router, when both dnat and snat are added, nf_nat_setup_info will be
called twice. The packet can be dropped at the 2nd time for DNAT due to
seqadj ext is already added at the 1st time for SNAT.

This patch is to fix it by checking for seqadj ext existence before adding
it, so that the packet will not be dropped if seqadj ext already exists.

Note that as Florian mentioned, as a long term, we should review ext_add()
behaviour, it's better to return a pointer to the existing ext instead.

Fixes: 4440a2ab3b9f ("netfilter: synproxy: Check oom when adding synproxy and seqadj ct extensions")
Reported-by: Li Shuang <shuali@redhat.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index eb541786ccb7..b1d3740ae36a 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -441,7 +441,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 		else
 			ct->status |= IPS_DST_NAT;
 
-		if (nfct_help(ct))
+		if (nfct_help(ct) && !nfct_seqadj(ct))
 			if (!nfct_seqadj_ext_add(ct))
 				return NF_DROP;
 	}
-- 
2.1.4
