From: Traiano Welcome <traiano@gmail.com>
Subject: Re: Kernel Performance Tuning for High Volume SCTP traffic
Date: Sat, 14 Oct 2017 00:03:54 +0800
Message-ID: <CAFKCRVLTA8Vrz-36rxfUtOf8Zc9mSPZteAgdyeETsqSa-XsOcQ@mail.gmail.com>
References: <CAFKCRVL-e03Cn35-Vvtb8+NSAz3Tk2Hje_Hg5K9HfqgokEBPgg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0094F48@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:48272 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdJMQD4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 12:03:56 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0094F48@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

On Fri, Oct 13, 2017 at 11:56 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Traiano Welcome
>
> (copied to netdev)
>> Sent: 13 October 2017 07:16
>> To: linux-sctp@vger.kernel.org
>> Subject: Kernel Performance Tuning for High Volume SCTP traffic
>>
>> Hi List
>>
>> I'm running a linux server processing high volumes of SCTP traffic and
>> am seeing large numbers of packet overruns (ifconfig output).
>
> I'd guess that overruns indicate that the ethernet MAC is failing to
> copy the receive frames into kernel memory.
> It is probably running out of receive buffers, but might be
> suffering from a lack of bus bandwidth.
> MAC drivers usually discard receive frames if they can't get
> a replacement buffer - so you shouldn't run out of rx buffers.
>
> This means the errors are probably below SCTP - so changing SCTP parameters
> is unlikely to help.
>


Does this mean that tuning UDP performance could help ? Or do you mean
hardware (NIC) performance could be the issue?



> I'd make sure any receive interrupt coalescing/mitigation is turned off.
>

I'll try that.



