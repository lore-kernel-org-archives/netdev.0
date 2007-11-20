From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Tue, 20 Nov 2007 15:05:18 +0100
Message-ID: <20071120140518.GA1502@one.firstfloor.org>
References: <20071118214515.GA8161@one.firstfloor.org> <20071118.144010.236028466.davem@davemloft.net> <20071119152933.GA19126@one.firstfloor.org> <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	wangchen@cn.fujitsu.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56679 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbXKTOFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 09:05:21 -0500
Content-Disposition: inline
In-Reply-To: <20071120002945.91fafb2b.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 12:29:45AM -0500, Bill Fink wrote:
> While I agree with your analysis that it could be worked around,
> who knows how all the various SNMP monitoring applications out there
> would interpret such an unusual event.  I liked Stephen's suggestion
> of a deferred decrement that would insure the counter didn't ever
> run backwards.  But the best approach seems to be just not to count
> it in the first place until tha application has actually received
> the packet, since as Herbert pointed out, that's what the RFC
> actually specifies for the meaning of the udpInDatagrams counter.

Together with another counter that counts "edge datagrams received"
that would be an excellent idea.

Here's a patch.

-Andi

---

Split UDP receive count into UdpInDatagrams and UdpInEarlyDatagrams

UdpInDatagrams can be confusing because it counts packets that 
might be dropped later.

Move UdpInDatagrams into recvmsg() as allowed by the RFC.

Add a new UdpInEarlyDatagrams counter to count datagrams received early,
but which might be dropped later

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux-2.6.24-rc1-hack/include/linux/snmp.h
===================================================================
--- linux-2.6.24-rc1-hack.orig/include/linux/snmp.h
+++ linux-2.6.24-rc1-hack/include/linux/snmp.h
@@ -138,6 +138,7 @@ enum
 	UDP_MIB_OUTDATAGRAMS,			/* OutDatagrams */
 	UDP_MIB_RCVBUFERRORS,			/* RcvbufErrors */
 	UDP_MIB_SNDBUFERRORS,			/* SndbufErrors */
+	UDP_MIB_INEARLYDATAGRAMS,		/* Early Datagrams Received */
 	__UDP_MIB_MAX
 };
 
Index: linux-2.6.24-rc1-hack/net/ipv4/udp.c
===================================================================
--- linux-2.6.24-rc1-hack.orig/net/ipv4/udp.c
+++ linux-2.6.24-rc1-hack/net/ipv4/udp.c
@@ -873,6 +873,8 @@ try_again:
 	if (err)
 		goto out_free;
 
+	UDP_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
+
 	sock_recv_timestamp(msg, sk, skb);
 
 	/* Copy the address. */
@@ -967,7 +969,8 @@ int udp_queue_rcv_skb(struct sock * sk, 
 
 			ret = (*up->encap_rcv)(sk, skb);
 			if (ret <= 0) {
-				UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+				UDP_INC_STATS_BH(UDP_MIB_INEARLYDATAGRAMS,
+						 up->pcflag);
 				return -ret;
 			}
 		}
@@ -1023,7 +1026,7 @@ int udp_queue_rcv_skb(struct sock * sk, 
 		goto drop;
 	}
 
-	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
+	UDP_INC_STATS_BH(UDP_MIB_INEARLYDATAGRAMS, up->pcflag);
 	return 0;
 
 drop:
Index: linux-2.6.24-rc1-hack/net/ipv4/proc.c
===================================================================
--- linux-2.6.24-rc1-hack.orig/net/ipv4/proc.c
+++ linux-2.6.24-rc1-hack/net/ipv4/proc.c
@@ -173,6 +173,7 @@ static const struct snmp_mib snmp4_udp_l
 	SNMP_MIB_ITEM("OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_ITEM("RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("SndbufErrors", UDP_MIB_SNDBUFERRORS),
+	SNMP_MIB_ITEM("InEarlyDatagrams", UDP_MIB_INEARLYDATAGRAMS),
 	SNMP_MIB_SENTINEL
 };
 
