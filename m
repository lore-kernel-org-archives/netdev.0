From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 8 Dec 2013 14:09:40 +0200
Message-ID: <52A46184.6070707@mellanox.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>	 <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>	 <20131203.165034.1085515763685633822.davem@davemloft.net>	 <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>	 <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAMEtUuzEM957fRjsb5aSG7xHWKp13fy59QxWpsU_=d+-6ydazg@mail.gmail.com>	 <1386117362.30495.49.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAMEtUuy8HA1nOQJTnxy+p7vNFV25zxMAmz1fh2spj0k4hYgh4w@mail.gmail.com>	 <1386120216.30495.59.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAJZOPZK8UnjGYDdZ4=6BQq55WviSkKA36WHfs
 mk03u6S7BxZNA@mail.gmail.com> <1386337011.30495.253.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:49652 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753192Ab3LHMKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 07:10:45 -0500
In-Reply-To: <1386337011.30495.253.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 15:36, Eric Dumazet wrote:
> On Fri, 2013-12-06 at 11:06 +0200, Or Gerlitz wrote:
>> On Wed, Dec 4, 2013 at 3:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> skb->dev is in the first cache line, where we access skb->next anyway.
>>> I could use skb->cb[] like the following patch :
>> Hi Eric, I applied on the net tree the patch you posted yesterday
>> "net: introduce dev_consume_skb_any()" along with the network drivers
>> part of this patch, unless I got it wrong, I assume both pieces are
>> needed?
>>
>> So I re-run the vxlan/veth test that we suspect goes through packet drops on TX.
>>
>> With the patches applied I have almost no samples of that event
>>
>> $ ./perf report -i perf.data
> How did you get this perf.data file ? There are a few drops.
>
>> Samples: 89  of event 'skb:kfree_skb', Event count (approx.): 89
>> +  39.33%  ksoftirqd/2  [kernel.kallsyms]  [k] net_tx_action
>> +  28.09%      swapper  [kernel.kallsyms]  [k] net_tx_action
>> +  28.09%         sshd  [kernel.kallsyms]  [k] net_tx_action
>> +   2.25%      swapper  [kernel.kallsyms]  [k] kfree_skb
>> +   1.12%  kworker/2:2  [kernel.kallsyms]  [k] net_tx_action
>> +   1.12%        iperf  [kernel.kallsyms]  [k] net_tx_action
>>
>>   ./perf report -i perf.data --sort dso,symbol
>> Samples: 89  of event 'skb:kfree_skb', Event count (approx.): 89
>> +  97.75%  [kernel.kallsyms]  [k] net_tx_action
>> +   2.25%  [kernel.kallsyms]  [k] kfree_skb
>> --
> OK, this means your driver drops few packets in its ndo_start_xmit() handler.

I wasn't sure to follow how the  above lead you to think the drops occur 
at the driver -- but, anyway, I applied your other patches and the one 
below which made the mlx4 driver to make a kfree_skb(skb) call - and 
don't see mlx4 hits in either the client or server side


client side:

Samples: 133  of event 'skb:kfree_skb', Event count (approx.): 133
+  40.60%  ksoftirqd/2  [kernel.kallsyms]  [k] net_tx_action
+  25.56%        iperf  [kernel.kallsyms]  [k] net_tx_action
+  24.06%      swapper  [kernel.kallsyms]  [k] net_tx_action
+   3.01%        iperf  [kernel.kallsyms]  [k] kfree_skb
+   2.26%      swapper  [kernel.kallsyms]  [k] kfree_skb
+   2.26%  kworker/2:1  [kernel.kallsyms]  [k] net_tx_action
+   0.75%       rcuc/2  [kernel.kallsyms]  [k] net_tx_action
+   0.75%  kworker/2:2  [kernel.kallsyms]  [k] net_tx_action
+   0.75%       ypbind  [kernel.kallsyms]  [k] net_tx_action

server side:

Samples: 57  of event 'skb:kfree_skb', Event count (approx.): 57
+  47.37%          swapper  [kernel.kallsyms]  [k] kfree_skb
+  22.81%            iperf  [kernel.kallsyms]  [k] kfree_skb
+   8.77%      ksoftirqd/2  [kernel.kallsyms]  [k] kfree_skb
+   7.02%  hald-addon-acpi  [kernel.kallsyms]  [k] kfree_skb
+   7.02%               ls  [kernel.kallsyms]  [k] kfree_skb
+   3.51%       umount.nfs  [kernel.kallsyms]  [k] kfree_skb
+   1.75%            udevd  [kernel.kallsyms]  [k] kfree_skb
+   1.75%       rpc.idmapd  [kernel.kallsyms]  [k] kfree_skb


I will provide you OOB the full perf report files, but I have scrolled 
into the hits and didn't see one in mlx4... any idea where/how to take 
this from here?


>
> Could you give us "ifconfig -a" reports as I already asked  ?

sure, I see on both sides there are some drops on 1Gbs NIC which is not 
part of the test


client side (mlx4 NIC is eth6)

r-dcs44-005 perf]# ifconfig -a
br1       Link encap:Ethernet  HWaddr 0E:08:CC:54:78:44
           inet addr:192.168.52.144  Bcast:192.168.52.255 Mask:255.255.255.0
           inet6 addr: fe80::c0c0:45ff:feff:bfed/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:11 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:732 (732.0 b)  TX bytes:648 (648.0 b)

eth0      Link encap:Ethernet  HWaddr 00:50:56:25:4B:05
           inet addr:10.212.75.5  Bcast:10.212.255.255 Mask:255.255.0.0
           inet6 addr: fe80::250:56ff:fe25:4b05/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500 Metric:1
           RX packets:70485 errors:0 dropped:467 overruns:0 frame:0
           TX packets:35821 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:58838076 (56.1 MiB)  TX bytes:20632115 (19.6 MiB)

