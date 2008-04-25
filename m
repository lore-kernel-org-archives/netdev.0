From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NET]: Fix wrong interpretation of some copy_to_user() results.
Date: Fri, 25 Apr 2008 12:41:55 +0400
Message-ID: <48119953.6060808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33799 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbYDYIop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 04:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found some places, that erroneously return the value obtained from
the copy_to_user() call: if some amount of bytes were not able to get
to the user (this is what this one returns) the proper behavior is to
return the -EFAULT error, not that number itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/can/raw.c b/net/can/raw.c
index ead50c7..201cbfc 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -573,7 +573,8 @@ static int raw_getsockopt(struct socket *sock, int level, int optname,
 			int fsize = ro->count * sizeof(struct can_filter);
 			if (len > fsize)
 				len = fsize;
-			err = copy_to_user(optval, ro->filter, len);
+			if (copy_to_user(optval, ro->filter, len))
+				err = -EFAULT;
 		} else
 			len = 0;
 		release_sock(sk);
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 6e1df62..0bcdc92 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -140,7 +140,7 @@ static ssize_t dccpprobe_read(struct file *file, char __user *buf,
 		goto out_free;
 
 	cnt = kfifo_get(dccpw.fifo, tbuf, len);
-	error = copy_to_user(buf, tbuf, cnt);
+	error = copy_to_user(buf, tbuf, cnt) ? -EFAULT : 0;
 
 out_free:
 	vfree(tbuf);
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 1c50959..82a09aa 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -200,9 +200,10 @@ static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 		if (width >= len)
 			break;
 
-		error = copy_to_user(buf + cnt, tbuf, width);
-		if (error)
+		if (copy_to_user(buf + cnt, tbuf, width)) {
+			error = -EFAULT;
 			break;
+		}
 		cnt += width;
 	}
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 0585315..230f9ca 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1756,8 +1756,8 @@ static int getsockopt(struct socket *sock,
 	else if (len < sizeof(value)) {
 		res = -EINVAL;
 	}
-	else if ((res = copy_to_user(ov, &value, sizeof(value)))) {
-		/* couldn't return value */
+	else if (copy_to_user(ov, &value, sizeof(value))) {
+		res = -EFAULT;
 	}
 	else {
 		res = put_user(sizeof(value), ol);
