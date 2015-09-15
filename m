From: Mathias Krause <minipli@googlemail.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Tue, 15 Sep 2015 20:15:40 +0200
Message-ID: <20150915181540.GA14826@jig.fritz.box>
References: <20150913195354.GA12352@jig.fritz.box>
 <878u87ipc6.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <878u87ipc6.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 15, 2015 at 06:07:05PM +0100, Rainer Weikusat wrote:
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
>  <at>  <at>  -2233,10 +2233,14  <at>  <at>  static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  	writable = unix_writable(sk);
>  	other = unix_peer_get(sk);
>  	if (other) {
> -		if (unix_peer(other) != sk) {
> +		unix_state_lock(other);
> +		if (!sock_flag(other, SOCK_DEAD) && unix_peer(other) != sk) {
> +			unix_state_unlock(other);
>  			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
>  			if (unix_recvq_full(other))
>  				writable = 0;
> +		} else {
> +			unix_state_unlock(other);
>  		}
>  		sock_put(other);
>  	}
> 
> That's obviously not going to help you when 'racing with
> unix_release_sock' as the socket might be released immediately after the
> unix_state_unlock, ie, before sock_poll_wait is called. Provided I
> understand this correctly, the problem is that the socket reference
> count may have become 1 by the time sock_put is called but the
> sock_poll_wait has created a new reference to it which isn't accounted
> for.
> 
> A simple way to fix that could be to do something like
> 
> unix_state_lock(other);
> if (!sock_flag(other, SOCK_DEAD)) sock_poll_wait(...)
> unix_state_unlock(other);

Sorry, but that does not fix the bug. I get the same GPF as before.

> This would imply that unix_release_sock either marked the socket as dead
> before the sock_poll_wait was executed or that the wake_up_interruptible
> call in there will run after ->peer_wait was used (and it will thus
> 'unpollwait' it again).

It must be something else as I also tried the following patch, which
moves the wake_up_interruptible_all() call into the locked code section:

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d359f6a..58570a7680ce 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -360,10 +360,12 @@ static void unix_dgram_disconnected(struct sock *sk, struct sock *other)
 		 * we signal error. Messages are lost. Do not make this,
 		 * when peer was not connected to us.
 		 */
+		unix_state_lock(other);
 		if (!sock_flag(other, SOCK_DEAD) && unix_peer(other) == sk) {
 			other->sk_err = ECONNRESET;
 			other->sk_error_report(other);
 		}
+		unix_state_unlock(other);
 	}
 }
 
@@ -413,11 +415,13 @@ static void unix_release_sock(struct sock *sk, int embrion)
 	u->path.mnt = NULL;
 	state = sk->sk_state;
 	sk->sk_state = TCP_CLOSE;
-	unix_state_unlock(sk);
-
-	wake_up_interruptible_all(&u->peer_wait);
 
 	skpair = unix_peer(sk);
+	unix_peer(sk) = NULL;
+
+	wake_up_interruptible_all(&u->peer_wait);
+
+	unix_state_unlock(sk);
 
 	if (skpair != NULL) {
 		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
@@ -431,7 +435,6 @@ static void unix_release_sock(struct sock *sk, int embrion)
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
 		}
 		sock_put(skpair); /* It may now die */
-		unix_peer(sk) = NULL;
 	}
 
 	/* Try to flush out this socket. Throw out buffers at least */
@@ -2440,10 +2443,18 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
 	if (other) {
-		if (unix_peer(other) != sk) {
+		unix_state_lock(other);
+
+		if (sock_flag(other, SOCK_DEAD) || (other->sk_shutdown & RCV_SHUTDOWN)) {
+			unix_state_unlock(other);
+			writable = 0;
+		} else if (unix_peer(other) != sk) {
 			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
+			unix_state_unlock(other);
 			if (unix_recvq_full(other))
 				writable = 0;
+		} else {
+			unix_state_unlock(other);
 		}
 		sock_put(other);
 	}
