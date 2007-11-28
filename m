From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Inconsistent lock  state and possible irq lock inversion dependency detected in ax25.ko
Date: Wed, 28 Nov 2007 14:48:08 +0100
Message-ID: <20071128134808.GA4355@ff.dom.local>
References: <4744AD8B.2000908@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, ralf@linux-mips.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:45305 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752444AbXK1Nnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 08:43:33 -0500
Content-Disposition: inline
In-Reply-To: <4744AD8B.2000908@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21-11-2007 23:13, Bernard Pidoux wrote:
...
> [ INFO: inconsistent lock state ]
> 
> The error seems to reside around ax25_disconnect+0x46/0xaf [ax25] that 
> is called when an AX25 connect timeout or a connection failure occurs.
> Connect timeout is probably activating
> ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
... 

Hi,

Could you try this patch? (2.6.23 or later - should be no difference)

Thanks,
Jarek P.

---

diff -Nurp linux-2.6.24-rc2-/net/ax25/ax25_subr.c linux-2.6.24-rc2+/net/ax25/ax25_subr.c
--- linux-2.6.24-rc2-/net/ax25/ax25_subr.c	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.24-rc2+/net/ax25/ax25_subr.c	2007-11-28 11:51:12.000000000 +0100
@@ -279,6 +279,7 @@ void ax25_disconnect(ax25_cb *ax25, int 
 	ax25_link_failed(ax25, reason);
 
 	if (ax25->sk != NULL) {
+		local_bh_disable();
 		bh_lock_sock(ax25->sk);
 		ax25->sk->sk_state     = TCP_CLOSE;
 		ax25->sk->sk_err       = reason;
@@ -288,5 +289,6 @@ void ax25_disconnect(ax25_cb *ax25, int 
 			sock_set_flag(ax25->sk, SOCK_DEAD);
 		}
 		bh_unlock_sock(ax25->sk);
+		local_bh_enable();
 	}
 }
