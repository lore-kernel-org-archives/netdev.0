From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: provide tx timestamps for partial writes
Date: Wed, 04 Jan 2017 04:55:33 -0800
Message-ID: <1483534533.4337.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483388457-4041-1-git-send-email-soheil.kdev@gmail.com>
         <CACSApvbYBv4GTGDKFT9jg3p9_w=3WD6aQZh7qwB2HbgCCTFxog@mail.gmail.com>
         <CACSApvYN48nRSdV5OQmrS+6BqJBMRocZ1LypziOj9jk4aTc7Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36222 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936052AbdADMzo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 07:55:44 -0500
Received: by mail-pg0-f67.google.com with SMTP id n5so37119111pgh.3
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 04:55:44 -0800 (PST)
In-Reply-To: <CACSApvYN48nRSdV5OQmrS+6BqJBMRocZ1LypziOj9jk4aTc7Pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-03 at 10:22 -0500, Soheil Hassas Yeganeh wrote:
> On Mon, Jan 2, 2017 at 3:23 PM, Soheil Hassas Yeganeh <soheil@google.com> wrote:
> > On Mon, Jan 2, 2017 at 3:20 PM, Soheil Hassas Yeganeh
> > <soheil.kdev@gmail.com> wrote:
> >> From: Soheil Hassas Yeganeh <soheil@google.com>
> >>
> >> For TCP sockets, tx timestamps are only captured when the user data
> >> is successfully and fully written to the socket. In many cases,
> >> however, TCP writes can be partial for which no timestamp is
> >> collected.
> >>
> >> Collect timestamps when the user data is partially copied into
> >> the socket.
> >>
> >> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> >> Cc: Willem de Bruijn <willemb@google.com>
> >> Cc: Yuchung Cheng <ycheng@google.com>
> >> Cc: Eric Dumazet <edumazet@google.com>
> >> Cc: Neal Cardwell <ncardwell@google.com>
> >> Cc: Martin KaFai Lau <kafai@fb.com>
> >> ---
> >>  net/ipv4/tcp.c | 8 ++++++--
> >>  1 file changed, 6 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> >> index 2e3807d..c207b16 100644
> >> --- a/net/ipv4/tcp.c
> >> +++ b/net/ipv4/tcp.c
> >> @@ -992,8 +992,10 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
> >>         return copied;
> >>
> >>  do_error:
> >> -       if (copied)
> >> +       if (copied) {
> >> +               tcp_tx_timestamp(sk, sk->sk_tsflags, tcp_write_queue_tail(sk));
> >>                 goto out;
> >> +       }
> >>  out_err:
> >>         /* make sure we wake any epoll edge trigger waiter */
> >>         if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 &&
> >> @@ -1329,8 +1331,10 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> >>         }
> >>
> >>  do_error:
> >> -       if (copied + copied_syn)
> >> +       if (copied + copied_syn) {
> >> +               tcp_tx_timestamp(sk, sk->sk_tsflags, tcp_write_queue_tail(sk));
> 
> Thanks to Willem for noting that this should be sockc.tsflags and not
> sk->sk_tsflags. I'll send V2 to fix.

Also, why not factorizing a bit and have a single point calling
tcp_tx_timestamp() ?

This would ease code review quite a bit.

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4a044964da6670829e5c47fef52d2cd76360b59f..11357f3bd1f82fa29129dd3ecf4d270feb4a6b1d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -958,10 +958,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		copied += copy;
 		offset += copy;
 		size -= copy;
-		if (!size) {
-			tcp_tx_timestamp(sk, sk->sk_tsflags, skb);
+		if (!size)
 			goto out;
-		}
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
 			continue;
@@ -987,8 +985,11 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	}
 
 out:
-	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
-		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
+	if (copied) {
+		tcp_tx_timestamp(sk, sk->sk_tsflags, tcp_write_queue_tail(sk));
+		if (!(flags & MSG_SENDPAGE_NOTLAST))
+			tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
+	}
 	return copied;
 
 do_error:
@@ -1281,7 +1282,6 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 		copied += copy;
 		if (!msg_data_left(msg)) {
-			tcp_tx_timestamp(sk, sockc.tsflags, skb);
 			if (unlikely(flags & MSG_EOR))
 				TCP_SKB_CB(skb)->eor = 1;
 			goto out;
@@ -1312,8 +1312,10 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	}
 
 out:
-	if (copied)
+	if (copied) {
+		tcp_tx_timestamp(sk, sockc.tsflags, tcp_write_queue_tail(sk));
 		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
+	}
 out_nopush:
 	release_sock(sk);
 	return copied + copied_syn;
