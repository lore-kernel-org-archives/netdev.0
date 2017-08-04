From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: User per-cpu 64-bit statistics
Date: Thu, 03 Aug 2017 22:36:08 -0700
Message-ID: <1501824968.25002.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170804043328.4730-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemlot.net,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170804043328.4730-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-08-03 at 21:33 -0700, Florian Fainelli wrote:
> During testing with a background iperf pushing 1Gbit/sec worth of
> traffic and having both ifconfig and ethtool collect statistics, we
> could see quite frequent deadlocks. Convert the often accessed DSA slave
> network devices statistics to per-cpu 64-bit statistics to remove these
> deadlocks and provide fast efficient statistics updates.
> 

This seems to be a bug fix, it would be nice to get a proper tag like :

Fixes: f613ed665bb3 ("net: dsa: Add support for 64-bit statistics")

Problem here is that if multiple cpus can call dsa_switch_rcv() at the
same time, then u64_stats_update_begin() contract is not respected.

include/linux/u64_stats_sync.h states :

 * Usage :
 *
 * Stats producer (writer) should use following template granted it already got
 * an exclusive access to counters (a lock is already taken, or per cpu
 * data is used [in a non preemptable context])
 *
 *   spin_lock_bh(...) or other synchronization to get exclusive access
 *   ...
 *   u64_stats_update_begin(&stats->syncp);
