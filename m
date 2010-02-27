From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 5/7 v2]IPv6:netfilter: Record MIB counter when
 reassembling all fragments
Date: Sat, 27 Feb 2010 14:40:04 +0800
Message-ID: <4B88BE44.7030600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58581 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753527Ab0B0GkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 01:40:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to RFC4293, this patch records MIB counter of IPSTATS_MIB_REASMFAILS, 
IPSTATS_MIB_REASMOKS, when reassembling fragments after all fragments reached.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 27d8ac1..4640795 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -485,6 +485,7 @@ static struct sk_buff *
 nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 {
 	struct sk_buff *fp, *op, *head = fq->q.fragments;
+	struct net *net = container_of(fq->q.net, struct net, ipv6.frags);
 	int    payload_len;
 
 	fq_kill(fq);
@@ -586,6 +587,9 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		NFCT_FRAG6_CB(fp)->orig = NULL;
 	}
 
+	rcu_read_lock();
+	IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
+	rcu_read_unlock();
 	return head;
 
 out_oversize:
@@ -596,6 +600,9 @@ out_oom:
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
