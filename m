From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 3/3] [XFRM]: Pack struct xfrm_policy
Date: Mon, 27 Nov 2006 18:05:26 -0200
Message-ID: <20061127200525.GZ11605@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:44931 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1758551AbWK0UF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 15:05:56 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[acme@newtoy net-2.6.20]$ pahole net/ipv4/tcp.o xfrm_policy
/* /pub/scm/linux/kernel/git/acme/net-2.6.20/include/linux/security.h:67 */
struct xfrm_policy {
        struct xfrm_policy *       next;                 /*     0     4 */
        struct hlist_node          bydst;                /*     4     8 */
        struct hlist_node          byidx;                /*    12     8 */
        rwlock_t                   lock;                 /*    20    36 */
        atomic_t                   refcnt;               /*    56     4 */
        struct timer_list          timer;                /*    60    24 */
        u8                         type;                 /*    84     1 */

        /* XXX 3 bytes hole, try to pack */

        u32                        priority;             /*    88     4 */
        u32                        index;                /*    92     4 */
        struct xfrm_selector       selector;             /*    96    56 */
        struct xfrm_lifetime_cfg   lft;                  /*   152    64 */
        struct xfrm_lifetime_cur   curlft;               /*   216    32 */
        struct dst_entry *         bundles;              /*   248     4 */
        __u16                      family;               /*   252     2 */
        __u8                       action;               /*   254     1 */
        __u8                       flags;                /*   255     1 */
        __u8                       dead;                 /*   256     1 */
        __u8                       xfrm_nr;              /*   257     1 */

        /* XXX 2 bytes hole, try to pack */

        struct xfrm_sec_ctx *      security;             /*   260     4 */
        struct xfrm_tmpl           xfrm_vec[6];          /*   264   360 */
}; /* size: 624, sum members: 619, holes: 2, sum holes: 5 */

So lets have just one hole instead of two, by moving 'type' to just before 'action',
end result:

[acme@newtoy net-2.6.20]$ codiff -s /tmp/tcp.o.before net/ipv4/tcp.o
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/tcp.c:
  struct xfrm_policy |   -4
 1 struct changed
[acme@newtoy net-2.6.20]$

[acme@newtoy net-2.6.20]$ pahole -c 64 net/ipv4/tcp.o xfrm_policy
/* /pub/scm/linux/kernel/git/acme/net-2.6.20/include/linux/security.h:67 */
struct xfrm_policy {
        struct xfrm_policy *       next;                 /*     0     4 */
        struct hlist_node          bydst;                /*     4     8 */
        struct hlist_node          byidx;                /*    12     8 */
        rwlock_t                   lock;                 /*    20    36 */
        atomic_t                   refcnt;               /*    56     4 */
        struct timer_list          timer;                /*    60    24 */
        u32                        priority;             /*    84     4 */
        u32                        index;                /*    88     4 */
        struct xfrm_selector       selector;             /*    92    56 */
        struct xfrm_lifetime_cfg   lft;                  /*   148    64 */
        struct xfrm_lifetime_cur   curlft;               /*   212    32 */
        struct dst_entry *         bundles;              /*   244     4 */
        u16                        family;               /*   248     2 */
        u8                         type;                 /*   250     1 */
        u8                         action;               /*   251     1 */
        u8                         flags;                /*   252     1 */
        u8                         dead;                 /*   253     1 */
        u8                         xfrm_nr;              /*   254     1 */

        /* XXX 1 byte hole, try to pack */

        struct xfrm_sec_ctx *      security;             /*   256     4 */
        struct xfrm_tmpl           xfrm_vec[6];          /*   260   360 */
}; /* size: 620, sum members: 619, holes: 1, sum holes: 1 */

Are there any fugly data dependencies here? None that I know.

In the process changed the removed the __ prefixed types, that are just for
userspace visible headers.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/net/xfrm.h |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 3878a88..984e5c4 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -340,18 +340,19 @@ struct xfrm_policy
 	atomic_t		refcnt;
 	struct timer_list	timer;
 
-	u8			type;
 	u32			priority;
 	u32			index;
 	struct xfrm_selector	selector;
 	struct xfrm_lifetime_cfg lft;
 	struct xfrm_lifetime_cur curlft;
 	struct dst_entry       *bundles;
-	__u16			family;
-	__u8			action;
-	__u8			flags;
-	__u8			dead;
-	__u8			xfrm_nr;
+	u16			family;
+	u8			type;
+	u8			action;
+	u8			flags;
+	u8			dead;
+	u8			xfrm_nr;
+	/* XXX 1 byte hole, try to pack */
 	struct xfrm_sec_ctx	*security;
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
-- 
1.4.2.1.g3d5c

