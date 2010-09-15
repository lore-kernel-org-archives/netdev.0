From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: list subscribed resources via proc_fs
Date: Thu, 16 Sep 2010 01:30:14 +0300
Message-ID: <1284589815-28302-4-git-send-email-remi@remlab.net>
References: <d214bd6716258777ce8b1023208bc347@chewa.net>
 <1284589815-28302-1-git-send-email-remi@remlab.net>
 <1284589815-28302-2-git-send-email-remi@remlab.net>
 <1284589815-28302-3-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36521 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599Ab0IOWaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:30:17 -0400
In-Reply-To: <1284589815-28302-3-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    1 +
 net/phonet/pn_dev.c         |    2 +
 net/phonet/socket.c         |   96 +++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 2d16783..13649eb 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -57,5 +57,6 @@ struct net_device *phonet_route_output(struct net *ne=
t, u8 daddr);
 #define PN_NO_ADDR	0xff
=20
 extern const struct file_operations pn_sock_seq_fops;
+extern const struct file_operations pn_res_seq_fops;
=20
 #endif
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index d0a4294..947038d 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -373,6 +373,7 @@ int __init phonet_device_init(void)
 	if (err)
 		return err;
=20
+	proc_net_fops_create(&init_net, "pnresource", 0, &pn_res_seq_fops);
 	register_netdevice_notifier(&phonet_device_notifier);
 	err =3D phonet_netlink_register();
 	if (err)
@@ -385,6 +386,7 @@ void phonet_device_exit(void)
 	rtnl_unregister_all(PF_PHONET);
 	unregister_netdevice_notifier(&phonet_device_notifier);
 	unregister_pernet_device(&phonet_net_ops);
+	proc_net_remove(&init_net, "pnresource");
 }
=20
 int phonet_route_add(struct net_device *dev, u8 daddr)
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index d4f41af..6bf6e3c 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -654,3 +654,99 @@ void pn_sock_unbind_all_res(struct sock *sk)
 		match--;
 	}
 }
+
+#ifdef CONFIG_PROC_FS
+static struct sock **pn_res_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct net *net =3D seq_file_net(seq);
+	unsigned i;
+
+	if (!net_eq(net, &init_net))
+		return NULL;
+
+	for (i =3D 0; i < 256; i++) {
+		if (pnres.sk[i] =3D=3D NULL)
+			continue;
+		if (!pos)
+			return pnres.sk + i;
+		pos--;
+	}
+	return NULL;
+}
+
+static struct sock **pn_res_get_next(struct seq_file *seq, struct sock=
 **sk)
+{
+	struct net *net =3D seq_file_net(seq);
+	unsigned i;
+
+	BUG_ON(!net_eq(net, &init_net));
+
+	for (i =3D (sk - pnres.sk) + 1; i < 256; i++)
+		if (pnres.sk[i])
+			return pnres.sk + i;
+	return NULL;
+}
+
+static void *pn_res_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(resource_mutex)
+{
+	mutex_lock(&resource_mutex);
+	return *pos ? pn_res_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *pn_res_seq_next(struct seq_file *seq, void *v, loff_t *po=
s)
+{
+	struct sock **sk;
+
+	if (v =3D=3D SEQ_START_TOKEN)
+		sk =3D pn_res_get_idx(seq, 0);
+	else
+		sk =3D pn_res_get_next(seq, v);
+	(*pos)++;
+	return sk;
+}
+
+static void pn_res_seq_stop(struct seq_file *seq, void *v)
+	__releases(resource_mutex)
+{
+	mutex_unlock(&resource_mutex);
+}
+
+static int pn_res_seq_show(struct seq_file *seq, void *v)
+{
+	int len;
+
+	if (v =3D=3D SEQ_START_TOKEN)
+		seq_printf(seq, "%s%n", "rs   uid inode", &len);
+	else {
+		struct sock **psk =3D v;
+		struct sock *sk =3D *psk;
+
+		seq_printf(seq, "%02X %5d %lu%n",
+			psk - pnres.sk, sock_i_uid(sk), sock_i_ino(sk), &len);
+	}
+	seq_printf(seq, "%*s\n", 63 - len, "");
+	return 0;
+}
+
+static const struct seq_operations pn_res_seq_ops =3D {
+	.start =3D pn_res_seq_start,
+	.next =3D pn_res_seq_next,
+	.stop =3D pn_res_seq_stop,
+	.show =3D pn_res_seq_show,
+};
+
+static int pn_res_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &pn_res_seq_ops,
+				sizeof(struct seq_net_private));
+}
+
+const struct file_operations pn_res_seq_fops =3D {
+	.owner =3D THIS_MODULE,
+	.open =3D pn_res_open,
+	.read =3D seq_read,
+	.llseek =3D seq_lseek,
+	.release =3D seq_release_net,
+};
+#endif
--=20
1.7.0.4

