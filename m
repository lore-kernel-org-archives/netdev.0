From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: Question with secure_ipv4_port_ephemeral() implementation
Date: Sun, 22 Apr 2012 14:20:53 +0900
Message-ID: <201204221420.GJB51054.OtHOFSQJFOVMFL@I-love.SAKURA.ne.jp>
References: <201204202130.IJF95312.tQJFLMFOFSVHOO@I-love.SAKURA.ne.jp>
	<1335065393.3209.361.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:52549 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab2DVFVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 01:21:40 -0400
In-Reply-To: <1335065393.3209.361.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> As I understand it, that 8-bit counter was used for all connections, so
> in order to spoof the source of a TCP connection it was only necessary
> to guess 24 bits of the ISN.  On a sufficiently fast network, it would
> now be feasible to carry out a brute force attack that ACKs all possible
> ISNs before the handshake times-out.  That's not yet feasible if the
> attacker has to guess all 32 bits of the ISN.

So, the purpose was to make the initial sequence number more random. OK.

> The original reason for periodically regenerating the secret was that
> the hash function was quite weak and the secret could presumably be
> found in a reasonably short time.  So, without regeneration, the hash
> also has to be stronger.

My concern is the purpose of making the automatic local port number selection
algorithm less random. That commit removed uptime factor from factors that
determine starting point of available local port scanning (due to removal of
periodic get_random_bytes() calls).

368 static inline u32 inet_sk_port_offset(const struct sock *sk)
369 {
370         const struct inet_sock *inet = inet_sk(sk);
371         return secure_ipv4_port_ephemeral(inet->inet_rcv_saddr,
372                                           inet->inet_daddr,
373                                           inet->inet_dport);
374 }

secure_ipv4_port_ephemeral() no longer depends on uptime.

565 int inet_hash_connect(struct inet_timewait_death_row *death_row,
566                       struct sock *sk)
567 {
568         return __inet_hash_connect(death_row, sk, inet_sk_port_offset(sk),
569                         __inet_check_established, __inet_hash_nolisten);
570 }

inet_sk_port_offset() no longer depends on uptime.
It returns same port offset for same addresses.

454 int __inet_hash_connect(struct inet_timewait_death_row *death_row,
455                 struct sock *sk, u32 port_offset,
456                 int (*check_established)(struct inet_timewait_death_row *,
457                         struct sock *, __u16, struct inet_timewait_sock **),
458                 int (*hash)(struct sock *sk, struct inet_timewait_sock *twp))
459 {
460         struct inet_hashinfo *hinfo = death_row->hashinfo;
461         const unsigned short snum = inet_sk(sk)->inet_num;
462         struct inet_bind_hashbucket *head;
463         struct inet_bind_bucket *tb;
464         int ret;
465         struct net *net = sock_net(sk);
466         int twrefcnt = 1;
467 
468         if (!snum) {
469                 int i, remaining, low, high, port;
470                 static u32 hint;
471                 u32 offset = hint + port_offset;

port_offset no longer depends on uptime.

472                 struct hlist_node *node;
473                 struct inet_timewait_sock *tw = NULL;
474 
475                 inet_get_local_port_range(&low, &high);
476                 remaining = (high - low) + 1;
477 
478                 local_bh_disable();
479                 for (i = 1; i <= remaining; i++) {
480                         port = low + (i + offset) % remaining;

That commit changed to scan available local port independent with uptime.

481                         if (inet_is_reserved_local_port(port))
482                                 continue;

I worried we unexpectedly made the automatic local port number selection
algorithm less random. If we expectedly made this algorithm less random,
I wanted to know whether there was a reason we should not depend on
uptime factor.
