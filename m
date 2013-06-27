From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Fri, 28 Jun 2013 00:39:38 +0300
Message-ID: <CAJZOPZLmbMsOAPhZ6GkY8EHReNjiHbRFw8XF8J5eCdVhb5jFFA@mail.gmail.com>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f49.google.com ([209.85.128.49]:40335 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3F0Vjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 17:39:39 -0400
Received: by mail-qe0-f49.google.com with SMTP id cz11so421052qeb.8
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 14:39:38 -0700 (PDT)
In-Reply-To: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 10:22 PM, Shawn Bohrer <sbohrer@rgmadvisors.com> wrote:
> I'm looking for opportunities to improve the multicast receive
> performance for our application, and I thought I'd spend some time
> trying to understand what I thought might be a small/simple
> improvement.  Profiling with perf I see that there is spin_lock
> contention in __udp4_lib_mcast_deliver:
>
> 0.68%  swapper  [kernel.kallsyms]               [k] _raw_spin_lock
>        |
>        --- _raw_spin_lock
>           |
>           |--24.13%-- perf_adjust_freq_unthr_context.part.21
>           |
>           |--22.40%-- scheduler_tick
>           |
>           |--14.96%-- __udp4_lib_mcast_deliver
>
> The lock appears to be the udp_hslot lock protecting sockets that have
> been hashed based on the local port.  My application contains multiple
> processes and each process listens on multiple multicast sockets.  We
> open one socket per multicast addr:port per machine.  All of the local
> UDP ports are unique.  The UDP hash table has 65536 entries and it
> appears the hash function is simply the port number plus a
> contribution from the network namespace (I believe the namespace part
> should be constant since we're not not using network namespaces.
> Perhaps I should disable CONFIG_NET_NS).
>
> $ dmesg | grep "UDP hash"
> [    0.606472] UDP hash table entries: 65536 (order: 9, 2097152 bytes)
>
> At this point I'm confused why there is any contention over this
> spin_lock.  We should have enough hash table entries to avoid
> collisions and all of our ports are unique.  Assuming that part is
> true I could imagine contention if the kernel is processing two
> packets for the same multicast addr:port in parallel but is that
> possible?  I'm using a Mellanox ConnectX-3 card that has multiple
> receive queues but I've always thought that all packets for a given
> srcip:srcport:destip:destport would all be delivered to a single queue
> and thus not processed in parallel.

But for a given dest mcast ip / udp port you can have multiple senders
where each has different source ucast ip / udp port, isn't that?
anyway if you disable the udp_rss module param you can be sure that
all traffic to dest mcast group goes to one ring, still this ring will
be the only one active, so I am not this is wise.

Or.
