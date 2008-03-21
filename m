From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][DLCI]: Fix tiny race between module unload and sock_ioctl.
Date: Fri, 21 Mar 2008 19:00:49 +0300
Message-ID: <47E3DBB1.4090706@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mike McLagan <mike.mclagan@linux.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47366 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbYCUQBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 12:01:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a narrow pedantry :) but the dlci_ioctl_hook check and call
should not be parted with the mutex lock.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/socket.c b/net/socket.c
index b6d35cd..9d3fbfb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -909,11 +909,10 @@ static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 			if (!dlci_ioctl_hook)
 				request_module("dlci");
 
-			if (dlci_ioctl_hook) {
-				mutex_lock(&dlci_ioctl_mutex);
+			mutex_lock(&dlci_ioctl_mutex);
+			if (dlci_ioctl_hook)
 				err = dlci_ioctl_hook(cmd, argp);
-				mutex_unlock(&dlci_ioctl_mutex);
-			}
+			mutex_unlock(&dlci_ioctl_mutex);
 			break;
 		default:
 			err = sock->ops->ioctl(sock, cmd, arg);
