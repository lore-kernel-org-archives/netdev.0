From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] vlan: Fix the b0rked ingress VLAN_FLAG_REORDER_HDR check.
Date: Tue, 24 May 2011 00:38:34 -0700
Message-ID: <m1oc2spmyt.fsf@fess.ebiederm.org>
References: <m1oc2tyn20.fsf_-_@fess.ebiederm.org>
	<20110524.005414.2103486595611055177.davem@davemloft.net>
	<m1aaectyed.fsf@fess.ebiederm.org>
	<20110524.022406.2228892895515155850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49846 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906Ab1EXHin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:38:43 -0400
In-Reply-To: <20110524.022406.2228892895515155850.davem@davemloft.net> (David
	Miller's message of "Tue, 24 May 2011 02:24:06 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 23 May 2011 23:18:02 -0700
>
>> Feel free to read through the code, to convince yourself it is correct.
>> In addition the code is untouched from the vlan header insertion for
>> emulation of vlan header acceleration in dev_hard_start_xmit() which
>> presumably has been working for quite awhile.
>
> I'm not keeping code there that does eth_hdr(skb)->foo when there
> can be either a vlan_hdr(skb) or a eth_hdr(skb) there.
>
> That's just asking for trouble.

How so?  eth_hdr(skb) is a proper subset of vlan_hdr(skb)?

vlan_insert_tag() moves the ethernet header to make space for the vlan
header after it, but before the rest of the data.  With the appropriate
fixups applied to the skb->mac_pointer.

I can see not leaving a vlan_hdr(skb) reference, but beyond that I'm
not seeing the problem.

Certainly we need to do the insert before we update the statics or
we will get rx_bytes wrong.

Would you be happier if the pkt_type check was moved earlier in the
function like say:

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index c08dae7..7571637 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -22,21 +22,6 @@ bool vlan_do_receive(struct sk_buff **skbp)
 	if (unlikely(!skb))
 		return false;
 
-	skb->dev = vlan_dev;
-	if (unlikely(!(vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR))) {
-		skb = *skbp = vlan_insert_tag(skb, skb->vlan_tci);
-		if (!skb)
-			return false;
-	}
-	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
-	skb->vlan_tci = 0;
-
-	rx_stats = this_cpu_ptr(vlan_dev_info(vlan_dev)->vlan_pcpu_stats);
-
-	u64_stats_update_begin(&rx_stats->syncp);
-	rx_stats->rx_packets++;
-	rx_stats->rx_bytes += skb->len;
-
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST:
 		break;
@@ -52,6 +37,21 @@ bool vlan_do_receive(struct sk_buff **skbp)
 			skb->pkt_type = PACKET_HOST;
 		break;
 	}
+
+	skb->dev = vlan_dev;
+	if (unlikely(!(vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR))) {
+		skb = *skbp = vlan_insert_tag(skb, skb->vlan_tci);
+		if (!skb)
+			return false;
+	}
+	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
+	skb->vlan_tci = 0;
+
+	rx_stats = this_cpu_ptr(vlan_dev_info(vlan_dev)->vlan_pcpu_stats);
+
+	u64_stats_update_begin(&rx_stats->syncp);
+	rx_stats->rx_packets++;
+	rx_stats->rx_bytes += skb->len;
 	u64_stats_update_end(&rx_stats->syncp);
 
 	return true;

Eric
