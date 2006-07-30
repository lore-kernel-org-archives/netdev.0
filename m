From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] fix memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Sun, 30 Jul 2006 21:38:02 +0200
Message-ID: <200607302138.02855.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:8694 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932461AbWG3Tg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 15:36:56 -0400
Received: by nf-out-0910.google.com with SMTP id o25so315843nfa
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2006 12:36:55 -0700 (PDT)
To: linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Pekka Savola <pekkas@netcore.fi>,
	Patrick McHardy <kaber@coreworks.de>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's an obvious memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
We are not freeing 'tbuf' on error.
Patch below fixes that.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 net/ipv4/tcp_probe.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

--- linux-2.6.18-rc3-orig/net/ipv4/tcp_probe.c	2006-07-30 13:21:53.000000000 +0200
+++ linux-2.6.18-rc3/net/ipv4/tcp_probe.c	2006-07-30 21:32:04.000000000 +0200
@@ -129,8 +129,10 @@ static ssize_t tcpprobe_read(struct file
 
 	error = wait_event_interruptible(tcpw.wait,
 					 __kfifo_len(tcpw.fifo) != 0);
-	if (error)
+	if (error) {
+		vfree(tbuf);
 		return error;
+	}
 
 	cnt = kfifo_get(tcpw.fifo, tbuf, len);
 	error = copy_to_user(buf, tbuf, cnt);