eth6      Link encap:Ethernet  HWaddr 00:02:C9:E9:BB:B2
           inet addr:192.168.30.144  Bcast:192.168.30.255 Mask:255.255.255.0
           inet6 addr: fe80::2:c900:1e9:bbb2/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500 Metric:1
           RX packets:58503788 errors:0 dropped:0 overruns:0 frame:0
           TX packets:389819285 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6604815254 (6.1 GiB)  TX bytes:589822872168 (549.3 GiB)

eth7      Link encap:Ethernet  HWaddr 52:54:00:86:B6:48
           BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:65536  Metric:1
           RX packets:137 errors:0 dropped:0 overruns:0 frame:0
           TX packets:137 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:13860 (13.5 KiB)  TX bytes:13860 (13.5 KiB)

veth0     Link encap:Ethernet  HWaddr E6:95:68:49:A6:3D
           inet addr:192.168.62.144  Bcast:192.168.62.255 Mask:255.255.255.0
           inet6 addr: fe80::e495:68ff:fe49:a63d/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:58510472 errors:0 dropped:0 overruns:0 frame:0
           TX packets:55440581 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:3680050172 (3.4 GiB)  TX bytes:552349060836 (514.4 GiB)

veth1     Link encap:Ethernet  HWaddr 5A:4D:A3:4B:B1:97
           inet6 addr: fe80::584d:a3ff:fe4b:b197/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:55440581 errors:0 dropped:0 overruns:0 frame:0
           TX packets:58510475 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:552349060836 (514.4 GiB)  TX bytes:3680050334 (3.4 GiB)

vxlan42   Link encap:Ethernet  HWaddr 0E:08:CC:54:78:44
           inet addr:192.168.42.144  Bcast:192.168.42.255 Mask:255.255.255.0
           inet6 addr: fe80::c08:ccff:fe54:7844/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:58510461 errors:0 dropped:0 overruns:0 frame:0
           TX packets:55440599 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2860902728 (2.6 GiB)  TX bytes:553236159764 (515.2 GiB)



server side (mlx4 NIC is eth2)

r-dcs47-005 perf]# ifconfig -a
br1       Link encap:Ethernet  HWaddr 2A:9B:C5:5F:FA:AB
           inet addr:192.168.52.147  Bcast:192.168.52.255 Mask:255.255.255.0
           inet6 addr: fe80::cca:f9ff:fead:4210/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:33 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2172 (2.1 KiB)  TX bytes:648 (648.0 b)

eth0      Link encap:Ethernet  HWaddr 00:50:56:25:4A:05
           inet addr:10.212.74.5  Bcast:10.212.255.255 Mask:255.255.0.0
           inet6 addr: fe80::250:56ff:fe25:4a05/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500 Metric:1
           RX packets:15274 errors:0 dropped:18 overruns:0 frame:0
           TX packets:9190 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:36265311 (34.5 MiB)  TX bytes:5736966 (5.4 MiB)

eth2      Link encap:Ethernet  HWaddr 00:02:C9:E9:C0:82
           inet addr:192.168.30.147  Bcast:192.168.30.255 Mask:255.255.255.0
           inet6 addr: fe80::2:c900:1e9:c082/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500 Metric:1
           RX packets:442423939 errors:0 dropped:0 overruns:0 frame:0
           TX packets:66524628 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:669425541728 (623.4 GiB)  TX bytes:7511309282 (6.9 GiB)

eth3      Link encap:Ethernet  HWaddr 52:54:00:5D:70:D9
           BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:65536  Metric:1
           RX packets:32 errors:0 dropped:0 overruns:0 frame:0
           TX packets:32 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2196 (2.1 KiB)  TX bytes:2196 (2.1 KiB)

veth0     Link encap:Ethernet  HWaddr 56:3D:34:30:86:68
           inet addr:192.168.62.147  Bcast:192.168.62.255 Mask:255.255.255.0
           inet6 addr: fe80::543d:34ff:fe30:8668/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:442491685 errors:0 dropped:0 overruns:0 frame:0
           TX packets:66538057 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:647403574534 (602.9 GiB)  TX bytes:4185942998 (3.8 GiB)

veth1     Link encap:Ethernet  HWaddr 2A:9B:C5:5F:FA:AB
           inet6 addr: fe80::289b:c5ff:fe5f:faab/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:66538066 errors:0 dropped:0 overruns:0 frame:0
           TX packets:442491738 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:4185943484 (3.8 GiB)  TX bytes:647403652126 (602.9 GiB)

vxlan42   Link encap:Ethernet  HWaddr F6:E2:99:BD:D6:58
           inet addr:192.168.42.147  Bcast:192.168.42.255 Mask:255.255.255.0
           inet6 addr: fe80::f4e2:99ff:febd:d658/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1450 Metric:1
           RX packets:442491767 errors:0 dropped:0 overruns:0 frame:0
           TX packets:66538082 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:641208829864 (597.1 GiB)  TX bytes:5250554092 (4.8 GiB)





>
> You could temporary change the dev_kfree_skb_any() in mlx4_en_xmit()
> to call kfree_skb(skb) instead, to get  a stack trace (perf record -a -g
> -e skb:kfree_skb sleep 20 ; perf report)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index f54ebd5a1702..53130f27dec0 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -873,7 +873,7 @@ tx_drop_unmap:
>   	}
>   
>   tx_drop:
> -	dev_kfree_skb_any(skb);
> +	kfree_skb(skb);
>   	priv->stats.tx_dropped++;
>   	return NETDEV_TX_OK;
>   }
>
>
