From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH] [IPV6] Merge Specification Conformity Improvements
Date: Mon, 13 Sep 2004 23:17:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913.231732.94153456.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Here're the changesets which improve conformity to 
the IPv6 specifications / standards.

Please pull from
    <bk://bk.skbuff.net:20609/linux-2.6-ndp-20040913/>

All changesets are product of USAGI/WIDE Project, and
signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>.

Plus, special thanks to Ville Nuorvala <vnuorval@tcs.hut.fi>
in GO/Core Project; credit is given in chagneset log.

We will make other couple of changesets for merging our efforts
by now.

Thank you!

HEADLINES
---------
ChangeSet@1.1868, 2004-09-13 15:50:00+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: save number of arguments for neigh_update() by flags.
ChangeSet@1.1869, 2004-09-13 15:50:56+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: suspect REACHABLE entry if new lladdr is different.
ChangeSet@1.1870, 2004-09-13 15:51:20+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: keep original state if new state is STALE and lladdr is unchanged
ChangeSet@1.1871, 2004-09-13 15:52:13+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: merge two flags for neigh_update() into one.
ChangeSet@1.1872, 2004-09-13 15:54:11+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: update IsRouter flag appropriately.
ChangeSet@1.1873, 2004-09-13 15:54:32+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: use time_after() and its friends.
ChangeSet@1.1874, 2004-09-13 15:56:10+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: update entry appripriately when receiving NS.
ChangeSet@1.1875, 2004-09-13 15:56:55+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: improve neighbour state machine.
ChangeSet@1.1876, 2004-09-13 15:57:40+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Fix message validation against Redirects.
ChangeSet@1.1877, 2004-09-13 15:59:11+09:00, yoshfuji@linux-ipv6.org
 [IPV6] don't use expired default routes.
ChangeSet@1.1878, 2004-09-13 16:02:20+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ensure to aging default routes.
ChangeSet@1.1879, 2004-09-13 16:04:16+09:00, yoshfuji@linux-ipv6.org
 [IPV6] purge routes via non-router neighbour but gateway.


DIFFSTATS
---------
 include/net/ip6_route.h |    1 
 include/net/neighbour.h |    5 -
 net/core/neighbour.c    |  221 ++++++++++++++++++++++++++----------------------
 net/ipv6/ip6_fib.c      |   12 ++
 net/ipv6/ndisc.c        |   56 ++++++------
 net/ipv6/route.c        |   54 +++++++----
 6 files changed, 199 insertions(+), 150 deletions(-)


CHANGESETS
----------
ChangeSet@1.1868, 2004-09-13 15:50:00+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: save number of arguments for neigh_update() by flags.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-13 16:32:27 +09:00
+++ b/include/net/neighbour.h	2004-09-13 16:32:27 +09:00
@@ -179,6 +179,10 @@
 	struct pneigh_entry	*phash_buckets[PNEIGH_HASHMASK+1];
 };
 
+/* flags for neigh_update() */
+#define NEIGH_UPDATE_F_OVERRIDE			0x00000001
+#define NEIGH_UPDATE_F_ADMIN			0x80000000
+
 extern void			neigh_table_init(struct neigh_table *tbl);
 extern int			neigh_table_clear(struct neigh_table *tbl);
 extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
@@ -189,7 +193,8 @@
 					     struct net_device *dev);
 extern void			neigh_destroy(struct neighbour *neigh);
 extern int			__neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
-extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, int override, int arp);
+extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, 
+					     u32 flags);
 extern void			neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 extern int			neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 extern int			neigh_resolve_output(struct sk_buff *skb);
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2004-09-13 16:32:27 +09:00
+++ b/net/atm/clip.c	2004-09-13 16:32:27 +09:00
@@ -110,7 +110,8 @@
 				goto out;
 			entry->expires = jiffies-1;
 				/* force resolution or expiration */
-			error = neigh_update(entry->neigh,NULL,NUD_NONE,0,0);
+			error = neigh_update(entry->neigh, NULL, NUD_NONE,
+					     NEIGH_UPDATE_F_ADMIN);
 			if (error)
 				printk(KERN_CRIT "unlink_clip_vcc: "
 				    "neigh_update failed with %d\n",error);
@@ -570,7 +571,8 @@
 		}
 		link_vcc(clip_vcc,entry);
 	}
-	error = neigh_update(neigh,llc_oui,NUD_PERMANENT,1,0);
+	error = neigh_update(neigh, llc_oui, NUD_PERMANENT, 
+			     NEIGH_UPDATE_F_OVERRIDE|NEIGH_UPDATE_F_ADMIN);
 	neigh_release(neigh);
 	return error;
 }
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-13 16:32:27 +09:00
+++ b/net/core/neighbour.c	2004-09-13 16:32:27 +09:00
@@ -800,14 +800,16 @@
 /* Generic update routine.
    -- lladdr is new lladdr or NULL, if it is not supplied.
    -- new    is new state.
-   -- override == 1 allows to override existing lladdr, if it is different.
-   -- arp == 0 means that the change is administrative.
+   -- flags
+	NEIGH_UPDATE_F_OVERRIDE allows to override existing lladdr,
+				if it is different.
+	NEIGH_UPDATE_F_ADMIN	means that the change is administrative.
 
    Caller MUST hold reference count on the entry.
  */
 
 int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
