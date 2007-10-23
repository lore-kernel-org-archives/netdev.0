From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH] LRO ack aggregation
Date: Tue, 23 Oct 2007 11:11:55 -0400
Message-ID: <471E0F3B.2020703@myri.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010408080901020903090300"
Cc: ossthema@de.ibm.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2011 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751781AbXJWPMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 11:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010408080901020903090300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

We recently did some performance comparisons between the new inet_lro
LRO support in the kernel, and our Myri10GE in-driver LRO.
For receive, we found they were nearly identical.  However, for
transmit, we found that Myri10GE's LRO shows much lower CPU
utilization.  We traced the CPU utilization difference to our driver
LRO aggregating TCP acks, and the inet_lro module not doing so.

I've attached a patch which adds support to inet_lro for aggregating
pure acks.  Aggregating pure acks (segments with TCP_PAYLOAD_LENGTH ==
0) entails freeing the skb (or putting the page in the frags case).
The patch also handles trimming (typical for 54-byte pure ack frames
which have been padded to the ethernet minimum 60 byte frame size).
In the frags case, I tried to keep things simple by only doing the
trim when the entire frame fits in the first frag.  To be safe, I
ensure that the padding is all 0 (or, more exactly, was some pattern
whose checksum is -0) so that it doesn't impact hardware checksums.

This patch also fixes a small bug in the skb LRO path dealing with
vlans that I found when doing my own testing.  Specifically, in the
desc->active case, the existing code always fails the
lro_tcp_ip_check() for NICs without LRO_F_EXTRACT_VLAN_ID, because it
  fails to subtract the vlan_hdr_len from the skb->len.

Jan-Bernd Themann (ossthema@de.ibm.com) has tested the patch using
the eHEA driver (skb codepath), and I have tested it using Myri10GE
(both frags and skb codepath).

Using a pair of identical low-end 2.0GHz Athlon 64 x2 3800+ with
Myri10GE 10GbE NICs, I ran 10 iterations of netperf TCP_SENDFILE
tests, taking the median run for comparison purposes.  The receiver
was running Myri10GE + patched inet_lro:

TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to rome-my
(192.168.1.16) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send Recv
Size   Size    Size     Time     Throughput  local    remote   local
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB us/KB

Myri10GE driver-specific LRO:
   87380  65536  65536    60.02      9442.65   16.24    69.31    0.282 1.203
Myri10GE + unpatched inet_lro:
   87380  65536  65536    60.02      9442.88   20.10    69.11    0.349 1.199
Myri10GE + patched inet_lro:
   87380  65536  65536    60.02      9443.30   16.95    68.97    0.294 1.197

The important bit here is the sender's CPU utilization, and service
demand (cost per byte).  As you can see, without aggregating ack's,
the overhead on the sender is roughly 20% higher, even when sending to
a receiver which uses LRO.  The differences are even more dramatic
when sending to a receiver which does not use LRO (and hence sends
more frequent acks).

Below is the same benchmark, run between a pair of 4-way 3.0GHz Xeon
5160 machines (Dell 2950) with Myri10GE NICs.  The receiver is running
Solaris 10U4, which does not do LRO, and is acking at approximately
8:1 (or ~100K acks/sec):

Myri10GE driver-specific LRO:
196712  65536  65536    60.01      9280.09   7.14     45.37    0.252   1.602
Myri10GE + unpatched inet_lro:
196712  65536  65536    60.01      8530.80   10.51    44.60    0.404   1.713
Myri10GE + patched inet_lro:
196712  65536  65536    60.00      9249.65   7.21     45.90    0.255   1.626

Signed off by: Andrew Gallatin <gallatin@myri.com>


Andrew Gallatin
Myricom Inc.


