From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NAT and requests to unrouted targets
Date: Mon, 19 Mar 2007 17:02:25 +0100
Message-ID: <45FEB411.5050004@trash.net>
References: <000001c766d8$66f1cc00$1a04010a@V505CP> <45F90905.4000408@trash.net> <001101c76711$cf7dc6a0$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020903080906070603010803"
Cc: netdev@vger.kernel.org,
	'Netfilter Development Mailinglist'
	<netfilter-devel@lists.netfilter.org>
To: Martin Schiller <mschiller@tdt.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59860 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030278AbXCSQC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 12:02:28 -0400
In-Reply-To: <001101c76711$cf7dc6a0$1a04010a@V505CP>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020903080906070603010803
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Martin Schiller wrote:
> To be more exactly, it's the examination of
> "ct->tuplehash[dir].tuple.dst.u.all != ct->tuplehash[!dir].tuple.src.u.all"
> which is only be done if XFRM is configured. Since I don't need this anyway,
> I deactivated XFRM now and my "ping -I" is working now. 


Could you try this patch (against current -git) with CONFIG_XFRM
enabled please?


--------------020903080906070603010803
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index adf25f9..6bcfdf6 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -253,14 +253,17 @@ ip_nat_local_fn(unsigned int hooknum,
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if (ct->tuplehash[dir].tuple.dst.ip !=
-		    ct->tuplehash[!dir].tuple.src.ip
-#ifdef CONFIG_XFRM
-		    || ct->tuplehash[dir].tuple.dst.u.all !=
-		       ct->tuplehash[!dir].tuple.src.u.all
-#endif
-		    )
+		    ct->tuplehash[!dir].tuple.src.ip) {
 			if (ip_route_me_harder(pskb, RTN_UNSPEC))
 				ret = NF_DROP;
+		}
+#ifdef CONFIG_XFRM
+		else if (ct->tuplehash[dir].tuple.dst.u.all !=
+			 ct->tuplehash[!dir].tuple.src.u.all)
+			if (ip_xfrm_me_harder(pskb))
+				ret = NF_DROP;
+#endif
+
 	}
 	return ret;
 }
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index e4d3ef1..15aa3db 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -245,14 +245,16 @@ nf_nat_local_fn(unsigned int hooknum,
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if (ct->tuplehash[dir].tuple.dst.u3.ip !=
-		    ct->tuplehash[!dir].tuple.src.u3.ip
-#ifdef CONFIG_XFRM
-		    || ct->tuplehash[dir].tuple.dst.u.all !=
-		       ct->tuplehash[!dir].tuple.src.u.all
-#endif
-		    )
+		    ct->tuplehash[!dir].tuple.src.u3.ip) {
 			if (ip_route_me_harder(pskb, RTN_UNSPEC))
 				ret = NF_DROP;
+		}
+#ifdef CONFIG_XFRM
+		else if (ct->tuplehash[dir].tuple.dst.u.all !=
+			 ct->tuplehash[!dir].tuple.src.u.all)
+			if (ip_xfrm_me_harder(pskb))
+				ret = NF_DROP;
+#endif
 	}
 	return ret;
 }

--------------020903080906070603010803--
