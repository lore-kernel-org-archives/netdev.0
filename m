From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take2] [AX25] circular locking with AX25 connection timeout
Date: Sat, 15 Dec 2007 11:18:10 +0100
Message-ID: <20071215101810.GA3143@ami.dom.local>
References: <476303C8.2060507@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:51705 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780AbXLOKP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 05:15:26 -0500
Received: by fk-out-0910.google.com with SMTP id z23so296204fkz.5
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 02:15:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <476303C8.2060507@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 11:29:28PM +0100, Bernard Pidoux wrote:
> Hi,
>
> This patch cancels a circular locking conflict that appeared with a timeout 
> of an AX25 connection.
>
> signed off by Jarek Poplawski

One spurious space less here, and maybe a few more words to the changelog.

Regards,
Jarek P.
---------------->

Subject: [PATCH] [NET] AX25: locking dependencies fix in ax25_disconnect

Bernard Pidoux reported these lockdep warnings:

[ INFO: possible irq lock inversion dependency detected ]
2.6.23.1 #1
---------------------------------------------------------
fpac/4933 just changed the state of lock:
 (slock-AF_AX25){--..}, at: [<d8be3312>] ax25_disconnect+0x46/0xaf
 [ax25]
 but this lock was taken by another, soft-irq-safe lock in the past:
  (ax25_list_lock){-+..}

  and interrupts could create inverse lock ordering between them.
  [...]

[ INFO: inconsistent lock state ]
2.6.23.1 #1
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
ax25_call/4005 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (slock-AF_AX25){-+..}, at: [<d8b79312>] ax25_disconnect+0x46/0xaf [ax25]
 [...]

This means slock-AF_AX25 could be taken both from softirq and process
context with softirqs enabled, so it's endangered itself, but also makes
ax25_list_lock vulnerable. It was not 100% verified if the real lockup
can happen, but this fix isn't very costly and looks safe anyway.
(It was tested by Bernard with 2.6.23.9 and 2.6.24-rc5 kernels.)


Reported_by: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Tested_by: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

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

