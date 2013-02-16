From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 0/3] v3 GRE: TCP segmentation offload
Date: Fri, 15 Feb 2013 17:41:28 -0800
Message-ID: <CALnjE+qsY14H2=PhdPi3yFX7UgBHJgm79z_amw54A4BhEm5hkA@mail.gmail.com>
References: <1360871081-1987-1-git-send-email-pshelar@nicira.com>
	<20130215.151824.1125629773152171791.davem@davemloft.net>
	<1360975955.19353.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com, jesse@nicira.com, bhutchings@solarflare.com,
	mirqus@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:47772 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750858Ab3BPBl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:41:29 -0500
Received: by mail-ve0-f197.google.com with SMTP id 15so5801255vea.4
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:41:28 -0800 (PST)
In-Reply-To: <1360975955.19353.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 4:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-02-15 at 15:18 -0500, David Miller wrote:
>
>> All applied, incorporating the suggestions/fixes from Eric.  Specifically,
>> using skb_reset_mac_len() in patch #2 and computing pkt_len before ip_local_out()
>> in patch #3.
>
> Thanks David
>
> There is this "tx-nocache-copy" issue :
>
> We currently enable the nocache copy for all devices but loopback.
>
> But its a loss of performance with tunnel devices
>
> Actually, it seems a loss even for regular ethernet devices :(
>
>
>
> # ethtool -K gre1 tx-nocache-copy on
> # perf stat netperf -H 7.7.8.84
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.8.84 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>
>  87380  16384  16384    10.00    4252.42
>
>  Performance counter stats for 'netperf -H 7.7.8.84':
>
>        9967.965824 task-clock                #    0.996 CPUs utilized
>                 54 context-switches          #    0.005 K/sec
>                  3 CPU-migrations            #    0.000 K/sec
>                261 page-faults               #    0.026 K/sec
>     27,964,187,393 cycles                    #    2.805 GHz
>     20,902,040,632 stalled-cycles-frontend   #   74.75% frontend cycles idle
>     13,524,565,776 stalled-cycles-backend    #   48.36% backend  cycles idle
>     15,929,463,578 instructions              #    0.57  insns per cycle
>                                              #    1.31  stalled cycles per insn
>      2,065,830,063 branches                  #  207.247 M/sec
>         35,891,035 branch-misses             #    1.74% of all branches
>
>       10.003882959 seconds time elapsed
>
>
> Now we use regular memory copy :
>
> # ethtool -K gre1 tx-nocache-copy off
> # perf stat netperf -H 7.7.8.84
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.8.84 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>
>  87380  16384  16384    10.00    7706.50
>
>  Performance counter stats for 'netperf -H 7.7.8.84':
>
>        5708.284991 task-clock                #    0.571 CPUs utilized
>              5,138 context-switches          #    0.900 K/sec
>                 24 CPU-migrations            #    0.004 K/sec
>                260 page-faults               #    0.046 K/sec
>     15,990,404,388 cycles                    #    2.801 GHz
>     10,903,764,099 stalled-cycles-frontend   #   68.19% frontend cycles idle
>      6,089,332,139 stalled-cycles-backend    #   38.08% backend  cycles idle
>     10,680,845,426 instructions              #    0.67  insns per cycle
>                                              #    1.02  stalled cycles per insn
>      1,401,663,288 branches                  #  245.549 M/sec
>         15,380,428 branch-misses             #    1.10% of all branches
>
>       10.004025020 seconds time elapsed
>
>

I am not seeing such big difference with these setting, are you
running this test on special hardware or in VM?

Thanks,
Pravin.
