From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Sat, 18 Apr 2009 21:43:59 +0200
Message-ID: <49EA2D7F.3080405@cosmosbay.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45883 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbZDRTow convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 15:44:52 -0400
In-Reply-To: <alpine.DEB.1.10.0904171238550.20049@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Thu, 16 Apr 2009, David Miller wrote:
>=20
>> We really need to find a good way to fix that IRQ affinity issue.

Yep... this is annoying, but disable_msi=3D1 can help

>=20
> Here are the results with setting interrupt affinity. We are still lo=
osing
> 5 usecs from .22 to .30-rc2. We will investigate more in depth time
> permitting.
>=20
> 	UDP ping pong 40 bytes
>=20
> Kernel		Test 1	Test 2	Test 3	Test 4	Avg
> 2.6.22		83.1125	83.4	83.03	82.95	83.07
> 2.6.23		83.33	83.51	83.18	83.42	83.21
> 2.6.24		82.7775	82.8	82.77	82.77	82.77
> 2.6.25		85.875	85.94	85.75	86.06	85.75
> 2.6.26		87.4025	87.53	87.25	87.3	87.53
> 2.6.27		87.81	87.81	87.77	87.82	87.84
> 2.6.28		87.4275	87.77	87.24	87.28	87.42
> 2.6.29		88.4325	88.48	88.42	88.44	88.39
> 2.6.30-rc2	88.4925	88.49	88.44	88.56	88.48

I did my tests with 3 machines, trying to reproduce your results and fa=
iled.

So its good news for us (we can go back watching TV :) )

192.168.20.110 : linux-2.6 latest git tree, receiver "newkernel"
192.168.20.120 : linux-2.6.22, receiver "oldkernel"
192.168.20.112 : 2.6.28.7 as the sender machine (we dont really care)

I only took traces on receivers to rule out different coalescing delays
of NIC that could depend on firmware or version

