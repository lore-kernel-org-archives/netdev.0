From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.23 take2] UDP: Cleanup UDP encapsulation code
Date: Fri, 06 Jul 2007 15:31:56 +0200
Message-ID: <468E444C.9070609@trash.net>
References: <200707051618.l65GIh0J030375@quickie.katalix.com> <200707051951.03619@auguste.remlab.net> <468D299E.5070902@katalix.com> <200707061055.17951.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040302060908080500090209"
Cc: ext James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57900 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbXGFNcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 09:32:19 -0400
In-Reply-To: <200707061055.17951.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040302060908080500090209
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

Rémi Denis-Courmont wrote:
> On Thursday 05 July 2007 20:25:50 ext James Chapman wrote:
> 
>>Rémi Denis-Courmont wrote:
>>
>>>By the way, couldn't encap_type be remove altogether (using two slightly
>>>different callbacks for ESP) from udp_sock?
>>
>>The notion of encap_type is needed for the setsockopt call so it would
>>have to stay in the API. If it were removed from udp_sock, getsockopt
>>would have to derive the encap_type from encap_rcv funcptr values, which
>>would be messy. I think it might complicate the logic in ESP too.
> 
> 
> Right. By the way, shouldn't "len" rather be signed in there?
> 
> 		unsigned int len;
> 
> 		/* if we're overly short, let UDP handle it */
> 		len = skb->len - sizeof(struct udphdr);
> 		if (len <= 0)
> 			goto udp;


It should, but the < 0 case can't happen since __udp4_lib_rcv
already makes sure that we have at least a complete UDP header.

Anyways, this patch fixes it.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------040302060908080500090209
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4ec4a25..2835535 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -951,14 +951,10 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		 * >0 if skb should be passed on to UDP.
 		 * <0 if skb should be resubmitted as proto -N
 		 */
-		unsigned int len;
 
 		/* if we're overly short, let UDP handle it */
-		len = skb->len - sizeof(struct udphdr);
-		if (len <= 0)
-			goto udp;
-
-		if (up->encap_rcv != NULL) {
+		if (skb->len > sizeof(struct udphdr) &&
+		    up->encap_rcv != NULL) {
 			int ret;
 
 			ret = (*up->encap_rcv)(sk, skb);
@@ -971,7 +967,6 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		/* FALLTHROUGH -- it's a UDP Packet */
 	}
 
-udp:
 	/*
 	 * 	UDP-Lite specific tests, ignored on UDP sockets
 	 */

--------------040302060908080500090209--
