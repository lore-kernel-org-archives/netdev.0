From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame
 isenabled
Date: Fri, 7 Oct 2011 19:29:21 -0300
Message-ID: <20111007222921.GB5541@oc1711230544.ibm.com>
References: <20111006135759.GH2681@mtldesk30>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AE76@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli@dev.mellanox.co.il>, Eli Cohen <eli@mellanox.co.il>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:41960 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759110Ab1JGW31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 18:29:27 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p97NnNg1009963
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 19:49:23 -0400
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p97MWspF680402
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 19:32:54 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p97MTNCo007981
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 19:29:24 -0300
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AE76@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 06, 2011 at 03:10:28PM +0100, David Laight wrote:
>  
> >  static void mlx4_bf_copy(unsigned long *dst, unsigned long *src,
> unsigned bytecnt) {
> > +	int i;
> > +	__le32 *psrc = (__le32 *)src;
> > +
> > +	/*
> > +	 * the buffer is already in big endian. For little endian
> machines that's
> > +	 * fine. For big endain machines we must swap since the chipset
> swaps again
> > +	 */
> > +	for (i = 0; i < bytecnt / 4; ++i)
> > +		psrc[i] = le32_to_cpu(psrc[i]);
> > +
> >  	__iowrite64_copy(dst, src, bytecnt / 8);
> >  }
> 
> That code looks horrid...
> 1) I'm not sure the caller expects the buffer to be corrupted.
> 2) It contains a lot of memory cycles.
> 3) It looked from the calls that this code is copying descriptors,
>    so the transfer length is probably 1 or 2 words - so the loop
>    is inefficient.
> 4) ppc doesn't have a fast byteswap instruction (very new gcc might
>    use the byteswapping memery access for the le32_to_cpu() though),
>    so it would be better getting the byteswap done inside
>    __iowrite64_copy() - since that is probably requesting a byteswap
>    anyway.
> OTOH I'm not at all clear about the 64bit xfers....
> 
> 

Plus, it doesn't work.  :-\

After doing some more investigation, I decided to add the ARP entries
manually and test for different packet sizes. Packets larger than 256
should use the non-BF path and work. Smaller packets should fail. To my
surprise, the smaller packets were fine. Tried many different sizes and
they all succeeded. Then, tried using broadcast and it worked too (after
setting the proper sysctl). Broadcast with 0, 8 and 16 ping size, all
OK. Removed the ARP entries, the ARP responses did not get to the other
side. So, I did a pretty nasty hack to not use BF for ARP packets and
after cleaning up the ARP table, everything seems to be working fine.
What follows is my patch, just for reference.

Regards,
Cascardo.

---
--- drivers/net/mlx4/en_tx.c.orig	2011-10-03 15:42:15.736104623 -0500
+++ drivers/net/mlx4/en_tx.c	2011-10-07 17:12:38.023792483 -0500
@@ -627,6 +627,7 @@
 	int lso_header_size;
 	void *fragptr;
 	bool bounce = false;
+	bool is_arp = false;
 
 	if (!priv->port_up)
 		goto tx_drop;
@@ -698,10 +699,11 @@
 		priv->port_stats.tx_chksum_offload++;
 	}
 
+	skb_reset_mac_header(skb);
+	ethh = eth_hdr(skb);
+	is_arp = ethh && ethh->h_proto == ETH_P_ARP;
 	if (unlikely(priv->validate_loopback)) {
 		/* Copy dst mac address to wqe */
-		skb_reset_mac_header(skb);
-		ethh = eth_hdr(skb);
 		if (ethh && ethh->h_dest) {
 			mac = mlx4_en_mac_to_u64(ethh->h_dest);
 			mac_h = (u32) ((mac & 0xffff00000000ULL) >> 16);
@@ -790,7 +792,7 @@
 	if (likely(!skb_shared(skb)))
 		skb_orphan(skb);
 
-	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tag) {
+	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tag && !is_arp) {
 		*(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;
 		op_own |= htonl((bf_index & 0xffff) << 8);
 		/* Ensure new descirptor hits memory
---
