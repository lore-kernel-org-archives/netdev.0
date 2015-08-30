From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V4 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Sun, 30 Aug 2015 08:52:09 -0700
Message-ID: <1440949929.8932.150.camel@edumazet-glaptop2.roam.corp.google.com>
References: <y>
	 <1440914382-23126-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <1440914382-23126-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jiri@resnulli.us,
	edumazet@google.com, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@au1.ibm.com, nacc@linux.vnet.ibm.com,
	srikar@linux.vnet.ibm.com
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440914382-23126-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-08-30 at 11:29 +0530, Raghavendra K T wrote:
> Docker container creation linearly increased from around 1.6 sec to 7.5 sec
> (at 1000 containers) and perf data showed 50% ovehead in snmp_fold_field.
> 
> reason: currently __snmp6_fill_stats64 calls snmp_fold_field that walks
> through per cpu data of an item (iteratively for around 36 items).
> 
> idea: This patch tries to aggregate the statistics by going through
> all the items of each cpu sequentially which is reducing cache
> misses.
> 
> Docker creation got faster by more than 2x after the patch.
> 
> Result:
>                        Before           After
> Docker creation time   6.836s           3.25s
> cache miss             2.7%             1.41%
> 
> perf before:
>     50.73%  docker           [kernel.kallsyms]       [k] snmp_fold_field
>      9.07%  swapper          [kernel.kallsyms]       [k] snooze_loop
>      3.49%  docker           [kernel.kallsyms]       [k] veth_stats_one
>      2.85%  swapper          [kernel.kallsyms]       [k] _raw_spin_lock
> 
> perf after:
>     10.57%  docker           docker                [.] scanblock
>      8.37%  swapper          [kernel.kallsyms]     [k] snooze_loop
>      6.91%  docker           [kernel.kallsyms]     [k] snmp_get_cpu_field
>      6.67%  docker           [kernel.kallsyms]     [k] veth_stats_one
> 
> changes/ideas suggested:
> Using buffer in stack (Eric), Usage of memset (David), Using memcpy in
> place of unaligned_put (Joe).
> 
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks.
