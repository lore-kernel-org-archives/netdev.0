From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH]Add IPv6 MIBs counters in MLD (mcast.c)
Date: Wed, 31 Mar 2004 13:26:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403311326.43647.mashirle@us.ibm.com>
References: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_TezaA6gCPmb2vM/"
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_TezaA6gCPmb2vM/
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Here is the patch against linux 2.6.4 kernel. Please review it.

Thanks
Shirley Ma
IBM Linux Technology Center


--Boundary-00=_TezaA6gCPmb2vM/
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="linux-2.6.4-mld-ipv6mib.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.4-mld-ipv6mib.patch"

diff -urN linux-2.6.4/net/ipv6/mcast.c linux-2.6.4-mld/net/ipv6/mcast.c
--- linux-2.6.4/net/ipv6/mcast.c	2004-03-10 18:55:43.000000000 -0800
+++ linux-2.6.4-mld/net/ipv6/mcast.c	2004-03-31 12:05:11.767673936 -0800
@@ -1317,6 +1317,7 @@
 	struct inet6_dev *idev = in6_dev_get(skb->dev);
 	int err;
 
+	IP6_INC_STATS(Ip6OutRequests);
 	payload_len = skb->tail - (unsigned char *)skb->nh.ipv6h -
 		sizeof(struct ipv6hdr);
 	mldlen = skb->tail - skb->h.raw;
@@ -1326,8 +1327,12 @@
 		IPPROTO_ICMPV6, csum_partial(skb->h.raw, mldlen, 0));
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
 		dev_queue_xmit);
-	if (!err)
+	if (!err) {
 		ICMP6_INC_STATS(idev,Icmp6OutMsgs);
+		IP6_INC_STATS(Ip6OutMcastPkts);
+	} else
+		IP6_INC_STATS(Ip6OutDiscards);
+
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
 }
@@ -1608,6 +1613,7 @@
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
 
+	IP6_INC_STATS(Ip6OutRequests);
 	snd_addr = addr;
 	if (type == ICMPV6_MGM_REDUCTION) {
 		snd_addr = &all_routers;
@@ -1620,8 +1626,10 @@
 
 	skb = sock_alloc_send_skb(sk, LL_RESERVED_SPACE(dev) + full_len, 1, &err);
 
-	if (skb == NULL)
+	if (skb == NULL) {
+		IP6_INC_STATS(Ip6OutDiscards);
 		return;
+	}
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	if (dev->hard_header) {
@@ -1664,13 +1672,16 @@
 		else
 			ICMP6_INC_STATS(idev, Icmp6OutGroupMembResponses);
 		ICMP6_INC_STATS(idev, Icmp6OutMsgs);
-	}
+		IP6_INC_STATS(Ip6OutMcastPkts);
+	} else
+		IP6_INC_STATS(Ip6OutDiscards);
 
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
 	return;
 
 out:
+	IP6_INC_STATS(Ip6OutDiscards);
 	kfree_skb(skb);
 }
 

--Boundary-00=_TezaA6gCPmb2vM/--
