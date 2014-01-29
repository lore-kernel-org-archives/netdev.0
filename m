From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v3] tun: add device name(iff) field to proc fdinfo entry
Date: Wed, 29 Jan 2014 16:43:31 +0900
Message-ID: <1390981411-16146-1-git-send-email-yamato@redhat.com>
References: <20140128.231947.1827551289841225189.davem@davemloft.net>
Cc: netdev@vger.kernel.org, yamato@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbaA2Hnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 02:43:39 -0500
In-Reply-To: <20140128.231947.1827551289841225189.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A file descriptor opened for /dev/net/tun and a tun device are
connected with ioctl.  Though understanding the connection is
important for trouble shooting, no way is given to a user to know
the connected device for a given file descriptor at userland.

This patch adds a new fdinfo field for the device name connected to
a file descriptor opened for /dev/net/tun.

Here is an example of the field:

    # lsof | grep tun
    qemu-syst 4565         qemu   25u      CHR             10,200       0t138      12921 /dev/net/tun
    ...

    # cat /proc/4565/fdinfo/25
    pos:	138
    flags:	0104002
    iff:	vnet0

    # ip link show dev vnet0
    8: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...

changelog:

    v2: indent iff just like the other fdinfo fields are.
    v3: remove unused variable.
        Both are suggested by David Miller <davem@davemloft.net>.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 drivers/net/tun.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bcf01af..44c4db8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -69,6 +69,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
+#include <linux/seq_file.h>
 
 #include <asm/uaccess.h>
 
@@ -2228,6 +2229,27 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 	return 0;
 }
 
+#ifdef CONFIG_PROC_FS
+static int tun_chr_show_fdinfo(struct seq_file *m, struct file *f)
+{
+	struct tun_struct *tun;
+	struct ifreq ifr;
+
+	memset(&ifr, 0, sizeof(ifr));
+
+	rtnl_lock();
+	tun = tun_get(f);
+	if (tun)
+		tun_get_iff(current->nsproxy->net_ns, tun, &ifr);
+	rtnl_unlock();
+
+	if (tun)
+		tun_put(tun);
+
+	return seq_printf(m, "iff:\t%s\n", ifr.ifr_name);
+}
+#endif
+
 static const struct file_operations tun_fops = {
 	.owner	= THIS_MODULE,
 	.llseek = no_llseek,
@@ -2242,7 +2264,10 @@ static const struct file_operations tun_fops = {
 #endif
 	.open	= tun_chr_open,
 	.release = tun_chr_close,
-	.fasync = tun_chr_fasync
+	.fasync = tun_chr_fasync,
+#ifdef CONFIG_PROC_FS
+	.show_fdinfo = tun_chr_show_fdinfo,
+#endif
 };
 
 static struct miscdevice tun_miscdev = {
-- 
1.8.5.3
