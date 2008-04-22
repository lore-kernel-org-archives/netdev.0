From: "Rui T. Matos" <rmatos@hng.av.it.pt>
Subject: [PATCH] Add tcindex classifier
Date: Tue, 22 Apr 2008 16:32:46 +0100
Message-ID: <9605.09382789514$1208882110@news.gmane.org>
References: <12088783661504-git-send-email->
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?q?Rui=20Tiago=20Ca=C3=A7=C3=A3o=20Matos?= <rmatos@av.it.pt>
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:60574 "EHLO av.it.pt"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753387AbYDVQc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 12:32:58 -0400
In-Reply-To: <12088783661504-git-send-email->
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rui Tiago Ca=C3=A7=C3=A3o Matos <rmatos@av.it.pt>

---
 include/netlink-types.h             |   10 ++
 include/netlink/route/cls/tcindex.h |   33 ++++
 lib/route/cls/tcindex.c             |  305 +++++++++++++++++++++++++++=
++++++++
 3 files changed, 348 insertions(+), 0 deletions(-)
 create mode 100644 include/netlink/route/cls/tcindex.h
 create mode 100644 lib/route/cls/tcindex.c

diff --git a/include/netlink-types.h b/include/netlink-types.h
index a690cb2..821108f 100644
--- a/include/netlink-types.h
+++ b/include/netlink-types.h
@@ -518,6 +518,16 @@ struct rtnl_fw
 	int			cf_mask;
 };
