From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG][AX25] 2.6.28.5 "inconsistent lock state" (2 CPUs / SMP
	enabled)
Date: Mon, 4 May 2009 07:31:53 +0000
Message-ID: <20090504073153.GA5354@ff.dom.local>
References: <4152EA8442834D52AA9C100377B9ABE2@A050313B>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jann Traschewski <jann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:44660 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbZEDHcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 03:32:01 -0400
Received: by qyk34 with SMTP id 34so5436370qyk.33
        for <netdev@vger.kernel.org>; Mon, 04 May 2009 00:32:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4152EA8442834D52AA9C100377B9ABE2@A050313B>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-05-2009 10:06, Jann Traschewski wrote:
> Hi,
> 
> the AX.25 code has still some problems with SMP and locking. I turned on
> lock debugging on my machine with a lot of AX.25 traffic. Although it did
> take serveral days until I got this:
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.28.5-dg8ngn #1
> ---------------------------------
> inconsistent {softirq-on-R} -> {in-softirq-W} usage.
> swapper/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
>  (clock-AF_AX25){-+-?}, at: [<f859ed33>] ax25_destroy_socket+0xb6/0x1c4
> [ax25]
> {softirq-on-R} state was registered at:
>   [<c013a751>] __lock_acquire+0x4e4/0x65e
>   [<c0124d14>] local_bh_enable+0xa5/0xa9
>   [<c013a914>] lock_acquire+0x49/0x61
>   [<c025a221>] sock_def_wakeup+0x11/0x3d
>   [<c02ca449>] _read_lock+0x19/0x24
>   [<c025a221>] sock_def_wakeup+0x11/0x3d
>   [<c025a221>] sock_def_wakeup+0x11/0x3d
>   [<f859fb9c>] ax25_release+0x17e/0x1ab [ax25]
>   [<c025847f>] sock_release+0x11/0x59
>   [<c0258883>] sock_close+0x19/0x1c
...

Hi,

Could you try this patch?

Thanks,
Jarek P.
---

 net/ax25/af_ax25.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index fd9d06f..f2fec78 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -314,8 +314,21 @@ void ax25_destroy_socket(ax25_cb *ax25)
 				/* A pending connection */
 				ax25_cb *sax25 = ax25_sk(skb->sk);
 
-				/* Queue the unaccepted socket for death */
-				sock_orphan(skb->sk);
+				/*
+				 * Queue the unaccepted socket for death.
+				 * Btw., it was never grafted, so sock_orphan()
+				 * is unnecessary.
+				 */
+				if (unlikely(skb->sk->sk_socket)) {
+					/*
+					 * This is old code, so let's leave it
+					 * for some time for debugging.
+					 */
+					sock_orphan(skb->sk);
+					WARN_ON_ONCE(1);
+				} else {
+					sock_set_flag(skb->sk, SOCK_DEAD);
+				}
 
 				/* 9A4GL: hack to release unaccepted sockets */
 				skb->sk->sk_state = TCP_LISTEN;
