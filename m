From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2] [XFRM] Cleanup xfrm_msg_min and xfrm_dispatch
Date: Sun, 1 May 2005 20:55:48 +0200
Message-ID: <20050501185548.GK577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Converts xfrm_msg_min and xfrm_dispatch to use c99 designated
initializers to make greping a little bit easier. Also replaces
two hardcoded message type with meaningful names.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru -X dontdiff linux-2.6.12-rc3.orig/include/linux/xfrm.h linux-2.6.12-rc3/include/linux/xfrm.h
--- linux-2.6.12-rc3.orig/include/linux/xfrm.h	2005-05-01 13:17:00.000000000 +0200
+++ linux-2.6.12-rc3/include/linux/xfrm.h	2005-05-01 12:21:08.000000000 +0200
@@ -144,6 +144,8 @@
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
 
+#define XFRM_NR_MSGTYPES (XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)
+
 struct xfrm_user_tmpl {
 	struct xfrm_id		id;
 	__u16			family;
diff -Nru -X dontdiff linux-2.6.12-rc3.orig/net/xfrm/xfrm_user.c linux-2.6.12-rc3/net/xfrm/xfrm_user.c
--- linux-2.6.12-rc3.orig/net/xfrm/xfrm_user.c	2005-04-30 20:22:26.000000000 +0200
+++ linux-2.6.12-rc3/net/xfrm/xfrm_user.c	2005-05-01 14:52:48.000000000 +0200
@@ -855,47 +855,44 @@
 	return 0;
 }
 
-static const int xfrm_msg_min[(XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)] = {
-	NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),	/* NEW SA */
-	NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),	/* DEL SA */
-	NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),	/* GET SA */
-	NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_info)),/* NEW POLICY */
-	NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_id)),  /* DEL POLICY */
-	NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_id)),  /* GET POLICY */
-	NLMSG_LENGTH(sizeof(struct xfrm_userspi_info)),	/* ALLOC SPI */
-	NLMSG_LENGTH(sizeof(struct xfrm_user_acquire)),	/* ACQUIRE */
-	NLMSG_LENGTH(sizeof(struct xfrm_user_expire)),	/* EXPIRE */
-	NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_info)),/* UPD POLICY */
-	NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),	/* UPD SA */
-	NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)), /* POLEXPIRE */
-	NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush)),	/* FLUSH SA */
-	NLMSG_LENGTH(0),				/* FLUSH POLICY */
+#define XMSGSIZE(type) NLMSG_LENGTH(sizeof(struct type))
+
+static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
+	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_info),
+	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_id),
+	[XFRM_MSG_GETSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_id),
+	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_info),
+	[XFRM_MSG_DELPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
+	[XFRM_MSG_GETPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
+	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userspi_info),
+	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_acquire),
+	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_expire),
+	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_info),
+	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_info),
+	[XFRM_MSG_POLEXPIRE   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_polexpire),
+	[XFRM_MSG_FLUSHSA     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_flush),
+	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = NLMSG_LENGTH(0),
 };
 
+#undef XMSGSIZE
+
 static struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, void **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
-} xfrm_dispatch[] = {
-	{	.doit	=	xfrm_add_sa, 		},
-	{	.doit	=	xfrm_del_sa, 		},
-	{
-		.doit	=	xfrm_get_sa,
-		.dump	=	xfrm_dump_sa,
-	},
-	{	.doit	=	xfrm_add_policy 	},
-	{	.doit	=	xfrm_get_policy 	},
-	{
-		.doit	=	xfrm_get_policy,
-		.dump	=	xfrm_dump_policy,
-	},
-	{	.doit	=	xfrm_alloc_userspi	},
-	{},
-	{},
-	{	.doit	=	xfrm_add_policy 	},
-	{	.doit	=	xfrm_add_sa, 		},
-	{},
-	{	.doit	=	xfrm_flush_sa		},
-	{	.doit	=	xfrm_flush_policy	},
+} xfrm_dispatch[XFRM_NR_MSGTYPES] = {
+	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
+	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = { .doit = xfrm_del_sa        },
+	[XFRM_MSG_GETSA       - XFRM_MSG_BASE] = { .doit = xfrm_get_sa,
+						   .dump = xfrm_dump_sa       },
+	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_add_policy    },
+	[XFRM_MSG_DELPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy    },
+	[XFRM_MSG_GETPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy,
+						   .dump = xfrm_dump_policy   },
+	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = { .doit = xfrm_alloc_userspi },
+	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_add_policy    },
+	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
+	[XFRM_MSG_FLUSHSA     - XFRM_MSG_BASE] = { .doit = xfrm_flush_sa      },
+	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = { .doit = xfrm_flush_policy  },
 };
 
 static int xfrm_done(struct netlink_callback *cb)
@@ -931,7 +928,9 @@
 		return -1;
 	}
 
-	if ((type == 2 || type == 5) && (nlh->nlmsg_flags & NLM_F_DUMP)) {
+	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
+	     type == (XFRM_MSG_GETPOLICY - XFRM_MSG_BASE)) &&
+	    (nlh->nlmsg_flags & NLM_F_DUMP)) {
 		u32 rlen;
 
 		if (link->dump == NULL)
