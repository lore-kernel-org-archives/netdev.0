From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic with the newly merged md5 signature support
Date: Tue, 12 Dec 2006 17:29:35 -0800 (PST)
Message-ID: <20061212.172935.106265967.davem@davemloft.net>
References: <60194.81.105.127.245.1165962133.squirrel@www.solinno.co.uk>
	<20061212.142523.85408861.davem@davemloft.net>
	<45239.81.105.127.245.1165964614.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751573AbWLMB3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 20:29:36 -0500
To: leigh@solinno.co.uk
In-Reply-To: <45239.81.105.127.245.1165964614.squirrel@www.solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Leigh Brown" <leigh@solinno.co.uk>
Date: Tue, 12 Dec 2006 23:03:34 -0000 (GMT)

> Well, the inline functions seem okay in that regard, but I'll bow to
> your superior judgement.

I think we're still not onto the right fix.

I took a look, and the issue seems to simply be that the
__tcp_put_md5sig_pool() is not doing the reference count
thing that __tcp_get_md5sig_pool() does (via tcp_md5sig_users).

The direct call to __tcp_free_md5sig_pool() seems to be
what causes this problem, we should be invoking
tcp_free_md5sig_pool() instead.

Can you give this patch a try?  Thanks.

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 090c690..4c57019 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2364,8 +2364,9 @@ struct tcp_md5sig_pool *__tcp_get_md5sig
 
 EXPORT_SYMBOL(__tcp_get_md5sig_pool);
 
-void __tcp_put_md5sig_pool(void) {
-	__tcp_free_md5sig_pool(tcp_md5sig_pool);
+void __tcp_put_md5sig_pool(void)
+{
+	tcp_free_md5sig_pool(tcp_md5sig_pool);
 }
 
 EXPORT_SYMBOL(__tcp_put_md5sig_pool);