-		 int override, int arp)
+		 u32 flags)
 {
 	u8 old;
 	int err;
@@ -822,7 +824,8 @@
 	old    = neigh->nud_state;
 	err    = -EPERM;
 
-	if (arp && (old & (NUD_NOARP | NUD_PERMANENT)))
+	if (!(flags & NEIGH_UPDATE_F_ADMIN) && 
+	    (old & (NUD_NOARP | NUD_PERMANENT)))
 		goto out;
 
 	if (!(new & NUD_VALID)) {
@@ -850,7 +853,7 @@
 		if (old & NUD_VALID) {
 			if (!memcmp(lladdr, neigh->ha, dev->addr_len))
 				lladdr = neigh->ha;
-			else if (!override)
+			else if (!(flags & NEIGH_UPDATE_F_OVERRIDE))
 				goto out;
 		}
 	} else {
@@ -928,7 +931,8 @@
 	struct neighbour *neigh = __neigh_lookup(tbl, saddr, dev,
 						 lladdr || !dev->addr_len);
 	if (neigh)
-		neigh_update(neigh, lladdr, NUD_STALE, 1, 1);
+		neigh_update(neigh, lladdr, NUD_STALE, 
+			     NEIGH_UPDATE_F_OVERRIDE);
 	return neigh;
 }
 
@@ -1274,7 +1278,9 @@
 
 		n = neigh_lookup(tbl, RTA_DATA(nda[NDA_DST - 1]), dev);
 		if (n) {
-			err = neigh_update(n, NULL, NUD_FAILED, 1, 0);
+			err = neigh_update(n, NULL, NUD_FAILED, 
+					   NEIGH_UPDATE_F_OVERRIDE|
+					   NEIGH_UPDATE_F_ADMIN);
 			neigh_release(n);
 		}
 		goto out_dev_put;
@@ -1347,7 +1353,8 @@
 						RTA_DATA(nda[NDA_LLADDR - 1]) :
 						NULL,
 					   ndm->ndm_state,
-					   override, 0);
+					   (override ? NEIGH_UPDATE_F_OVERRIDE : 0) |
+					   NEIGH_UPDATE_F_ADMIN);
 		}
 		if (n)
 			neigh_release(n);
diff -Nru a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	2004-09-13 16:32:27 +09:00
+++ b/net/ipv4/arp.c	2004-09-13 16:32:27 +09:00
@@ -914,7 +914,7 @@
 		if (arp->ar_op != htons(ARPOP_REPLY) ||
 		    skb->pkt_type != PACKET_HOST)
 			state = NUD_STALE;
-		neigh_update(n, sha, state, override, 1);
+		neigh_update(n, sha, state, override ? NEIGH_UPDATE_F_OVERRIDE : 0);
 		neigh_release(n);
 	}
 
@@ -1021,7 +1021,9 @@
 		if (r->arp_flags & ATF_PERM)
 			state = NUD_PERMANENT;
 		err = neigh_update(neigh, (r->arp_flags&ATF_COM) ?
-				   r->arp_ha.sa_data : NULL, state, 1, 0);
+				   r->arp_ha.sa_data : NULL, state, 
+				   NEIGH_UPDATE_F_OVERRIDE|
+				   NEIGH_UPDATE_F_ADMIN);
 		neigh_release(neigh);
 	}
 	return err;
@@ -1101,7 +1103,9 @@
 	neigh = neigh_lookup(&arp_tbl, &ip, dev);
 	if (neigh) {
 		if (neigh->nud_state&~NUD_NOARP)
-			err = neigh_update(neigh, NULL, NUD_FAILED, 1, 0);
+			err = neigh_update(neigh, NULL, NUD_FAILED, 
+					   NEIGH_UPDATE_F_OVERRIDE|
+					   NEIGH_UPDATE_F_ADMIN);
 		neigh_release(neigh);
 	}
 	return err;
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-13 16:32:27 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-13 16:32:27 +09:00
@@ -911,7 +911,7 @@
 
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
-			     msg->icmph.icmp6_override, 1);
+			     msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0);
 		neigh_release(neigh);
 	}
 }
@@ -1079,7 +1079,7 @@
 				goto out;
 			}
 		}
-		neigh_update(neigh, lladdr, NUD_STALE, 1, 1);
+		neigh_update(neigh, lladdr, NUD_STALE, NEIGH_UPDATE_F_OVERRIDE);
 	}
 
 	if (ndopts.nd_opts_pi) {
@@ -1204,7 +1204,7 @@
 
 	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
 	if (neigh) {
-		neigh_update(neigh, lladdr, NUD_STALE, 1, 1);
+		neigh_update(neigh, lladdr, NUD_STALE, NEIGH_UPDATE_F_OVERRIDE);
 		if (neigh->nud_state&NUD_VALID)
 			rt6_redirect(dest, &skb->nh.ipv6h->saddr, neigh, on_link);
 		else

ChangeSet@1.1869, 2004-09-13 15:50:56+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: suspect REACHABLE entry if new lladdr is different.
 
 When we receive NA without Override flag, if it comes with
 different lladdr from one in our REACHABLE entry,
 set the state to STALE. (RFC2461 7.2.5)
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-13 16:32:31 +09:00
+++ b/include/net/neighbour.h	2004-09-13 16:32:31 +09:00
@@ -181,6 +181,7 @@
 
 /* flags for neigh_update() */
 #define NEIGH_UPDATE_F_OVERRIDE			0x00000001
+#define NEIGH_UPDATE_F_SUSPECT_CONNECTED	0x00000002
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
 extern void			neigh_table_init(struct neigh_table *tbl);
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-13 16:32:31 +09:00
+++ b/net/core/neighbour.c	2004-09-13 16:32:31 +09:00
@@ -803,6 +803,9 @@
    -- flags
 	NEIGH_UPDATE_F_OVERRIDE allows to override existing lladdr,
 				if it is different.
+	NEIGH_UPDATE_F_SUSPECT_CONNECTED will suspect existing "connected"
+				lladdr instead of overriding it 
+				if it is different.
 	NEIGH_UPDATE_F_ADMIN	means that the change is administrative.
 
    Caller MUST hold reference count on the entry.
@@ -850,12 +853,9 @@
 		   - compare new & old
 		   - if they are different, check override flag
 		 */
-		if (old & NUD_VALID) {
-			if (!memcmp(lladdr, neigh->ha, dev->addr_len))
-				lladdr = neigh->ha;
-			else if (!(flags & NEIGH_UPDATE_F_OVERRIDE))
-				goto out;
-		}
+		if ((old & NUD_VALID) && 
+		    !memcmp(lladdr, neigh->ha, dev->addr_len))
+			lladdr = neigh->ha;
 	} else {
 		/* No address is supplied; if we know something,
 		   use it, otherwise discard the request.
@@ -876,9 +876,20 @@
 	   do not change entry state, if new one is STALE.
 	 */
 	err = 0;
-	if ((old & NUD_VALID) && lladdr == neigh->ha &&
-	    (new == old || (new == NUD_STALE && (old & NUD_CONNECTED))))
-		goto out;
+	if (old & NUD_VALID) {
+		if (lladdr != neigh->ha && !(flags & NEIGH_UPDATE_F_OVERRIDE)) {
+			if ((flags & NEIGH_UPDATE_F_SUSPECT_CONNECTED) &&
+			    (old & NUD_CONNECTED)) {
+				lladdr = neigh->ha;
+				new = NUD_STALE;
+			} else
+				goto out;
+		} else {
+			if (lladdr == neigh->ha && 
+			    new == NUD_STALE && (old & NUD_CONNECTED))
+				new = old;
+		}
+	}
 
 	neigh_del_timer(neigh);
 	neigh->nud_state = new;
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-13 16:32:31 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-13 16:32:31 +09:00
@@ -911,7 +911,8 @@
 
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
-			     msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0);
+			     NEIGH_UPDATE_F_SUSPECT_CONNECTED|
+			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0));
 		neigh_release(neigh);
 	}
 }

