From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 17:38:53 -0700 (PDT)
Message-ID: <20060420.173853.60273448.davem@davemloft.net>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>
	<20060420213305.GK26746@pb15.lixom.net>
	<c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29599
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932179AbWDUAi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 20:38:59 -0400
To: andy.grover@gmail.com
In-Reply-To: <c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Andrew Grover" <andy.grover@gmail.com>
Date: Thu, 20 Apr 2006 15:14:15 -0700

> First obviously it's a technology for RX CPU improvement so there's no
> benefit on TX workloads. Second it depends on there being buffers to
> copy the data into *before* the data arrives. This happens to be the
> case for benchmarks like netperf and Chariot, but real apps using
> poll/select wouldn't see a benefit,  Just laying the cards out here.
> BUT we are seeing very good CPU savings on some workloads, so for
> those apps (and if select/poll apps could make use of a
> yet-to-be-implemented async net interface) it would be a win.
> 
> I don't know what the breakdown is of apps doing blocking reads vs.
> waiting, does anyone know?

All the bandwidth benchmarks tend to block, real world servers (and
most clients to some extent) tend to use non-blocking reads and
poll/select except in some very limited cases and designs doing
something like 1 thread per connection.

This is an issue for the TCP prequeue and as a consequence VJ's net
channel ideas.  We need something to wakeup some context in order to
push channel data.

All the net channel stuff really wants is an execution context to
run the TCP stack outside of software interrupts.  I/O AT wants
something similar.

For net channels the probably best thing to do is to just queue
to the socket's netchannel, and mark poll state appropriately
and just wait for the thread to get back into recvmsg() to run
the queue.  So I think net channels can be handled in all cases
and application I/O models.

For I/O AT you'd really want to get the DMA engine going as soon
as you had those packets, but I do not see a clean and reliable way
to determine the target pages before the app gets back to recvmsg().

I/O AT really expects a lot of things to be in place in order for it
to function at all.  And sadly, that set of requirements isn't
actually very common outside of benchmarking tools and a few
uncommonly designed servers.  Even a web browser does non-blocking
reads and poll().