=20
+struct rtnl_tcindex
+{
+        uint32_t                ci_hash;
+        uint16_t                ci_filter_mask;
+        uint32_t                ci_shift;
+        uint32_t                ci_fall_through;
+        uint32_t                ci_classid;
+        int                     ci_mask;
+};
+
 struct rtnl_dsmark_qdisc
 {
 	uint16_t	qdm_indices;
diff --git a/include/netlink/route/cls/tcindex.h b/include/netlink/rout=
e/cls/tcindex.h
new file mode 100644
index 0000000..cba6059
--- /dev/null
+++ b/include/netlink/route/cls/tcindex.h
@@ -0,0 +1,33 @@
+/*
+ * netlink/route/cls/tcindex.h	tcindex classifier
+ *
+ *	This library is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU Lesser General Public
+ *	License as published by the Free Software Foundation version 2.1
+ *	of the License.
+ *
+ * Copyright (c) 2003-2006 Thomas Graf <tgraf@suug.ch>
+ * Copyright (c) 2008 Rui Matos <rmatos@av.it.pt>
+ */
+
+#ifndef NETLINK_TCINDEX_H_
+#define NETLINK_TCINDEX_H_
+
+#include <netlink/netlink.h>
+#include <netlink/cache.h>
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+extern int rtnl_tcindex_set_hash                (struct rtnl_cls *, ui=
nt32_t);
+extern int rtnl_tcindex_set_mask                (struct rtnl_cls *, ui=
nt16_t);
+extern int rtnl_tcindex_set_shift               (struct rtnl_cls *, ui=
nt32_t);
+extern int rtnl_tcindex_set_fall_through        (struct rtnl_cls *, ui=
nt32_t);
+extern int rtnl_tcindex_set_classid             (struct rtnl_cls *, ui=
nt32_t);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif
diff --git a/lib/route/cls/tcindex.c b/lib/route/cls/tcindex.c
new file mode 100644
index 0000000..bc664bb
--- /dev/null
+++ b/lib/route/cls/tcindex.c
@@ -0,0 +1,305 @@
+/*
+ * lib/route/cls/tcindex.c      tcindex classifier
+ *
+ *	This library is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU Lesser General Public
+ *	License as published by the Free Software Foundation version 2.1
+ *	of the License.
+ *
+ * Copyright (c) 2003-2006 Thomas Graf <tgraf@suug.ch>
+ * Copyright (c) 2008 Rui Matos <rmatos@av.it.pt>
+ */
+
+/**
+ * @ingroup cls_api
+ * @defgroup tcindex tcindex Classifier
+ *
+ * @{
+ */
+
+#include <netlink-local.h>
+#include <netlink-tc.h>
+#include <netlink/netlink.h>
+#include <netlink/route/classifier.h>
+#include <netlink/route/classifier-modules.h>
+#include <netlink/route/cls/tcindex.h>
+
+/** @cond SKIP */
+#define TCINDEX_ATTR_HASH         (1 << 0)
+#define TCINDEX_ATTR_MASK         (1 << 1)
+#define TCINDEX_ATTR_SHIFT        (1 << 2)
+#define TCINDEX_ATTR_FALL_THROUGH (1 << 3)
+#define TCINDEX_ATTR_CLASSID      (1 << 4)
+#define TCINDEX_ATTR_POLICE       (1 << 5)
+#define TCINDEX_ATTR_ACTION       (1 << 6)
+/** @endcond */
+
+static inline struct rtnl_tcindex *tcindex_cls(struct rtnl_cls *cls)
+{
+	return (struct rtnl_tcindex *) cls->c_subdata;
+}
+
+static inline struct rtnl_tcindex *tcindex_alloc(struct rtnl_cls *cls)
+{
+	if (!cls->c_subdata)
+		cls->c_subdata =3D calloc(1, sizeof(struct rtnl_tcindex));
+
+	return tcindex_cls(cls);
+}
+
+static struct nla_policy tcindex_policy[TCA_TCINDEX_MAX+1] =3D {
+
+};
+
+static int tcindex_msg_parser(struct rtnl_cls *cls)
+{
+	int err;
+	struct nlattr *tb[TCA_TCINDEX_MAX + 1];
+	struct rtnl_tcindex *tci;
+
+	err =3D tca_parse(tb, TCA_TCINDEX_MAX, (struct rtnl_tca *) cls, tcind=
ex_policy);
+	if (err < 0)
+		return err;
+
+        tci =3D tcindex_alloc(cls);
+	if (!tci)
+		goto errout_nomem;
+
+        if (tb[TCA_TCINDEX_HASH]) {
+                tci->ci_hash =3D nla_get_u32(tb[TCA_TCINDEX_HASH]);
+                tci->ci_mask =3D TCINDEX_ATTR_HASH;
+        }
+        if (tb[TCA_TCINDEX_MASK]) {
+                tci->ci_filter_mask =3D nla_get_u16(tb[TCA_TCINDEX_MAS=
K]);
+                tci->ci_mask =3D TCINDEX_ATTR_MASK;
+        }
+        if (tb[TCA_TCINDEX_SHIFT]) {
+                tci->ci_shift =3D nla_get_u32(tb[TCA_TCINDEX_SHIFT]);
+                tci->ci_mask =3D TCINDEX_ATTR_SHIFT;
+        }
+        if (tb[TCA_TCINDEX_FALL_THROUGH]) {
+                tci->ci_fall_through =3D nla_get_u32(tb[TCA_TCINDEX_FA=
LL_THROUGH]);
+                tci->ci_mask =3D TCINDEX_ATTR_FALL_THROUGH;
+        }
+        if (tb[TCA_TCINDEX_CLASSID]) {
+                tci->ci_classid =3D nla_get_u32(tb[TCA_TCINDEX_CLASSID=
]);
+                tci->ci_mask =3D TCINDEX_ATTR_CLASSID;
+        }
+
+	return 0;
+
+errout_nomem:
+	err =3D nl_errno(ENOMEM);
+
+	return err;
+}
+
+static void tcindex_free_data(struct rtnl_cls *cls)
+{
+#if 0
+	struct rtnl_tci *tci =3D tcindex_cls(cls);
+
+	if (!tci)
+		return;
+#endif
+
+	free(cls->c_subdata);
+}
+
+static int tcindex_clone(struct rtnl_cls *_dst, struct rtnl_cls *_src)
+{
+	struct rtnl_tcindex *dst, *src =3D tcindex_cls(_src);
+
+	if (!src)
+		return 0;
+
+	dst =3D tcindex_alloc(_dst);
+	if (!dst)
+		return nl_errno(ENOMEM);
+
+	return 0;
+#if 0
+errout:
+	return nl_get_errno();
+#endif
+}
+
+/* FIXME: I should understand what are the *dump* functions for */
+static int tcindex_dump_brief(struct rtnl_cls *cls, struct nl_dump_par=
ams *p,
+			  int line)
+{
+	struct rtnl_tcindex *tci =3D tcindex_cls(cls);
+	char buf[32];
+
+	if (!tci)
+		goto ignore;
+
+	if (tci->ci_mask & TCINDEX_ATTR_CLASSID)
+		dp_dump(p, " target %s",
+			rtnl_tc_handle2str(tci->ci_classid, buf, sizeof(buf)));
+
+ignore:
+	return line;
+}
+
+static int tcindex_dump_full(struct rtnl_cls *cls, struct nl_dump_para=
ms *p,
+			 int line)
+{
+#if 0
+	struct rtnl_fw *f =3D fw_cls(cls);
+
+	if (!f)
+		goto ignore;
+
+	if (f->cf_mask & FW_ATTR_INDEV)
+		dp_dump(p, "indev %s ", f->cf_indev);
+
+ignore:
+#endif
+	return line;
+}
+
+static int tcindex_dump_stats(struct rtnl_cls *cls, struct nl_dump_par=
ams *p,
+			  int line)
+{
+#if 0
+	struct rtnl_fw *f =3D fw_cls(cls);
+
+	if (!f)
+		goto ignore;
+
+ignore:
+#endif
+	return line;
+}
+
+static struct nl_msg *tcindex_get_opts(struct rtnl_cls *cls)
+{
+	struct rtnl_tcindex *tci;
+	struct nl_msg *msg;
+
+	tci =3D tcindex_cls(cls);
+	if (!tci)
+		return NULL;
+
+	msg =3D nlmsg_alloc();
+	if (!msg)
+		return NULL;
+
+	if (tci->ci_mask & TCINDEX_ATTR_HASH)
+		nla_put_u32(msg, TCA_TCINDEX_HASH, tci->ci_hash);
+	if (tci->ci_mask & TCINDEX_ATTR_MASK)
+		nla_put_u16(msg, TCA_TCINDEX_MASK, tci->ci_filter_mask);
+	if (tci->ci_mask & TCINDEX_ATTR_SHIFT)
+		nla_put_u32(msg, TCA_TCINDEX_SHIFT, tci->ci_shift);
+	if (tci->ci_mask & TCINDEX_ATTR_FALL_THROUGH)
+		nla_put_u32(msg, TCA_TCINDEX_FALL_THROUGH, tci->ci_fall_through);
+	if (tci->ci_mask & TCINDEX_ATTR_CLASSID)
+		nla_put_u32(msg, TCA_TCINDEX_CLASSID, tci->ci_classid);
+
+	return msg;
+}
+
+/**
+ * @name Attribute Modifications
+ * @{
+ */
+
+int rtnl_tcindex_set_hash(struct rtnl_cls *cls, uint32_t hash)
+{
+	struct rtnl_tcindex *tci;
+
+	tci =3D tcindex_alloc(cls);
+	if (!tci)
+		return nl_errno(ENOMEM);
+
+        tci->ci_hash =3D hash;
+        tci->ci_mask |=3D TCINDEX_ATTR_HASH;
+
+	return 0;
+}
+
+int rtnl_tcindex_set_mask(struct rtnl_cls *cls, uint16_t mask)
+{
+	struct rtnl_tcindex *tci;
+
+	tci =3D tcindex_alloc(cls);
+	if (!tci)
+		return nl_errno(ENOMEM);
+
+        tci->ci_filter_mask =3D mask;
+        tci->ci_mask |=3D TCINDEX_ATTR_MASK;
+
+	return 0;
+}
+
+int rtnl_tcindex_set_shift(struct rtnl_cls *cls, uint32_t shift)
+{
+	struct rtnl_tcindex *tci;
+
+	tci =3D tcindex_alloc(cls);
+	if (!tci)
+		return nl_errno(ENOMEM);
+
+        tci->ci_shift =3D shift;
+        tci->ci_mask |=3D TCINDEX_ATTR_SHIFT;
+
+	return 0;
+}
+
+int rtnl_tcindex_set_fall_through(struct rtnl_cls *cls, uint32_t value=
)
+{
+	struct rtnl_tcindex *tci;
+
+	tci =3D tcindex_alloc(cls);
+	if (!tci)
+		return nl_errno(ENOMEM);
+
+        if (value =3D=3D 0)
+                tci->ci_fall_through =3D 0;
+        else
+                tci->ci_fall_through =3D 1;
+
+        tci->ci_mask |=3D TCINDEX_ATTR_FALL_THROUGH;
+
+	return 0;
+}
+
+int rtnl_tcindex_set_classid(struct rtnl_cls *cls, uint32_t classid)
+{
+	struct rtnl_tcindex *tci;
+
+	tci =3D tcindex_alloc(cls);
+	if (!tci)
+		return nl_errno(ENOMEM);
+
+        tci->ci_classid =3D classid;
+        tci->ci_mask |=3D TCINDEX_ATTR_CLASSID;
+
+	return 0;
+}
+
+/** @} */
+
+static struct rtnl_cls_ops tcindex_ops =3D {
+	.co_kind		=3D "tcindex",
+	.co_msg_parser		=3D tcindex_msg_parser,
+	.co_free_data		=3D tcindex_free_data,
+	.co_clone		=3D tcindex_clone,
+	.co_get_opts		=3D tcindex_get_opts,
+	.co_dump[NL_DUMP_BRIEF]	=3D tcindex_dump_brief,
+	.co_dump[NL_DUMP_FULL]	=3D tcindex_dump_full,
+	.co_dump[NL_DUMP_STATS]	=3D tcindex_dump_stats,
+};
+
+static void __init tcindex_init(void)
+{
+	rtnl_cls_register(&tcindex_ops);
+}
+
+static void __exit tcindex_exit(void)
+{
+	rtnl_cls_unregister(&tcindex_ops);
+}
+
+/** @} */
--=20
1.5.4.1

