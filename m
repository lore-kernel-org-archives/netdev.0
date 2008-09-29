From: Jarek Poplawski <jarkao2@gmail.com>
Subject: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Mon, 29 Sep 2008 12:30:36 +0000
Message-ID: <20080929123036.GA16954@ff.dom.local>
References: <48DF7D51.1010507@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:52999 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbYI2Map (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 08:30:45 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1417400fgg.17
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2008 05:30:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48DF7D51.1010507@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2008 at 02:49:21PM +0200, Bernard Pidoux F6BVP wrote:
> Hi,
>
> Here is another report catched via netconsole.
> Kernel is linux-2.6.27-rc7
> kernel panic occurs within less than a minute after boot.
>
>
> ------------------------------
> dim sep 28 14:38:59 CEST 2008
> ------------------------------
> BUG: unable to handle kernel paging request at 6b6b6b73
> IP: [<c0254689>] datagram_poll+0xd9/0xf0
> *pde = 00000000
> Oops: 0002 [#1]

Looks like some socket is used after kfree. Is it vanilla kernel?
I think ax25/rose folks should rather be Cc-ed... Anyway, below
is my poor try to get more debugging.

Cheers,
Jarek P.

---

 net/core/datagram.c |    1 +
 net/core/sock.c     |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 52f577a..ab3d3dc 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -635,6 +635,7 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 			return mask;
 	}
 
+	BUG_ON((long) sk->sk_socket == 0x6b6b6b6b);
 	/* writable? */
 	if (sock_writeable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
diff --git a/net/core/sock.c b/net/core/sock.c
index 2d358dd..bf5465b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -960,6 +960,8 @@ void sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
 
+	printk("AX25_DBG: %p, %p, %u, %u, %u\n", sk, sk->sk_socket,
+				 sk->sk_family, sk->sk_type, sk->sk_protocol);
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
 
