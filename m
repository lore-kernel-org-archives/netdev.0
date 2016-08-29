From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] kcm: fix a socket double free
Date: Sun, 28 Aug 2016 21:28:26 -0700
Message-ID: <1472444906-9566-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33131 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbcH2Eam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 00:30:42 -0400
Received: by mail-pf0-f195.google.com with SMTP id i6so8575051pfe.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 21:30:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry reported a double free on kcm socket, which could
be easily reproduced by:

	#include <unistd.h>
	#include <sys/syscall.h>

	int main()
	{
	  int fd = syscall(SYS_socket, 0x29ul, 0x5ul, 0x0ul, 0, 0, 0);
	  syscall(SYS_ioctl, fd, 0x89e2ul, 0x20a98000ul, 0, 0, 0);
	  return 0;
	}

This is because on the error path, after we install
the new socket file, we call sock_release() to clean
up the socket, which leaves the fd pointing to a freed
socket. Fix this by calling sys_close() on that fd
directly.

Fixes: ab7ac4eb9832 ("kcm: Kernel Connection Multiplexor module")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/kcm/kcmsock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index cb39e05..4116932 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -13,6 +13,7 @@
 #include <linux/socket.h>
 #include <linux/uaccess.h>
 #include <linux/workqueue.h>
+#include <linux/syscalls.h>
 #include <net/kcm.h>
 #include <net/netns/generic.h>
 #include <net/sock.h>
@@ -2029,7 +2030,7 @@ static int kcm_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			if (copy_to_user((void __user *)arg, &info,
 					 sizeof(info))) {
 				err = -EFAULT;
-				sock_release(newsock);
+				sys_close(info.fd);
 			}
 		}
 
-- 
1.8.4.5
