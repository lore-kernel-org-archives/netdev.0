From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] PPC64 iSeries virtual ethernet proc files
Date: Mon, 7 Jun 2004 16:43:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607164312.258a9f99.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1";
 boundary="Signature=_Mon__7_Jun_2004_16_43_13_+1000_rI7AdqH.jktRpZ4z"
Cc: Jeff Garzik <jgarzik@pobox.com>,
        ppc64-dev
 <linuxppc64-dev@lists.linuxppc.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus <torvalds@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Signature=_Mon__7_Jun_2004_16_43_13_+1000_rI7AdqH.jktRpZ4z
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Hi Andrew,

From: David Gibson <david@gibson.dropbear.id.au>

This patch just adds back some of the iserires_veth proc files to provide
information to user space (particularly Kudzu) to allow the virtual
ethernets to be discovered.  These files existed in a 2.4 version of this
driver that was shipped by some distros.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

diff -ruN 2.6.7-rc2-bk7/drivers/net/iseries_veth.c 2.6.7-rc2-bk7.veth.proc.1/drivers/net/iseries_veth.c
--- 2.6.7-rc2-bk7/drivers/net/iseries_veth.c	2004-06-07 13:35:47.000000000 +1000
+++ 2.6.7-rc2-bk7.veth.proc.1/drivers/net/iseries_veth.c	2004-06-07 15:28:40.000000000 +1000
@@ -165,6 +165,7 @@
 static HvLpIndex this_lp;
 static struct veth_lpar_connection *veth_cnx[HVMAXARCHITECTEDLPS]; /* = 0 */
 static struct net_device *veth_dev[HVMAXARCHITECTEDVIRTUALLANS]; /* = 0 */
+struct proc_dir_entry *veth_proc_root; /* = NULL */
 
 static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void veth_recycle_msg(struct veth_lpar_connection *, struct veth_msg *);
@@ -1328,6 +1329,91 @@
 }
 
 /*
+ * procfs code (used by userspace for discovery)
+ */
+static int proc_veth_dump_port(char *page, char **start, off_t off, int count,
+			int *eof, void *data)
+{
+	char *out = page;
+	struct net_device *dev = data;
+	struct veth_port *port = dev->priv;
+	long len;
+	int i;
+
+	BUG_ON(port == NULL);
+
+	out += sprintf(out, "Net device name:\t%s\n", dev->name);
+	out += sprintf(out, "Address:\t%012lX\n", port->mac_addr >> 16);
+
+	read_lock_irq(&port->mcast_gate);
+	out += sprintf(out, "Promiscuous:\t%d\n", port->promiscuous);
+	out += sprintf(out, "All multicast:\t%d\n", port->all_mcast);
+	out += sprintf(out, "Number multicast:\t%d\n", port->num_mcast);
+
+	for (i = 0; i < port->num_mcast; ++i)
+		out += sprintf(out, "   %012lX\n", port->mcast_addr[i] >> 16);
+	read_unlock_irq(&port->mcast_gate);
+
+	len = (out - page) - off;
+	if (len < count)
+		*eof = 1;
+	else
+		len = count;
+
+	if (len <= 0)
+		len = 0;
+	else
+		*start = page + off;
+	return len;
+}
+
+static void veth_proc_init(void)
+{
+	int i;
+
+	veth_proc_root = proc_mkdir("iSeries/veth", NULL);
+	if (veth_proc_root == NULL)
+		return;
+
+	for (i = 0; i < HVMAXARCHITECTEDVIRTUALLANS; i++) {
+		struct proc_dir_entry *ent;
+		char name[10];
+
+		if (veth_dev[i] == NULL)
+			continue;
+
+		sprintf(name, "veth%d", i);
+		ent = create_proc_entry(name, S_IFREG | S_IRUSR,
+					veth_proc_root);
+		if (ent == NULL)
+			return;
+
+		ent->nlink = 1;
+		ent->owner = THIS_MODULE;
+		ent->data = veth_dev[i];
+		ent->read_proc = proc_veth_dump_port;
+		ent->write_proc = NULL;
+	}
+}
+
+static void veth_proc_delete(void)
+{
+	int i;
+
+	for (i = 0; i < HVMAXARCHITECTEDVIRTUALLANS; i++) {
+		char name[10];
+
+		if (veth_dev[i] == NULL)
+			continue;
+
+		sprintf(name, "veth%d", i);
+		remove_proc_entry(name, veth_proc_root);
+	}
+
+	remove_proc_entry("iSeries/veth", NULL);
+}
+
+/*
  * Module initialization/cleanup
  */
 
@@ -1335,6 +1421,8 @@
 {
 	int i;
 
+	veth_proc_delete();
+
 	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i)
 		veth_destroy_connection(i);
 
@@ -1394,6 +1482,8 @@
 		if (veth_cnx[i])
 			veth_kick_statemachine(veth_cnx[i]);
 
+	veth_proc_init();
+
 	return 0;
 }
 module_init(veth_module_init);

--Signature=_Mon__7_Jun_2004_16_43_13_+1000_rI7AdqH.jktRpZ4z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAxA6BFG47PeJeR58RAiYFAJ9Lu7T3X9XuAyz7AxQXC/c1zBOIZwCg13/K
RRnDHqJY7GNOR/6682jTN0U=
=NID2
-----END PGP SIGNATURE-----

--Signature=_Mon__7_Jun_2004_16_43_13_+1000_rI7AdqH.jktRpZ4z--
