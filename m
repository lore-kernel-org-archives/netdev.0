From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Check against correct policy list in ip_forward/ip6_forward
Date: Sun, 17 Oct 2004 17:48:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4172943B.8050904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060107060407040907040007"
Cc: netdev@oss.sgi.com, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060107060407040907040007
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

currently forwarded packets from a tunnel mode SA are checked
in ip_forward/ip6_forward against the XFRM_POLICY_FWD policy
list. Neither racoon nor pluto generate a policy for
IPSEC_DIR_FWD, so the checks are performed against an empty
list. I'm not sure who is wrong here, Linux or the keying daemons,
but I think using XFRM_POLICY_IN is more logical since we also
use XFRM_POLICY_OUT for forwarded packets, not XFRM_POLICY_FWD.

This patch changes ip_forward/ip6_forward to check against the
XFRM_POLICY_IN list.

BTW: The policy checks succeed as long as the policy list really is
empty because xfrm_policy_check skips the check if
xfrm_policy_list[dir] == NULL:

        return  !xfrm_policy_list[dir] ||
                (skb->dst->flags & DST_NOPOLICY) ||
                __xfrm_policy_check(sk, dir, skb, family);

I think this should really read (!xfrm_policy_list[dir] && !skb->sp)
so decapsulated IPsec packets are dropped if no policy exists.

Regards
Patrick


--------------060107060407040907040007
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/17 05:19:03+02:00 kaber@coreworks.de 
#   [IPSEC]: Check against correct policy list in ip_forward/ip6_forward
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/ip6_output.c
#   2004/10/17 05:18:26+02:00 kaber@coreworks.de +1 -1
#   [IPSEC]: Check against correct policy list in ip_forward/ip6_forward
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/ip_forward.c
#   2004/10/17 05:18:26+02:00 kaber@coreworks.de +1 -1
#   [IPSEC]: Check against correct policy list in ip_forward/ip6_forward
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
--- a/net/ipv4/ip_forward.c	2004-10-17 16:57:28 +02:00
+++ b/net/ipv4/ip_forward.c	2004-10-17 16:57:28 +02:00
@@ -60,7 +60,7 @@
 	struct rtable *rt;	/* Route we use */
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
-	if (!xfrm4_policy_check(NULL, XFRM_POLICY_FWD, skb))
+	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
 
 	if (IPCB(skb)->opt.router_alert && ip_call_ra_chain(skb))
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-10-17 16:57:28 +02:00
+++ b/net/ipv6/ip6_output.c	2004-10-17 16:57:28 +02:00
@@ -355,7 +355,7 @@
 	if (ipv6_devconf.forwarding == 0)
 		goto error;
 
-	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		IP6_INC_STATS(IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}

--------------060107060407040907040007--
