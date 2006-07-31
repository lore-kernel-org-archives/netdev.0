From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] SNMPv2 udpInDatagrams counter error
Date: Mon, 31 Jul 2006 06:03:55 -0400
Message-ID: <1154340236.3642.11.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:19858 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751476AbWGaJFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 05:05:22 -0400
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, you are right. 
I also send the same mail several ago, and get no response. You
patch is fine. But I think following code has no effect:

if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {

It just let UDP datagrams with checksum error be added into  UDP receive
queue, and then discard it. I think this can be used to capture a UDP
datagrams use a filter. But I if use a filter to capture a UDP
datagrams,  the code should like that:

if (!sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {

IPv6 doesn't do this, so I think delete condition 'sk->sk_filter' is
better. Do you think so?

Specially, do you try to send UDP datagrams with checksum error to echo-
udp(port 7), may be your patch will let neither udpInDatagrams nor
udpInErrors be increased. Because in my test, that datagrams can be send
to echo-udp and get a echo reply.

----- Original Message ----- 
From: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
To: <netdev@vger.kernel.org>
Sent: Monday, July 31, 2006 4:19 PM
Subject: Re: [PATCH] SNMPv2 udpInDatagrams counter error


> This has been raised earlier, cf.
http://bugzilla.kernel.org/show_bug.cgi?id=6660
> 
> Wei Yongjun wrote:
> |  When I send a UDP datagrams with checksum error to target, I found
that:
> |  Under IPv6, counter udpInErrors increased, but under IPv4 counter
> |  udpInDatagrams increased. I lookup into the source code, and found
that,
> |  under IPv4 UDP datagrams with checksum error will be delivered to
UDP
> |  receive queue, but IPv6 does not. IPv4 delivered into UDP receive
queue,
> |  increased udpInDatagrams, then discard it before delivered to UDP
user.
> |  RFC said udpInDatagrams is the total number of UDP datagrams
delivered
> |  to UDP users, so udpInDatagrams should not be increased while UDP
> |  datagrams with checksum error received.
> |  
> |  Refer to RFC2013:
> |    udpInDatagrams OBJECT-TYPE
> |        SYNTAX      Counter32
> |        MAX-ACCESS  read-only
> |        STATUS      current
> |        DESCRIPTION
> |                "The total number of UDP datagrams delivered to UDP
> |  users."
> |        ::= { udp 1 }
> |  
> |  Following is my patch:
> |  
> |  --- a/net/ipv4/udp.c 2006-07-31 09:33:45.392479344 -0400
> |  +++ b/net/ipv4/udp.c 2006-07-31 09:34:26.430240656 -0400
> |  @@ -1018,7 +1018,7 @@ static int udp_queue_rcv_skb(struct sock
> |   /* FALLTHROUGH -- it's a UDP Packet */
> |   }
> |   
> |  - if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
> |  + if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
> |   if (__udp_checksum_complete(skb)) {
> |   UDP_INC_STATS_BH(UDP_MIB_INERRORS);
> |   kfree_skb(skb);
> |  
> |  Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>
> |  
> |  
> |  -
> |  To unsubscribe from this list: send the line "unsubscribe netdev"
in
> |  the body of a message to majordomo@vger.kernel.org
> |  More majordomo info at  http://vger.kernel.org/majordomo-info.html
> |  
> |  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

