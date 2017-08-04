From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: User per-cpu 64-bit statistics
Date: Fri, 4 Aug 2017 08:51:54 -0700
Message-ID: <455c39d3-302e-68ab-3812-112c48ed48c2@gmail.com>
References: <20170804043328.4730-1-f.fainelli@gmail.com>
 <1501824968.25002.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemlot.net,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501824968.25002.35.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2017 10:36 PM, Eric Dumazet wrote:
> On Thu, 2017-08-03 at 21:33 -0700, Florian Fainelli wrote:
>> During testing with a background iperf pushing 1Gbit/sec worth of
>> traffic and having both ifconfig and ethtool collect statistics, we
>> could see quite frequent deadlocks. Convert the often accessed DSA slave
>> network devices statistics to per-cpu 64-bit statistics to remove these
>> deadlocks and provide fast efficient statistics updates.
>>
> 
> This seems to be a bug fix, it would be nice to get a proper tag like :
> 
> Fixes: f613ed665bb3 ("net: dsa: Add support for 64-bit statistics")

Right, should have been added, thanks!

> 
> Problem here is that if multiple cpus can call dsa_switch_rcv() at the
> same time, then u64_stats_update_begin() contract is not respected.

This is really where I struggled understanding what is wrong in the
non-per CPU version, my understanding is that we have:

- writers for xmit executes in process context
- writers for receive executes from NAPI (from the DSA's master network
device through it's own NAPI doing netif_receive_skb -> netdev_uses_dsa
-> netif_receive_skb)

readers should all execute in process context. The test scenario that
led to a deadlock involved running iperf in the background, having a
while loop with both ifconfig and ethtool reading stats, and somehow
when iperf exited, either reader would just be locked. So I guess this
leaves us with the two writers not being mutually excluded then, right?

> 
> include/linux/u64_stats_sync.h states :
> 
>  * Usage :
>  *
>  * Stats producer (writer) should use following template granted it already got
>  * an exclusive access to counters (a lock is already taken, or per cpu
>  * data is used [in a non preemptable context])
>  *
>  *   spin_lock_bh(...) or other synchronization to get exclusive access
>  *   ...
>  *   u64_stats_update_begin(&stats->syncp);
> 
> 
> 

-- 
Florian
