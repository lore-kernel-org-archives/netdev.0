From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 06:12:53 -0700
Message-ID: <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	 <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406101726390.11647@dtop>
	 <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.10.1406102114520.28698@dinf>
	 <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406110011170.11647@dtop>
	 <alpine.DEB.2.02.1406110022550.11647@dtop>
	 <alpine.DEB.2.02.1406110036490.11647@dtop>
	 <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:50026 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbaFKNMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 09:12:54 -0400
Received: by mail-pa0-f54.google.com with SMTP id rd3so1914196pab.27
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 06:12:53 -0700 (PDT)
In-Reply-To: <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-11 at 05:41 -0700, Eric Dumazet wrote:

> 
> OK then we probably have another bug in UDP, which is that we call
> sk_dst_set(sk, dst_clone(&rt->dst)); with a dst having DST_NOCACHE set
> 
> Its a problem, because sk_dst_get() cannot deal safely with such dst.

You could try this in top of other patches.

diff --git a/include/net/sock.h b/include/net/sock.h
index 21569cf456ed..427ac7cc50fc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1728,8 +1728,8 @@ sk_dst_get(struct sock *sk)
 
 	rcu_read_lock();
 	dst = rcu_dereference(sk->sk_dst_cache);
-	if (dst)
-		dst_hold(dst);
+	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
+		dst = NULL;
 	rcu_read_unlock();
 	return dst;
 }
