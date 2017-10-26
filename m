From: Eelco Chaudron <echaudro@redhat.com>
Subject: [PATCH net-next] arp: Ignore packets with an all zero sender mac address
Date: Thu, 26 Oct 2017 10:37:01 +0200
Message-ID: <887efd3fea68d2499edcc6afb35d5fe4341d93a7.1508939295.git.echaudro@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37492 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751970AbdJZIhH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 04:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some applications/devices seem to forget their MAC address when
performing some kind of a failover which triggers (something that
looks like) a gratuities arp.

The ARP packet looks something like this:

  Address Resolution Protocol (reply)
      Hardware type: Ethernet (1)
      Protocol type: IPv4 (0x0800)
      Hardware size: 6
      Protocol size: 4
      Opcode: reply (2)
      Sender MAC address: 00:00:00:00:00:00
      Sender IP address: 10.0.0.1
      Target MAC address: 00:00:00:00:00:00
      Target IP address: 255.255.255.255

This will result in existing arp entries being overwritten with an all
zero mac address. Until the arp entry times out this host can no
longer initiate a connection to this device.

Checking for and ignoring invalid mac addresses will solve this
problem.

Signed-off-by: Eelco Chaudron <echaudro@redhat.com>
---
 net/ipv4/arp.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index a8d7c5a9fb05..e60c88b203e9 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -750,6 +750,16 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	case ARPHRD_IEEE1394:
 		break;
 #endif
+	case ARPHRD_ETHER:
+	case ARPHRD_FDDI:
+	case ARPHRD_IEEE802:
+		/*
+		 * Check for bad sender hardware addresses. An all zero MAC
+		 * address is not valid for Ethernet, FDDI or IEEE802.
+		 */
+		if (is_zero_ether_addr(sha))
+			goto out_free_skb;
+		break;
 	default:
 		tha = arp_ptr;
 		arp_ptr += dev->addr_len;
-- 
2.13.6
