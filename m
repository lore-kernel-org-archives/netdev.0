From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sun, 20 Mar 2011 12:59:50 +0100
Message-ID: <20110320115950.GB3038@nuttenaction>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net>
 <20110319.214100.183043711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:33297 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751052Ab1CTL7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 07:59:52 -0400
Content-Disposition: inline
In-Reply-To: <20110319.214100.183043711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2011-03-19 21:41:00 [-0700]:

>What in the world is a server running on multi-GHZ cpus doing such
>that it cannot accept() fast enough to keep up with a 100 connections
>per second?
>
>We were handling that just fine 10+ years ago.
>
>The math simply doesn't add up.

Davem, what the hell - you don't get it! ;-) No Davem, the problem is not the
accept() performance rather it is the time since SYN/ACK is arrived and
request_sock are created: RTT time to the client (including client SYN/ACK
processing) and finally the accept() processing time. During _this_ duration
the backlog is of relevance. For connection with a high RTT the backlog can be
quite high - local accept() processing delay does not really matter.

The actual behavior is not really fine. max_syn_backlog and somaxconn are
somewhat[TM] unsynchronized. max_syn_backlog considers the system memory
characteristic where somaxconn is just a dump show stopper. My patch is a
compromise it increase the value to 256 because it showed up that 256 seems
reasonable for many setups. Many system administrators will not notice the
problem, server authors may know about this limitation (and adjust the listen
argument)- so why should we make the life of the administrators a little bit
more easy by adjusting the default? Low memory systems does not suffer, the
limit is still reasonable small. The memory footprint for a server with 4
listening sockets is just insignificant. But connection failure due to backlog
limits will magically go away.

The math is a function from incoming connections / time, the RTT and
processing delay of client and server side..

Have a nice Sunday, Hagen
