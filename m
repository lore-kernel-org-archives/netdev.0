From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: add SO_MAX_DGRAM_QLEN for AF_UNIX SOCK_DGRAM
 sockets
Date: Tue, 03 Mar 2015 06:30:19 -0800
Message-ID: <1425393019.5130.181.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425342774-32667-1-git-send-email-christian@iwakd.de>
	 <20150302.213807.367185406305242762.davem@davemloft.net>
	 <0b5908020d83bcbaa7f4938e5cb433ea@iwakd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dan-+z8lB9qDZjnk1uMJSBkQmQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Seiler <christian-+GPkE3DhqnY@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0b5908020d83bcbaa7f4938e5cb433ea-+GPkE3DhqnY@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 10:04 +0100, Christian Seiler wrote:

> Also note that if I have a stream socket, by default I can buffer up to
> 256 kiB of data in the kernel. I did some test measurements on x86_64
> and including overhead of internal bookkeeping structures, I can fit up
> to 555 datagrams in there if each is at most 192 bytes long, at least
> 333 datagrams if each is at most 704 bytes long and at least 185
> datagrams if each is at most 1728 bytes long. If I compare these
> numbers to 11, that's an order of magnitude in difference.

Problem about AF_UNIX socket is file descriptor passing.

Increasing the 10 limit allows attackers to OOM host faster I guess.

You could extend the limit if we were sure queued messages were without
passed fds.

Then, we could either increase sysctl_max_dgram_qlen or do something
like :

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 526b6edab018..a608317e7dd4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -643,7 +643,9 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 				&af_unix_sk_receive_queue_lock_key);
 
 	sk->sk_write_space	= unix_write_space;
-	sk->sk_max_ack_backlog	= net->unx.sysctl_max_dgram_qlen;
+	sk->sk_max_ack_backlog	= max_t(u32,
+					net->unx.sysctl_max_dgram_qlen,
+					sk->sk_rcvbuf / SKB_TRUESIZE(256));
 	sk->sk_destruct		= unix_sock_destructor;
 	u	  = unix_sk(sk);
 	u->path.dentry = NULL;
