From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] Fix IPv6 ECN marking in RED
Date: Sat, 06 Mar 2004 01:30:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40491B9C.4040203@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000205080405010300010805"
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000205080405010300010805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

this patch fixes IPv6 ECN marking in RED and changes it to use the
functions from net/inet_ecn.h. Currently a local variable is marked
instead of the packet.

Best regards
Patrick

--------------000205080405010300010805
Content-Type: text/x-patch;
 name="red-ecn-marking.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="red-ecn-marking.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/03/06 01:06:26+01:00 kaber@trash.net 
#   Fix IPv6 ECN marking in RED
# 
# net/sched/sch_red.c
#   2004/03/06 01:03:45+01:00 kaber@trash.net +4 -19
#   Fix IPv6 ECN marking in RED
# 
diff -Nru a/net/sched/sch_red.c b/net/sched/sch_red.c
--- a/net/sched/sch_red.c	Sat Mar  6 01:07:33 2004
+++ b/net/sched/sch_red.c	Sat Mar  6 01:07:33 2004
@@ -41,9 +41,6 @@
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
 
-#define RED_ECN_ECT  0x02
-#define RED_ECN_CE   0x01
-
 
 /*	Random Early Detection (RED) algorithm.
 	=======================================
@@ -165,28 +162,16 @@
 
 	switch (skb->protocol) {
 	case __constant_htons(ETH_P_IP):
-	{
-		u8 tos = skb->nh.iph->tos;
-
-		if (!(tos & RED_ECN_ECT))
+		if (!INET_ECN_is_capable(skb->nh.iph->tos))
 			return 0;
-
-		if (!(tos & RED_ECN_CE))
+		if (INET_ECN_is_not_ce(skb->nh.iph->tos))
 			IP_ECN_set_ce(skb->nh.iph);
-
 		return 1;
-	}
-
 	case __constant_htons(ETH_P_IPV6):
-	{
-		u32 label = *(u32*)skb->nh.raw;
-
-		if (!(label & __constant_htonl(RED_ECN_ECT<<20)))
+		if (!INET_ECN_is_capable(ip6_get_dsfield(skb->nh.ipv6h)))
 			return 0;
-		label |= __constant_htonl(RED_ECN_CE<<20);
+		IP6_ECN_set_ce(skb->nh.ipv6h);
 		return 1;
-	}
-
 	default:
 		return 0;
 	}

--------------000205080405010300010805--