>         David
>
>
>> I think a large amount of performance tuning can probably be done to
>> improve the linux kernel's SCTP handling performance, but there seem
>> to be no guides on this available. Could anyone advise on this?
>>
>>
>> Here are my current settings, and below, some stats:
>>
>>
>> -----
>> net.sctp.addip_enable = 0
>> net.sctp.addip_noauth_enable = 0
>> net.sctp.addr_scope_policy = 1
>> net.sctp.association_max_retrans = 10
>> net.sctp.auth_enable = 0
>> net.sctp.cookie_hmac_alg = sha1
>> net.sctp.cookie_preserve_enable = 1
>> net.sctp.default_auto_asconf = 0
>> net.sctp.hb_interval = 30000
>> net.sctp.max_autoclose = 8589934
>> net.sctp.max_burst = 40
>> net.sctp.max_init_retransmits = 8
>> net.sctp.path_max_retrans = 5
>> net.sctp.pf_enable = 1
>> net.sctp.pf_retrans = 0
>> net.sctp.prsctp_enable = 1
>> net.sctp.rcvbuf_policy = 0
>> net.sctp.rto_alpha_exp_divisor = 3
>> net.sctp.rto_beta_exp_divisor = 2
>> net.sctp.rto_initial = 3000
>> net.sctp.rto_max = 60000
>> net.sctp.rto_min = 1000
>> net.sctp.rwnd_update_shift = 4
>> net.sctp.sack_timeout = 50
>> net.sctp.sctp_mem = 61733040 82310730 123466080
>> net.sctp.sctp_rmem = 40960 8655000 41943040
>> net.sctp.sctp_wmem = 40960 8655000 41943040
>> net.sctp.sndbuf_policy = 0
>> net.sctp.valid_cookie_life = 60000
>> -----
>>
>>
>> I'm seeing a high rate of packet errors (almost all overruns) on both
>> 10gb NICs attached to my linux server.
>>
>> The system is handling high volumes of network traffic, so this is
>> likely a linux kernel tuning problem.
>>
>> All the normal tuning parameters I've tried thus far seems to be
>> having little effect and I'm still seeing high volumes of packet
>> overruns.
>>
>> Any pointers on other things I could try to get the system handling
>> SCTP packets efficiently would be much appreciated!
>>
>> -----
>> :~# ifconfig ens4f1
>>
>> ens4f1    Link encap:Ethernet  HWaddr 5c:b9:01:de:0d:4c
>>           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:9000  Metric:1
>>           RX packets:22313514162 errors:17598241316 dropped:68
>> overruns:17598241316 frame:0
>>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:1000
>>           RX bytes:31767480894219 (31.7 TB)  TX bytes:0 (0.0 B)
>>           Interrupt:17 Memory:c9800000-c9ffffff
>> -----
>>
>> System details:
>>
>> OS        : Ubuntu Linux (4.11.0-14-generic #20~16.04.1-Ubuntu SMP x86_64 )
>> CPU Cores : 72
>> NIC Model : NetXtreme II BCM57810 10 Gigabit Ethernet
>> RAM       : 240 GiB
>>
>> NIC sample stats showing packet error rate:
>>
>> ----
>>
>> for i in `seq 1 10`;do echo "$i) `date`" - $(ifconfig ens4f0| egrep
>> "RX"| egrep overruns;sleep 5);done
>>
>> 1) Thu Oct 12 19:50:40 SGT 2017 - RX packets:8364065830
>> errors:2594507718 dropped:215 overruns:2594507718 frame:0
>> 2) Thu Oct 12 19:50:45 SGT 2017 - RX packets:8365336060
>> errors:2596662672 dropped:215 overruns:2596662672 frame:0
>> 3) Thu Oct 12 19:50:50 SGT 2017 - RX packets:8366602087
>> errors:2598840959 dropped:215 overruns:2598840959 frame:0
>> 4) Thu Oct 12 19:50:55 SGT 2017 - RX packets:8367881271
>> errors:2600989229 dropped:215 overruns:2600989229 frame:0
>> 5) Thu Oct 12 19:51:01 SGT 2017 - RX packets:8369147536
>> errors:2603157030 dropped:215 overruns:2603157030frame:0
>> 6) Thu Oct 12 19:51:06 SGT 2017 - RX packets:8370149567
>> errors:2604904183 dropped:215 overruns:2604904183frame:0
>> 7) Thu Oct 12 19:51:11 SGT 2017 - RX packets:8371298018
>> errors:2607183939 dropped:215 overruns:2607183939frame:0
>> 8) Thu Oct 12 19:51:16 SGT 2017 - RX packets:8372455587
>> errors:2609411186 dropped:215 overruns:2609411186frame:0
>> 9) Thu Oct 12 19:51:21 SGT 2017 - RX packets:8373585102
>> errors:2611680597 dropped:215 overruns:2611680597 frame:0
>> 10) Thu Oct 12 19:51:26 SGT 2017 - RX packets:8374678508
>> errors:2614053000 dropped:215 overruns:2614053000 frame:0
>>
>> ----
>>
>> However, checking (with tc) shows no ring buffer overruns on NIC:
>>
>> ----
>>
>> tc -s qdisc show dev ens4f0|egrep drop
>>
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>
>> -----
>>
>> Checking tcp retransmits, the rate is low:
>>
>> -----
>>
>> for i in `seq 1 10`;do echo "`date`" - $(netstat -s | grep -i
>> retransmited;sleep 2);done
>>
>> Thu Oct 12 20:04:29 SGT 2017 - 10633 segments retransmited
>> Thu Oct 12 20:04:31 SGT 2017 - 10634 segments retransmited
>> Thu Oct 12 20:04:33 SGT 2017 - 10636 segments retransmited
>> Thu Oct 12 20:04:35 SGT 2017 - 10636 segments retransmited
>> Thu Oct 12 20:04:37 SGT 2017 - 10638 segments retransmited
>> Thu Oct 12 20:04:39 SGT 2017 - 10639 segments retransmited
>> Thu Oct 12 20:04:41 SGT 2017 - 10640 segments retransmited
>> Thu Oct 12 20:04:43 SGT 2017 - 10640 segments retransmited
>> Thu Oct 12 20:04:45 SGT 2017 - 10643 segments retransmited
>>
>> ------
>>
>> What I've tried so far:
>>
>> - Tuning the NIC parameters (packet coalesce, offloading, upping NIC
>> ring buffers etc ...):
>>
>> ethtool -L ens4f0 combined 30
>> ethtool -K ens4f0 gso on rx on tx on sg on tso on
>> ethtool -C ens4f0 rx-usecs 96
>> ethtool -C ens4f0 adaptive-rx on
>> ethtool -G ens4f0 rx 4078 tx 4078
>>
>> - sysctl tunables for the kernel (mainly increasing kernel tcp buffers):
>>
>> ---
>>
>> sysctl -w net.ipv4.tcp_low_latency=1
>> sysctl -w net.ipv4.tcp_max_syn_backlog=16384
>> sysctl -w net.core.optmem_max=20480000
>> sysctl -w net.core.netdev_max_backlog=5000000
>> sysctl -w net.ipv4.tcp_rmem="65536 1747600 83886080"
>> sysctl -w net.core.somaxconn=1280
>> sysctl -w kernel.sched_min_granularity_ns=10000000
>> sysctl -w kernel.sched_wakeup_granularity_ns=15000000
>> sysctl -w net.ipv4.tcp_wmem="65536 1747600 83886080"
>> sysctl -w net.core.wmem_max=2147483647
>> sysctl -w net.core.wmem_default=2147483647
>> sysctl -w net.core.rmem_max=2147483647
>> sysctl -w net.core.rmem_default=2147483647
>> sysctl -w net.ipv4.tcp_congestion_control=cubic
>> sysctl -w net.ipv4.tcp_rmem="163840 3495200 268754560"
>> sysctl -w net.ipv4.tcp_wmem="163840 3495200 268754560"
>> sysctl -w net.ipv4.udp_rmem_min="163840 3495200 268754560"
>> sysctl -w net.ipv4.udp_wmem_min="163840 3495200 268754560"
>> sysctl -w net.ipv4.tcp_mem="268754560 268754560 268754560"
>> sysctl -w net.ipv4.udp_mem="268754560 268754560 268754560"
>> sysctl -w net.ipv4.tcp_mtu_probing=1
>> sysctl -w net.ipv4.tcp_slow_start_after_idle=0
>>
>>
>> Results after this (apparently not much):
>>
>>
>> ----
>>
>> :~# for i in `seq 1 10`;do echo "$i) `date`" - $(ifconfig ens4f1|
>> egrep "RX"| egrep overruns;sleep 5);done
>>
>> 1) Thu Oct 12 20:42:56 SGT 2017 - RX packets:16260617113
>> errors:10964865836 dropped:68 overruns:10964865836 frame:0
>> 2) Thu Oct 12 20:43:01 SGT 2017 - RX packets:16263268608
>> errors:10969589847 dropped:68 overruns:10969589847 frame:0
>> 3) Thu Oct 12 20:43:06 SGT 2017 - RX packets:16265869693
>> errors:10974489639 dropped:68 overruns:10974489639 frame:0
>> 4) Thu Oct 12 20:43:11 SGT 2017 - RX packets:16268487078
>> errors:10979323070 dropped:68 overruns:10979323070 frame:0
>> 5) Thu Oct 12 20:43:16 SGT 2017 - RX packets:16271098501
>> errors:10984193349 dropped:68 overruns:10984193349 frame:0
>> 6) Thu Oct 12 20:43:21 SGT 2017 - RX packets:16273804004
>> errors:10988857622 dropped:68 overruns:10988857622 frame:0
>> 7) Thu Oct 12 20:43:26 SGT 2017 - RX packets:16276493470
>> errors:10993340211 dropped:68 overruns:10993340211 frame:0
>> 8) Thu Oct 12 20:43:31 SGT 2017 - RX packets:16278612090
>> errors:10997152436 dropped:68 overruns:10997152436 frame:0
>> 9) Thu Oct 12 20:43:36 SGT 2017 - RX packets:16281253727
>> errors:11001834579 dropped:68 overruns:11001834579 frame:0
>> 10) Thu Oct 12 20:43:41 SGT 2017 - RX packets:16283972622
>> errors:11006374277 dropped:68 overruns:11006374277 frame:0
>>
>> ----
>>
>> Freak the CPU for better performance:
>>
>> cpufreq-set -r -g performance
>>
>> Results (nothing significant):
>>
>> ----
>>
>> :~# for i in `seq 1 10`;do echo "$i) `date`" - $(ifconfig ens4f1|
>> egrep "RX"| egrep overruns;sleep 5);done
>>
>> 1) Thu Oct 12 21:53:07 SGT 2017 - RX packets:18506492788
>> errors:14622639426 dropped:68 overruns:14622639426 frame:0
>> 2) Thu Oct 12 21:53:12 SGT 2017 - RX packets:18509314581
>> errors:14626750641 dropped:68 overruns:14626750641 frame:0
>> 3) Thu Oct 12 21:53:17 SGT 2017 - RX packets:18511485458
>> errors:14630268859 dropped:68 overruns:14630268859 frame:0
>> 4) Thu Oct 12 21:53:22 SGT 2017 - RX packets:18514223562
>> errors:14634547845 dropped:68 overruns:14634547845 frame:0
>> 5) Thu Oct 12 21:53:27 SGT 2017 - RX packets:18516926578
>> errors:14638745143 dropped:68 overruns:14638745143 frame:0
>> 6) Thu Oct 12 21:53:32 SGT 2017 - RX packets:18519605412
>> errors:14642929021 dropped:68 overruns:14642929021 frame:0
>> 7) Thu Oct 12 21:53:37 SGT 2017 - RX packets:18522523560
>> errors:14647108982 dropped:68 overruns:14647108982 frame:0
>> 8) Thu Oct 12 21:53:42 SGT 2017 - RX packets:18525185869
>> errors:14651577286 dropped:68 overruns:14651577286 frame:0
>> 9) Thu Oct 12 21:53:47 SGT 2017 - RX packets:18527947266
>> errors:14655961847 dropped:68 overruns:14655961847 frame:0
>> 10) Thu Oct 12 21:53:52 SGT 2017 - RX packets:18530703288
>> errors:14659988398 dropped:68 overruns:14659988398 frame:0
>>
>> ----
>>
>> Results using sar:
>>
>> ----
>>
>> :~# sar -n EDEV 5 3| egrep "(ens4f1|IFACE)"
>>
>> 11:17:43 PM     IFACE   rxerr/s   txerr/s    coll/s  rxdrop/s
>> txdrop/s  txcarr/s  rxfram/s  rxfifo/s  txfifo/s
>> 11:17:48 PM    ens4f1 360809.40      0.00      0.00      0.00
>> 0.00      0.00      0.00 360809.40      0.00
>> 11:17:53 PM    ens4f1 382500.40      0.00      0.00      0.00
>> 0.00      0.00      0.00 382500.40      0.00
>> 11:17:58 PM    ens4f1 353717.00      0.00      0.00      0.00
>> 0.00      0.00      0.00 353717.00      0.00
>> Average:       ens4f1 365675.60      0.00      0.00      0.00
>> 0.00      0.00      0.00 365675.60      0.00
>>
>> ----
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
