From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Wed, 19 Jul 2006 14:35:15 +0200
Message-ID: <44BE2703.8060907@yahoo.fr>
References: <200607161120.k6GBKZEG009486@cmf.nrl.navy.mil> <44BD2636.1010105@yahoo.fr> <20060718194318.GA15572@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070007040800030700040101"
Cc: chas3@users.sourceforge.net, David Miller <davem@davemloft.net>,
	shemminger@osdl.org, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sophia.inria.fr ([138.96.64.20]:38636 "EHLO sophia.inria.fr")
	by vger.kernel.org with ESMTP id S964799AbWGSMhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 08:37:09 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060718194318.GA15572@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070007040800030700040101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote :
> Probably. Patches are welcome :)
Here are they, in both case I checked that the stuff to clear
was not already cleared, but I could not produce any misbehavior
by writing random junk instead of clearing the data. All my tests
were on the loopback using UML.

For IPv4, the added safety seems worth, but for IPv6 it's less clear.

Thanks.

-- 
Guillaume


--------------070007040800030700040101
Content-Type: text/x-patch;
 name="clear_ip6cb.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="clear_ip6cb.diff"

Clear the accumulated junk in IP6CB when starting to handle an
IPV6 packet.

Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>
---

 ip6_input.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -70,6 +70,8 @@ int ipv6_rcv(struct sk_buff *skb, struct
 		IP6_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
+
+	memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
 
 	/*
 	 * Store incoming device index. When the packet will


--------------070007040800030700040101
Content-Type: text/x-patch;
 name="clear_whole_ipcb.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="clear_whole_ipcb.diff"

Clear the whole IPCB, this clears also IPCB(skb)->flags.

Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>
---

 ip_input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -429,7 +429,7 @@ int ip_rcv(struct sk_buff *skb, struct n
 	}
 
 	/* Remove any debris in the socket control block */
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 
 	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);


--------------070007040800030700040101--
