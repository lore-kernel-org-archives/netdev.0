From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 6/7] [PATCH] af_iucv: do not call iucv_sock_kill() twice
Date: Wed, 16 Sep 2009 16:37:27 +0200
Message-ID: <20090916144304.809592000@linux.vnet.ibm.com>
References: <20090916143721.863799000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:57656 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbZIPOnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 10:43:03 -0400
Content-Disposition: inline; filename=606-af_iucv-sock-kill.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

For non-accepted sockets on the accept queue, iucv_sock_kill()
is called twice (in iucv_sock_close() and iucv_sock_cleanup_listen()).
This typically results in a kernel oops as shown below.

Remove the duplicate call to iucv_sock_kill() and set the SOCK_ZAPPED
flag in iucv_sock_close() only.

The iucv_sock_kill() function frees a socket only if the socket is zapped
and orphaned (sk->sk_socket == NULL):
  - Non-accepted sockets are always orphaned and, thus, iucv_sock_kill()
    frees the socket twice.
  - For accepted sockets or sockets created with iucv_sock_create(),
    sk->sk_socket is initialized. This caused the first call to
    iucv_sock_kill() to return immediately. To free these sockets,
    iucv_sock_release() uses sock_orphan() before calling iucv_sock_kill().

<1>Unable to handle kernel pointer dereference at virtual kernel address 000000003edd3000
<4>Oops: 0011 [#1] PREEMPT SMP DEBUG_PAGEALLOC
<4>Modules linked in: af_iucv sunrpc qeth_l3 dm_multipath dm_mod qeth vmur ccwgroup
<4>CPU: 0 Not tainted 2.6.30 #4
<4>Process iucv_sock_close (pid: 2486, task: 000000003aea4340, ksp: 000000003b75bc68)
<4>Krnl PSW : 0704200180000000 000003e00168e23a (iucv_sock_kill+0x2e/0xcc [af_iucv])
<4>           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 EA:3
<4>Krnl GPRS: 0000000000000000 000000003b75c000 000000003edd37f0 0000000000000001
<4>           000003e00168ec62 000000003988d960 0000000000000000 000003e0016b0608
<4>           000000003fe81b20 000000003839bb58 00000000399977f0 000000003edd37f0
<4>           000003e00168b000 000003e00168f138 000000003b75bcd0 000000003b75bc98
<4>Krnl Code: 000003e00168e22a: c0c0ffffe6eb	larl	%r12,3e00168b000
<4>           000003e00168e230: b90400b2		lgr	%r11,%r2
<4>           000003e00168e234: e3e0f0980024	stg	%r14,152(%r15)
<4>          >000003e00168e23a: e310225e0090	llgc	%r1,606(%r2)
<4>           000003e00168e240: a7110001		tmll	%r1,1
<4>           000003e00168e244: a7840007		brc	8,3e00168e252
<4>           000003e00168e248: d507d00023c8	clc	0(8,%r13),968(%r2)
<4>           000003e00168e24e: a7840009		brc	8,3e00168e260
<4>Call Trace:
<4>([<000003e0016b0608>] afiucv_dbf+0x0/0xfffffffffffdea20 [af_iucv])
<4> [<000003e00168ec6c>] iucv_sock_close+0x130/0x368 [af_iucv]
<4> [<000003e00168ef02>] iucv_sock_release+0x5e/0xe4 [af_iucv]
<4> [<0000000000438e6c>] sock_release+0x44/0x104
<4> [<0000000000438f5e>] sock_close+0x32/0x50
<4> [<0000000000207898>] __fput+0xf4/0x250
<4> [<00000000002038aa>] filp_close+0x7a/0xa8
<4> [<00000000002039ba>] SyS_close+0xe2/0x148
<4> [<0000000000117c8e>] sysc_noemu+0x10/0x16
<4> [<00000042ff8deeac>] 0x42ff8deeac

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- linux-2.6-uschi.orig/net/iucv/af_iucv.c
+++ linux-2.6-uschi/net/iucv/af_iucv.c
@@ -361,10 +361,9 @@ static void iucv_sock_cleanup_listen(str
 	}
 
 	parent->sk_state = IUCV_CLOSED;
-	sock_set_flag(parent, SOCK_ZAPPED);
 }
 
-/* Kill socket */
+/* Kill socket (only if zapped and orphaned) */
 static void iucv_sock_kill(struct sock *sk)
 {
 	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
@@ -426,17 +425,18 @@ static void iucv_sock_close(struct sock 
 
 		skb_queue_purge(&iucv->send_skb_q);
 		skb_queue_purge(&iucv->backlog_skb_q);
-
-		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
 
 	default:
 		sock_set_flag(sk, SOCK_ZAPPED);
+		/* nothing to do here */
 		break;
 	}
 
+	/* mark socket for deletion by iucv_sock_kill() */
+	sock_set_flag(sk, SOCK_ZAPPED);
+
 	release_sock(sk);
-	iucv_sock_kill(sk);
 }
 
 static void iucv_sock_init(struct sock *sk, struct sock *parent)

