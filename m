From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Tue, 03 Apr 2012 17:36:14 -0400 (EDT)
Message-ID: <20120403.173614.962252876842659412.davem@davemloft.net>
References: <1333481821.18626.322.camel@edumazet-glaptop>
	<20120403.172126.672236532461758456.davem@davemloft.net>
	<1333488689.18626.331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab2DCVg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 17:36:28 -0400
In-Reply-To: <1333488689.18626.331.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Apr 2012 23:31:29 +0200

> The code in tcp_sendmsg() and do_tcp_sendpages() is similar (actually
> probably copy/pasted) but the thing is tcp_sendmsg() is called once per
> sendmsg() call (and the push logic is OK at the end of it), while a
> single splice() system call can call do_tcp_sendpages() 16 times (or
> even more if pipe buffer was extended by fcntl(F_SETPIPE_SZ))

Ok, so this means that in essence the tcp_mark_push should also only
be done in the final sendpage call.

And since I'm wholly convinced that the URG stuff is a complete
"don't care" for this path, I'm convinced your patch is the right
thing to do.

Applied to 'net' and queued up for -stable, thanks Eric.

> Maybe a real fix would be to call do_tcp_sendpages() exactly once, but I
> tried this today and found needed surgery was complex). Also this would
> lock socket for a long period and could add latencies because of backlog
> processing.

I don't think this is a good idea.  Maybe we can do some level of
batching at some point, but it would need to have a limit.
