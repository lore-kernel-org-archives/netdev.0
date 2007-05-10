From: rhee@ncsu.edu
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Thu, 10 May 2007 14:39:25 -0400 (EDT)
Message-ID: <2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu>
References: <20070506203736.648c09d9.billfink@mindspring.com>
    <649aecc70705080241p7e715a8bw801555709051534d@mail.gmail.com>
    <20070509023131.70e2cc45.billfink@mindspring.com>
    <20070510113215.f5ff2d34.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Bill Fink" <billfink@mindspring.com>,
	"SANGTAE HA" <sangtae.ha@gmail.com>,
	"Linux Network Developers" <netdev@vger.kernel.org>
To: "Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni21wi.unity.ncsu.edu ([152.1.227.221]:41961 "EHLO
	uni21wi.unity.ncsu.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbXEJTkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 15:40:37 -0400
In-Reply-To: <20070510113215.f5ff2d34.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Bill,
Could you test with the lastest version of CUBIC? this is not the latest
version of it you tested.
Injong

> As a followup, I ran a somewhat interesting test.  I increased the
> requested socket buffer size to 100 MB, which is sufficient to
> overstress the capabilities of the netem delay emulator (which can
> handle up to about 8.5 Gbps).  This causes some packet loss when
> using the standard Reno agressive "slow start".
>
> [root@lang2 ~]# netstat -s | grep -i retrans
>     0 segments retransmited
>
> [root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
> cubic
>
> [root@lang2 ~]# echo 0 > /sys/module/tcp_cubic/parameters/initial_ssthresh
> [root@lang2 ~]# cat /sys/module/tcp_cubic/parameters/initial_ssthresh
> 0
>
> [root@lang2 ~]# nuttcp -T10 -i1 -w100m 192.168.89.15
>    69.9829 MB /   1.00 sec =  585.1895 Mbps
>   311.9521 MB /   1.00 sec = 2616.9019 Mbps
>     0.2332 MB /   1.00 sec =    1.9559 Mbps
>    37.9907 MB /   1.00 sec =  318.6912 Mbps
>   702.7856 MB /   1.00 sec = 5895.4640 Mbps
>   817.0142 MB /   1.00 sec = 6853.7006 Mbps
>   820.3125 MB /   1.00 sec = 6881.3626 Mbps
>   820.5625 MB /   1.00 sec = 6883.2601 Mbps
>   813.0125 MB /   1.00 sec = 6820.2678 Mbps
>   815.7756 MB /   1.00 sec = 6842.8867 Mbps
>
>  5253.2500 MB /  10.07 sec = 4378.0109 Mbps 72 %TX 35 %RX
>
> [root@lang2 ~]# netstat -s | grep -i retrans
>     464 segments retransmited
>     464 fast retransmits
>
> Contrast that with the default behavior.
>
> [root@lang2 ~]# echo 100 >
> /sys/module/tcp_cubic/parameters/initial_ssthresh
> [root@lang2 ~]# cat /sys/module/tcp_cubic/parameters/initial_ssthresh
> 100
>
> [root@lang2 ~]# nuttcp -T10 -i1 -w100m 192.168.89.15
>     6.8188 MB /   1.00 sec =   57.1670 Mbps
>    16.2097 MB /   1.00 sec =  135.9795 Mbps
>    25.4810 MB /   1.00 sec =  213.7525 Mbps
>    38.7256 MB /   1.00 sec =  324.8580 Mbps
>    49.7998 MB /   1.00 sec =  417.7565 Mbps
>    62.5745 MB /   1.00 sec =  524.9189 Mbps
>    78.6646 MB /   1.00 sec =  659.8947 Mbps
>    98.9673 MB /   1.00 sec =  830.2086 Mbps
>   124.3201 MB /   1.00 sec = 1038.7288 Mbps
>   156.1584 MB /   1.00 sec = 1309.9730 Mbps
>
>   775.2500 MB /  10.64 sec =  611.0181 Mbps 7 %TX 7 %RX
>
> [root@lang2 ~]# netstat -s | grep -i retrans
>     464 segments retransmited
>     464 fast retransmits
>
> The standard Reno aggressive "slow start" gets much better overall
> performance even in this case, because even though the default cubic
> behavior manages to avoid the "congestion" event, its lack of
> aggressiveness during the initial slow start period puts it at a
> major disadvantage.  It would take a long time for the tortoise
> in this race to catch up with the hare.
>
> It seems best to ramp up as quickly as possible to any congestion,
> using the standard Reno aggressive "slow start" behavior, and then
> let the power of cubic take over from there, getting the best of
> both worlds.
>
> For completeness here's the same test with bic.
>
> First with the standard Reno aggessive "slow start" behavior:
>
> [root@lang2 ~]# netstat -s | grep -i retrans
>     464 segments retransmited
>     464 fast retransmits
>
> [root@lang2 ~]# echo bic > /proc/sys/net/ipv4/tcp_congestion_control
> [root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
> bic
>
> [root@lang2 ~]# echo 0 > /sys/module/tcp_bic/parameters/initial_ssthresh
> [root@lang2 ~]# cat /sys/module/tcp_bic/parameters/initial_ssthresh
> 0
>
> [root@lang2 ~]# nuttcp -T10 -i1 -w100m 192.168.89.15
>    69.9829 MB /   1.00 sec =  585.2770 Mbps
>   302.3921 MB /   1.00 sec = 2536.7045 Mbps
>     0.0000 MB /   1.00 sec =    0.0000 Mbps
>     0.7520 MB /   1.00 sec =    6.3079 Mbps
>   114.1570 MB /   1.00 sec =  957.5914 Mbps
>   792.9634 MB /   1.00 sec = 6651.5131 Mbps
>   845.9099 MB /   1.00 sec = 7096.4182 Mbps
>   865.0825 MB /   1.00 sec = 7257.1575 Mbps
>   890.4663 MB /   1.00 sec = 7470.0567 Mbps
>   911.5039 MB /   1.00 sec = 7646.3560 Mbps
>
>  4829.9375 MB /  10.05 sec = 4033.0191 Mbps 76 %TX 32 %RX
>
> [root@lang2 ~]# netstat -s | grep -i retrans
>     1093 segments retransmited
>     1093 fast retransmits
>
> And then with the default bic behavior:
>
> [root@lang2 ~]# echo 100 > /sys/module/tcp_bic/parameters/initial_ssthresh
> [root@lang2 ~]# cat /sys/module/tcp_bic/parameters/initial_ssthresh
> 100
>
> [root@lang2 ~]# nuttcp -T10 -i1 -w100m 192.168.89.15
>     9.9548 MB /   1.00 sec =   83.1028 Mbps
>    47.5439 MB /   1.00 sec =  398.8351 Mbps
>   107.6147 MB /   1.00 sec =  902.7506 Mbps
>   183.9038 MB /   1.00 sec = 1542.7124 Mbps
>   313.4875 MB /   1.00 sec = 2629.7689 Mbps
>   531.0012 MB /   1.00 sec = 4454.3032 Mbps
>   841.7866 MB /   1.00 sec = 7061.5098 Mbps
>   837.5867 MB /   1.00 sec = 7026.4041 Mbps
>   834.8889 MB /   1.00 sec = 7003.3667 Mbps
>
>  4539.6250 MB /  10.00 sec = 3806.5410 Mbps 50 %TX 34 %RX
>
> [root@lang2 ~]# netstat -s | grep -i retrans
>     1093 segments retransmited
>     1093 fast retransmits
>
> bic actually does much better than cubic for this scenario, and only
> loses out to the standard Reno aggressive "slow start" behavior by a
> small amount.  Of course in the case of no congestion, it loses out
> by a much more significant margin.
>
> This reinforces my belief that it's best to marry the standard Reno
> aggressive initial "slow start" behavior with the better performance
> of bic or cubic during the subsequent steady state portion of the
> TCP session.
>
> I can of course achieve that objective by setting initial_ssthresh
> to 0, but perhaps that should be made the default behavior.
>
> 						-Bill
>
>
>
> On Wed, 9 May 2007, I wrote:
>
>> Hi Sangtae,
>>
>> On Tue, 8 May 2007, SANGTAE HA wrote:
>>
>> > Hi Bill,
>> >
>> > At this time, BIC and CUBIC use a less aggressive slow start than
>> > other protocols. Because we observed "slow start" is somewhat
>> > aggressive and introduced a lot of packet losses. This may be changed
>> > to standard "slow start" in later version of BIC and CUBIC, but, at
>> > this time, we still using a modified slow start.
>>
>> "slow start" is somewhat of a misnomer.  However, I'd argue in favor
>> of using the standard "slow start" for BIC and CUBIC as the default.
>> Is the rationale for using a less agressive "slow start" to be gentler
>> to certain receivers, which possibly can't handle a rapidly increasing
>> initial burst of packets (and the resultant necessary allocation of
>> system resources)?  Or is it related to encountering actual network
>> congestion during the initial "slow start" period, and how well that
>> is responded to?
>>
>> > So, as you observed, this modified slow start behavior may slow for
>> > 10G testing. You can alleviate this for your 10G testing by changing
>> > BIC and CUBIC to use a standard "slow start" by loading these modules
>> > with "initial_ssthresh=0".
>>
>> I saw the initial_ssthresh parameter, but didn't know what it did or
>> even what its units were.  I saw the default value was 100 and tried
>> increasing it, but I didn't think to try setting it to 0.
>>
>> [root@lang2 ~]# grep -r initial_ssthresh
>> /usr/src/kernels/linux-2.6.20.7/Documentation/
>> [root@lang2 ~]#
>>
>> It would be good to have some documentation for these bic and cubic
>> parameters similar to the documentation in ip-sysctl.txt for the
>> /proc/sys/net/ipv[46]/* variables (I know, I know, I should just
>> "use the source").
>>
>> Is it expected that the cubic "slow start" is that much less agressive
>> than the bic "slow start" (from 10 secs to max rate for bic in my test
>> to 25 secs to max rate for cubic).  This could be considered a
>> performance
>> regression since the default TCP was changed from bic to cubic.
>>
>> In any event, I'm now happy as setting initial_ssthresh to 0 works
>> well for me.
>>
>> [root@lang2 ~]# netstat -s | grep -i retrans
>>     0 segments retransmited
>>
>> [root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
>> cubic
>>
>> [root@lang2 ~]# cat /sys/module/tcp_cubic/parameters/initial_ssthresh
>> 0
>>
>> [root@lang2 ~]# nuttcp -T10 -i1 -w60m 192.168.89.15
>>    69.9829 MB /   1.00 sec =  584.2065 Mbps
>>   843.1467 MB /   1.00 sec = 7072.9052 Mbps
>>   844.3655 MB /   1.00 sec = 7082.6544 Mbps
>>   842.2671 MB /   1.00 sec = 7065.7169 Mbps
>>   839.9204 MB /   1.00 sec = 7045.8335 Mbps
>>   840.1780 MB /   1.00 sec = 7048.3114 Mbps
>>   834.1475 MB /   1.00 sec = 6997.4270 Mbps
>>   835.5972 MB /   1.00 sec = 7009.3148 Mbps
>>   835.8152 MB /   1.00 sec = 7011.7537 Mbps
>>   830.9333 MB /   1.00 sec = 6969.9281 Mbps
>>
>>  7617.1875 MB /  10.01 sec = 6386.2622 Mbps 90 %TX 46 %RX
>>
>> [root@lang2 ~]# netstat -s | grep -i retrans
>>     0 segments retransmited
>>
>> 						-Thanks a lot!
>>
>> 						-Bill
>>
>>
>>
>> > Regards,
>> > Sangtae
>> >
>> >
>> > On 5/6/07, Bill Fink <billfink@mindspring.com> wrote:
>> > > The initial TCP slow start on 2.6.20.7 cubic (and to a lesser
>> > > extent bic) seems to be way too slow.  With an ~80 ms RTT, this
>> > > is what cubic delivers (thirty second test with one second interval
>> > > reporting and specifying a socket buffer size of 60 MB):
>> > >
>> > > [root@lang2 ~]# netstat -s | grep -i retrans
>> > >     0 segments retransmited
>> > >
>> > > [root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
>> > > cubic
>> > >
>> > > [root@lang2 ~]# nuttcp -T30 -i1 -w60m 192.168.89.15
>> > >     6.8188 MB /   1.00 sec =   57.0365 Mbps
>> > >    16.2097 MB /   1.00 sec =  135.9824 Mbps
>> > >    25.4553 MB /   1.00 sec =  213.5420 Mbps
>> > >    35.5127 MB /   1.00 sec =  297.9119 Mbps
>> > >    43.0066 MB /   1.00 sec =  360.7770 Mbps
>> > >    50.3210 MB /   1.00 sec =  422.1370 Mbps
>> > >    59.0796 MB /   1.00 sec =  495.6124 Mbps
>> > >    69.1284 MB /   1.00 sec =  579.9098 Mbps
>> > >    76.6479 MB /   1.00 sec =  642.9130 Mbps
>> > >    90.6189 MB /   1.00 sec =  760.2835 Mbps
>> > >   109.4348 MB /   1.00 sec =  918.0361 Mbps
>> > >   128.3105 MB /   1.00 sec = 1076.3813 Mbps
>> > >   150.4932 MB /   1.00 sec = 1262.4686 Mbps
>> > >   175.9229 MB /   1.00 sec = 1475.7965 Mbps
>> > >   205.9412 MB /   1.00 sec = 1727.6150 Mbps
>> > >   240.8130 MB /   1.00 sec = 2020.1504 Mbps
>> > >   282.1790 MB /   1.00 sec = 2367.1644 Mbps
>> > >   318.1841 MB /   1.00 sec = 2669.1349 Mbps
>> > >   372.6814 MB /   1.00 sec = 3126.1687 Mbps
>> > >   440.8411 MB /   1.00 sec = 3698.5200 Mbps
>> > >   524.8633 MB /   1.00 sec = 4403.0220 Mbps
>> > >   614.3542 MB /   1.00 sec = 5153.7367 Mbps
>> > >   718.9917 MB /   1.00 sec = 6031.5386 Mbps
>> > >   829.0474 MB /   1.00 sec = 6954.6438 Mbps
>> > >   867.3289 MB /   1.00 sec = 7275.9510 Mbps
>> > >   865.7759 MB /   1.00 sec = 7262.9813 Mbps
>> > >   864.4795 MB /   1.00 sec = 7251.7071 Mbps
>> > >   864.5425 MB /   1.00 sec = 7252.8519 Mbps
>> > >   867.3372 MB /   1.00 sec = 7246.9232 Mbps
>> > >
>> > > 10773.6875 MB /  30.00 sec = 3012.3936 Mbps 38 %TX 25 %RX
>> > >
>> > > [root@lang2 ~]# netstat -s | grep -i retrans
>> > >     0 segments retransmited
>> > >
>> > > It takes 25 seconds for cubic TCP to reach its maximal rate.
>> > > Note that there were no TCP retransmissions (no congestion
>> > > experienced).
>> > >
>> > > Now with bic (only 20 second test this time):
>> > >
>> > > [root@lang2 ~]# echo bic > /proc/sys/net/ipv4/tcp_congestion_control
>> > > [root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
>> > > bic
>> > >
>> > > [root@lang2 ~]# nuttcp -T20 -i1 -w60m 192.168.89.15
>> > >     9.9548 MB /   1.00 sec =   83.1497 Mbps
>> > >    47.2021 MB /   1.00 sec =  395.9762 Mbps
>> > >    92.4304 MB /   1.00 sec =  775.3889 Mbps
>> > >   134.3774 MB /   1.00 sec = 1127.2758 Mbps
>> > >   194.3286 MB /   1.00 sec = 1630.1987 Mbps
>> > >   280.0598 MB /   1.00 sec = 2349.3613 Mbps
>> > >   404.3201 MB /   1.00 sec = 3391.8250 Mbps
>> > >   559.1594 MB /   1.00 sec = 4690.6677 Mbps
>> > >   792.7100 MB /   1.00 sec = 6650.0257 Mbps
>> > >   857.2241 MB /   1.00 sec = 7190.6942 Mbps
>> > >   852.6912 MB /   1.00 sec = 7153.3283 Mbps
>> > >   852.6968 MB /   1.00 sec = 7153.2538 Mbps
>> > >   851.3162 MB /   1.00 sec = 7141.7575 Mbps
>> > >   851.4927 MB /   1.00 sec = 7143.0240 Mbps
>> > >   850.8782 MB /   1.00 sec = 7137.8762 Mbps
>> > >   852.7119 MB /   1.00 sec = 7153.2949 Mbps
>> > >   852.3879 MB /   1.00 sec = 7150.2982 Mbps
>> > >   850.2163 MB /   1.00 sec = 7132.5165 Mbps
>> > >   849.8340 MB /   1.00 sec = 7129.0026 Mbps
>> > >
>> > > 11882.7500 MB /  20.00 sec = 4984.0068 Mbps 67 %TX 41 %RX
>> > >
>> > > [root@lang2 ~]# netstat -s | grep -i retrans
>> > >     0 segments retransmited
>> > >
>> > > bic does better but still takes 10 seconds to achieve its maximal
>> > > rate.
>> > >
>> > > Surprisingly venerable reno does the best (only a 10 second test):
>> > >
>> > > [root@lang2 ~]# echo reno >
>> /proc/sys/net/ipv4/tcp_congestion_control
>> > > [root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
>> > > reno
>> > >
>> > > [root@lang2 ~]# nuttcp -T10 -i1 -w60m 192.168.89.15
>> > >    69.9829 MB /   1.01 sec =  583.5822 Mbps
>> > >   844.3870 MB /   1.00 sec = 7083.2808 Mbps
>> > >   862.7568 MB /   1.00 sec = 7237.7342 Mbps
>> > >   859.5725 MB /   1.00 sec = 7210.8981 Mbps
>> > >   860.1365 MB /   1.00 sec = 7215.4487 Mbps
>> > >   865.3940 MB /   1.00 sec = 7259.8434 Mbps
>> > >   863.9678 MB /   1.00 sec = 7247.4942 Mbps
>> > >   864.7493 MB /   1.00 sec = 7254.4634 Mbps
>> > >   864.6660 MB /   1.00 sec = 7253.5183 Mbps
>> > >
>> > >  7816.9375 MB /  10.00 sec = 6554.4883 Mbps 90 %TX 53 %RX
>> > >
>> > > [root@lang2 ~]# netstat -s | grep -i retrans
>> > >     0 segments retransmited
>> > >
>> > > reno achieves its maximal rate in about 2 seconds.  This is what I
>> > > would expect from the exponential increase during TCP's initial
>> > > slow start.  To achieve 10 Gbps on an 80 ms RTT with 9000 byte
>> > > jumbo frame packets would require:
>> > >
>> > >         [root@lang2 ~]# bc -l
>> > >         scale=10
>> > >         10^10*0.080/9000/8
>> > >         11111.1111111111
>> > >
>> > > So 11111 packets would have to be in flight during one RTT.
>> > > It should take log2(11111)+1 round trips to achieve 10 Gbps
>> > > (note bc's l() function is logE);
>> > >
>> > >         [root@lang2 ~]# bc -l
>> > >         scale=10
>> > >         l(11111)/l(2)+1
>> > >         14.4397010470
>> > >
>> > > And 15 round trips at 80 ms each gives a total time of:
>> > >
>> > >         [root@lang2 ~]# bc -l
>> > >         scale=10
>> > >         15*0.080
>> > >         1.200
>> > >
>> > > So if there is no packet loss (which there wasn't), it should only
>> > > take about 1.2 seconds to achieve 10 Gbps.  Only TCP reno is in
>> > > this ballpark range.
>> > >
>> > > Now it's quite possible there's something basic I don't understand,
>> > > such as some /proc/sys/net/ipv4/tcp_* or
>> /sys/module/tcp_*/parameters/*
>> > > parameter I've overlooked, in which case feel free to just refer me
>> > > to any suitable documentation.
>> > >
>> > > I also checked the Changelog for 2.6.20.{8,9,10,11} to see if there
>> > > might be any relevant recent bug fixes, but the only thing that
>> seemed
>> > > even remotely related was the 2.6.20.11 bug fix for the tcp_mem
>> setting.
>> > > Although this did affect me, I manually adjusted the tcp_mem
>> settings
>> > > before running these tests.
>> > >
>> > > [root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_mem
>>            393216  524288  786432
>> > >
>> > > The test setup was:
>> > >
>> > >         +-------+                 +-------+
>> +-------+
>> > >         |       |eth2         eth2|       |eth3         eth2|
>> |
>> > >         | lang2 |-----10-GigE-----| lang1 |-----10-GigE-----| lang3
>> |
>> > >         |       |                 |       |                 |
>> |
>> > >         +-------+                 +-------+
>> +-------+
>> > >         192.168.88.14    192.168.88.13/192.168.89.13
>> 192.168.89.15
>> > >
>> > > All three systems are dual 2.8 GHz AMD Opteron Processor 254 systems
>> > > with 4 GB memory and all running the 2.6.20.7 kernel.  All the NICs
>> > > are Myricom PCI-E 10-GigE NICs.
>> > >
>> > > The 80 ms delay was introduced by applying netem to lang1's eth3
>> > > interface:
>> > >
>> > > [root@lang1 ~]# tc qdisc add dev eth3 root netem delay 80ms limit
>> 20000
>> > > [root@lang1 ~]# tc qdisc show
>> > > qdisc pfifo_fast 0: dev eth2 root bands 3 priomap  1 2 2 2 1 2 0 0 1
>> 1 1 1 1 1 1 1
>> > > qdisc netem 8022: dev eth3 limit 20000 delay 80.0ms reorder 100%
>> > >
>> > > Experimentation determined that netem running on lang1 could handle
>> > > about 8-8.5 Gbps without dropping packets.
>> > >
>> > > 8.5 Gbps UDP test:
>> > >
>> > > [root@lang2 ~]# nuttcp -u -Ri8.5g -w20m 192.168.89.15
>> > > 10136.4844 MB /  10.01 sec = 8497.8205 Mbps 100 %TX 56 %RX 0 /
>> 1297470 drop/pkt 0.00 %loss
>> > >
>> > > Increasing the rate to 9 Gbps would give some loss:
>> > >
>> > > [root@lang2 ~]# nuttcp -u -Ri9g -w20m 192.168.89.15
>> > > 10219.1719 MB /  10.01 sec = 8560.2455 Mbps 100 %TX 58 %RX 65500 /
>> 1373554 drop/pkt 4.77 %loss
>> > >
>> > > Based on this, the specification of a 60 MB TCP socket buffer size
>> was
>> > > used during the TCP tests to avoid overstressing the lang1 netem
>> delay
>> > > emulator (to avoid dropping any packets).
>> > >
>> > > Simple ping through the lang1 netem delay emulator:
>> > >
>> > > [root@lang2 ~]# ping -c 5 192.168.89.15
>> > > PING 192.168.89.15 (192.168.89.15) 56(84) bytes of data.
>> > > 64 bytes from 192.168.89.15: icmp_seq=1 ttl=63 time=80.4 ms
>> > > 64 bytes from 192.168.89.15: icmp_seq=2 ttl=63 time=82.1 ms
>> > > 64 bytes from 192.168.89.15: icmp_seq=3 ttl=63 time=82.1 ms
>> > > 64 bytes from 192.168.89.15: icmp_seq=4 ttl=63 time=82.1 ms
>> > > 64 bytes from 192.168.89.15: icmp_seq=5 ttl=63 time=82.1 ms
>> > >
>> > > --- 192.168.89.15 ping statistics ---
>> > > 5 packets transmitted, 5 received, 0% packet loss, time 4014ms
>> > > rtt min/avg/max/mdev = 80.453/81.804/82.173/0.722 ms
>> > >
>> > > And a bidirectional traceroute (using the "nuttcp -xt" option):
>> > >
>> > > [root@lang2 ~]# nuttcp -xt 192.168.89.15
>> > > traceroute to 192.168.89.15 (192.168.89.15), 30 hops max, 40 byte
>> packets
>> > >  1  192.168.88.13 (192.168.88.13)  0.141 ms   0.125 ms   0.125 ms
>> > >  2  192.168.89.15 (192.168.89.15)  82.112 ms   82.039 ms   82.541 ms
>> > >
>> > > traceroute to 192.168.88.14 (192.168.88.14), 30 hops max, 40 byte
>> packets
>> > >  1  192.168.89.13 (192.168.89.13)  81.101 ms   83.001 ms   82.999 ms
>> > >  2  192.168.88.14 (192.168.88.14)  83.005 ms   82.985 ms   82.978 ms
>> > >
>> > > So is this a real bug in cubic (and bic), or do I just not
>> understand
>> > > something basic.
>> > >
>> > >                                                 -Bill
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

