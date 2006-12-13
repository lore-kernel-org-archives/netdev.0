From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: Re: kernel panic with the newly merged md5 signature support
Date: Wed, 13 Dec 2006 23:43:50 -0000 (GMT)
Message-ID: <45575.81.105.127.245.1166053430.squirrel@www.solinno.co.uk>
References: <60194.81.105.127.245.1165962133.squirrel@www.solinno.co.uk>
    <20061212.142523.85408861.davem@davemloft.net>
    <45239.81.105.127.245.1165964614.squirrel@www.solinno.co.uk>
    <20061212.172935.106265967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:1668 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbWLNAHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 19:07:51 -0500
In-Reply-To: <20061212.172935.106265967.davem@davemloft.net>
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, December 13, 2006 1:29 am, David Miller said:
> I think we're still not onto the right fix.
>
> I took a look, and the issue seems to simply be that the
> __tcp_put_md5sig_pool() is not doing the reference count
> thing that __tcp_get_md5sig_pool() does (via tcp_md5sig_users).
>
> The direct call to __tcp_free_md5sig_pool() seems to be
> what causes this problem, we should be invoking
> tcp_free_md5sig_pool() instead.
>
> Can you give this patch a try?  Thanks.
[...]

I just had to kill the parameter:-

--- net/ipv4/tcp.c.orig	2006-12-10 21:46:26.000000000 +0000
+++ net/ipv4/tcp.c	2006-12-13 17:38:29.000000000 +0000
@@ -2362,7 +2362,7 @@ struct tcp_md5sig_pool *__tcp_get_md5sig
 EXPORT_SYMBOL(__tcp_get_md5sig_pool);

 void __tcp_put_md5sig_pool(void) {
-	__tcp_free_md5sig_pool(tcp_md5sig_pool);
+	tcp_free_md5sig_pool();
 }

 EXPORT_SYMBOL(__tcp_put_md5sig_pool);

It still seems to me that it shouldn't be necessary to alloc and free
the pool from tcp_(get|put)_md5sig_pool, as you'll always have alloc'd
the pool before calculating the hash, but I'm happy enough as at least
its working now.

Cheers,

Leigh.