bnx2 driver statically included in vmlinux.
(on newkernel, its "disable_msi" set to 1 (because this is the only way=
 my BCM5708S can
 have interrupt affinities set by the admin used by the hardware on 2.6=
=2E28+)

Result for both new and old kernel :

3 us of latency to answer to a ICMP ping request, if irq affinity corre=
ct.

This 3 us includes the overhead of timestamping and pcap copy of packet=
s
 since I have my tcpdump launched.

In my case I want NIC IRQs on CPU0 : "echo 1 >/proc/irq/16/smp_affinity=
"


(trace taken on the receiver side)
ICMP Ping for 2.6.30-rc2 : 3us, 3us, 3us, 3us
15:11:52.856072 IP 192.168.20.112 > 192.168.20.110: ICMP echo request, =
id 7957, seq 3330, length 64
15:11:52.856075 IP 192.168.20.110 > 192.168.20.112: ICMP echo reply, id=
 7957, seq 3330, length 64

15:11:52.856168 IP 192.168.20.112 > 192.168.20.110: ICMP echo request, =
id 7957, seq 3331, length 64
15:11:52.856171 IP 192.168.20.110 > 192.168.20.112: ICMP echo reply, id=
 7957, seq 3331, length 64

15:11:52.856264 IP 192.168.20.112 > 192.168.20.110: ICMP echo request, =
id 7957, seq 3332, length 64
15:11:52.856267 IP 192.168.20.110 > 192.168.20.112: ICMP echo reply, id=
 7957, seq 3332, length 64

15:11:52.856359 IP 192.168.20.112 > 192.168.20.110: ICMP echo request, =
id 7957, seq 3333, length 64
15:11:52.856362 IP 192.168.20.110 > 192.168.20.112: ICMP echo reply, id=
 7957, seq 3333, length 64


ICMP Ping for 2.6.22: 3us, 3us, 3us, 3us : Exactly same latencies than =
current kernel

20:35:06.375011 IP 192.168.20.112 > 192.168.20.120: icmp 64: echo reque=
st seq 110
20:35:06.375014 IP 192.168.20.120 > 192.168.20.112: icmp 64: echo reply=
 seq 110

20:35:06.375106 IP 192.168.20.112 > 192.168.20.120: icmp 64: echo reque=
st seq 111
20:35:06.375109 IP 192.168.20.120 > 192.168.20.112: icmp 64: echo reply=
 seq 111

20:35:06.375201 IP 192.168.20.112 > 192.168.20.120: icmp 64: echo reque=
st seq 112
20:35:06.375204 IP 192.168.20.120 > 192.168.20.112: icmp 64: echo reply=
 seq 112

20:35:06.375296 IP 192.168.20.112 > 192.168.20.120: icmp 64: echo reque=
st seq 113
20:35:06.375299 IP 192.168.20.120 > 192.168.20.112: icmp 64: echo reply=
 seq 113



Answering to a ping involves the regular network stack, with softirq an=
d all...
But we know for sure that the reply comes from the cpu that handled the=
 rx, so
no false sharing between cpus, and that no user land process was involv=
ed, only softirqs.


Now with your udpping I get very variables times : 21 us, 14 us, 27 us,=
 11 us on following random samples

(trace taken on receiver side again)
15:18:50.256238 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
15:18:50.256259 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

15:18:50.256371 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
15:18:50.256385 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

15:18:50.256498 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
15:18:50.256525 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

15:18:50.256638 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
15:18:50.256649 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

Then if I force uddpping receiver running on CPU2 (same physical CPU re=
ceiving NIC interrupts,
but a different core) :

I get : 13us, 11us, 10us, 10us, which is not bad.

21:07:48.823741 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:07:48.823754 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

21:07:48.823852 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:07:48.823863 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

21:07:48.823962 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:07:48.823972 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

21:07:48.824087 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:07:48.824097 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

If run on another physical cpu : I get 15us, 12us, 12us, 12us

21:09:10.667120 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:09:10.667135 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300
21:09:10.667234 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:09:10.667246 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300
21:09:10.667345 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:09:10.667357 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300
21:09:10.667471 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:09:10.667483 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300


If I force udpping to same cpu than IRQS (CPU0) I get : 7us, 8us, 7us, =
7us
And yes, this is very good and expected IMHO :)

21:04:23.780421 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:04:23.780428 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

21:04:23.780539 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:04:23.780547 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

21:04:23.780663 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:04:23.780670 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300

21:04:23.780783 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300
21:04:23.780790 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300


Now running the receiver on 2.6.22

udpping: 6us, 15us, 14us, 13us

16:34:34.266069 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
16:34:34.266075 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

16:34:34.266093 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
16:34:34.266108 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

16:34:34.266209 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
16:34:34.266223 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

16:34:34.266323 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
16:34:34.266335 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

Same cpu for user process and IRQS :

udpping : 7us, 9us, 8us, 10us : Very good, as we could expect !

20:39:07.106698 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
20:39:07.106705 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

20:39:07.106808 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
20:39:07.106819 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

20:39:07.106918 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
20:39:07.106926 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

20:39:07.107046 IP 192.168.20.112.9001 > 192.168.20.120.9000: UDP, leng=
th 300
20:39:07.107056 IP 192.168.20.120.9000 > 192.168.20.112.9001: UDP, leng=
th 300

But in the overall, I get litle bit better results with 2.6.30-rc2 : 7 =
us


I did an oprofile session on 2.6.30-rc2 for the 'best case' (7us of lat=
ency)
tracing only kernel events.

