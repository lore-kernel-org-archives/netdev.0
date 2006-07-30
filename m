From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] fix memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Sun, 30 Jul 2006 17:48:23 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607301747170.26424@d.namei>
References: <200607302138.02855.jesper.juhl@gmail.com>
 <20060730142922.7c1d4f7d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Juhl <jesper.juhl@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Pekka Savola <pekkas@netcore.fi>,
	Patrick McHardy <kaber@coreworks.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:38880 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932408AbWG3Vs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 17:48:27 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060730142922.7c1d4f7d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 30 Jul 2006, Stephen Hemminger wrote:

> On Sun, 30 Jul 2006 21:38:02 +0200
> Jesper Juhl <jesper.juhl@gmail.com> wrote:
> 
> > There's an obvious memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
> > We are not freeing 'tbuf' on error.
> > Patch below fixes that.
> > 
> > 
> > Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> Agreed, thanks for catching it.  The whole kfifo interface is kind of
> annoying have to do an extra copy.

Might be cleaner to make a single return path for cleanup:

Signed-off-by: James Morris <jmorris@namei.org>

---


--- linux-2.6.18-rc2-mm1.o/net/ipv4/tcp_probe.c	2006-07-28 11:01:46.000000000 -0400
+++ linux-2.6.18-rc2-mm1.w/net/ipv4/tcp_probe.c	2006-07-30 17:45:53.000000000 -0400
@@ -130,11 +130,12 @@ static ssize_t tcpprobe_read(struct file
 	error = wait_event_interruptible(tcpw.wait,
 					 __kfifo_len(tcpw.fifo) != 0);
 	if (error)
-		return error;
+		goto out_free;
 
 	cnt = kfifo_get(tcpw.fifo, tbuf, len);
 	error = copy_to_user(buf, tbuf, cnt);
 
+out_free:
 	vfree(tbuf);
 
 	return error ? error : cnt;
