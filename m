From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: set SPLICE_F_NONBLOCK after first buffer has been
 spliced
Date: Thu, 05 Nov 2009 11:30:01 +0100
Message-ID: <4AF2A929.3000201@gmail.com>
References: <20091105095947.32131.99768.stgit@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jens.axboe@oracle.com,
	max@duempel.org, Linux Netdev List <netdev@vger.kernel.org>
To: Max Kellermann <mk@cm4all.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753409AbZKEKac@vger.kernel.org>
In-Reply-To: <20091105095947.32131.99768.stgit@rabbit.intern.cm-ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Max Kellermann a =C3=A9crit :
> When splicing a large amount of bytes from a TCP socket to a pipe
> (more than PIPE_BUFFERS), splice() can block, even though the pipe wa=
s
> empty.  The correct behavior would be to copy as much as possible, an=
d
> return without blocking.  Block only if nothing can be transferred.
> When the destination pipe is (initially) writable, splice() should do
> the same with or without SPLICE_F_NONBLOCK.
>=20
> The cause is the loop in tcp_splice_read(): it calls
> __tcp_splice_read() (and thus skb_splice_bits() and splice_to_pipe())
> again and again, until the requested number of bytes has been
> transferred, or an error occurs.  In the first iteration, up to 64 kB
> is copied, and the second iteration will block, because
> splice_to_pipe() is called again and sees the pipe is already full.
>=20
> This patch adds SPLICE_F_NONBLOCK to the splice flags after the first
> iteration has finished successfully.  This prevents the second
> splice_to_pipe() call from blocking.  The resulting EAGAIN error is
> handled gracefully, and tcp_splice_read() returns the number of bytes
> successfully moved.
> ---
>=20
>  net/ipv4/tcp.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 9114524..0f8b01f 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -628,6 +628,11 @@ ssize_t tcp_splice_read(struct socket *sock, lof=
f_t *ppos,
>  		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
>  		    signal_pending(current))
>  			break;
> +
> +		/* the following splice_to_pipe() calls should not
> +		   block, because we have already successfully
> +		   transferred at least one buffer */
> +		tss.flags |=3D SPLICE_F_NONBLOCK;
>  	}
> =20
>  	release_sock(sk);
>=20

CC netdev

I dont think this patch is correct. Could you describe your use case ?

If you dont want to block on output pipe, you should set this NONBLOCK=20
flag before calling splice(SPLICE_F_NONBLOCK) syscall.

ie : Use the socket in blocking mode, but output pipe in non-blocking m=
ode.

Some application could have a thread working in full blocking mode, and=
 have another
thread reading the pipe (and eventually unblocking first thread)

Thanks
