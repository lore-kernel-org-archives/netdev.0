From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet_diag: fix oops for IPv4 AF_INET6 TCP SYN-RECV
 state
Date: Fri, 07 Dec 2012 13:20:19 -0500 (EST)
Message-ID: <20121207.132019.1647690876686095833.davem@davemloft.net>
References: <1354808546-644-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab2LGSUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 13:20:22 -0500
In-Reply-To: <1354808546-644-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu,  6 Dec 2012 10:42:26 -0500

> Fix inet_diag to be aware of the fact that AF_INET6 TCP connections
> instantiated for IPv4 traffic and in the SYN-RECV state were actually
> created with inet_reqsk_alloc(), instead of inet6_reqsk_alloc(). This
> means that for such connections inet6_rsk(req) returns a pointer to a
> random spot in memory up to roughly 64KB beyond the end of the
> request_sock.
> 
> With this bug, for a server using AF_INET6 TCP sockets and serving
> IPv4 traffic, an inet_diag user like `ss state SYN-RECV` would lead to
> inet_diag_fill_req() causing an oops or the export to user space of 16
> bytes of kernel memory as a garbage IPv6 address, depending on where
> the garbage inet6_rsk(req) pointed.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Thanks for this fix, but it opens up more questions.

We don't seem to make any validations upon inet_diag_hostcond's
prefix_len.  That parameter we pass into bitstring_match() can
be just about anything.

As another example, what if we do an ipv6 128-bit compare on what's
actually an ipv4 address in the inet request sock?

I think we need to, using cond->family, make some kind of validations
upon cond->prefix_len.
