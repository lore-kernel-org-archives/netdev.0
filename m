From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] fix memory leak in
 net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Thu, 10 Aug 2006 16:52:16 -0700
Message-ID: <20060810165216.103c6940@localhost.localdomain>
References: <9a8748490608041630t5e667bf5k3a50dcf148187e6c@mail.gmail.com>
	<20060804.165931.48505912.davem@davemloft.net>
	<9a8748490608101518s38c6e6a3r9d8599ca3c106ef3@mail.gmail.com>
	<20060810.163612.71164812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25836 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932335AbWHJXxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 19:53:17 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060810.163612.71164812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, here is my version...
Don't leak memory on interrupted read. And only allocate
as much memory as needed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.orig/net/ipv4/tcp_probe.c	2006-08-10 16:32:36.000000000 -0700
+++ linux-2.6/net/ipv4/tcp_probe.c	2006-08-10 16:45:30.000000000 -0700
@@ -114,7 +114,7 @@
 static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 			     size_t len, loff_t *ppos)
 {
-	int error = 0, cnt = 0;
+	int error, cnt;
 	unsigned char *tbuf;
 
 	if (!buf || len < 0)
@@ -123,15 +123,16 @@
 	if (len == 0)
 		return 0;
 
-	tbuf = vmalloc(len);
-	if (!tbuf)
-		return -ENOMEM;
-
 	error = wait_event_interruptible(tcpw.wait,
 					 __kfifo_len(tcpw.fifo) != 0);
 	if (error)
 		return error;
 
+	len = min(len, kfifo_len(tcpw.fifo));
+	tbuf = vmalloc(len);
+	if (!tbuf)
+		return -ENOMEM;
+
 	cnt = kfifo_get(tcpw.fifo, tbuf, len);
 	error = copy_to_user(buf, tbuf, cnt);
 
