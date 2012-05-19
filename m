From: Tom Herbert <therbert@google.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun
 Fire X4150(x86) and e1000e
Date: Fri, 18 May 2012 19:07:16 -0700
Message-ID: <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, davem@davemloft.net
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, May 18, 2012 at 7:04 AM, Denys Fedoryshchenko <denys@visp.net.lb> w=
rote:
> It seems logic in BQL has serious issues. The most bad thing, if someone
> don't want limits (especially low as this),
> there is no way to disable BQL in Kernel configuration, only tuning each
> interface over sysfs values.
>
echo max > /sys/class/net/ethX/tx-Y/byte_queue_limits/limit_min
 should disable BQL for a queue

> I just did short debug:
> if (limit !=3D dql->limit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk("New limit %d\n", dql->limit);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dql->limit =3D limit;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ovlimit =3D 0;
> }
>
> And got this numbers:
> [ =A0 18.696839] New limit 0
> [ =A0 19.622967] New limit 42
> [ =A0 20.037810] New limit 165
> [ =A0 35.473666] New limit 386
> [ =A0 37.418591] New limit 1374
> [ =A0 37.420064] New limit 6432
> [ =A0 39.209480] New limit 16548
> [ =A0 39.214773] New limit 1704
> [ =A0 40.696065] New limit 6762
> [ =A0 40.696390] New limit 15564
> [ =A0 41.921120] New limit 25788
> [ =A0 41.921165] New limit 388
> [ =A0 42.696286] New limit 534
> [ =A0 42.696539] New limit 1096
> [ =A0 42.696719] New limit 2304
> [ =A0 53.360394] New limit 24334
> [ =A0 54.696072] New limit 484
> [ =A0 54.696135] New limit 934
>
> This means sometimes limit goes below MTU, and till queue limit increased=
, i
> will see this traffic "stalled",
> if there is large packet in queue. Probably BQL miscalculate queue as full
> because of some specific handling
> of sent packets in e1000e on this specific hardware. Because it should not
> be full, it is 1Gbps wire,
> and it is empty. So in result, instead of eliminating latency, it is addi=
ng
> it.
>

Not expected, we've be running e1000e with BQL for a while.  A few question=
s:

1) What kernel are you running?
2) What sort of traffic load are you using?
3) Have you tried a different interrupt mode?

Per #3, I am wondering if dynamic conservative mode interrupt
throttling is not producing interrupts deterministically for BQL.
I'll try to reproduce the problem in this mode.

> I can make a patch that will make minimum BQL value not less than MTU +
> overhead, is it ok like this?
> Probably it will solve issue, but it is more workaround and safety fuse,
> than a solution.
>
That would just be a bandaid and could just make this a latent issue
for the future.

Tom