(and unfortunalty IRQ16 is shared by eth0, eth1 and uhci_hcd:usb1


CPU: Core 2, speed 3000.19 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 10000
samples  cum. samples  %        cum. %     symbol name
252423   252423        19.4717  19.4717    mwait_idle
99195    351618         7.6518  27.1235    apic_timer_interrupt
64108    415726         4.9452  32.0687    bnx2_interrupt
62195    477921         4.7977  36.8664    find_busiest_group
60022    537943         4.6300  41.4964    scheduler_tick
40772    578715         3.1451  44.6415    read_tsc
38550    617265         2.9737  47.6152    uhci_irq
36074    653339         2.7827  50.3980    sched_clock_cpu
25319    678658         1.9531  52.3510    rb_get_reader_page
25114    703772         1.9373  54.2883    native_sched_clock
23753    727525         1.8323  56.1206    getnstimeofday
22103    749628         1.7050  57.8256    ktime_get
19924    769552         1.5369  59.3625    hrtimer_interrupt
18999    788551         1.4656  60.8281    ktime_get_ts
17910    806461         1.3816  62.2096    tick_check_oneshot_broadcast
17664    824125         1.3626  63.5722    ring_buffer_consume
13354    837479         1.0301  64.6023    irq_entries_start
12885    850364         0.9939  65.5963    sched_clock_tick
12270    862634         0.9465  66.5428    tick_sched_timer
11232    873866         0.8664  67.4092    __schedule
10607    884473         0.8182  68.2274    softlockup_tick
9446     893919         0.7287  68.9561    raise_softirq
8483     902402         0.6544  69.6104    run_timer_softirq
8295     910697         0.6399  70.2503    __do_softirq
8208     918905         0.6332  70.8835    copy_to_user
7929     926834         0.6116  71.4951    run_rebalance_domains
7478     934312         0.5768  72.0720    bnx2_poll_work
6872     941184         0.5301  72.6021    cpu_idle
6267     947451         0.4834  73.0855    rcu_pending
5953     953404         0.4592  73.5447    rb_advance_reader
5781     959185         0.4459  73.9906    handle_fasteoi_irq
5762     964947         0.4445  74.4351    cpu_clock
5615     970562         0.4331  74.8682    udp_sendmsg
5544     976106         0.4277  75.2959    __skb_recv_datagram
5493     981599         0.4237  75.7196    set_normalized_timespec
5437     987036         0.4194  76.1390    update_wall_time
5282     992318         0.4074  76.5465    smp_apic_timer_interrupt
5097     997415         0.3932  76.9397    ip_append_data
5034     1002449        0.3883  77.3280    find_next_bit


my vmstat 1 on 2.6.30-rC2 receiver during test :

 0  0      0 4047312  12944  40156    0    0     0     0 64231 26101  0=
  1 99  0
 0  1      0 4047312  12948  40156    0    0     0    32 64297 25762  0=
  1 99  0
 0  0      0 4047304  12952  40156    0    0     0     8 64650 25510  0=
  1 99  0
 0  0      0 4047312  12960  40152    0    0     0   344 64533 25434  0=
  1 98  1
 0  0      0 4047312  12960  40156    0    0     0     0 64279 25628  0=
  1 99  0
 0  0      0 4047312  12960  40156    0    0     0     4 64606 25356  0=
  1 99  0
 0  0      0 4047312  12960  40156    0    0     0     0 64253 25732  0=
  1 99  0
 0  1      0 4047304  12968  40152    0    0     0    40 64735 25211  0=
  1 99  0
 0  0      0 4047312  12968  40156    0    0     0   356 64638 25443  0=
  1 99  0
 0  0      0 4047312  12968  40156    0    0     0     0 64269 25608  0=
  1 99  0
 0  0      0 4047312  12968  40156    0    0     0     0 64562 25120  0=
  1 99  0
 1  0      0 4047312  12968  40156    0    0     0     4 64668 24811  0=
  1 99  0


My three machines have same hardware :
HP ProLiant BL460c G1
2 quad core Intel(R) Xeon(R) CPU E5450  @ 3.00GHz  FSB 1333MHz
4GB ram (667 MHz)
Broadcom Corporation NetXtreme II BCM5708S Gigabit Ethernet (rev 12)
32 bit kernel


In conclusion, something might be wrong in your methodology, or your ha=
rdware, or...

Please Christoph, would you mind posting more information on your confi=
g ?

Any chance you have CONFIG_PREEMT enabled or any expensive kernel debug=
 thing ?

