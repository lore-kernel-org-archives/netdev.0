From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 3/5]IPv6:netfilter: Record MIB counter when reassembling
 all fragments
Date: Wed, 24 Feb 2010 14:08:26 +0800
Message-ID: <4B84C25A.4080403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to RFC4293, this patch records MIB counter of IPSTATS_MIB_REASMFAILS, 
IPSTATS_MIB_REASMOKS, when reassembling fragments after all fragments reached.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 4a1b5bd..9f50c13 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -398,6 +398,7 @@ static struct sk_buff *
 nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 {
 	struct sk_buff *fp, *op, *head = fq->q.fragments;
+	struct net *net = container_of(fq->q.net, struct net, ipv6.frags);
 	int    payload_len;
 
 	fq_kill(fq);
@@ -499,6 +500,9 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		NFCT_FRAG6_CB(fp)->orig = NULL;
 	}
 
+	rcu_read_lock();
+	IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
+	rcu_read_unlock();
 	return head;
 
 out_oversize:
@@ -509,6 +513,9 @@ out_oom:
 	if (net_ratelimit())
 		printk(KERN_DEBUG "nf_ct_frag6_reasm: no memory for reassembly\n");
 out_fail:
+	rcu_read_lock();
+	IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	rcu_read_unlock();
 	return NULL;
 }
 
-- 
1.6.3.3