>
> On 2012-05-17 19:54, Denys Fedoryshchenko wrote:
>>
>> Also i notice, limit constantly changing over time (even i am not
>> touching it).
>>
>> centaur ~ # grep "" /sys/class/net/eth0/queues/tx-0/byte_queue_limits/*
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/hold_time:1000
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/inflight:0
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit:13018
>>
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit_max:1879048192
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit_min:0
>> centaur ~ # grep "" /sys/class/net/eth0/queues/tx-0/byte_queue_limits/*
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/hold_time:1000
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/inflight:4542
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit:13018
>>
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit_max:1879048192
>> /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit_min:0
>>
>> Is it supposed to be like this?
>>
>> On 2012-05-17 16:42, Denys Fedoryshchenko wrote:
>>>
>>> Found commit that cause problem:
>>>
>>> author =A0Tom Herbert <therbert@google.com>
>>> Mon, 28 Nov 2011 16:33:16 +0000 (16:33 +0000)
>>> committer =A0 =A0 =A0 David S. Miller <davem@davemloft.net>
>>> Tue, 29 Nov 2011 17:46:19 +0000 (12:46 -0500)
>>> commit =A03f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c
>>> tree =A0 =A0d6670a4f94b2b9dedacc38edb6f0e1306b889f6b =A0 =A0 =A0 =A0tre=
e | snapshot
>>> parent =A0114cf5802165ee93e3ab461c9c505cd94a08b800 =A0 =A0 =A0 =A0commi=
t | diff
>>> e1000e: Support for byte queue limits
>>>
>>> Changes to e1000e to use byte queue limits.
>>>
>>> Signed-off-by: Tom Herbert <therbert@google.com>
>>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>> Signed-off-by: David S. Miller <davem@davemloft.net>
>>>
>>> If i reverse it, problem disappearing.
>>>
>>> How i reproduce it:
>>> In two consoles do "fast" ping to nearby host
>>> ping 194.146.XXX.XXX -s1472 -i0.0001
>>> ping 194.146.XXX.XXX -s1472 -i0.1
>>>
>>> For third open ssh to host with "problem", open mcedit, and just
>>> scroll down large text file.
>>> After few seconds some "stalls" will occur, and in ping history i can
>>> see:
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1797 ttl=3D64 time=3D0.161 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1798 ttl=3D64 time=3D0.198 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1799 ttl=3D64 time=3D0.340 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1800 ttl=3D64 time=3D0.381 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1801 ttl=3D64 time=3D914 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1802 ttl=3D64 time=3D804 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1803 ttl=3D64 time=3D704 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1804 ttl=3D64 time=3D594 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1805 ttl=3D64 time=3D0.287 ms
>>> 1480 bytes from 194.146.153.7: icmp_req=3D1806 ttl=3D64 time=3D0.226 ms
>>>
>>>
>>> If i apply small patch - problem will disappear. Sure it is not a
>>> solution, but
>>> let me know how i can help to debug problem more.
>>>
>>> --- netdev.c =A0 =A02012-05-12 20:08:37.000000000 +0300
>>> +++ netdev.c.patched =A0 =A02012-05-17 16:32:28.895760472 +0300
>>> @@ -1135,7 +1135,7 @@
>>>
>>> =A0 =A0 =A0 =A0tx_ring->next_to_clean =3D i;
>>>
>>> - =A0 =A0 =A0 netdev_completed_queue(netdev, pkts_compl, bytes_compl);
>>> +// =A0 =A0 netdev_completed_queue(netdev, pkts_compl, bytes_compl);
>>>
>>> =A0#define TX_WAKE_THRESHOLD 32
>>> =A0 =A0 =A0 =A0if (count && netif_carrier_ok(netdev) &&
>>> @@ -2263,7 +2263,7 @@
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e1000_put_txbuf(adapter, buffer_info);
>>> =A0 =A0 =A0 =A0}
>>>
>>> - =A0 =A0 =A0 netdev_reset_queue(adapter->netdev);
>>> +// =A0 =A0 netdev_reset_queue(adapter->netdev);
>>> =A0 =A0 =A0 =A0size =3D sizeof(struct e1000_buffer) * tx_ring->count;
>>> =A0 =A0 =A0 =A0memset(tx_ring->buffer_info, 0, size);
>>>
>>> @@ -5056,7 +5056,7 @@
>>> =A0 =A0 =A0 =A0/* if count is 0 then mapping error has occurred */
>>> =A0 =A0 =A0 =A0count =3D e1000_tx_map(adapter, skb, first, max_per_txd,
>>> nr_frags, mss);
>>> =A0 =A0 =A0 =A0if (count) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_sent_queue(netdev, skb->len);
>>> +// =A0 =A0 =A0 =A0 =A0 =A0 netdev_sent_queue(netdev, skb->len);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e1000_tx_queue(adapter, tx_flags, count);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Make sure there is space in the ring =
for the next send.
>>> */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e1000_maybe_stop_tx(netdev, MAX_SKB_FRAG=
S + 2);
>>>
>>>
>>>
>>> On 2012-05-15 17:15, Denys Fedoryshchenko wrote:
>>>>
>>>> Hi
>>>>
>>>> I have two identical servers, Sun Fire X4150, both has different
>>>> flavors of Linux, x86_64 and i386.
>>>> 04:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
>>>> Ethernet Controller (Copper) (rev 01)
>>>> 04:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
>>>> Ethernet Controller (Copper) (rev 01)
>>>> 0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
>>>> Ethernet Controller (rev 06)
>>>> 0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit
>>>> Ethernet Controller (rev 06)
>>>> I am using now interface:
>>>> #ethtool -i eth0
>>>> driver: e1000e
>>>> version: 1.9.5-k
>>>> firmware-version: 2.1-11
>>>> bus-info: 0000:04:00.0
>>>> There is 2 CPU , Intel(R) Xeon(R) CPU =A0 =A0 =A0 =A0 =A0 E5440 =A0@ 2=
.83GHz .
>>>>
>>>> i386 was acting as NAT and shaper, and as soon as i removed shaper
>>>> from it, i started to experience strange lockups, e.g. traffic is
>>>> normal for 5-30 seconds, then short lockup for 500-3000ms (usually
>>>> around 1000ms) with dropped packets counter increasing. I was
>>>> suspecting it is due load, but it seems was wrong.
>>>> Recently, on another server, x86_64 i am using as development, i
>>>> upgrade kernel (it was old, from 2.6 series) and on completely idle
>>>> machine started to experience same latency spikes, while i am just
>>>> running mc and for example typing in text editor - i notice "stalls".
>>>> After i investigate it a little more, i notice also small amount of
>>>> drops on interface. No tcpdump running. Also this machine is idle, and
>>>> the only traffic there - some small broadcasts from network, my ssh,
>>>> and ping.
>>>>
>>>> Dropped packets in ifconfig
>>>> =A0 =A0 =A0 =A0 =A0RX packets:3752868 errors:0 dropped:5350 overruns:0=
 frame:0
