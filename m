From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] netrom: Fix sock_orphan() use in nr_release
Date: Mon, 6 Oct 2008 00:16:48 +0200
Message-ID: <20081005221648.GB2613@ami.dom.local>
References: <20081002194845.GB2664@ami.dom.local> <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local> <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local> <20081004200939.GB15152@ami.dom.local> <1223231469.18094.10.camel@f6bvp-5> <20081005204013.GB2526@ami.dom.local> <1223241500.18094.32.camel@f6bvp-5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bernard, f6bvp" <f6bvp@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:2386 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120AbYJEWPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 18:15:55 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1537548ugf.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 15:15:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1223241500.18094.32.camel@f6bvp-5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netrom: Fix sock_orphan() use in nr_release

While debugging another bug it was found that NetRom socks
are sometimes seen unorphaned in sk_free(). This patch moves
sock_orphan() in nr_release() to the beginning (like in ax25,
or rose).

Reported-and-tested-by: Bernard Pidoux f6bvp <f6bvp@free.fr>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

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
 
