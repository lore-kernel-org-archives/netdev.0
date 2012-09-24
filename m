From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Mon, 24 Sep 2012 19:00:11 +0200
Message-ID: <1348506011.26828.1195.camel@edumazet-glaptop>
References: <20120905043523.GA12988@redhat.com>
	 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
	 <20120914212958.GA25053@redhat.com>
	 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
	 <20120919211059.GA10985@redhat.com>
	 <1348092082.31352.51.camel@edumazet-glaptop>
	 <20120920020223.GA28110@redhat.com>  <20120924153921.GA13845@redhat.com>
	 <1348504445.26828.1131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38107 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab2IXRAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 13:00:15 -0400
Received: by bkcjk13 with SMTP id jk13so1056256bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 10:00:14 -0700 (PDT)
In-Reply-To: <1348504445.26828.1131.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>

On Mon, 2012-09-24 at 18:34 +0200, Eric Dumazet wrote:

> OK, I believe I found the reason. I Will post a patch.
> 
> open a raw socket AF_INET, TCP_PROTO
> + connect() ->sk_state set to TCP_ESTABLISHED
> + setsockopt( SO_KEEPALIVE, &on)  -> crash

I confirm following patch fixes the problem for me.

Thanks again

[PATCH] net: guard tcp_set_keepalive() to tcp sockets

Its possible to use RAW sockets to get a crash in 
tcp_set_keepalive() / sk_reset_timer()

Fix is to make sure socket is a SOCK_STREAM one.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 3057920..a6000fb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -691,7 +691,8 @@ set_rcvbuf:
 
 	case SO_KEEPALIVE:
 #ifdef CONFIG_INET
-		if (sk->sk_protocol == IPPROTO_TCP)
+		if (sk->sk_protocol == IPPROTO_TCP &&
+		    sk->sk_type == SOCK_STREAM)
 			tcp_set_keepalive(sk, valbool);
 #endif
 		sock_valbool_flag(sk, SOCK_KEEPOPEN, valbool);
