From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: [PATCH] [IPV6] Don't use obsolete entries.
Date: Sat, 15 Jan 2005 18:27:56 +0900 (JST)
Message-ID: <20050115.182756.133007240.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@wide.ad.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Following changesets improve specification conformity.
Please pull them from:
 <bk://bk.skbuff.net:20611/linux-2.6-inet6/>

Thanks.

HEADLINES
---------
ChangeSet@1.2334, 2005-01-15 17:44:55+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Don't use expired default routes.
ChangeSet@1.2335, 2005-01-15 18:05:34+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Don't update FAILED entries on receipt of NAs.


DIFFSTATS
---------
 net/ipv6/ndisc.c |    4 ++++
 net/ipv6/route.c |   18 +++++++++++++-----
 2 files changed, 17 insertions(+), 5 deletions(-)


CHANGESETS
----------
ChangeSet@1.2334, 2005-01-15 17:44:55+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Don't use expired default routes.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2005-01-15 18:20:47 +09:00
+++ b/net/ipv6/route.c	2005-01-15 18:20:47 +09:00
@@ -167,6 +167,12 @@
 	}
 }
 
+static __inline__ int rt6_check_expired(const struct rt6_info *rt)
+{
+	return (rt->rt6i_flags & RTF_EXPIRES &&
+		time_after(jiffies, rt->rt6i_expires));
+}
+
 /*
  *	Route lookup. Any rt6_lock is implied.
  */
@@ -237,8 +243,7 @@
 		     sprt->rt6i_dev->ifindex == oif))
 			m += 8;
 
-		if ((sprt->rt6i_flags & RTF_EXPIRES) &&
-		    time_after(jiffies, sprt->rt6i_expires))
+		if (rt6_check_expired(sprt))
 			continue;
 
 		if (sprt == rt6_dflt_pointer)
@@ -296,7 +301,8 @@
 			for (sprt = rt6_dflt_pointer->u.next;
 			     sprt; sprt = sprt->u.next) {
 				if (sprt->u.dst.obsolete <= 0 &&
-				    sprt->u.dst.error == 0) {
+				    sprt->u.dst.error == 0 &&
+				    !rt6_check_expired(sprt)) {
 					match = sprt;
 					break;
 				}
@@ -305,7 +311,8 @@
 			     !match && sprt;
 			     sprt = sprt->u.next) {
 				if (sprt->u.dst.obsolete <= 0 &&
-				    sprt->u.dst.error == 0) {
+				    sprt->u.dst.error == 0 &&
+				    !rt6_check_expired(sprt)) {
 					match = sprt;
 					break;
 				}
@@ -331,7 +338,8 @@
 		 */
 		for (sprt = ip6_routing_table.leaf;
 		     sprt; sprt = sprt->u.next) {
-			if ((sprt->rt6i_flags & RTF_DEFAULT) &&
+			if (!rt6_check_expired(sprt) &&
+			    (sprt->rt6i_flags & RTF_DEFAULT) &&
 			    (!oif ||
 			     (sprt->rt6i_dev &&
 			      sprt->rt6i_dev->ifindex == oif))) {

ChangeSet@1.2335, 2005-01-15 18:05:34+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Don't update FAILED entries on receipt of NAs.
 
 As NAs do not create new entries (RFC2461 7.2.5),
 NA should not change state of FAILED entries.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2005-01-15 18:20:52 +09:00
+++ b/net/ipv6/ndisc.c	2005-01-15 18:20:52 +09:00
@@ -903,6 +903,9 @@
 	if (neigh) {
 		u8 old_flags = neigh->flags;
 
+		if (neigh->nud_state & NUD_FAILED)
+			goto out;
+
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
@@ -920,6 +923,7 @@
 				ip6_del_rt(rt, NULL, NULL);
 		}
 
+out:
 		neigh_release(neigh);
 	}
 }

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
