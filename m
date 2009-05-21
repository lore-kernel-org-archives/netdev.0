From: =?UTF-8?Q?Micha=C5=82=20Miros=C5=82aw=20?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH 1/6 2.6.30-rc6] genetlink: Introduce genl_register_family_with_ops()
Date: Thu, 21 May 2009 22:34:04 +0200 (CEST)
Message-ID: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48064 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754348AbZEUUeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 16:34:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces genl_register_family_with_ops() that registers a genetl=
ink
family along with operations from a table. This is used to kill copy'n'=
paste
occurrences in following patches.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

diff -urN linux-orig-mqbr/include/net/genetlink.h linux-mqbr/include/ne=
t/genetlink.h
--- linux-orig-mqbr/include/net/genetlink.h	2009-03-24 00:12:14.0000000=
00 +0100
+++ linux-mqbr/include/net/genetlink.h	2009-05-21 17:46:30.000000000 +0=
200
@@ -88,6 +88,8 @@
 };
=20
 extern int genl_register_family(struct genl_family *family);
+extern int genl_register_family_with_ops(struct genl_family *family,
+	struct genl_ops *ops, size_t n_ops);
 extern int genl_unregister_family(struct genl_family *family);
 extern int genl_register_ops(struct genl_family *, struct genl_ops *op=
s);
 extern int genl_unregister_ops(struct genl_family *, struct genl_ops *=
ops);
diff -urN linux-orig-mqbr/net/netlink/genetlink.c linux-mqbr/net/netlin=
k/genetlink.c
--- linux-orig-mqbr/net/netlink/genetlink.c	2009-03-24 00:12:14.0000000=
00 +0100
+++ linux-mqbr/net/netlink/genetlink.c	2009-05-21 18:43:34.000000000 +0=
200
@@ -384,6 +384,52 @@
 }
=20
 /**
+ * genl_register_family_with_ops - register a generic netlink family
+ * @family: generic netlink family
+ * @ops: operations to be registered
+ * @n_ops: number of elements to register
+ *
+ * Registers the specified family and operations from the specified ta=
ble.
+ * Only one family may be registered with the same family name or iden=
tifier.
+ *
+ * The family id may equal GENL_ID_GENERATE causing an unique id to
+ * be automatically generated and assigned.
+ *
+ * Either a doit or dumpit callback must be specified for every regist=
ered
+ * operation or the function will fail. Only one operation structure p=
er
+ * command identifier may be registered.
+ *
+ * See include/net/genetlink.h for more documenation on the operations
+ * structure.
+ *
+ * This is equivalent to calling genl_register_family() followed by
+ * genl_register_ops() for every operation entry in the table taking
+ * care to unregister the family on error path.
+ *
+ * Return 0 on success or a negative error code.
+ */
+int genl_register_family_with_ops(struct genl_family *family,
+	struct genl_ops *ops, size_t n_ops)
+{
+	int err, i;
+
+	err =3D genl_register_family(family);
+	if (err)
+		return err;
+
+	for (i =3D 0; i < n_ops; ++i, ++ops) {
+		err =3D genl_register_ops(family, ops);
+		if (err)
+			goto err_out;
+	}
+	return 0;
+err_out:
+	genl_unregister_family(family);
+	return err;
+}
+EXPORT_SYMBOL(genl_register_family_with_ops);
+
+/**
  * genl_unregister_family - unregister generic netlink family
  * @family: generic netlink family
  *