ChangeSet@1.1870, 2004-09-13 15:51:20+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: keep original state if new state is STALE and lladdr is unchanged
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-13 16:32:34 +09:00
+++ b/include/net/neighbour.h	2004-09-13 16:32:34 +09:00
@@ -182,6 +182,7 @@
 /* flags for neigh_update() */
 #define NEIGH_UPDATE_F_OVERRIDE			0x00000001
 #define NEIGH_UPDATE_F_SUSPECT_CONNECTED	0x00000002
+#define NEIGH_UPDATE_F_RETAIN_STATE		0x00000004
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
 extern void			neigh_table_init(struct neigh_table *tbl);
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-13 16:32:34 +09:00
+++ b/net/core/neighbour.c	2004-09-13 16:32:34 +09:00
@@ -806,6 +806,8 @@
 	NEIGH_UPDATE_F_SUSPECT_CONNECTED will suspect existing "connected"
 				lladdr instead of overriding it 
 				if it is different.
+	NEIGH_UPDATE_F_RETAIN_STATE allows to retain current state
+				if lladdr is unchanged.
 	NEIGH_UPDATE_F_ADMIN	means that the change is administrative.
 
    Caller MUST hold reference count on the entry.
@@ -885,8 +887,9 @@
 			} else
 				goto out;
 		} else {
-			if (lladdr == neigh->ha && 
-			    new == NUD_STALE && (old & NUD_CONNECTED))
+			if (lladdr == neigh->ha && new == NUD_STALE &&
+			    ((flags & NEIGH_UPDATE_F_RETAIN_STATE) ||
+			     (old & NUD_CONNECTED)))
 				new = old;
 		}
 	}
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-13 16:32:34 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-13 16:32:34 +09:00
@@ -912,6 +912,7 @@
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
 			     NEIGH_UPDATE_F_SUSPECT_CONNECTED|
+			     NEIGH_UPDATE_F_RETAIN_STATE|
 			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0));
 		neigh_release(neigh);
 	}
@@ -1080,7 +1081,9 @@
 				goto out;
 			}
 		}
-		neigh_update(neigh, lladdr, NUD_STALE, NEIGH_UPDATE_F_OVERRIDE);
+		neigh_update(neigh, lladdr, NUD_STALE,
+			     NEIGH_UPDATE_F_RETAIN_STATE|
+			     NEIGH_UPDATE_F_OVERRIDE);
 	}
 
 	if (ndopts.nd_opts_pi) {
@@ -1205,7 +1208,9 @@
 
 	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
 	if (neigh) {
-		neigh_update(neigh, lladdr, NUD_STALE, NEIGH_UPDATE_F_OVERRIDE);
+		neigh_update(neigh, lladdr, NUD_STALE, 
+			     NEIGH_UPDATE_F_RETAIN_STATE|
+			     NEIGH_UPDATE_F_OVERRIDE);
 		if (neigh->nud_state&NUD_VALID)
 			rt6_redirect(dest, &skb->nh.ipv6h->saddr, neigh, on_link);
 		else

ChangeSet@1.1871, 2004-09-13 15:52:13+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: merge two flags for neigh_update() into one.
 
 This is because SUSPECT_CONNECTED can be effective 
 only if OVERRIDE is unset, and used only if RETAIN_STATE is set.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-13 16:32:37 +09:00
+++ b/include/net/neighbour.h	2004-09-13 16:32:37 +09:00
@@ -181,8 +181,7 @@
 
 /* flags for neigh_update() */
 #define NEIGH_UPDATE_F_OVERRIDE			0x00000001
-#define NEIGH_UPDATE_F_SUSPECT_CONNECTED	0x00000002
-#define NEIGH_UPDATE_F_RETAIN_STATE		0x00000004
+#define NEIGH_UPDATE_F_WEAK_OVERRIDE		0x00000002
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
 extern void			neigh_table_init(struct neigh_table *tbl);
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-13 16:32:37 +09:00
+++ b/net/core/neighbour.c	2004-09-13 16:32:37 +09:00
@@ -803,10 +803,10 @@
    -- flags
 	NEIGH_UPDATE_F_OVERRIDE allows to override existing lladdr,
 				if it is different.
-	NEIGH_UPDATE_F_SUSPECT_CONNECTED will suspect existing "connected"
+	NEIGH_UPDATE_F_WEAK_OVERRIDE will suspect existing "connected"
 				lladdr instead of overriding it 
 				if it is different.
-	NEIGH_UPDATE_F_RETAIN_STATE allows to retain current state
+				It also allows to retain current state
 				if lladdr is unchanged.
 	NEIGH_UPDATE_F_ADMIN	means that the change is administrative.
 
@@ -880,7 +880,7 @@
 	err = 0;
 	if (old & NUD_VALID) {
 		if (lladdr != neigh->ha && !(flags & NEIGH_UPDATE_F_OVERRIDE)) {
-			if ((flags & NEIGH_UPDATE_F_SUSPECT_CONNECTED) &&
+			if ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) &&
 			    (old & NUD_CONNECTED)) {
 				lladdr = neigh->ha;
 				new = NUD_STALE;
@@ -888,8 +888,9 @@
 				goto out;
 		} else {
 			if (lladdr == neigh->ha && new == NUD_STALE &&
-			    ((flags & NEIGH_UPDATE_F_RETAIN_STATE) ||
-			     (old & NUD_CONNECTED)))
+			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
+			     (old & NUD_CONNECTED))
+			    )
 				new = old;
 		}
 	}
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-13 16:32:37 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-13 16:32:37 +09:00
@@ -911,8 +911,7 @@
 
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
-			     NEIGH_UPDATE_F_SUSPECT_CONNECTED|
-			     NEIGH_UPDATE_F_RETAIN_STATE|
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0));
 		neigh_release(neigh);
 	}
