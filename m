From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Sun, 1 Mar 2009 13:44:45 +0200
Message-ID: <200903011344.45814.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_tUnqJ8GOLIa2nBi"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35232 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978AbZCALox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 06:44:53 -0500
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 1F4F21A45B3
	for <netdev@vger.kernel.org>; Sun,  1 Mar 2009 13:44:46 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_tUnqJ8GOLIa2nBi
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Windows (XP at least) hosts on boot, with configured static ip, performing 
address conflict detection, which is defined in RFC3927.
Here is quote of important information:

"
An ARP announcement is identical to the ARP Probe described above, 
except    that now the sender and target IP addresses are both set 
to the host's newly selected IPv4 address. 
"

But it same time this goes wrong with RFC5227.
"
The 'sender IP address' field MUST be set to all zeroes; this is to avoid
polluting ARP caches in other hosts on the same link in the case
where the address turns out to be already in use by another host.
"

When ARP proxy configured, it must not answer to both cases, because 
it is address conflict verification in any case. For Windows it is just 
causing to detect false "ip conflict". Already there is code for RFC5227, so 
just trivially we just check also if source ip == target ip.

Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>
---

--Boundary-00=_tUnqJ8GOLIa2nBi
Content-Type: text/x-diff;
  charset="us-ascii";
  name="arp_announce.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="arp_announce.diff"

diff --git a/net-next-2.6/net/ipv4/arp.c b/linux-net-next-a/net/ipv4/arp.c
index 3f6b735..5afaf2a 100644
--- a/net-next-2.6/net/ipv4/arp.c
+++ b/linux-net-next-a/net/ipv4/arp.c
@@ -801,8 +801,11 @@ static int arp_process(struct sk_buff *skb)
  *  cache.
  */
 
-	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
-	if (sip == 0) {
+	/* 
+	*  Special case: IPv4 duplicate address detection packet (RFC2131)
+	*  and Gratuitous ARP/ARP Announce. (RFC3927, Section 2.4) 
+	*/
+	if (sip == 0 || tip == sip) {
 		if (arp->ar_op == htons(ARPOP_REQUEST) &&
 		    inet_addr_type(net, tip) == RTN_LOCAL &&
 		    !arp_ignore(in_dev, sip, tip))

--Boundary-00=_tUnqJ8GOLIa2nBi--
