From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/33] netfilter: nf_ct_sip: extend RCU read lock in set_expected_rtp_rtcp()
Date: Fri,  4 Oct 2013 10:32:46 +0200
Message-ID: <1380875598-5250-2-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "holger@eitzenberger.org" <holger@eitzenberger.org>

Currently set_expected_rtp_rtcp() in the SIP helper uses
rcu_dereference() two times to access two different NAT hook
functions. However, only the first one is protected by the RCU
reader lock, but the 2nd isn't. Fix it by extending the RCU
protected area.

This is more a cosmetic thing since we rely on all netfilter hooks
being rcu_read_lock()ed by nf_hook_slow() in many places anyways,
as Patrick McHardy clarified.

Signed-off-by: Holger Eitzenberger <holger.eitzenberger@sophos.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_sip.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index e0c4373..5ed8c44 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -966,7 +966,6 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 #endif
 			skip_expect = 1;
 	} while (!skip_expect);
-	rcu_read_unlock();
 
 	base_port = ntohs(tuple.dst.u.udp.port) & ~1;
 	rtp_port = htons(base_port);
@@ -980,8 +979,10 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 			goto err1;
 	}
 
-	if (skip_expect)
+	if (skip_expect) {
+		rcu_read_unlock();
 		return NF_ACCEPT;
+	}
 
 	rtp_exp = nf_ct_expect_alloc(ct);
 	if (rtp_exp == NULL)
@@ -1012,6 +1013,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 err2:
 	nf_ct_expect_put(rtp_exp);
 err1:
+	rcu_read_unlock();
 	return ret;
 }
 
-- 
1.7.10.4

