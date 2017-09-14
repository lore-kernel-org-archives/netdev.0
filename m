From: Tariq Toukan <tariqt@mellanox.com>
Subject: Page allocator bottleneck
Date: Thu, 14 Sep 2017 19:49:31 +0300
Message-ID: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0070.outbound.protection.outlook.com ([104.47.2.70]:60800
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751434AbdINQtn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 12:49:43 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

As part of the efforts to support increasing next-generation NIC speeds,
I am investigating SW bottlenecks in network stack receive flow.

Here I share some numbers I got for a simple experiment, in which I 
simulate the page allocation rate needed in 200Gpbs NICs.

I ran the test below over 3 different (modified) mlx5 driver versions,
loaded on server side (RX):
1) RX page cache disabled, 2 packets per page.
2) RX page cache disabled, one packet per page.
3) Huge RX page cache, one packet per page.

All page allocations are of order 0.

NIC: Connectx-5 100 Gbps.
CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz

Test:
128 TCP streams (using super_netperf).
Changing num of RX queues.
HW LRO OFF, GRO ON, MTU 1500.
Observe: BW as a function of num RX queues.

Results:

Driver #1:
#rings	BW (Mbps)
1	23,813
2	44,086
3	62,128
4	78,058
6	94,210 (linerate)
8	94,205 (linerate)
12	94,202 (linerate)
16	94,191 (linerate)

Driver #2:
#rings	BW (Mbps)
1	18,835
2	36,716
3	50,521
4	61,746
6	63,637
8	60,299
12	51,048
16	43,337

Driver #3:
#rings	BW (Mbps)
1	19,316
2	44,850
3	69,549
4	87,434
6	94,342 (linerate)
8	94,350 (linerate)
12	94,327 (linerate)
16	94,327 (linerate)


Insights:
Major degradation between #1 and #2, not getting any close to linerate!
Degradation is fixed between #2 and #3.
This is because page allocator cannot stand the higher allocation rate.
In #2, we also see that the addition of rings (cores) reduces BW (!!), 
as result of increasing congestion over shared resources.

Congestion in this case is very clear.
When monitored in perf top:
85.58% [kernel] [k] queued_spin_lock_slowpath

I think that page allocator issues should be discussed separately:
1) Rate: Increase the allocation rate on a single core.
2) Scalability: Reduce congestion and sync overhead between cores.

This is clearly the current bottleneck in the network stack receive flow.

I know about some efforts that were made in the past two years.
For example the ones from Jesper et al.:
- Page-pool (not accepted AFAIK).
- Page-allocation bulking.
- Optimize order-0 allocations in Per-Cpu-Pages.

I am not an mm expert, but wanted to raise the issue again, to combine 
the efforts and hear from you guys about status and possible directions.

Best regards,
Tariq Toukan
