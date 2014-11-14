From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] icmp: Remove some spurious dropped packet profile
 hits from the ICMP path
Date: Fri, 14 Nov 2014 10:29:23 -0800
Message-ID: <54664A03.7070007@hp.com>
References: <20141113225457.A3E502900805@tardy> <1415931471.17262.27.camel@edumazet-glaptop2.roam.corp.google.com> <54662AF9.4050002@hp.com> <1415984329.17262.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:23218 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbaKNS3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 13:29:25 -0500
In-Reply-To: <1415984329.17262.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2014 08:58 AM, Eric Dumazet wrote:
> On Fri, 2014-11-14 at 08:16 -0800, Rick Jones wrote:
>
>> I thought the point of the drop profiling was to show where the drops
>> were happening.  Leaving the kfree_skb() up in icmp_rcv() does not
>> improve showing where the drops happened.  That is why I've pushed it
>> down into the routines called by icmp_rcv().
>
> OK, but we drop an icmp message, and that really should be enough.
>
> The point is that most normal icmp messages wont be dropped, but
> consumed.
>
> I am not sure we want to bloat the kernel for such minor problem.

I can certainly rework the patch that way, but one thing I have noticed 
when the system is the initiator of pings rather than the target, is 
that I get (or at least I think I do) drop profile hits in ping_rcv():

# To display the perf.data header info, please use 
--header/--header-only options.
#
# Samples: 997K of event 'skb:kfree_skb'
# Event count (approx.): 997789
#
# Children      Self  Symbol                                      Shared 
Object
# ........  ........  .......................................... 
...........................
#
    100.00%   100.00%  [k] kfree_skb 
[kernel.kallsyms]
             |
             |--100.00%-- ping_rcv
             |          icmp_rcv
             |          ip_local_deliver_finish
             |          ip_local_deliver
             |          ip_rcv_finish
             |          ip_rcv
             |          __netif_receive_skb_core
             |          __netif_receive_skb
             |          netif_receive_skb_internal
             |          napi_gro_receive
             |          e1000_receive_skb
             |          e1000_clean_rx_irq
             |          e1000e_poll
             |          net_rx_action
             |          __do_softirq

I don't have an explanation for it though.  Perhaps it is just confusion 
on my part.

That is from:

raj@raj-8510w:~$ sudo ~/net-next/tools/perf/perf record -a -g -e 
skb:kfree_skb ping -n -f -q tardy.usa.hp.com -c 1000000
PING tardy.usa.hp.com (16.103.148.51) 56(84) bytes of data.

--- tardy.usa.hp.com ping statistics ---
1000000 packets transmitted, 1000000 received, 0% packet loss, time 65751ms
rtt min/avg/max/mdev = 0.036/0.053/0.170/0.008 ms, ipg/ewma 0.065/0.052 ms
[ perf record: Woken up 1037 times to write data ]
[ perf record: Captured and wrote 259.456 MB perf.data (~11335798 samples) ]
Warning:
Processed 1002854 events and lost 2 chunks!

Check IO/CPU overload!
