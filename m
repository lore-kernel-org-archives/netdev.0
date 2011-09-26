From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC]  bridge: handle bridge group address per 802.1 standards
Date: Mon, 26 Sep 2011 15:36:30 -0700
Message-ID: <20110926153630.3959b0ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45173 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296Ab1IZWgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 18:36:32 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 8AD46141007D
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 15:36:32 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YqO6FGHCmdUi for <netdev@vger.kernel.org>;
	Mon, 26 Sep 2011 15:36:31 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 5B14F1410001
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 15:36:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Linux bridge code would process all packets addressed to
the multicast address 01:80:C2:00:00:0X as local and
and never forward. This may have been correct in the ancient past, but
reading the relevant standards, the correct behavior is to handle only
the bridge group address as a special case and leave all other link
local multicast packets alone.

Recently there has been some complaints about forwarding (or not) of
802.1X EAPOL frames by the bridge. Thanks to Tony Jeffree of the 
802.1 Bridging Working Group for point me in the correct direction.
The 802.1X-2010 standard Table 11-1 details how different
addresses are assigned based on connectivity associations.
      
  Bridge group address:		01-80-C2-00-00-00
  PAE group address:            01-80-C2-00-00-03
  Link Layer Discovery          01-80-C2-00-00-0E

Warning: this may mean that some people using bridge who expect
link local packets to be isolated, now need to add firewall rules.
But in my opinion, following the standard is the correct thing to
do regardless.

This means when using 802.1x with libvirt, there are several options:
  1. Use macvtap not bridge
  2. Turn off STP in libvirt
  3. Use PAE group address for 802.1x
  4. Provide a user level application using AF_LLC to forward
     the 802.2 frames

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_input.c	2011-09-16 13:12:58.061369744 -0700
+++ b/net/bridge/br_input.c	2011-09-26 11:57:41.724554692 -0700
@@ -126,18 +126,6 @@ static int br_handle_local_finish(struct
 	return 0;	 /* process further */
 }
 
-/* Does address match the link local multicast address.
- * 01:80:c2:00:00:0X
- */
-static inline int is_link_local(const unsigned char *dest)
-{
-	__be16 *a = (__be16 *)dest;
-	static const __be16 *b = (const __be16 *)br_group_address;
-	static const __be16 m = cpu_to_be16(0xfff0);
-
-	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
-}
-
 /*
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
@@ -161,13 +149,10 @@ rx_handler_result_t br_handle_frame(stru
 
 	p = br_port_get_rcu(skb->dev);
 
-	if (unlikely(is_link_local(dest))) {
-		/* Pause frames shouldn't be passed up by driver anyway */
-		if (skb->protocol == htons(ETH_P_PAUSE))
-			goto drop;
-
-		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
+	/* Special handling for bridge group address */
+	if (unlikely(compare_ether_addr(dest, br_group_address) == 0)) {
+		/* If STP is turned off, then act like a hub. */
+		if (p->br->stp_enabled == BR_NO_STP)
 			goto forward;
 
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
