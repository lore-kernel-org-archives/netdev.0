From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netfilter: take care of timewait sockets
Date: Mon, 03 Sep 2012 11:57:18 +0200
Message-ID: <1346666238.2563.113.camel@edumazet-glaptop>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
	 <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
	 <20120902132834.GB7456@breakpoint.cc>
	 <1346626385.2563.44.camel@edumazet-glaptop>
	 <1346629684.2563.78.camel@edumazet-glaptop>
	 <20120903074718.GA14750@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42741 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756210Ab2ICJ5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 05:57:22 -0400
Received: by eekc1 with SMTP id c1so1907811eek.19
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2012 02:57:21 -0700 (PDT)
In-Reply-To: <20120903074718.GA14750@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Mon, 2012-09-03 at 09:47 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> > full blown socket.
> > 
> > But with TCP early demux, we can have skb->sk pointing to a timewait
> > socket.
> > 
> > Same fix is needed in netfnetlink_log
> 
> Looks good, but IMHO it is very un-intuitive that
> skb->sk might be a pointer to an object that is not struct sock (or
> a compatible object).

Its kind of a compatible object, if all skb->sk users are aware of it.

You are totally right, this is messy, but TCP edemux is a layering
violation helping a bit performance...

sock_edemux() should also be fixed.

David, tell me if you prefer to change TCP demux to avoid timewait,
as I have no strong opinion.

[PATCH] net: sock_edemux() should take care of timewait sockets

sock_edemux() can handle either a regular socket or a timewait socket

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 8f67ced..7f64467 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1523,7 +1523,12 @@ EXPORT_SYMBOL(sock_rfree);
 
 void sock_edemux(struct sk_buff *skb)
 {
-	sock_put(skb->sk);
+	struct sock *sk = skb->sk;
+
+	if (sk->sk_state == TCP_TIME_WAIT)
+		inet_twsk_put(inet_twsk(sk));
+	else
+		sock_put(sk);
 }
 EXPORT_SYMBOL(sock_edemux);
 
