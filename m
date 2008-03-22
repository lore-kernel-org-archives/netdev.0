From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Sat, 22 Mar 2008 12:36:20 +0100
Message-ID: <20080322113620.GA3213@ami.dom.local>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:57832 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247AbYCVLcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 07:32:43 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1792014ugc.16
        for <netdev@vger.kernel.org>; Sat, 22 Mar 2008 04:32:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47E2EC1B.9070405@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2008 at 11:58:35PM +0100, Bernard Pidoux wrote:
...
> BUG: spinlock bad magic on CPU#0, swapper/0
> BUG: unable to handle kernel paging request at virtual address 6b6b6c2f
> printing eip: c01e730b *pde = 00000000
> Oops: 0000 [#1] SMP
...
> Pid: 0, comm: swapper Not tainted (2.6.24.3 #8)
> EIP: 0060:[<c01e730b>] EFLAGS: 00010002 CPU: 0
> EIP is at spin_bug+0xdb/0xf0
...

Hi,

Bernard, could you try this debugging patch?

Thanks,
Jarek P.

---

diff -Nurp 2.6.24.3-/net/core/sock.c 2.6.24.3+/net/core/sock.c
--- 2.6.24.3-/net/core/sock.c	2008-01-24 23:58:37.000000000 +0100
+++ 2.6.24.3+/net/core/sock.c	2008-03-22 12:10:10.000000000 +0100
@@ -1517,14 +1517,21 @@ static void sock_def_write_space(struct 
 	 * progress.  --DaveM
 	 */
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
-		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
+			if (!sk->sk_socket || sk->sk_socket->sk != sk) {
+				WARN_ON_ONCE(1);
+				sk->sk_socket = NULL;
+				sk->sk_sleep = NULL;
+				goto out;
+			}
 			wake_up_interruptible(sk->sk_sleep);
+		}
 
 		/* Should agree with poll, otherwise some programs break */
 		if (sock_writeable(sk))
 			sk_wake_async(sk, 2, POLL_OUT);
 	}
-
+out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
