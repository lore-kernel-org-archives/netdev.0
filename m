From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next] tun: delete original tun_get() and rename __tun_get() to tun_get()
Date: Sat, 23 Sep 2017 22:36:52 +0800
Message-ID: <1506177412-20280-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:53818 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750766AbdIWOh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 23 Sep 2017 10:37:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

it seems no need to keep tun_get() and __tun_get() at same time.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/net/tun.c | 26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3c9985f..206bc6c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -692,7 +692,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 	return err;
 }
 
-static struct tun_struct *__tun_get(struct tun_file *tfile)
+static struct tun_struct *tun_get(struct tun_file *tfile)
 {
 	struct tun_struct *tun;
 
@@ -705,11 +705,6 @@ static struct tun_struct *__tun_get(struct tun_file *tfile)
 	return tun;
 }
 
-static struct tun_struct *tun_get(struct file *file)
-{
-	return __tun_get(file->private_data);
-}
-
 static void tun_put(struct tun_struct *tun)
 {
 	dev_put(tun->dev);
@@ -1149,7 +1144,7 @@ static void tun_net_init(struct net_device *dev)
 static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
 {
 	struct tun_file *tfile = file->private_data;
-	struct tun_struct *tun = __tun_get(tfile);
+	struct tun_struct *tun = tun_get(tfile);
 	struct sock *sk;
 	unsigned int mask = 0;
 
@@ -1569,8 +1564,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 static ssize_t tun_chr_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct file *file = iocb->ki_filp;
-	struct tun_struct *tun = tun_get(file);
 	struct tun_file *tfile = file->private_data;
+	struct tun_struct *tun = tun_get(tfile);
 	ssize_t result;
 
 	if (!tun)
@@ -1754,7 +1749,7 @@ static ssize_t tun_chr_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct file *file = iocb->ki_filp;
 	struct tun_file *tfile = file->private_data;
-	struct tun_struct *tun = __tun_get(tfile);
+	struct tun_struct *tun = tun_get(tfile);
 	ssize_t len = iov_iter_count(to), ret;
 
 	if (!tun)
@@ -1831,7 +1826,7 @@ static int tun_sendmsg(struct socket *sock, struct msghdr *m, size_t total_len)
 {
 	int ret;
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
-	struct tun_struct *tun = __tun_get(tfile);
+	struct tun_struct *tun = tun_get(tfile);
 
 	if (!tun)
 		return -EBADFD;
@@ -1847,7 +1842,7 @@ static int tun_recvmsg(struct socket *sock, struct msghdr *m, size_t total_len,
 		       int flags)
 {
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
-	struct tun_struct *tun = __tun_get(tfile);
+	struct tun_struct *tun = tun_get(tfile);
 	int ret;
 
 	if (!tun)
@@ -1879,7 +1874,7 @@ static int tun_peek_len(struct socket *sock)
 	struct tun_struct *tun;
 	int ret = 0;
 
-	tun = __tun_get(tfile);
+	tun = tun_get(tfile);
 	if (!tun)
 		return 0;
 
@@ -2265,7 +2260,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	ret = 0;
 	rtnl_lock();
 
-	tun = __tun_get(tfile);
+	tun = tun_get(tfile);
 	if (cmd == TUNSETIFF) {
 		ret = -EEXIST;
 		if (tun)
@@ -2612,15 +2607,16 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 }
 
 #ifdef CONFIG_PROC_FS
-static void tun_chr_show_fdinfo(struct seq_file *m, struct file *f)
+static void tun_chr_show_fdinfo(struct seq_file *m, struct file *file)
 {
+	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
 	struct ifreq ifr;
 
 	memset(&ifr, 0, sizeof(ifr));
 
 	rtnl_lock();
-	tun = tun_get(f);
+	tun = tun_get(tfile);
 	if (tun)
 		tun_get_iff(current->nsproxy->net_ns, tun, &ifr);
 	rtnl_unlock();
-- 
2.7.4
