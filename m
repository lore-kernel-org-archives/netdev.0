From: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Mon, 26 May 2014 18:17:06 -0300
Message-ID: <20140526211706.GA25474@kernel.org>
References: <536101C9.9090601@gmail.com>
 <CAKgNAkgA_xTfRZhpyVwuACpCY7xMK89e0bK4PuVMG9reNV6Skw@mail.gmail.com>
 <20140512143451.GB13801@kernel.org>
 <20140521210535.GA5414@kernel.org>
 <537E0961.8040005@gmail.com>
 <20140526134647.GB8176@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?utf-8?B?T25kxZllaiBCw61sa2E=?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	Chris Friesen <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140526134647.GB8176-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Em Mon, May 26, 2014 at 10:46:47AM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Thu, May 22, 2014 at 04:27:45PM +0200, Michael Kerrisk (man-pages) escreveu:
> > Thanks! I applied this patch against 3.15-rc6.

> > recvmmsg() now (mostly) does what I expect: 
> > * it waits until either the timeout expires or vlen messages 
> >   have been received
> > * If no message is received before timeout, it returns -1/EAGAIN.
> > * If vlen messages are received before the timeout expires, then
> >   the remaining time is returned in timeout.

> > One question: in the event that the call is interrupted by a signal 
> > handler, it fails (as expected) with EINTR, but the 'timeout' value is 
> > not updated with the remaining time on the timer. Would it be desirable 
> > to emulate the behavior of select() (and other syscalls) in this 
> > respect, and instead return the remaining time if interrupted by 
> > a signal?
 
> I think so, will check how to achieve that!

Can you try the attached patch on top of the first one?

It starts adding explicit parentheses on a ternary, as David requested,
and then should return the remaining timeouts in cases like signals,
etc.

Please let me know if this is enough.

- Arnaldo

P.S. compile testing while sending this message :-)

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="recvmsg-return-timeout-harder.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index aef3d7f9c3fa..c48f61c79801 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2106,7 +2106,7 @@ static inline long sock_rcvtimeo(const struct sock *sk, bool noblock)
 
 static inline long sock_rcvtimeop(const struct sock *sk, long *timeop, bool noblock)
 {
-	return noblock ? 0 : timeop ? *timeop : sk->sk_rcvtimeo;
+	return noblock ? 0 : (timeop ? *timeop : sk->sk_rcvtimeo);
 }
 
 static inline long sock_sndtimeo(const struct sock *sk, bool noblock)
diff --git a/net/core/datagram.c b/net/core/datagram.c
index a08c4c9dcd23..0dd1715374fa 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -224,12 +224,14 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 			goto no_packet;
 
 	} while (!wait_for_more_packets(sk, err, &timeo, last));
-
+out:
+	if (timeop)
+		*timeop = timeo;
 	return NULL;
 
 no_packet:
 	*err = error;
-	return NULL;
+	goto out;
 }
 EXPORT_SYMBOL(__skb_recv_datagram);
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index feaacaa0c970..0991da69f39d 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1480,8 +1480,10 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 
 			finish_wait(sk_sleep(sk), &wait);
 
-			if (err)
-				return err;
+			if (err) {
+				copied = err;
+				break;
+			}
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index e8b8bb3d50ab..e9082ed598cd 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -78,7 +78,8 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 				release_sock(&rx->sk);
 				if (continue_call)
 					rxrpc_put_call(continue_call);
-				return -ENODATA;
+				copied = -ENODATA;
+				goto out_copied;
 			}
 		}
 
@@ -135,7 +136,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 				release_sock(&rx->sk);
 				rxrpc_put_call(continue_call);
 				_leave(" = %d [noncont]", copied);
-				return copied;
+				goto out_copied;
 			}
 		}
 
@@ -251,9 +252,10 @@ out:
 		rxrpc_put_call(call);
 	if (continue_call)
 		rxrpc_put_call(continue_call);
+	_leave(" = %d [data]", copied);
+out_copied:
 	if (timeop)
 		*timeop = timeo;
-	_leave(" = %d [data]", copied);
 	return copied;
 
 	/* handle non-DATA messages such as aborts, incoming connections and
@@ -330,7 +332,8 @@ terminal_message:
 	if (continue_call)
 		rxrpc_put_call(continue_call);
 	_leave(" = %d", ret);
-	return ret;
+	copied = ret;
+	goto out_copied;
 
 copy_error:
 	_debug("copy error");
@@ -339,7 +342,8 @@ copy_error:
 	if (continue_call)
 		rxrpc_put_call(continue_call);
 	_leave(" = %d", ret);
-	return ret;
+	copied = ret;
+	goto out_copied;
 
 wait_interrupted:
 	ret = sock_intr_errno(timeo);
@@ -350,8 +354,7 @@ wait_error:
 	if (copied)
 		copied = ret;
 	_leave(" = %d [waitfail %d]", copied, ret);
-	return copied;
-
+	goto out_copied;
 }
 
 /**
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d5d3f9b42bca..d05161a168bc 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6548,11 +6548,8 @@ static struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
 			skb = skb_dequeue(&sk->sk_receive_queue);
 		}
 
-		if (skb) {
-			if (timeop)
-				*timeop = timeo;
-			return skb;
-		}
+		if (skb)
+			break;
 
 		/* Caller is allowed not to check sk->sk_err before calling. */
 		error = sock_error(sk);
@@ -6572,11 +6569,15 @@ static struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
 			goto no_packet;
 	} while (sctp_wait_for_packet(sk, err, &timeo) == 0);
 
-	return NULL;
+out:
+	if (timeop)
+		*timeop = timeo;
+
+	return skb;
 
 no_packet:
 	*err = error;
-	return NULL;
+	goto out;
 }
 
 /* If sndbuf has changed, wake up per association sndbuf waiters.  */
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 721904c37359..3203defdb503 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1926,7 +1926,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int check_creds = 0;
 	int target;
 	int err = 0;
-	long timeo;
+	long timeo = sock_rcvtimeop(sk, timeop, noblock);
 	int skip;
 
 	err = -EINVAL;
@@ -1938,7 +1938,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 
 	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
-	timeo = sock_rcvtimeop(sk, timeop, noblock);
 
 	/* Lock the socket to prevent queue disordering
 	 * while sleeps in memcpy_tomsg
@@ -2070,9 +2069,9 @@ again:
 
 	mutex_unlock(&u->readlock);
 	scm_recv(sock, msg, siocb->scm, flags);
+out:
 	if (timeop)
 		*timeop = timeo;
-out:
 	return copied ? : err;
 }
 
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 2e784d976133..73957d47dac7 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1653,7 +1653,7 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 	int err;
 	size_t target;
 	ssize_t copied;
-	long timeout;
+	long timeout = sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
 	struct vsock_transport_recv_notify_data recv_data;
 
 	DEFINE_WAIT(wait);
@@ -1711,7 +1711,6 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 		err = -ENOMEM;
 		goto out;
 	}
-	timeout = sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
 	copied = 0;
 
 	err = transport->notify_recv_init(vsk, target, &recv_data);
@@ -1820,9 +1819,9 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 
 out_wait:
 	finish_wait(sk_sleep(sk), &wait);
+out:
 	if (timeop)
 		*timeop = timeout;
-out:
 	release_sock(sk);
 	return err;
 }

--LZvS9be/3tNcYl/X--
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
