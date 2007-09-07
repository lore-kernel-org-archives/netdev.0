From: Rick Jones <rick.jones2@hp.com>
Subject: Re: auto recycling of TIME_WAIT connections
Date: Fri, 07 Sep 2007 10:04:09 -0700
Message-ID: <46E18489.6060100@hp.com>
References: <46E11829.4090607@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:38098 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965374AbXIGRFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 13:05:13 -0400
In-Reply-To: <46E11829.4090607@draigBrady.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The first issue, requires a large timeout, and
> the TIME_WAIT timeout is currently 60 seconds on linux.
> That timeout effectively limits the connection rate between
> local TCP clients and a server to 32k/60s or around 500 connections/second.

Actually, it would be more like 60k/60s if the application were making 
explicit calls to bind() as arguably it should if it is going to be 
churning through so many connections.

This was an issue over a decade ago with SPECweb96 benchmarking.  The 
initial solution was to make the explicit bind() calls and not rely on 
the anonymous/ephemeral port space.  After that, one starts adding 
additional IP's into the mix (at least where possible).  And if that 
fails, one has to go back to the beginning and ask oneself exactly why a 
client is trying to churn through so many connections per second in the 
first place.

If we were slavishly conformant to the RFC's :) that 60 seconds would be 
240 seconds...

> But that issue can't really happen when the client
> and server are on the same machine can it, and
> even if it could, the timeouts involved would be shorter.
> 
> Now linux does have an (undocumented) /proc/sys/net/ipv4/tcp_tw_recycle flag
> to enable recycling of TIME_WAIT connections. This is global however and could cause
> problems in general for external connections.

Rampant speculation begins...

If the client can be convinced to just call shutdown(SHUT_RDWR) rather 
than close(), and be the first to do so, ahead of the server, I think it 
will retain a link to the TCP endpoint in TIME_WAIT.  It could then, in 
TCP theory, call connect() again, and go through a path that allows 
transition from TIME_WAIT to ESTABLISHED if all the right things wrt 
Initial Sequence Number selection happen.  Whether randomization of the 
ISN allows that today is questionable.

> So how about auto enabling recycling for local connections?

I think the standard response is that one can never _really_ know what 
is local and what not, particularly in the presence of netfilter and the 
rewriting of headers behind one's back.

rick jones
