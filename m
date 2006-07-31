From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] SNMPv2 udpInDatagrams counter error
Date: Mon, 31 Jul 2006 09:19:02 +0100
Message-ID: <200607310919.02824@strip-the-willow>
References: <1154335874.3194.3.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:2731 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1750990AbWGaITN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 04:19:13 -0400
Received: from gerrit (gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id k6V8J3wY017730
	for <netdev@vger.kernel.org>; Mon, 31 Jul 2006 09:19:03 +0100 (BST)
To: netdev@vger.kernel.org
In-Reply-To: <1154335874.3194.3.camel@LINE>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This has been raised earlier, cf. http://bugzilla.kernel.org/show_bug.cgi?id=6660

Wei Yongjun wrote:
|  When I send a UDP datagrams with checksum error to target, I found that:
|  Under IPv6, counter udpInErrors increased, but under IPv4 counter
|  udpInDatagrams increased. I lookup into the source code, and found that,
|  under IPv4 UDP datagrams with checksum error will be delivered to UDP
|  receive queue, but IPv6 does not. IPv4 delivered into UDP receive queue,
|  increased udpInDatagrams, then discard it before delivered to UDP user.
|  RFC said udpInDatagrams is the total number of UDP datagrams delivered
|  to UDP users, so udpInDatagrams should not be increased while UDP
|  datagrams with checksum error received.
|  
|  Refer to RFC2013:
|    udpInDatagrams OBJECT-TYPE
|        SYNTAX      Counter32
|        MAX-ACCESS  read-only
|        STATUS      current
|        DESCRIPTION
|                "The total number of UDP datagrams delivered to UDP
|  users."
|        ::= { udp 1 }
|  
|  Following is my patch:
|  
|  --- a/net/ipv4/udp.c	2006-07-31 09:33:45.392479344 -0400
|  +++ b/net/ipv4/udp.c	2006-07-31 09:34:26.430240656 -0400
|  @@ -1018,7 +1018,7 @@ static int udp_queue_rcv_skb(struct sock
|   		/* FALLTHROUGH -- it's a UDP Packet */
|   	}
|   
|  -	if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
|  +	if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
|   		if (__udp_checksum_complete(skb)) {
|   			UDP_INC_STATS_BH(UDP_MIB_INERRORS);
|   			kfree_skb(skb);
|  
|  Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>
|  
|  
|  -
|  To unsubscribe from this list: send the line "unsubscribe netdev" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
