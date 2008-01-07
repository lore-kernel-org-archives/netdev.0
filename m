From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Mon, 7 Jan 2008 10:21:47 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801071000390.17676@kivilampi-30.cs.helsinki.fi>
References: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	paul.moore@hp.com, latten@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52099 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbYAGIVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 03:21:49 -0500
In-Reply-To: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 6 Jan 2008, Herbert Xu wrote:

> is definitely not a fast path.  If a function ends up being called
> just once the compiler will most likely inline it anyway, making the
> use of the keyword inline redundant.

Unexpected enough, even this logic seems to fail in a way with my gcc, I'm 
yet to study it closer but it seems to me that e.g., uninlining only once 
called tcp_fastretrans_alert is worth of at least 100 bytes (note that 
it's not inlined by us, gcc did it all by itself)! Otherwise I'd fail to 
understand why I got -270 bytes from uninlining tcp_moderate_cwnd which is 
only 57 bytes as unlined with three call sites.

    net/ipv4/tcp_input.c:
      tcp_undo_cwr          |  -48
      tcp_try_undo_recovery |  -55
      tcp_ack               | -2941
     3 functions changed, 3044 bytes removed, diff: -3044
    
    net/ipv4/tcp_input.c:
      tcp_moderate_cwnd     |  +57
      tcp_fastretrans_alert | +2717
     2 functions changed, 2774 bytes added, diff: +2774
    
    net/ipv4/tcp_input.o:
     5 functions changed, 2774 bytes added, 3044 bytes removed, diff: -270

I'll probably force uninlining of it without tcp_moderate_cwnd noise and 
try a number of gcc versions.


-- 
 i.
