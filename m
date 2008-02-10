From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2][AX25] af_ax25: remove sock lock in ax25_info_show()
Date: Sun, 10 Feb 2008 14:10:51 +0100
Message-ID: <20080210131051.GA7750@ami.dom.local>
References: <47664A0C.4060903@free.fr> <20071218135202.GA2023@ff.dom.local> <47ADF4A2.6070705@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Jann Traschewski <jann@gmx.de>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:29247 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbYBJNG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 08:06:59 -0500
Received: by ug-out-1314.google.com with SMTP id z38so150932ugc.16
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 05:06:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47ADF4A2.6070705@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is a little bit better version, I hope.

Regards,
Jarek P.

--------------> (take 2)

Subject: [AX25] af_ax25: remove sock lock in ax25_info_show()
 
This lockdep warning:

> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.24 #3
> -------------------------------------------------------
> swapper/0 is trying to acquire lock:
>  (ax25_list_lock){-+..}, at: [<f91dd3b1>] ax25_destroy_socket+0x171/0x1f0 [ax25]
> 
> but task is already holding lock:
>  (slock-AF_AX25){-+..}, at: [<f91dbabc>] ax25_std_heartbeat_expiry+0x1c/0xe0 [ax25]
> 
> which lock already depends on the new lock.
...

shows that ax25_list_lock and slock-AF_AX25 are taken in different
order: ax25_info_show() takes slock (bh_lock_sock(ax25->sk)) while
ax25_list_lock is held, so reversely to other functions. To fix this
the sock lock should be moved to ax25_info_start(), and there would
be still problem with breaking ax25_list_lock (it seems this "proper"
order isn't optimal yet). But, since it's only for reading proc info
it seems this is not necessary (e.g.  ax25_send_to_raw() does similar
reading without this lock too).

So, this patch removes sock lock to avoid deadlock possibility; there
is also used sock_i_ino() function, which reads sk_socket under proper
read lock. Additionally printf format of this i_ino is changed to %lu.


Reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/ax25/af_ax25.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 94b2b1b..48bfcc7 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1924,12 +1924,10 @@ static int ax25_info_show(struct seq_file *seq, void *v)
 		   ax25->paclen);
 
 	if (ax25->sk != NULL) {
-		bh_lock_sock(ax25->sk);
-		seq_printf(seq," %d %d %ld\n",
+		seq_printf(seq, " %d %d %lu\n",
 			   atomic_read(&ax25->sk->sk_wmem_alloc),
 			   atomic_read(&ax25->sk->sk_rmem_alloc),
-			   ax25->sk->sk_socket != NULL ? SOCK_INODE(ax25->sk->sk_socket)->i_ino : 0L);
-		bh_unlock_sock(ax25->sk);
+			   sock_i_ino(ax25->sk));
 	} else {
 		seq_puts(seq, " * * *\n");
 	}