--------------010408080901020903090300
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="ack_aggr.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ack_aggr.diff"

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index ac3b1d3..eba145b 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -58,9 +58,6 @@ static int lro_tcp_ip_check(struct iphdr
 	if (ntohs(iph->tot_len) != len)
 		return -1;
 
-	if (TCP_PAYLOAD_LENGTH(iph, tcph) == 0)
-		return -1;
-
 	if (iph->ihl != IPH_LEN_WO_OPTIONS)
 		return -1;
 
@@ -223,6 +220,11 @@ static void lro_add_packet(struct net_lr
 
 	lro_add_common(lro_desc, iph, tcph, tcp_data_len);
 
+	if (tcp_data_len == 0) {
+		dev_kfree_skb_any(skb);
+		return;
+	}
+
 	skb_pull(skb, (skb->len - tcp_data_len));
 	parent->truesize += skb->truesize;
 
@@ -244,6 +246,11 @@ static void lro_add_frags(struct net_lro
 
 	lro_add_common(lro_desc, iph, tcph, tcp_data_len);
 
+	if (tcp_data_len == 0) {
+		put_page(skb_frags[0].page);
+		return;
+	}
+
 	skb->truesize += truesize;
 
 	skb_frags[0].page_offset += hlen;
@@ -338,6 +345,8 @@ static int __lro_proc_skb(struct net_lro
 	struct tcphdr *tcph;
 	u64 flags;
 	int vlan_hdr_len = 0;
+	int pkt_len;
+	int trim;
 
 	if (!lro_mgr->get_skb_header
 	    || lro_mgr->get_skb_header(skb, (void *)&iph, (void *)&tcph,
@@ -355,6 +364,17 @@ static int __lro_proc_skb(struct net_lro
 	    && !test_bit(LRO_F_EXTRACT_VLAN_ID, &lro_mgr->features))
 		vlan_hdr_len = VLAN_HLEN;
 
+	/* strip padding from runts iff the padding is all zero */
+	pkt_len = vlan_hdr_len + ntohs(iph->tot_len);
+	trim = skb->len - pkt_len;
+	if (trim > 0) {
+		u8 *pad = skb_tail_pointer(skb) - trim;
+		if (unlikely(ip_compute_csum(pad, trim) != 0xffff)) {
+			goto out;
+		}
+		skb_trim(skb, skb->len - trim);
+	}
+	
 	if (!lro_desc->active) { /* start new lro session */
 		if (lro_tcp_ip_check(iph, tcph, skb->len - vlan_hdr_len, NULL))
 			goto out;
@@ -368,7 +388,7 @@ static int __lro_proc_skb(struct net_lro
 	if (lro_desc->tcp_next_seq != ntohl(tcph->seq))
 		goto out2;
 
-	if (lro_tcp_ip_check(iph, tcph, skb->len, lro_desc))
+	if (lro_tcp_ip_check(iph, tcph, skb->len - vlan_hdr_len, lro_desc))
 		goto out2;
 
 	lro_add_packet(lro_desc, skb, iph, tcph);
@@ -412,18 +432,20 @@ static struct sk_buff *lro_gen_skb(struc
 
 	memcpy(skb->data, mac_hdr, hdr_len);
 
-	skb_frags = skb_shinfo(skb)->frags;
-	while (data_len > 0) {
-		*skb_frags = *frags;
-		data_len -= frags->size;
-		skb_frags++;
-		frags++;
-		skb_shinfo(skb)->nr_frags++;
+	if (skb->data_len == 0) {
+		put_page(frags[0].page);
+	} else {
+		skb_frags = skb_shinfo(skb)->frags;
+		while (data_len > 0) {
+			*skb_frags = *frags;
+			data_len -= frags->size;
+			skb_frags++;
+			frags++;
+			skb_shinfo(skb)->nr_frags++;
+		}
+		skb_shinfo(skb)->frags[0].page_offset += hdr_len;
+		skb_shinfo(skb)->frags[0].size -= hdr_len;
 	}
-
-	skb_shinfo(skb)->frags[0].page_offset += hdr_len;
-	skb_shinfo(skb)->frags[0].size -= hdr_len;
-
 	skb->ip_summed = ip_summed;
 	skb->csum = sum;
 	skb->protocol = eth_type_trans(skb, lro_mgr->dev);
@@ -445,6 +467,8 @@ static struct sk_buff *__lro_proc_segmen
 	int mac_hdr_len;
 	int hdr_len = LRO_MAX_PG_HLEN;
 	int vlan_hdr_len = 0;
+	int pkt_len;
+	int trim;
 
 	if (!lro_mgr->get_frag_header
 	    || lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
@@ -463,6 +487,19 @@ static struct sk_buff *__lro_proc_segmen
 	if (!lro_desc)
 		goto out1;
 
+	/* strip padding from runts iff the padding is all zero */
+	pkt_len = mac_hdr_len + ntohs(iph->tot_len);
+	trim = len - pkt_len;
+	if (trim > 0 && pkt_len <= frags->size) {
+		u8 *pad = page_address(frags->page) + frags->page_offset +
+			pkt_len;
+		if (unlikely(ip_compute_csum(pad, trim) != 0xffff))
+			goto out1;
+		frags->size -= trim;
+		len -= trim;
+		true_size -= trim;
+	}
+
 	if (!lro_desc->active) { /* start new lro session */
 		if (lro_tcp_ip_check(iph, tcph, len - mac_hdr_len, NULL))
 			goto out1;

--------------010408080901020903090300--
