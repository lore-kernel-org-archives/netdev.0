From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 06:30:42 +0100
Message-ID: <42182082.9060301@trash.net>
References: <4217266F.6090700@trash.net> <20050219184351.GB10773@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070001030401070402070602"
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050219184351.GB10773@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070001030401070402070602
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:

> I know this comment is probably a bit late but why didn't we simply put
> type/code into sport/dport in struct flowi instead of introducing the
> monstrosities of xfrm_flowi_sport/xfrm_flowi_dport?
> 
> Something like
> 
> struct {
> 	__u16	type;
> 	__u16	code;
> } icmpt;
> 
> would've done (and still would do) the trick, no?

Here is an updated patch that kills xfrm_flowi_{sport,dport}.
I've checked around, there seems to be nothing that relies
on type and code beeing u8.


--------------070001030401070402070602
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/20 06:19:59+01:00 kaber@coreworks.de 
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#   
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport
#   and kills xfrm_flowi_sport/dport instead of changing xfrm_init_tempsel(),
#   as suggested by Herbert Xu.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/xfrm.h
#   2005/02/20 06:19:50+01:00 kaber@coreworks.de +4 -44
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#   
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport
#   and kills xfrm_flowi_sport/dport instead of changing xfrm_init_tempsel(),
#   as suggested by Herbert Xu.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/flow.h
#   2005/02/20 06:19:50+01:00 kaber@coreworks.de +2 -2
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#   
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport
#   and kills xfrm_flowi_sport/dport instead of changing xfrm_init_tempsel(),
#   as suggested by Herbert Xu.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/flow.h b/include/net/flow.h
--- a/include/net/flow.h	2005-02-20 06:20:34 +01:00
+++ b/include/net/flow.h	2005-02-20 06:20:34 +01:00
@@ -58,8 +58,8 @@
 		} ports;
 
 		struct {
-			__u8	type;
-			__u8	code;
+			__u16	type;
+			__u16	code;
 		} icmpt;
 
 		struct {
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2005-02-20 06:20:34 +01:00
+++ b/include/net/xfrm.h	2005-02-20 06:20:34 +01:00
@@ -417,53 +417,13 @@
 	return 1;
 }
 
-static __inline__
-u16 xfrm_flowi_sport(struct flowi *fl)
-{
-	u16 port;
-	switch(fl->proto) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_SCTP:
-		port = fl->fl_ip_sport;
-		break;
-	case IPPROTO_ICMP:
-	case IPPROTO_ICMPV6:
-		port = htons(fl->fl_icmp_type);
-		break;
-	default:
-		port = 0;	/*XXX*/
-	}
-	return port;
-}
-
-static __inline__
-u16 xfrm_flowi_dport(struct flowi *fl)
-{
-	u16 port;
-	switch(fl->proto) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_SCTP:
-		port = fl->fl_ip_dport;
-		break;
-	case IPPROTO_ICMP:
-	case IPPROTO_ICMPV6:
-		port = htons(fl->fl_icmp_code);
-		break;
-	default:
-		port = 0;	/*XXX*/
-	}
-	return port;
-}
-
 static inline int
 __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		!((fl->fl_ip_dport ^ sel->dport) & sel->dport_mask) &&
+		!((fl->fl_ip_sport ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
@@ -473,8 +433,8 @@
 {
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		!((fl->fl_ip_dport ^ sel->dport) & sel->dport_mask) &&
+		!((fl->fl_ip_sport ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }

--------------070001030401070402070602--