@@ -1082,7 +1081,7 @@
 			}
 		}
 		neigh_update(neigh, lladdr, NUD_STALE,
-			     NEIGH_UPDATE_F_RETAIN_STATE|
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE);
 	}
 
@@ -1209,7 +1208,7 @@
 	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
 	if (neigh) {
 		neigh_update(neigh, lladdr, NUD_STALE, 
-			     NEIGH_UPDATE_F_RETAIN_STATE|
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE);
 		if (neigh->nud_state&NUD_VALID)
 			rt6_redirect(dest, &skb->nh.ipv6h->saddr, neigh, on_link);

ChangeSet@1.1872, 2004-09-13 15:54:11+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: update IsRouter flag appropriately.
 
 Update IsRouter (NTF_ROUTER) flag approrpriately.
 Specifically, 
  - we should not update it blindly; if Override Flag is 
    unset and lladdr is differnt, we should NOT.
  - we should set it when we have received RA.
  - we should set it when we have received Redirect
    whose target is off-link.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-13 16:32:40 +09:00
+++ b/include/net/neighbour.h	2004-09-13 16:32:40 +09:00
@@ -182,6 +182,8 @@
 /* flags for neigh_update() */
 #define NEIGH_UPDATE_F_OVERRIDE			0x00000001
 #define NEIGH_UPDATE_F_WEAK_OVERRIDE		0x00000002
+#define NEIGH_UPDATE_F_OVERRIDE_ISROUTER	0x00000004
+#define NEIGH_UPDATE_F_ISROUTER			0x40000000
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
 extern void			neigh_table_init(struct neigh_table *tbl);
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-13 16:32:40 +09:00
+++ b/net/core/neighbour.c	2004-09-13 16:32:40 +09:00
@@ -810,6 +810,11 @@
 				if lladdr is unchanged.
 	NEIGH_UPDATE_F_ADMIN	means that the change is administrative.
 
+	NEIGH_UPDATE_F_OVERRIDE_ISROUTER allows to override existing 
+				NTF_ROUTER flag.
+	NEIGH_UPDATE_F_ISROUTER	indicates if the neighbour is known as
+				a router.
+
    Caller MUST hold reference count on the entry.
  */
 
@@ -822,6 +827,7 @@
 	int notify = 0;
 #endif
 	struct net_device *dev;
+	int update_isrouter = 0;
 
 	write_lock_bh(&neigh->lock);
 
@@ -878,8 +884,10 @@
 	   do not change entry state, if new one is STALE.
 	 */
 	err = 0;
+	update_isrouter = flags & NEIGH_UPDATE_F_OVERRIDE_ISROUTER;
 	if (old & NUD_VALID) {
 		if (lladdr != neigh->ha && !(flags & NEIGH_UPDATE_F_OVERRIDE)) {
+			update_isrouter = 0;
 			if ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) &&
 			    (old & NUD_CONNECTED)) {
 				lladdr = neigh->ha;
@@ -931,6 +939,11 @@
 		skb_queue_purge(&neigh->arp_queue);
 	}
 out:
+	if (update_isrouter) {
+		neigh->flags = (flags & NEIGH_UPDATE_F_ISROUTER) ?
+			(neigh->flags | NTF_ROUTER) :
+			(neigh->flags & ~NTF_ROUTER);
+	}
 	write_unlock_bh(&neigh->lock);
 #ifdef CONFIG_ARPD
 	if (notify && neigh->parms->app_probes)
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-13 16:32:40 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-13 16:32:40 +09:00
@@ -894,25 +894,25 @@
 	neigh = neigh_lookup(&nd_tbl, &msg->target, dev);
 
 	if (neigh) {
-		if (neigh->flags & NTF_ROUTER) {
-			if (msg->icmph.icmp6_router == 0) {
-				/*
-				 *	Change: router to host
-				 */
-				struct rt6_info *rt;
-				rt = rt6_get_dflt_router(saddr, dev);
-				if (rt)
-					ip6_del_rt(rt, NULL, NULL);
-			}
-		} else {
-			if (msg->icmph.icmp6_router)
-				neigh->flags |= NTF_ROUTER;
-		}
+		u8 old_flags = neigh->flags;
 
 		neigh_update(neigh, lladdr,
 			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0));
+			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0)|
+			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
+			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0));
+
+		if ((old_flags & ~neigh->flags) & NTF_ROUTER) {
+			/*
+			 * Change: router to host
+			 */
+			struct rt6_info *rt;
+			rt = rt6_get_dflt_router(saddr, dev);
+			if (rt)
+				ip6_del_rt(rt, NULL, NULL);
+		}
+
 		neigh_release(neigh);
 	}
 }
