From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: PROBLEM: tun/tap crashes if open() /dev/net/tun and then poll()
 it.
Date: Mon, 6 Jul 2009 07:48:35 +0200
Message-ID: <20090706074835.3fe641f0@mako-desktop>
References: <4A4F1480.70203@gmail.com>
	<20090706001114.2d4517be@mako-desktop>
	<20090706011230.GC15156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eugene Kapun <abacabadabacaba@gmail.com>, maxk@qualcomm.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20090706011230.GC15156@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Jul 2009 09:12:30 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Jul 06, 2009 at 12:11:14AM +0200, Mariusz Kozlowski wrote:
> >
> > 	Can you try this patch?
... 
> Good catch.  Can you please resend with a sign-off?

Sure. Just wanted to wait for confirmation from Eugene.

Fix NULL pointer dereference in tun_chr_pool() introduced by
commit 33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554 and triggered
by this code:

	int fd;
	struct pollfd pfd;
	fd = open("/dev/net/tun", O_RDWR);
	pfd.fd = fd;
	pfd.events = POLLIN | POLLOUT;
	poll(&pfd, 1, 0);

Reported-by: Eugene Kapun <abacabadabacaba@gmail.com>
Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a1b0697..bcbb25e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -482,12 +482,14 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 {
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun = __tun_get(tfile);
-	struct sock *sk = tun->sk;
+	struct sock *sk;
 	unsigned int mask = 0;
 
 	if (!tun)
 		return POLLERR;
 
+	sk = tun->sk;
+
 	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
 	poll_wait(file, &tfile->read_wait, wait);

