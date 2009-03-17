From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCHv3] netns: oops in ip[6]_frag_reasm incrementing stats
Date: Tue, 17 Mar 2009 12:55:42 +0100
Message-ID: <49BF8FBE.7010800@dti2.net>
References: <49BA87F4.1090709@dti2.net> <49BA8B65.2060408@dti2.net> <49BE4192.7090706@dti2.net> <49BEBF25.70008@gmail.com> <49BECA4A.4080207@dti2.net> <20090316224645.GA3129@ami.dom.local>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:2028 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbZCQLzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 07:55:48 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50002690984.msg
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 12:55:43 +0100
In-Reply-To: <20090316224645.GA3129@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev can be NULL in ip[6]_frag_reasm for skb's coming from RAW sockets.

Quagga's OSPFD sends fragmented packets on a RAW socket, when netfilter
conntrack reassembles them on the OUTPUT path you hit this code path.

You can test it with something like "hping2 -0 -d 2000 -f AA.BB.CC.DD"

Changes from v2: (address comments from Jarek Poplawski)
	- Patch reworked to get the net pointer with container_of()
	  instead of passing it to function calls.
	- Fix IPv6 code
Changes from v1:
	- Fixed description

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/ipv4/ip_fragment.c |    5 +++--
 net/ipv6/reassembly.c  |    7 +++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 6659ac0..4806e33 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -463,6 +463,7 @@ err:
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 			 struct net_device *dev)
 {
+	struct net *net = container_of(qp->q.net, struct net, ipv4.frags);
 	struct iphdr *iph;
 	struct sk_buff *fp, *head = qp->q.fragments;
 	int len;
@@ -548,7 +549,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	iph = ip_hdr(head);
 	iph->frag_off = 0;
 	iph->tot_len = htons(len);
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMOKS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	return 0;
 
@@ -562,7 +563,7 @@ out_oversize:
 		printk(KERN_INFO "Oversized IP packet from %pI4.\n",
 			&qp->saddr);
 out_fail:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 	return err;
 }
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 3c57511..e9ac7a1 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -452,6 +452,7 @@ err:
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 			  struct net_device *dev)
 {
+	struct net *net = container_of(fq->q.net, struct net, ipv6.frags);
 	struct sk_buff *fp, *head = fq->q.fragments;
 	int    payload_len;
 	unsigned int nhoff;
@@ -551,8 +552,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 					  head->csum);
 
 	rcu_read_lock();
-	IP6_INC_STATS_BH(dev_net(dev),
-			 __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
+	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
 	rcu_read_unlock();
 	fq->q.fragments = NULL;
 	return 1;
@@ -566,8 +566,7 @@ out_oom:
 		printk(KERN_DEBUG "ip6_frag_reasm: no memory for reassembly\n");
 out_fail:
 	rcu_read_lock();
-	IP6_INC_STATS_BH(dev_net(dev),
-			 __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 	rcu_read_unlock();
 	return -1;
 }
-- 
1.5.6.5

