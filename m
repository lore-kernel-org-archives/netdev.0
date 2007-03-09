From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: Add packet sock option to return orig_dev to userspace when bonded
Date: Thu, 8 Mar 2007 18:17:39 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329026E9753@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<jgarzik@pobox.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2863 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965157AbXCICRm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 21:17:42 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch applies against commit
704e0b01791bfcb75355f269a6f0054a75c9c563
of branch 'master' from davem/net-2.6.22

---
Summary:

Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
	NET: Add packet sock option to return orig_dev to userspace when
bonded

---
Add a packet socket option to allow the orig_dev index to be returned to
userspace when passing traffic through a bonded device.  This is very
useful
for layer 2 traffic being able to report which physical device actually
received the traffic, instead of having the bond hide that information.

The new option is called PACKET_BONDED_ORIGDEV.

Signed-off-by: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>

---
 include/linux/if_packet.h |    1 +
 net/packet/af_packet.c    |   34 +++++++++++++++++++++++++++++++---
 2 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index f3de05c..b68c177 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -42,6 +42,7 @@ struct sockaddr_ll
 #define PACKET_STATISTICS		6
 #define PACKET_COPY_THRESH		7
 #define PACKET_AUXDATA			8
+#define PACKET_BONDED_ORIGDEV		9
 
 struct tpacket_stats
 {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9866a8..05e53a0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -201,7 +201,8 @@ struct packet_sock {
 	struct packet_type	prot_hook;
 	spinlock_t		bind_lock;
 	unsigned int		running:1,	/* prot_hook is
attached*/
-				auxdata:1;
+				auxdata:1,
+				origdev:1;	/* return orig_dev for
bonds */
 	int			ifindex;	/* bound device
*/
 	__be16			num;
 #ifdef CONFIG_PACKET_MULTICAST
@@ -528,7 +529,11 @@ static int packet_rcv(struct sk_buff *sk
 	sll->sll_hatype = dev->type;
 	sll->sll_protocol = skb->protocol;
 	sll->sll_pkttype = skb->pkt_type;
-	sll->sll_ifindex = dev->ifindex;
+	/* Look at all traffic types bound for us - includes BC and MC
*/
+	if (unlikely(po->origdev) && skb->pkt_type == PACKET_HOST)
+		sll->sll_ifindex = orig_dev->ifindex;
+	else
+		sll->sll_ifindex = dev->ifindex;
 	sll->sll_halen = 0;
 
 	if (dev->hard_header_parse)
@@ -673,7 +678,11 @@ static int tpacket_rcv(struct sk_buff *s
 	sll->sll_hatype = dev->type;
 	sll->sll_protocol = skb->protocol;
 	sll->sll_pkttype = skb->pkt_type;
-	sll->sll_ifindex = dev->ifindex;
+	/* Look at all traffic types bound for us - includes BC and MC
*/
+	if (unlikely(po->origdev) && skb->pkt_type == PACKET_HOST)
+		sll->sll_ifindex = orig_dev->ifindex;
+	else
+		sll->sll_ifindex = dev->ifindex;
 
 	h->tp_status = status;
 	smp_mb();
@@ -1413,6 +1422,18 @@ packet_setsockopt(struct socket *sock, i
 		po->auxdata = !!val;
 		return 0;
 	}
+	case PACKET_BONDED_ORIGDEV:
+	{
+		int val;
+
+		if (optlen < sizeof(val))
+			return -EINVAL;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+
+		po->origdev = !!val;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1456,6 +1477,13 @@ static int packet_getsockopt(struct sock
 
 		data = &val;
 		break;
+	case PACKET_BONDED_ORIGDEV:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		val = po->origdev;
+
+		data = &val;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}


-- 
Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
