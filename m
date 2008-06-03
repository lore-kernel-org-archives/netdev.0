From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 4 Jun 2008 02:22:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu> <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1229339905-1212535336=:7315"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>, mingo@elte.hu,
	mcmanus@ducksong.com, peterz@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680AbYFCXWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:22:18 -0400
In-Reply-To: <20080603.150344.145518113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1229339905-1212535336=:7315
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 3 Jun 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 4 Jun 2008 01:01:25 +0300 (EEST)
> 
> > On Wed, 4 Jun 2008, Ilpo Järvinen wrote:
> > 
> > > ...I couldn't immediately find anything obviously wrong with those changes 
> > > but the patch below might be worth of a try (without the revert of 
> > > course). If it ever spits out that WARN_ON for you, we were playing with 
> > > fire too much and it's better to return on the safe side there...
> > 
> > 
> > > [PATCH] tcp DEFER_ACCEPT: see if header prediction got turned on
> > > 
> > > If header prediction is turned on under some circumstances,
> > > DA can deadlock though I have great trouble in figuring out
> > 
> > ...Nah, keepalive timer would then eventually kill it then, so no
> > deadlock seems possible through that one.
> 
> Keepalive is very long, it might still "seem" like a deadlock for
> someone without much patience :-)

I think we want that clearing there, it's better to be safe than sorry 
there and to not put any trust on the keepalive thingie which tears down 
rather than results in a connection.

But here's somewhat more likely explanation... Only compile tested...
It probably needs some commenting from people who understand locking 
variants & details (I don't).


-- 
 i.


--
[PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk

It seems that replacement of DA code also moved parts outside
of appropriate locking. The Ingo's problem seems to come from
the fact that two flows could now race in
(inet_csk_)reqsk_queue_add corrupting the queue. ...This can
leave dangling socks around which won't resolve themselves
without stimuli from outside (e.g., external RST would help
I think).

Then some details I'm not too sure of:
I guess we want to put listen_sk->sk_state checking under the
lock as well. I've not evaluated if ->sk_data_ready too
requires locking but assumed it does.

I'm by no means familiar with all locking variants, requirements,
etc.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c9454f0..d21d2b9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4562,6 +4562,7 @@ static int tcp_defer_accept_check(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tp->defer_tcp_accept.request) {
+		struct sock *listen_sk = tp->defer_tcp_accept.listen_sk;
 		int queued_data =  tp->rcv_nxt - tp->copied_seq;
 		int hasfin =  !skb_queue_empty(&sk->sk_receive_queue) ?
 			tcp_hdr((struct sk_buff *)
@@ -4570,8 +4571,9 @@ static int tcp_defer_accept_check(struct sock *sk)
 		if (queued_data && hasfin)
 			queued_data--;
 
-		if (queued_data &&
-		    tp->defer_tcp_accept.listen_sk->sk_state == TCP_LISTEN) {
+		bh_lock_sock(listen_sk);
+
+		if (queued_data && listen_sk->sk_state == TCP_LISTEN) {
 			if (sock_flag(sk, SOCK_KEEPOPEN)) {
 				inet_csk_reset_keepalive_timer(sk,
 							       keepalive_time_when(tp));
@@ -4579,23 +4581,24 @@ static int tcp_defer_accept_check(struct sock *sk)
 				inet_csk_delete_keepalive_timer(sk);
 			}
 
-			inet_csk_reqsk_queue_add(
-				tp->defer_tcp_accept.listen_sk,
-				tp->defer_tcp_accept.request,
-				sk);
+			inet_csk_reqsk_queue_add(listen_sk,
+						 tp->defer_tcp_accept.request,
+						 sk);
 
 			tp->defer_tcp_accept.listen_sk->sk_data_ready(
-				tp->defer_tcp_accept.listen_sk, 0);
+						listen_sk, 0);
 
-			sock_put(tp->defer_tcp_accept.listen_sk);
+			sock_put(listen_sk);
 			sock_put(sk);
 			tp->defer_tcp_accept.listen_sk = NULL;
 			tp->defer_tcp_accept.request = NULL;
-		} else if (hasfin ||
-			   tp->defer_tcp_accept.listen_sk->sk_state != TCP_LISTEN) {
+		} else if (hasfin || listen_sk->sk_state != TCP_LISTEN) {
+			bh_unlock_sock(listen_sk);
 			tcp_reset(sk);
 			return -1;
 		}
+
+		bh_unlock_sock(listen_sk);
 	}
 	return 0;
 }
-- 
1.5.2.2

---696208474-1229339905-1212535336=:7315--
