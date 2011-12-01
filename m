From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] netconsole: implement ipv4 tos support
Date: Wed, 30 Nov 2011 17:18:50 -0800
Message-ID: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45396 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab1LABTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 20:19:01 -0500
Received: by iage36 with SMTP id e36so1627805iag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:19:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 Documentation/networking/netconsole.txt |    1 +
 drivers/net/netconsole.c                |   28 +++++++++++++++++++++++=
+++++
 include/linux/netpoll.h                 |    1 +
 net/core/netpoll.c                      |    4 +++-
 4 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/netconsole.txt b/Documentation/ne=
tworking/netconsole.txt
index 8d02207..a02374f 100644
--- a/Documentation/networking/netconsole.txt
+++ b/Documentation/networking/netconsole.txt
@@ -94,6 +94,7 @@ The interface exposes these parameters of a netconsol=
e target to userspace:
 	remote_ip	Remote agent's IP address		(read-write)
 	local_mac	Local interface's MAC address		(read-only)
 	remote_mac	Remote agent's MAC address		(read-write)
+	tos		TOS byte value to utilize		(read-write)
=20
 The "enabled" attribute is also used to control whether the parameters=
 of
 a target can be updated or not -- you can modify the parameters of onl=
y
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index e888202..d24d5df 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -90,6 +90,7 @@ static DEFINE_SPINLOCK(target_list_lock);
  *		remote_ip	(read-write)
  *		local_mac	(read-only)
  *		remote_mac	(read-write)
+ *		tos		(read-write)
  */
 struct netconsole_target {
 	struct list_head	list;
@@ -221,6 +222,7 @@ static void free_param_target(struct netconsole_tar=
get *nt)
  *				|	remote_ip
  *				|	local_mac
  *				|	remote_mac
+ *				|	tos
  *				|
  *				<target>/...
  */
@@ -288,6 +290,11 @@ static ssize_t show_remote_mac(struct netconsole_t=
arget *nt, char *buf)
 	return snprintf(buf, PAGE_SIZE, "%pM\n", nt->np.remote_mac);
 }
=20
+static ssize_t show_tos(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", nt->np.tos);
+}
+
 /*
  * This one is special -- targets created through the configfs interfa=
ce
  * are not enabled (and the corresponding netpoll activated) by defaul=
t.
@@ -451,6 +458,25 @@ static ssize_t store_remote_mac(struct netconsole_=
target *nt,
 	return strnlen(buf, count);
 }
=20
+static ssize_t store_tos(struct netconsole_target *nt,
+			 const char *buf,
+			 size_t count)
+{
+	int rv;
+
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "
+				"disable to update parameters\n",
+				config_item_name(&nt->item));
+		return -EINVAL;
+	}
+
+	rv =3D kstrtou8(buf, 10, &nt->np.tos);
+	if (rv < 0)
+		return rv;
+	return strnlen(buf, count);
+}
+
 /*
  * Attribute definitions for netconsole_target.
  */
@@ -471,6 +497,7 @@ NETCONSOLE_TARGET_ATTR_RW(local_ip);
 NETCONSOLE_TARGET_ATTR_RW(remote_ip);
 NETCONSOLE_TARGET_ATTR_RO(local_mac);
 NETCONSOLE_TARGET_ATTR_RW(remote_mac);
+NETCONSOLE_TARGET_ATTR_RW(tos);
=20
 static struct configfs_attribute *netconsole_target_attrs[] =3D {
 	&netconsole_target_enabled.attr,
@@ -481,6 +508,7 @@ static struct configfs_attribute *netconsole_target=
_attrs[] =3D {
 	&netconsole_target_remote_ip.attr,
 	&netconsole_target_local_mac.attr,
 	&netconsole_target_remote_mac.attr,
+	&netconsole_target_tos.attr,
 	NULL,
 };
=20
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 5dfa091..d659c8b 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -21,6 +21,7 @@ struct netpoll {
 	__be32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	u8 remote_mac[ETH_ALEN];
+	u8 tos;
=20
 	struct list_head rx; /* rx_np list element */
 };
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 0d38808..b01ce07 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -388,7 +388,7 @@ void netpoll_send_udp(struct netpoll *np, const cha=
r *msg, int len)
=20
 	/* iph->version =3D 4; iph->ihl =3D 5; */
 	put_unaligned(0x45, (unsigned char *)iph);
-	iph->tos      =3D 0;
+	iph->tos      =3D np->tos;
 	put_unaligned(htons(ip_len), &(iph->tot_len));
 	iph->id       =3D 0;
 	iph->frag_off =3D 0;
@@ -639,6 +639,8 @@ void netpoll_print_options(struct netpoll *np)
 			 np->name, &np->remote_ip);
 	printk(KERN_INFO "%s: remote ethernet address %pM\n",
 	                 np->name, np->remote_mac);
+	printk(KERN_INFO "%s: tos value %d (0x%02x)\n",
+	                 np->name, np->tos, np->tos);
 }
 EXPORT_SYMBOL(netpoll_print_options);
=20
--=20
1.7.3.1
