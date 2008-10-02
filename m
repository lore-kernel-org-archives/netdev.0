From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Thu, 2 Oct 2008 21:48:45 +0200
Message-ID: <20081002194845.GB2664@ami.dom.local>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local> <48E1F417.7080304@free.fr> <20080930101030.GA6290@ff.dom.local> <20080930111733.GB6290@ff.dom.local> <48E29337.2080400@free.fr> <20080930213052.GA6449@ami.dom.local> <48E2ACDE.30406@free.fr> <20081001055828.GA10831@ff.dom.local> <1222971618.6267.26.camel@f6bvp-5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: "Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:48190 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbYJBTrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 15:47:46 -0400
Received: by ey-out-2122.google.com with SMTP id 6so425554eyi.37
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 12:47:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1222971618.6267.26.camel@f6bvp-5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2008 at 08:20:18PM +0200, Bernard, f6bvp wrote:
> Hi Jarek,
Hi Bernard,

> 
> Finally I am able to access the faulty 2.6.27-rc7 f6bvp-9 system via
> ssh.
> I can read /var/log/kernel/message file immediately after a kernel
> failure and a reboot. 
> When this is done, the system is stable until I start FPAC suite
> applications (fpad, fpacwpd ...) as shown below.
> 
> Oct  2 16:50:00 f6bvp-9 kernel: AX25_DBG: c36fc338, 00000000, 1, 0, 0
...

This looks like the output from debugging patch #1 and I'm now more
interested with #2 (which I resend below). I also append a new patch
here (let's call this #4) to netrom. So try to use 2.6.27-rc with
these patches only:

- debugging patch #2 (net/core/sock.c)
- patch #3 (drivers/net/lib8390.c)
- patch #4 (net/netrom/af_netrom.c)


> Although I did not change anything, and contrarily to my previous
> observation, the system instability as shown above occurs
> systematically.
> There was no problem with Kernel 2.6.25-10 I was using before (with
> patches for AX25 and ROSE that are now included in 2.6.27-rc7).
> I did not try 2.6.26 on this machine, thus I cannot tell if the bug was
> already present.
> Would it be worth to test 2.6.26 ?   

Yes, but only if you think you can do it safely.

> With the SSH limited access I have from my remote site, can I continue
> this debuging effort constructively, or do we wait until I am back in
> front of the local console ?

This debugging can still oops, so it depends on you. I need some warning
log from this debugging patch #2, so if you are sure this could safely
reboot to some default kernel? Otherwise I can wait, no problem. 

Cheers,
Jarek P.

--- (debugging patch #2)

 net/core/sock.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 2d358dd..3ad8eaa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -960,6 +960,15 @@ void sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
 
+	if (sk->sk_socket) {
+		printk("AX25_DBG: %p, %p, %u, %u, %u, %p\n", sk, sk->sk_socket,
+			 sk->sk_family, sk->sk_type, sk->sk_protocol, sk->sk_socket->sk);
+		if (sk->sk_family == 3 && sk->sk_type == 5 && sk->sk_protocol == 240) {
+			WARN_ON_ONCE(1);
+			sock_orphan(sk);
+		}
+	}
+
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
 

--- (patch #4)

 net/netrom/af_netrom.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 532e4fa..9f1ea4a 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -525,6 +525,7 @@ static int nr_release(struct socket *sock)
 	if (sk == NULL) return 0;
 
 	sock_hold(sk);
+	sock_orphan(sk);
 	lock_sock(sk);
 	nr = nr_sk(sk);
 
@@ -548,7 +549,6 @@ static int nr_release(struct socket *sock)
 		sk->sk_state    = TCP_CLOSE;
 		sk->sk_shutdown |= SEND_SHUTDOWN;
 		sk->sk_state_change(sk);
-		sock_orphan(sk);
 		sock_set_flag(sk, SOCK_DESTROY);
 		break;
 
