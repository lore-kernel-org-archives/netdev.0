From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Mon, 23 Apr 2012 13:57:17 -0700
Message-ID: <4F95C22D.3010908@hp.com>
References: <1335173934.3293.84.camel@edumazet-glaptop> <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop> <20120423.160149.1515408777176168288.davem@davemloft.net> <1335213446.5205.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:47940 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954Ab2DWU5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 16:57:20 -0400
In-Reply-To: <1335213446.5205.65.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2012 01:37 PM, Eric Dumazet wrote:
> In my 10Gbit tests (standard netperf using 16K buffers), I've seen
> backlogs of 300 ACK packets...

Probably better to call that something other than 16K buffers - the send 
size was probably 16K, which reflected SO_SNDBUF at the time the data 
socket was created, but clearly SO_SNDBUF grew in that timeframe.

And those values are "standard" for netperf only in the context of 
(default) Linux - on other platforms the defaults in the stack and so in 
netperf are probably different.

The classic/migrated classic tests report only the initial socket buffer 
sizes, not what they become by the end of the test:

raj@tardy:~/netperf2_trunk/src$ ./netperf -H 192.168.1.3
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.1.3 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384  16384    10.00     941.06

To see what they are at the end of the test requires more direct use of 
the omni path.  Either by way of test type:

raj@tardy:~/netperf2_trunk/src$ ./netperf -H 192.168.1.3 -t omni
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.3 () 
port 0 AF_INET
Local       Remote      Local  Elapsed Throughput Throughput
Send Socket Recv Socket Send   Time               Units
Size        Size        Size   (sec)
Final       Final
266640      87380       16384  10.00   940.92     10^6bits/s

or omni output selection:

raj@tardy:~/netperf2_trunk/src$ ./netperf -H 192.168.1.3 -- -k 
lss_size_req,lss_size,lss_size_end,rsr_size_req,rsr_size,rsr_size_end
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.1.3 () port 0 AF_INET
LSS_SIZE_REQ=-1
LSS_SIZE=16384
LSS_SIZE_END=266640
RSR_SIZE_REQ=-1
RSR_SIZE=87380
RSR_SIZE_END=87380

BTW, does it make sense that the SO_SNDBUF size on the netperf side 
(lss_size_end - 2.6.38-14-generic kernel) grew larger than the SO_RCVBUF 
on the netserver side? (3.2.0-rc4+)

rick jones

PS - here is data flowing the other way:
raj@tardy:~/netperf2_trunk/src$ ./netperf -H 192.168.1.3 -t TCP_MAERTS 
-- -k lsr_size_req,lsr_size,lsr_size_end,rss_size_req,rss_size,rss_size_end
MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.1.3 () port 0 AF_INET
LSR_SIZE_REQ=-1
LSR_SIZE=87380
LSR_SIZE_END=4194304
RSS_SIZE_REQ=-1
RSS_SIZE=16384
RSS_SIZE_END=65536
