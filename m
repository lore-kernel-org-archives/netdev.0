From: Stephen Hemminger <stephen@networkplumber.org>
Subject: 16% regression on 10G caused by TCP small queues
Date: Wed, 23 Oct 2013 19:29:54 -0700
Message-ID: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dave =?ISO-8859-1?B?VORodA==?= <dave.taht@bufferbloat.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:62134 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab3JXC36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 22:29:58 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb12so1844590pbc.8
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 19:29:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the course of testing routing functionality, I discovered a that the single flow TCP
throughput was much worse than expected. At first, it looked like a router problem,
or maybe because one end was a FreeBSD system (which has noticeably slower TCP performance).
But reducing it down to two systems directly connected over 10G (ixgbe) found the problem.

With a single TCP flow, in 3.5 kernel the performance with iperf is 9.41 Gbit/sec
which is at the link limit for TCP with timestamps etc. But in 3.6 and later the
throughput dropped to 7.9 Gbit/sec which is a regression of 16%.

Doing bisect shows that the commit causing this is:

  commit 46d3ceabd8d98ed0ad10f20c595ca784e34786c5
  Author: Eric Dumazet <eric.dumazet@gmail.com>
  Date:   Wed Jul 11 05:50:31 2012 +0000

    tcp: TCP Small Queues
    
    This introduce TSQ (TCP Small Queues)


There are several options at this point:
  0. Ignore it. Sorry, this is not acceptable.
     People do transfer files over 10G and expect line rate!
 
  1. Rip it out. which adds to the buffer bloat.
     This is a throughput vs latency tradeoff.

  2. Neuter it by making TCP small queues configurable and default off.
     Allows people who are willing to sacrifice performance go ahead and
     enable it.
 
  3. Tweak it. Make the default queue value in kernel big enough that no loss is
     observable.
 
  4. Do something smarter like a dynamic TCP small queue that adapts.