@@ -1082,7 +1082,9 @@
 		}
 		neigh_update(neigh, lladdr, NUD_STALE,
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE);
+			     NEIGH_UPDATE_F_OVERRIDE|
+			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
+			     NEIGH_UPDATE_F_ISROUTER);
 	}
 
 	if (ndopts.nd_opts_pi) {
@@ -1209,7 +1211,10 @@
 	if (neigh) {
 		neigh_update(neigh, lladdr, NUD_STALE, 
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE);
+			     NEIGH_UPDATE_F_OVERRIDE|
+			     (on_link ? 0 : (NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
+					     NEIGH_UPDATE_F_ISROUTER))
+			     );
 		if (neigh->nud_state&NUD_VALID)
 			rt6_redirect(dest, &skb->nh.ipv6h->saddr, neigh, on_link);
 		else

ChangeSet@1.1873, 2004-09-13 15:54:32+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: use time_after() and its friends.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-13 16:32:43 +09:00
+++ b/net/core/neighbour.c	2004-09-13 16:32:43 +09:00
@@ -133,7 +133,7 @@
 			if (atomic_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT) &&
 			    (n->nud_state != NUD_INCOMPLETE ||
-			     jiffies - n->used > n->parms->retrans_time)) {
+			     time_after(jiffies, n->used + n->parms->retrans_time))) {
 				*np	= n->next;
 				n->dead = 1;
 				shrunk	= 1;
@@ -255,7 +255,7 @@
 
 	if (tbl->entries > tbl->gc_thresh3 ||
 	    (tbl->entries > tbl->gc_thresh2 &&
-	     now - tbl->last_flush > 5 * HZ)) {
+	     time_after(now, tbl->last_flush + 5 * HZ))) {
 		if (!neigh_forced_gc(tbl) &&
 		    tbl->entries > tbl->gc_thresh3)
 			goto out;
@@ -563,12 +563,12 @@
 	if (state & (NUD_NOARP | NUD_PERMANENT))
 		return;
 	if (state & NUD_REACHABLE) {
-		if (now - n->confirmed > n->parms->reachable_time) {
+		if (time_after(now, n->confirmed + n->parms->reachable_time)) {
 			n->nud_state = NUD_STALE;
 			neigh_suspect(n);
 		}
 	} else if (state & NUD_VALID) {
-		if (now - n->confirmed < n->parms->reachable_time) {
+		if (time_before(now, n->confirmed + n->parms->reachable_time)) {
 			neigh_del_timer(n);
 			n->nud_state = NUD_REACHABLE;
 			neigh_connect(n);
@@ -589,7 +589,7 @@
 	 *	periodically recompute ReachableTime from random function
 	 */
 
-	if (now - tbl->last_rand > 300 * HZ) {
+	if (time_after(now, tbl->last_rand + 300 * HZ)) {
 		struct neigh_parms *p;
 		tbl->last_rand = now;
 		for (p = &tbl->parms; p; p = p->next)
@@ -612,12 +612,12 @@
 				goto next_elt;
 			}
 
-			if ((long)(n->used - n->confirmed) < 0)
+			if (time_before(n->used, n->confirmed))
 				n->used = n->confirmed;
 
 			if (atomic_read(&n->refcnt) == 1 &&
 			    (state == NUD_FAILED ||
-			     now - n->used > n->parms->gc_staletime)) {
+			     time_after(now, n->used + n->parms->gc_staletime))) {
 				*np = n->next;
 				n->dead = 1;
 				write_unlock(&n->lock);
@@ -626,7 +626,7 @@
 			}
 
 			if (n->nud_state & NUD_REACHABLE &&
-			    now - n->confirmed > n->parms->reachable_time) {
+			    time_after(now, n->confirmed + n->parms->reachable_time)) {
 				n->nud_state = NUD_STALE;
 				neigh_suspect(n);
 			}
@@ -671,7 +671,7 @@
 	}
 
 	if ((state & NUD_VALID) &&
-	    now - neigh->confirmed < neigh->parms->reachable_time) {
+	    time_before(now, neigh->confirmed + neigh->parms->reachable_time)) {
 		neigh->nud_state = NUD_REACHABLE;
 		NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
 		neigh_connect(neigh);
@@ -1126,26 +1126,25 @@
 		    struct sk_buff *skb)
 {
 	unsigned long now = jiffies;
-	long sched_next = net_random() % p->proxy_delay;
+	unsigned long sched_next = now + (net_random() % p->proxy_delay);
 
 	if (tbl->proxy_queue.qlen > p->proxy_qlen) {
 		kfree_skb(skb);
 		return;
 	}
 	skb->stamp.tv_sec  = LOCALLY_ENQUEUED;
-	skb->stamp.tv_usec = now + sched_next;
+	skb->stamp.tv_usec = sched_next;
 
 	spin_lock(&tbl->proxy_queue.lock);
 	if (del_timer(&tbl->proxy_timer)) {
-		long tval = tbl->proxy_timer.expires - now;
-		if (tval < sched_next)
-			sched_next = tval;
+		if (time_before(tbl->proxy_timer.expires, sched_next))
+			sched_next = tbl->proxy_timer.expires;
 	}
 	dst_release(skb->dst);
 	skb->dst = NULL;
 	dev_hold(skb->dev);
 	__skb_queue_tail(&tbl->proxy_queue, skb);
-	mod_timer(&tbl->proxy_timer, now + sched_next);
+	mod_timer(&tbl->proxy_timer, sched_next);
 	spin_unlock(&tbl->proxy_queue.lock);
 }
 

ChangeSet@1.1874, 2004-09-13 15:56:10+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: update entry appripriately when receiving NS.
 
 Update neighbour entry appropriately by passing correct flags
 when receiving NS.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-13 16:32:46 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-13 16:32:46 +09:00
@@ -810,8 +810,11 @@
 	 *	update / create cache entry
 	 *	for the source address
 	 */
-	neigh = neigh_event_ns(&nd_tbl, lladdr, saddr, dev);
-
+	neigh = __neigh_lookup(&nd_tbl, saddr, dev, lladdr || !dev->addr_len);
+	if (neigh)
+		neigh_update(neigh, lladdr, NUD_STALE, 
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
+			     NEIGH_UPDATE_F_OVERRIDE);
 	if (neigh || !dev->hard_header) {
 		ndisc_send_na(dev, neigh, saddr, &msg->target,
 			      idev->cnf.forwarding, 

ChangeSet@1.1875, 2004-09-13 15:56:55+09:00, yoshfuji@linux-ipv6.org
 [NET] NEIGHBOUR: improve neighbour state machine.
 
 This centralizes neighbour state transition by timer into
 neigh_timer_handler(), and kill neigh_sync().
 This improves timing accuracy of state transition.
 
 neigh_timer_handler() for each entry is now reponsible 
 for state transition of the entry, and 
 neigh_periodic_timer() is just for garbage collection.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-13 16:32:50 +09:00
+++ b/include/net/neighbour.h	2004-09-13 16:32:50 +09:00
@@ -51,7 +51,7 @@
 #include <linux/err.h>
 #include <linux/sysctl.h>
 
-#define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_DELAY|NUD_PROBE)
+#define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_REACHABLE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
 #define NUD_CONNECTED	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE)
 
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-13 16:32:50 +09:00
+++ b/net/core/neighbour.c	2004-09-13 16:32:50 +09:00
@@ -542,40 +542,6 @@
 		hh->hh_output = neigh->ops->hh_output;
 }
 
-/*
-   Transitions NUD_STALE <-> NUD_REACHABLE do not occur
-   when fast path is built: we have no timers associated with
-   these states, we do not have time to check state when sending.
-   neigh_periodic_timer check periodically neigh->confirmed
-   time and moves NUD_REACHABLE -> NUD_STALE.
-
-   If a routine wants to know TRUE entry state, it calls
-   neigh_sync before checking state.
-
-   Called with write_locked neigh.
- */
-
-static void neigh_sync(struct neighbour *n)
-{
-	unsigned long now = jiffies;
-	u8 state = n->nud_state;
-
-	if (state & (NUD_NOARP | NUD_PERMANENT))
-		return;
-	if (state & NUD_REACHABLE) {
-		if (time_after(now, n->confirmed + n->parms->reachable_time)) {
-			n->nud_state = NUD_STALE;
-			neigh_suspect(n);
-		}
-	} else if (state & NUD_VALID) {
-		if (time_before(now, n->confirmed + n->parms->reachable_time)) {
-			neigh_del_timer(n);
-			n->nud_state = NUD_REACHABLE;
-			neigh_connect(n);
-		}
-	}
-}
-
 static void neigh_periodic_timer(unsigned long arg)
 {
 	struct neigh_table *tbl = (struct neigh_table *)arg;
@@ -624,12 +590,6 @@
 				neigh_release(n);
 				continue;
 			}
-
-			if (n->nud_state & NUD_REACHABLE &&
-			    time_after(now, n->confirmed + n->parms->reachable_time)) {
-				n->nud_state = NUD_STALE;
-				neigh_suspect(n);
-			}
 			write_unlock(&n->lock);
 
 next_elt:
@@ -654,7 +614,7 @@
 
 static void neigh_timer_handler(unsigned long arg)
 {
-	unsigned long now = jiffies;
+	unsigned long now, next;
 	struct neighbour *neigh = (struct neighbour *)arg;
 	unsigned state;
 	int notify = 0;
@@ -662,6 +622,8 @@
 	write_lock(&neigh->lock);
 
 	state = neigh->nud_state;
+	now = jiffies;
+	next = now + HZ;
 
 	if (!(state & NUD_IN_TIMER)) {
 #ifndef CONFIG_SMP
@@ -670,20 +632,42 @@
 		goto out;
 	}
 
-	if ((state & NUD_VALID) &&
-	    time_before(now, neigh->confirmed + neigh->parms->reachable_time)) {
-		neigh->nud_state = NUD_REACHABLE;
-		NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
-		neigh_connect(neigh);
-		goto out;
-	}
-	if (state == NUD_DELAY) {
-		NEIGH_PRINTK2("neigh %p is probed.\n", neigh);
-		neigh->nud_state = NUD_PROBE;
-		atomic_set(&neigh->probes, 0);
+	if (state & NUD_REACHABLE) {
+		if (time_before_eq(now, 
+				   neigh->confirmed + neigh->parms->reachable_time)) {
+			NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
+			next = neigh->confirmed + neigh->parms->reachable_time;
+		} else if (time_before_eq(now,
+					  neigh->used + neigh->parms->delay_probe_time)) {
+			NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
+			neigh->nud_state = NUD_DELAY;
+			neigh_suspect(neigh);
+			next = now + neigh->parms->delay_probe_time;
+		} else {
+			NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
+			neigh->nud_state = NUD_STALE;
+			neigh_suspect(neigh);
+		}
+	} else if (state & NUD_DELAY) {
+		if (time_before_eq(now, 
+				   neigh->confirmed + neigh->parms->delay_probe_time)) {
+			NEIGH_PRINTK2("neigh %p is now reachable.\n", neigh);
+			neigh->nud_state = NUD_REACHABLE;
+			neigh_connect(neigh);
+			next = neigh->confirmed + neigh->parms->reachable_time;
+		} else {
+			NEIGH_PRINTK2("neigh %p is probed.\n", neigh);
+			neigh->nud_state = NUD_PROBE;
+			atomic_set(&neigh->probes, 0);
+			next = now + neigh->parms->retrans_time;
+		}
+	} else {
+		/* NUD_PROBE|NUD_INCOMPLETE */
+		next = now + neigh->parms->retrans_time;
 	}
 
-	if (atomic_read(&neigh->probes) >= neigh_max_probes(neigh)) {
+	if ((neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) &&
+	    atomic_read(&neigh->probes) >= neigh_max_probes(neigh)) {
 		struct sk_buff *skb;
 
 		neigh->nud_state = NUD_FAILED;
@@ -703,19 +687,24 @@
 			write_lock(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
-		goto out;
 	}
 
-	neigh->timer.expires = now + neigh->parms->retrans_time;
-	add_timer(&neigh->timer);
-	write_unlock(&neigh->lock);
-
-	neigh->ops->solicit(neigh, skb_peek(&neigh->arp_queue));
-	atomic_inc(&neigh->probes);
-	return;
-
+	if (neigh->nud_state & NUD_IN_TIMER) {
+		neigh_hold(neigh);
+		if (time_before(next, jiffies + HZ/2))
+			next = jiffies + HZ/2;
+		neigh->timer.expires = next;
+		add_timer(&neigh->timer);
+	}
+	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
+		write_unlock(&neigh->lock);
+		neigh->ops->solicit(neigh, skb_peek(&neigh->arp_queue));
+		atomic_inc(&neigh->probes);
+	} else {
 out:
-	write_unlock(&neigh->lock);
+		write_unlock(&neigh->lock);
+	}
+
 #ifdef CONFIG_ARPD
 	if (notify && neigh->parms->app_probes)
 		neigh_app_notify(neigh);
@@ -726,6 +715,7 @@
 int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
 	int rc;
+	unsigned long now;
 
 	write_lock_bh(&neigh->lock);
 
@@ -733,18 +723,15 @@
 	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
 		goto out_unlock_bh;
 
+	now = jiffies;
+	
 	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
 		if (neigh->parms->mcast_probes + neigh->parms->app_probes) {
 			atomic_set(&neigh->probes, neigh->parms->ucast_probes);
 			neigh->nud_state     = NUD_INCOMPLETE;
 			neigh_hold(neigh);
-			neigh->timer.expires = jiffies +
-					       neigh->parms->retrans_time;
+			neigh->timer.expires = now + 1;
 			add_timer(&neigh->timer);
-			write_unlock_bh(&neigh->lock);
-			neigh->ops->solicit(neigh, skb);
-			atomic_inc(&neigh->probes);
-			write_lock_bh(&neigh->lock);
 		} else {
 			neigh->nud_state = NUD_FAILED;
 			write_unlock_bh(&neigh->lock);
@@ -753,6 +740,12 @@
 				kfree_skb(skb);
 			return 1;
 		}
+	} else if (neigh->nud_state & NUD_STALE) {
+		NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
+		neigh_hold(neigh);
+		neigh->nud_state = NUD_DELAY;
+		neigh->timer.expires = jiffies + neigh->parms->delay_probe_time;
+		add_timer(&neigh->timer);
 	}
 
 	if (neigh->nud_state == NUD_INCOMPLETE) {
@@ -767,13 +760,6 @@
 			__skb_queue_tail(&neigh->arp_queue, skb);
 		}
 		rc = 1;
-	} else if (neigh->nud_state == NUD_STALE) {
-		NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
-		neigh_hold(neigh);
-		neigh->nud_state = NUD_DELAY;
-		neigh->timer.expires = jiffies + neigh->parms->delay_probe_time;
-		add_timer(&neigh->timer);
-		rc = 0;
 	}
 out_unlock_bh:
 	write_unlock_bh(&neigh->lock);
@@ -874,8 +860,6 @@
 		lladdr = neigh->ha;
 	}
 
-	neigh_sync(neigh);
-	old = neigh->nud_state;
 	if (new & NUD_CONNECTED)
 		neigh->confirmed = jiffies;
 	neigh->updated = jiffies;
@@ -903,8 +887,18 @@
 		}
 	}
 
-	neigh_del_timer(neigh);
-	neigh->nud_state = new;
+	if (new != old) {
+		neigh_del_timer(neigh);
+		if (new & NUD_IN_TIMER) {
+			neigh_hold(neigh);
+			neigh->timer.expires = jiffies + 
+						((new & NUD_REACHABLE) ? 
+						 neigh->parms->reachable_time : 0);
+			add_timer(&neigh->timer);
+		}
+		neigh->nud_state = new;
+	}
+
 	if (lladdr != neigh->ha) {
 		memcpy(&neigh->ha, lladdr, dev->addr_len);
 		neigh_update_hhs(neigh);

ChangeSet@1.1876, 2004-09-13 15:57:40+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: Fix message validation against Redirects.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/ip6_route.h b/include/net/ip6_route.h
--- a/include/net/ip6_route.h	2004-09-13 16:32:53 +09:00
+++ b/include/net/ip6_route.h	2004-09-13 16:32:53 +09:00
@@ -92,6 +92,7 @@
 extern void			rt6_redirect(struct in6_addr *dest,
 					     struct in6_addr *saddr,
 					     struct neighbour *neigh,
+					     u8 *lladdr,
 					     int on_link);
 
 extern void			rt6_pmtu_discovery(struct in6_addr *daddr,
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-13 16:32:53 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-13 16:32:53 +09:00
@@ -1204,24 +1204,11 @@
 			return;
 		}
 	}
-	/* passed validation tests */
-
-	/*
-	   We install redirect only if nexthop state is valid.
-	 */
 
 	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
 	if (neigh) {
-		neigh_update(neigh, lladdr, NUD_STALE, 
-			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE|
-			     (on_link ? 0 : (NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
-					     NEIGH_UPDATE_F_ISROUTER))
-			     );
-		if (neigh->nud_state&NUD_VALID)
-			rt6_redirect(dest, &skb->nh.ipv6h->saddr, neigh, on_link);
-		else
-			__neigh_event_send(neigh, NULL);
+		rt6_redirect(dest, &skb->nh.ipv6h->saddr, neigh, lladdr, 
+			     on_link);
 		neigh_release(neigh);
 	}
 	in6_dev_put(in6_dev);
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-09-13 16:32:53 +09:00
+++ b/net/ipv6/route.c	2004-09-13 16:32:53 +09:00
@@ -1007,7 +1007,7 @@
  *	Handle redirects
  */
 void rt6_redirect(struct in6_addr *dest, struct in6_addr *saddr,
-		  struct neighbour *neigh, int on_link)
+		  struct neighbour *neigh, u8 *lladdr, int on_link)
 {
 	struct rt6_info *rt, *nrt;
 
@@ -1020,22 +1020,13 @@
 	if (neigh->dev != rt->rt6i_dev)
 		goto out;
 
-	/* Redirect received -> path was valid.
-	   Look, redirects are sent only in response to data packets,
-	   so that this nexthop apparently is reachable. --ANK
-	 */
-	dst_confirm(&rt->u.dst);
-
-	/* Duplicate redirect: silently ignore. */
-	if (neigh == rt->u.dst.neighbour)
-		goto out;
-
-	/* Current route is on-link; redirect is always invalid.
-	   
-	   Seems, previous statement is not true. It could
-	   be node, which looks for us as on-link (f.e. proxy ndisc)
-	   But then router serving it might decide, that we should
-	   know truth 8)8) --ANK (980726).
+	/*
+	 * Current route is on-link; redirect is always invalid.
+	 * 
+	 * Seems, previous statement is not true. It could
+	 * be node, which looks for us as on-link (f.e. proxy ndisc)
+	 * But then router serving it might decide, that we should
+	 * know truth 8)8) --ANK (980726).
 	 */
 	if (!(rt->rt6i_flags&RTF_GATEWAY))
 		goto out;
@@ -1047,7 +1038,6 @@
 	 *	is a bit fuzzy and one might need to check all default
 	 *	routers.
 	 */
-
 	if (ipv6_addr_cmp(saddr, &rt->rt6i_gateway)) {
 		if (rt->rt6i_flags & RTF_DEFAULT) {
 			struct rt6_info *rt1;
@@ -1075,6 +1065,24 @@
 	/*
 	 *	We have finally decided to accept it.
 	 */
+
+	neigh_update(neigh, lladdr, NUD_STALE, 
+		     NEIGH_UPDATE_F_WEAK_OVERRIDE|
+		     NEIGH_UPDATE_F_OVERRIDE|
+		     (on_link ? 0 : (NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
+				     NEIGH_UPDATE_F_ISROUTER))
+		     );
+
+	/*
+	 * Redirect received -> path was valid.
+	 * Look, redirects are sent only in response to data packets,
+	 * so that this nexthop apparently is reachable. --ANK
+	 */
+	dst_confirm(&rt->u.dst);
+
+	/* Duplicate redirect: silently ignore. */
+	if (neigh == rt->u.dst.neighbour)
+		goto out;
 
 	nrt = ip6_rt_copy(rt);
 	if (nrt == NULL)

ChangeSet@1.1877, 2004-09-13 15:59:11+09:00, yoshfuji@linux-ipv6.org
 [IPV6] don't use expired default routes.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-09-13 16:32:56 +09:00
+++ b/net/ipv6/route.c	2004-09-13 16:32:56 +09:00
@@ -227,6 +227,10 @@
 		     sprt->rt6i_dev->ifindex == oif))
 			m += 8;
 
+		if (sprt->rt6i_expires &&
+		    time_after(jiffies, sprt->rt6i_expires))
+			continue;
+
 		if (sprt == rt6_dflt_pointer)
 			m += 4;
 

ChangeSet@1.1878, 2004-09-13 16:02:20+09:00, yoshfuji@linux-ipv6.org
 [IPV6] ensure to aging default routes.
 
 This patch is product of corraboration with Ville Nuorvala 
 <vnuorval@tcs.hut.fi>.
 
 Signed-off-by: Hideaki YOSHIFUJi <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c	2004-09-13 16:32:59 +09:00
+++ b/net/ipv6/ip6_fib.c	2004-09-13 16:32:59 +09:00
@@ -49,6 +49,9 @@
 
 struct rt6_statistics	rt6_stats;
 
+extern struct rt6_info *rt6_dflt_pointer;
+extern spinlock_t rt6_dflt_lock;
+
 static kmem_cache_t * fib6_node_kmem;
 
 enum fib_walk_state_t
@@ -1184,6 +1187,10 @@
 	if (rt->rt6i_flags&RTF_EXPIRES && rt->rt6i_expires) {
 		if (time_after(now, rt->rt6i_expires)) {
 			RT6_TRACE("expiring %p\n", rt);
+			spin_lock_bh(&rt6_dflt_lock);
+			if (rt == rt6_dflt_pointer)
+				rt6_dflt_pointer = NULL;
+			spin_unlock_bh(&rt6_dflt_lock);
 			return -1;
 		}
 		gc_args.more++;
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-09-13 16:32:59 +09:00
+++ b/net/ipv6/route.c	2004-09-13 16:32:59 +09:00
@@ -208,8 +208,8 @@
 /*
  *	pointer to the last default router chosen. BH is disabled locally.
  */
-static struct rt6_info *rt6_dflt_pointer;
-static spinlock_t rt6_dflt_lock = SPIN_LOCK_UNLOCKED;
+struct rt6_info *rt6_dflt_pointer;
+spinlock_t rt6_dflt_lock = SPIN_LOCK_UNLOCKED;
 
 /* Default Router Selection (RFC 2461 6.3.6) */
 static struct rt6_info *rt6_best_dflt(struct rt6_info *rt, int oif)
@@ -227,7 +227,7 @@
 		     sprt->rt6i_dev->ifindex == oif))
 			m += 8;
 
-		if (sprt->rt6i_expires &&
+		if ((sprt->rt6i_flags & RTF_EXPIRES) &&
 		    time_after(jiffies, sprt->rt6i_expires))
 			continue;
 
@@ -1265,7 +1265,7 @@
 	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
 	ipv6_addr_copy(&rtmsg.rtmsg_gateway, gwaddr);
 	rtmsg.rtmsg_metric = 1024;
-	rtmsg.rtmsg_flags = RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT | RTF_UP;
+	rtmsg.rtmsg_flags = RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT | RTF_UP | RTF_EXPIRES;
 
 	rtmsg.rtmsg_ifindex = dev->ifindex;
 

ChangeSet@1.1879, 2004-09-13 16:04:16+09:00, yoshfuji@linux-ipv6.org
 [IPV6] purge routes via non-router neighbour but gateway.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c	2004-09-13 16:33:02 +09:00
+++ b/net/ipv6/ip6_fib.c	2004-09-13 16:33:02 +09:00
@@ -1199,6 +1199,11 @@
 		    time_after_eq(now, rt->u.dst.lastuse + gc_args.timeout)) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
+		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
+			   (!(rt->rt6i_nexthop->flags & NTF_ROUTER))) {
+			RT6_TRACE("purging route %p via non-router but gateway\n",
+				  rt);
+			return -1;
 		}
 		gc_args.more++;
 	}

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
