From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Thu, 27 Jun 2013 14:22:18 -0500
Message-ID: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:58737 "EHLO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753654Ab3F0TXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 15:23:10 -0400
Received: by mail-ve0-f170.google.com with SMTP id 14so1087859vea.1
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 12:22:24 -0700 (PDT)
Received: from sbohrermbp13-local.rgmadvisors.com ([173.227.92.65])
        by mx.google.com with ESMTPSA id wl4sm3055017vdb.3.2013.06.27.12.22.23
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Jun 2013 12:22:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking for opportunities to improve the multicast receive
performance for our application, and I thought I'd spend some time
trying to understand what I thought might be a small/simple
improvement.  Profiling with perf I see that there is spin_lock
contention in __udp4_lib_mcast_deliver:

0.68%  swapper  [kernel.kallsyms]               [k] _raw_spin_lock
       |
       --- _raw_spin_lock
          |
          |--24.13%-- perf_adjust_freq_unthr_context.part.21
          |
          |--22.40%-- scheduler_tick
          |
          |--14.96%-- __udp4_lib_mcast_deliver

The lock appears to be the udp_hslot lock protecting sockets that have
been hashed based on the local port.  My application contains multiple
processes and each process listens on multiple multicast sockets.  We
open one socket per multicast addr:port per machine.  All of the local
UDP ports are unique.  The UDP hash table has 65536 entries and it
appears the hash function is simply the port number plus a
contribution from the network namespace (I believe the namespace part
should be constant since we're not not using network namespaces.
Perhaps I should disable CONFIG_NET_NS).

$ dmesg | grep "UDP hash"
[    0.606472] UDP hash table entries: 65536 (order: 9, 2097152 bytes)

At this point I'm confused why there is any contention over this
spin_lock.  We should have enough hash table entries to avoid
collisions and all of our ports are unique.  Assuming that part is
true I could imagine contention if the kernel is processing two
packets for the same multicast addr:port in parallel but is that
possible?  I'm using a Mellanox ConnectX-3 card that has multiple
receive queues but I've always thought that all packets for a given
srcip:srcport:destip:destport would all be delivered to a single queue
and thus not processed in parallel.

There is obviously something wrong with my thinking and I'd appreciate
if someone could tell me what I'm missing.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
