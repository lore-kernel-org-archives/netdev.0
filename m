From: James Chapman <jchapman@katalix.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Thu, 10 Jan 2008 18:25:43 +0000
Message-ID: <47866327.8090905@katalix.com>
References: <478654C3.60806@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37574 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbYAJSZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 13:25:46 -0500
In-Reply-To: <478654C3.60806@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Hi all,
> 
> I've got an issue that's popped up with a deployed system running
> 2.6.10.  I'm looking for some help figuring out why incoming network
> packets aren't being processed fast enough.
> 
> After a recent userspace app change, we've started seeing packets being
> dropped by the ethernet hardware (e1000, NAPI is enabled).

What's changed in your application? Any real-time threads in there?

>From the top output below, looks like SigtranServices is consuming all
your CPU...

> The
> error/dropped/fifo counts are going up in ethtool:
> 
>      rx_packets: 32180834
>      rx_bytes: 5480756958
>      rx_errors: 862506
>      rx_dropped: 771345
>      rx_length_errors: 0
>      rx_over_errors: 0
>      rx_crc_errors: 0
>      rx_frame_errors: 0
>      rx_fifo_errors: 91161
>      rx_missed_errors: 91161
> 
> This link is receiving roughly 13K packets/sec, and we're dropping
> roughly 51 packets/sec due to fifo errors.
> 
> Increasing the rx descriptor ring size from 256 up to around 3000 or so
> seems to make the problem stop, but it seems to me that this is just a
> workaround for the latency in processing the incoming packets.
> 
> So, I'm looking for some suggestions on how to fix this or to figure out
> where the latency is coming from.
> 
> Some additional information:
> 
> 
> 1) Interrupts are being processed on both cpus:
> 
> root@base0-0-0-13-0-11-1:/root> cat /proc/interrupts
>            CPU0       CPU1
>  30:    1703756    4530785  U3-MPIC Level     eth0
> 
> 
> 
> 
> 2) "top" shows a fair amount of time processing softirqs, but very
> little time in ksoftirqd (or is that a sampling artifact?).
> 
> 
> Tasks: 79 total, 1 running, 78 sleeping, 0 stopped, 0 zombie
> Cpu0: 23.6% us, 30.9% sy, 0.0% ni, 36.9% id, 0.0% wa, 0.3% hi, 8.3% si
> Cpu1: 30.4% us, 24.1% sy, 0.0% ni, 5.9% id, 0.0% wa, 0.7% hi, 38.9% si
> Mem:  4007812k total, 2199148k used,  1808664k free,     0k buffers
> Swap:   0k total,       0k used,      0k free,   219844k cached
> 
>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>  5375 root      15   0 2682m 1.8g 6640 S 99.9 46.7  31:17.68
> SigtranServices
>  7696 root      17   0  6952 3212 1192 S  7.3  0.1   0:15.75
> schedmon.ppc210
>  7859 root      16   0  2688 1228  964 R  0.7  0.0   0:00.04 top
>  2956 root       8  -8 18940 7436 5776 S  0.3  0.2   0:01.35 blademtc
>     1 root      16   0  1660  620  532 S  0.0  0.0   0:30.62 init
>     2 root      RT   0     0    0    0 S  0.0  0.0   0:00.01 migration/0
>     3 root      15   0     0    0    0 S  0.0  0.0   0:00.55 ksoftirqd/0
>     4 root      RT   0     0    0    0 S  0.0  0.0   0:00.01 migration/1
>     5 root      15   0     0    0    0 S  0.0  0.0   0:00.43 ksoftirqd/1
> 
> 
> 3) /proc/sys/net/core/netdev_max_backlog is set to the default of 300
> 
> 
> So...anyone have any ideas/suggestions?
> 
> Thanks,
> 
> Chris

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

