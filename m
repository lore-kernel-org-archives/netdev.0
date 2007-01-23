From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 16:44:10 +1100
Message-ID: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0701221954250.11520@twinlark.arctic.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2420 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933000AbXAWFoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 00:44:17 -0500
To: dean@arctic.org (dean gaudet)
In-Reply-To: <Pine.LNX.4.64.0701221954250.11520@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dean gaudet <dean@arctic.org> wrote:
> in the test program below the getsockname result on a TCP socket changes 
> across a write which produces EPIPE... here's a fragment of the strace:
> 
> getsockname(3, {sa_family=AF_INET, sin_port=htons(37636), sin_addr=inet_addr("127.0.0.1")}, [17863593746633850896]) = 0
> ...
> write(3, "hi!\n", 4)                    = 4
> write(3, "hi!\n", 4)                    = -1 EPIPE (Broken pipe)
> --- SIGPIPE (Broken pipe) @ 0 (0) ---
> getsockname(3, {sa_family=AF_INET, sin_port=htons(59882), sin_addr=inet_addr("127.0.0.1")}, [16927060683038654480]) = 0
> 
> why does the port# change?  this is on 2.6.19.1.

Prior to the last write, the socket entered the CLOSED state meaning
that the old port is no longer allocated to it.  As a result, the
last write operates on an unconnected socket which causes a new local
port to be allocated as an autobind.  It then fails because the socket
is still not connected.

So any attempt to run getsockname after an error on the socket is
simply buggy.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
