From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Phonet: sockets list through proc_fs
Date: Tue, 21 Jul 2009 14:57:57 +0300
Message-ID: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:54699 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbZGULz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 07:55:56 -0400
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6LBtZU0012342
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 14:55:45 +0300
Received: from localhost.localdomain (esdhcp03634.research.nokia.com [172.21.36.34])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6LBtWcC014694
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 14:55:33 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

This provides a list of sockets with their Phonet bind addresses and
some socket debug informations through /proc/net/phonet.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    2 +
 net/phonet/pn_dev.c         |    7 +++
 net/phonet/socket.c         |   96 +++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 105 insertions(+), 0 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 29d1267..44c923c 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -49,4 +49,6 @@ void phonet_address_notify(int event, struct net_devi=
ce *dev, u8 addr);
=20
 #define PN_NO_ADDR	0xff
=20
+extern const struct file_operations pn_sock_seq_fops;
+
 #endif
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index b0d6ddd..5107b79 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -218,6 +218,11 @@ static int phonet_init_net(struct net *net)
 	if (!pnn)
 		return -ENOMEM;
=20
+	if (!proc_net_fops_create(net, "phonet", 0, &pn_sock_seq_fops)) {
+		kfree(pnn);
+		return -ENOMEM;
+	}
+
 	INIT_LIST_HEAD(&pnn->pndevs.list);
 	spin_lock_init(&pnn->pndevs.lock);
 	net_assign_generic(net, phonet_net_id, pnn);
@@ -233,6 +238,8 @@ static void phonet_exit_net(struct net *net)
 	for_each_netdev(net, dev)
 		phonet_device_destroy(dev);
 	rtnl_unlock();
+
+	proc_net_remove(net, "phonet");
 	kfree(pnn);
 }
=20
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index ada2a35..aa1617a 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -412,3 +412,99 @@ found:
 	return 0;
 }
 EXPORT_SYMBOL(pn_sock_get_port);
+
+static struct sock *pn_sock_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct net *net =3D seq_file_net(seq);
+	struct hlist_node *node;
+	struct sock *sknode;
+
+	sk_for_each(sknode, node, &pnsocks.hlist) {
+		if (!net_eq(net, sock_net(sknode)))
+			continue;
+		if (!pos)
+			return sknode;
+		pos--;
+	}
+	return NULL;
+}
+
+static struct sock *pn_sock_get_next(struct seq_file *seq, struct sock=
 *sk)
+{
+	struct net *net =3D seq_file_net(seq);
+
+	do
+		sk =3D sk_next(sk);
+	while (sk && !net_eq(net, sock_net(sk)));
+
+	return sk;
+}
+
+static void *pn_sock_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(pnsocks.lock)
+{
+	spin_lock_bh(&pnsocks.lock);
+	return *pos ? pn_sock_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *pn_sock_seq_next(struct seq_file *seq, void *v, loff_t *p=
os)
+{
+	struct sock *sk;
+
+	if (v =3D=3D SEQ_START_TOKEN)
+		sk =3D pn_sock_get_idx(seq, 0);
+	else
+		sk =3D pn_sock_get_next(seq, v);
+	(*pos)++;
+	return sk;
+}
+
+static void pn_sock_seq_stop(struct seq_file *seq, void *v)
+	__releases(pnsocks.lock)
+{
+	spin_unlock_bh(&pnsocks.lock);
+}
+
+static int pn_sock_seq_show(struct seq_file *seq, void *v)
+{
+	int len;
+
+	if (v =3D=3D SEQ_START_TOKEN)
+		seq_printf(seq, "%s%n", "pt  loc  rem rs st tx_queue rx_queue "
+			"  uid inode ref pointer drops", &len);
+	else {
+		struct sock *sk =3D v;
+		struct pn_sock *pn =3D pn_sk(sk);
+
+		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
+			"%d %p %d%n",
+			sk->sk_protocol, pn->sobject, 0, pn->resource,
+			sk->sk_state,
+			sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
+			sock_i_uid(sk), sock_i_ino(sk),
+			atomic_read(&sk->sk_refcnt), sk,
+			atomic_read(&sk->sk_drops), &len);
+	}
+	seq_printf(seq, "%*s\n", 127 - len, "");
+	return 0;
+}
+
+static const struct seq_operations pn_sock_seq_ops =3D {
+	.start =3D pn_sock_seq_start,
+	.next =3D pn_sock_seq_next,
+	.stop =3D pn_sock_seq_stop,
+	.show =3D pn_sock_seq_show,
+};
+
+static int pn_sock_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &pn_sock_seq_ops);
+}
+
+const struct file_operations pn_sock_seq_fops =3D {
+	.owner =3D THIS_MODULE,
+	.open =3D pn_sock_open,
+	.read =3D seq_read,
+	.llseek =3D seq_lseek,
+	.release =3D seq_release,
+};
--=20
1.6.0.4

