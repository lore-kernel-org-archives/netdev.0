From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: tun: Move tun check into the block of TUNSETIFF condition check
Date: Tue, 25 Oct 2016 22:26:09 +0800
Message-ID: <1477405569-17684-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, jasowang@redhat.com, edumazet@google.com,
        pabeni@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg342.qq.com ([14.17.44.37]:40226 "EHLO smtpbg342.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753338AbcJYO1c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 10:27:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When cmd is TUNSETIFF and tun is not null, the original codes go ahead,
then reach the default case of switch(cmd) and set the ret is -EINVAL.
It is not clear for readers.

Now move the tun check into the block of TUNSETIFF condition check, and
return -EEXIST instead of -EINVAL when the tfile already owns one tun.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/tun.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9328568..9142db8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2005,7 +2005,11 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	rtnl_lock();
 
 	tun = __tun_get(tfile);
-	if (cmd == TUNSETIFF && !tun) {
+	if (cmd == TUNSETIFF) {
+		ret = -EEXIST;
+		if (tun)
+			goto unlock;
+
 		ifr.ifr_name[IFNAMSIZ-1] = '\0';
 
 		ret = tun_set_iff(sock_net(&tfile->sk), file, &ifr);
-- 
1.9.1