>>>> Counter is increasing sometimes, when this stall happening.
>>>>
>>>> ethtool -S is clean, there is no dropped packets.
>>>>
>>>> I did tried to check load (mpstat and perf), there is nothing
>>>> suspicious, latencytop also doesn't show anything suspicious.
>>>> dropwatch report a lot of drops, but mostly because there is some
>>>> broadcasts and etc. tcpdump at the moment of such drops doesn't show
>>>> anything suspicious.
>>>> Changed qdisc from default fifo_fast to bfifo, without any result.
>>>> Tried: =A0ethtool -K eth0 tso off gso off gro off sg off , no result
>>>> Problem occured at 3.3.6 - 3.4.0-rc7, most probably 3.3.0 also, but i
>>>> don't remember for sure. I thik on some kernels like 3.1 probably it
>>>> doesn't occur, i will check it soon, because it is not always reliable
>>>> to reproduce it. All tests i did on 3.4.0-rc7.
>>>>
>>>> I did run also in background tcpdump, additionally iptables with
>>>> timestamps, and at time when stall occured, seems i am still receiving
>>>> packets properly, also on iperf udp =A0(from some host to this SunFire)
>>>> at this moments no packets missing. But i am sure RX interface errors
>>>> are increasing.
>>>> If i do iperf from SunFire to test host - there is packetloss at
>>>> moments when stall occured.
>>>>
>>>> I suspect that by some reason network card stop to transmit, but
>>>> unable to pinpoint issue. All other hosts in this network are fine and
>>>> don't have such problems.
>>>> Can you help me with that please? Maybe i can provide more debug
>>>> information, compile with patches and etc. Also i will try to fallback
>>>> to 3.1 and 3.0 kernels.
>>>>
>>>> Here it is how it occurs and i am reproducing it:
>>>> I'm just opening file, and start to scroll it in mc, then in another
>>>> console i run ping
>>>> [1337089061.844167] 1480 bytes from 194.146.153.20: icmp_req=3D162
>>>> ttl=3D64 time=3D0.485 ms
>>>> [1337089061.944138] 1480 bytes from 194.146.153.20: icmp_req=3D163
>>>> ttl=3D64 time=3D0.470 ms
>>>> [1337089062.467759] 1480 bytes from 194.146.153.20: icmp_req=3D164
>>>> ttl=3D64 time=3D424 ms
>>>> [1337089062.467899] 1480 bytes from 194.146.153.20: icmp_req=3D165
>>>> ttl=3D64 time=3D324 ms
>>>> [1337089062.468058] 1480 bytes from 194.146.153.20: icmp_req=3D166
>>>> ttl=3D64 time=3D214 ms
>>>> [1337089062.468161] 1480 bytes from 194.146.153.20: icmp_req=3D167
>>>> ttl=3D64 time=3D104 ms
>>>> [1337089062.468958] 1480 bytes from 194.146.153.20: icmp_req=3D168
>>>> ttl=3D64 time=3D1.15 ms
>>>> [1337089062.568604] 1480 bytes from 194.146.153.20: icmp_req=3D169
>>>> ttl=3D64 time=3D0.477 ms
>>>> [1337089062.668909] 1480 bytes from 194.146.153.20: icmp_req=3D170
>>>> ttl=3D64 time=3D0.667 ms
>>>>
>>>> Remote host tcpdump:
>>>> 1337089061.934737 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 163, length 1480
>>>> 1337089062.458360 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 164, length 1480
>>>> 1337089062.458380 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 164, length 1480
>>>> 1337089062.458481 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 165, length 1480
>>>> 1337089062.458502 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 165, length 1480
>>>> 1337089062.458606 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 166, length 1480
>>>> 1337089062.458623 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 166, length 1480
>>>> 1337089062.458729 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 167, length 1480
>>>> 1337089062.458745 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 167, length 1480
>>>> 1337089062.459537 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 168, length 1480
>>>> 1337089062.459545 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 168, length 1480
>>>>
>>>> Local host(SunFire) tcpdump:
>>>> 1337089061.844140 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 162, length 1480
>>>> 1337089061.943661 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 163, length 1480
>>>> 1337089061.944124 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 163, length 1480
>>>> 1337089062.465622 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 164, length 1480
>>>> 1337089062.465630 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 165, length 1480
>>>> 1337089062.465632 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 166, length 1480
>>>> 1337089062.465634 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 167, length 1480
>>>> 1337089062.467730 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 164, length 1480
>>>> 1337089062.467785 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 168, length 1480
>>>> 1337089062.467884 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 165, length 1480
>>>> 1337089062.468035 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 166, length 1480
>>>> 1337089062.468129 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 167, length 1480
>>>> 1337089062.468928 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 168, length 1480
>>>> 1337089062.568112 IP 194.146.153.22 > 194.146.153.20: ICMP echo
>>>> request, id 3486, seq 169, length 1480
>>>> 1337089062.568578 IP 194.146.153.20 > 194.146.153.22: ICMP echo
>>>> reply, id 3486, seq 169, length 1480
>>>>
>>>> lspci -t
>>>> centaur src # lspci -t
>>>> -[0000:00]-+-00.0
>>>> =A0 =A0 =A0 =A0 =A0 +-02.0-[01-05]--+-00.0-[02-04]--+-00.0-[03]--
>>>> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 \-02.0-[04]--+-00.0
>>>> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\-00.1
>>>> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 \-00.3-[05]--
>>>> =A0 =A0 =A0 =A0 =A0 +-03.0-[06]--
>>>> =A0 =A0 =A0 =A0 =A0 +-04.0-[07]----00.0
>>>> =A0 =A0 =A0 =A0 =A0 +-05.0-[08]--
>>>> =A0 =A0 =A0 =A0 =A0 +-06.0-[09]--
>>>> =A0 =A0 =A0 =A0 =A0 +-07.0-[0a]--
>>>> =A0 =A0 =A0 =A0 =A0 +-08.0
>>>> =A0 =A0 =A0 =A0 =A0 +-10.0
>>>> =A0 =A0 =A0 =A0 =A0 +-10.1
>>>> =A0 =A0 =A0 =A0 =A0 +-10.2
>>>> =A0 =A0 =A0 =A0 =A0 +-11.0
>>>> =A0 =A0 =A0 =A0 =A0 +-13.0
>>>> =A0 =A0 =A0 =A0 =A0 +-15.0
>>>> =A0 =A0 =A0 =A0 =A0 +-16.0
>>>> =A0 =A0 =A0 =A0 =A0 +-1c.0-[0b]--+-00.0
>>>> =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0\-00.1
>>>> =A0 =A0 =A0 =A0 =A0 +-1d.0
>>>> =A0 =A0 =A0 =A0 =A0 +-1d.1
>>>> =A0 =A0 =A0 =A0 =A0 +-1d.2
>>>> =A0 =A0 =A0 =A0 =A0 +-1d.3
>>>> =A0 =A0 =A0 =A0 =A0 +-1d.7
>>>> =A0 =A0 =A0 =A0 =A0 +-1e.0-[0c]----05.0
>>>> =A0 =A0 =A0 =A0 =A0 +-1f.0
>>>> =A0 =A0 =A0 =A0 =A0 +-1f.1
>>>> =A0 =A0 =A0 =A0 =A0 +-1f.2
>>>> =A0 =A0 =A0 =A0 =A0 \-1f.3
>>>> lspci
>>>> 00:00.0 Host bridge: Intel Corporation 5000P Chipset Memory
>>>> Controller Hub (rev b1)
>>>> 00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
>>>> x4 Port 2 (rev b1)
>>>> 00:03.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
>>>> x4 Port 3 (rev b1)
>>>> 00:04.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
>>>> x8 Port 4-5 (rev b1)
>>>> 00:05.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
>>>> x4 Port 5 (rev b1)
>>>> 00:06.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
>>>> x8 Port 6-7 (rev b1)
>>>> 00:07.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
>>>> x4 Port 7 (rev b1)
>>>> 00:08.0 System peripheral: Intel Corporation 5000 Series Chipset DMA
>>>> Engine (rev b1)
>>>> 00:10.0 Host bridge: Intel Corporation 5000 Series Chipset FSB
>>>> Registers (rev b1)
>>>> 00:10.1 Host bridge: Intel Corporation 5000 Series Chipset FSB
>>>> Registers (rev b1)
>>>> 00:10.2 Host bridge: Intel Corporation 5000 Series Chipset FSB
>>>> Registers (rev b1)
>>>> 00:11.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
>>>> Registers (rev b1)
>>>> 00:13.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
>>>> Registers (rev b1)
>>>> 00:15.0 Host bridge: Intel Corporation 5000 Series Chipset FBD
>>>> Registers (rev b1)
>>>> 00:16.0 Host bridge: Intel Corporation 5000 Series Chipset FBD
>>>> Registers (rev b1)
>>>> 00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset
>>>> PCI Express Root Port 1 (rev 09)
>>>> 00:1d.0 USB controller: Intel Corporation 631xESB/632xESB/3100
>>>> Chipset UHCI USB Controller #1 (rev 09)
>>>> 00:1d.1 USB controller: Intel Corporation 631xESB/632xESB/3100
>>>> Chipset UHCI USB Controller #2 (rev 09)
>>>> 00:1d.2 USB controller: Intel Corporation 631xESB/632xESB/3100
>>>> Chipset UHCI USB Controller #3 (rev 09)
>>>> 00:1d.3 USB controller: Intel Corporation 631xESB/632xESB/3100
>>>> Chipset UHCI USB Controller #4 (rev 09)
>>>> 00:1d.7 USB controller: Intel Corporation 631xESB/632xESB/3100
>>>> Chipset EHCI USB2 Controller (rev 09)
>>>> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
>>>> 00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset
>>>> LPC Interface Controller (rev 09)
>>>> 00:1f.1 IDE interface: Intel Corporation 631xESB/632xESB IDE
>>>> Controller (rev 09)
>>>> 00:1f.2 SATA controller: Intel Corporation 631xESB/632xESB SATA AHCI
>>>> Controller (rev 09)
>>>> 00:1f.3 SMBus: Intel Corporation 631xESB/632xESB/3100 Chipset SMBus
>>>> Controller (rev 09)
>>>> 01:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
>>>> Upstream Port (rev 01)
>>>> 01:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to
>>>> PCI-X Bridge (rev 01)
>>>> 02:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
>>>> Downstream Port E1 (rev 01)
>>>> 02:02.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
>>>> Downstream Port E3 (rev 01)
>>>> 04:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
>>>> Ethernet Controller (Copper) (rev 01)
>>>> 04:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
>>>> Ethernet Controller (Copper) (rev 01)
>>>> 07:00.0 RAID bus controller: Adaptec AAC-RAID (rev 09)
>>>> 0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
>>>> Ethernet Controller (rev 06)
>>>> 0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit
>>>> Ethernet Controller (rev 06)
>>>> 0c:05.0 VGA compatible controller: ASPEED Technology, Inc. ASPEED
>>>> Graphics Family
>>>>
>>>>
>>>> dmesg:
>>>> [ =A0 =A04.936885] e1000: Intel(R) PRO/1000 Network Driver - version
>>>> 7.3.21-k8-NAPI
>>>> [ =A0 =A04.936887] e1000: Copyright (c) 1999-2006 Intel Corporation.
>>>> [ =A0 =A04.936966] e1000e: Intel(R) PRO/1000 Network Driver - 1.9.5-k
>>>> [ =A0 =A04.936967] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
>>>> [ =A0 =A04.938529] e1000e 0000:04:00.0: (unregistered net_device):
>>>> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
>>>> [ =A0 =A04.939598] e1000e 0000:04:00.0: irq 65 for MSI/MSI-X
>>>> [ =A0 =A04.992246] e1000e 0000:04:00.0: eth0: (PCI Express:2.5GT/s:Wid=
th
>>>> x4) 00:1e:68:04:99:f8
>>>> [ =A0 =A04.992657] e1000e 0000:04:00.0: eth0: Intel(R) PRO/1000 Network
>>>> Connection
>>>> [ =A0 =A04.992964] e1000e 0000:04:00.0: eth0: MAC: 5, PHY: 5, PBA No:
>>>> FFFFFF-0FF
>>>> [ =A0 =A04.994745] e1000e 0000:04:00.1: (unregistered net_device):
>>>> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
>>>> [ =A0 =A04.996233] e1000e 0000:04:00.1: irq 66 for MSI/MSI-X
>>>> [ =A0 =A05.050901] e1000e 0000:04:00.1: eth1: (PCI Express:2.5GT/s:Wid=
th
>>>> x4) 00:1e:68:04:99:f9
>>>> [ =A0 =A05.051317] e1000e 0000:04:00.1: eth1: Intel(R) PRO/1000 Network
>>>> Connection
>>>> [ =A0 =A05.051623] e1000e 0000:04:00.1: eth1: MAC: 5, PHY: 5, PBA No:
>>>> FFFFFF-0FF
>>>> [ =A0 =A05.051857] e1000e 0000:0b:00.0: Disabling ASPM =A0L1
>>>> [ =A0 =A05.052168] e1000e 0000:0b:00.0: (unregistered net_device):
>>>> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
>>>> [ =A0 =A05.052611] e1000e 0000:0b:00.0: irq 67 for MSI/MSI-X
>>>> [ =A0 =A05.223454] e1000e 0000:0b:00.0: eth2: (PCI Express:2.5GT/s:Wid=
th
>>>> x4) 00:1e:68:04:99:fa
>>>> [ =A0 =A05.223864] e1000e 0000:0b:00.0: eth2: Intel(R) PRO/1000 Network
>>>> Connection
>>>> [ =A0 =A05.224178] e1000e 0000:0b:00.0: eth2: MAC: 0, PHY: 4, PBA No:
>>>> C83246-002
>>>> [ =A0 =A05.224412] e1000e 0000:0b:00.1: Disabling ASPM =A0L1
>>>> [ =A0 =A05.224709] e1000e 0000:0b:00.1: (unregistered net_device):
>>>> Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
>>>> [ =A0 =A05.225168] e1000e 0000:0b:00.1: irq 68 for MSI/MSI-X
>>>> [ =A0 =A05.397603] e1000e 0000:0b:00.1: eth3: (PCI Express:2.5GT/s:Wid=
th
>>>> x4) 00:1e:68:04:99:fb
>>>> [ =A0 =A05.398021] e1000e 0000:0b:00.1: eth3: Intel(R) PRO/1000 Network
>>>> Connection
>>>> [ =A0 =A05.398336] e1000e 0000:0b:00.1: eth3: MAC: 0, PHY: 4, PBA No:
>>>> C83246-002
>>>> [ =A0 13.859817] e1000e 0000:04:00.0: irq 65 for MSI/MSI-X
>>>> [ =A0 13.962309] e1000e 0000:04:00.0: irq 65 for MSI/MSI-X
>>>> [ =A0 17.150392] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex,
>>>> Flow Control: None
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>> ---
>>> Network engineer
>>> Denys Fedoryshchenko
>>>
>>> Dora Highway - Center Cebaco - 2nd Floor
>>> Beirut, Lebanon
>>> Tel: =A0 =A0+961 1 247373
>>> E-Mail: denys@visp.net.lb
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>>
>> ---
>> Network engineer
>> Denys Fedoryshchenko
>>
>> Dora Highway - Center Cebaco - 2nd Floor
>> Beirut, Lebanon
>> Tel: =A0 =A0+961 1 247373
>> E-Mail: denys@visp.net.lb
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
> ---
> Network engineer
> Denys Fedoryshchenko
>
> Dora Highway - Center Cebaco - 2nd Floor
> Beirut, Lebanon
> Tel: =A0 =A0+961 1 247373
> E-Mail: denys@visp.net.lb

---------------------------------------------------------------------------=
---
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and =

threat landscape has changed and how IT managers can respond. Discussions =

will include endpoint security, mobile security and the latest in malware =

threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
