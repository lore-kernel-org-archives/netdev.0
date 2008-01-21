From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [IPV4] route: fix locking in rt_run_flush()
Date: Mon, 21 Jan 2008 22:14:52 +0100
Message-ID: <47950B4C.6030608@cosmosbay.com>
References: <12009281372201-git-send-email-joonwpark81@gmail.com> <20080121.024043.105024413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35290 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbYAUVPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 16:15:04 -0500
In-Reply-To: <20080121.024043.105024413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Joonwoo Park <joonwpark81@gmail.com>
> Date: Tue, 22 Jan 2008 00:08:57 +0900
>=20
>> The rt_run_flush() can be stucked if it was called while netdev is o=
n the=20
>> high load.
>> It's possible when pushing rtable to rt_hash is faster than pulling
>> from it.
>>
>> The commands 'ifconfig up or ifconfig mtu' and netif_carrier_on() ca=
n
>> introduce soft lockup like this:
>>
>> [  363.528001] BUG: soft lockup - CPU#0 stuck for 11s! [events/0:9]
>> [  363.531492]
>> [  363.535027] Pid: 9, comm: events/0 Not tainted (2.6.24-rc8 #14)
>> [  363.538837] EIP: 0060:[<c4086a39>] EFLAGS: 00000286 CPU: 0
>> [  363.542762] EIP is at kfree+0xa9/0xf0
>> ...
>> [  363.660815]  [<c42fb0fd>] skb_release_data+0x5d/0x90
>> [  363.666989]  [<c42fb7dc>] skb_release_all+0x5c/0xd0
>> [  363.673207]  [<c42faf8b>] __kfree_skb+0xb/0x90
>> [  363.679474]  [<c42fb029>] kfree_skb+0x19/0x40
>> [  363.685811]  [<c4322d87>] ip_rcv+0x27/0x290
>> [  363.692223]  [<c4300ae5>] netif_receive_skb+0x255/0x320
>> [  363.698759]  [<f88465aa>] e1000_clean_rx_irq+0x14a/0x4f0 [e1000]
>> [  363.705456]  [<f88437c2>] e1000_clean+0x62/0x270 [e1000]
>> [  363.712217]  [<c43031ee>] net_rx_action+0x16e/0x220
>> [  363.719065]  [<c40346d7>] __do_softirq+0x87/0x100
>> [  363.726001]  [<c40347a7>] do_softirq+0x57/0x60
>> [  363.732979]  [<c4034b4e>] local_bh_enable_ip+0xae/0x100
>> [  363.740094]  [<c43e73f5>] _spin_unlock_bh+0x25/0x30
>> [  363.747283]  [<c431ec88>] rt_run_flush+0xc8/0xe0
>> [  363.754566]  [<c4320c76>] rt_cache_flush+0xd6/0xe0
>> [  363.761917]  [<c4350269>] fib_netdev_event+0x89/0xa0
>> [  363.769361]  [<c4047d67>] notifier_call_chain+0x37/0x80
>> ...
>>
>> This patch makes rt_run_flush() to run with softirq is disabled.
>>
>> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
>=20
> I agree with the analysis of the problem, however not the solution.
>=20
> This will absolutely kill software interrupt latency.
>=20
> In fact, we have moved much of the flush work into a workqueue in
> net-2.6.25 because of how important that is
>=20
> We need to find some other way to solve this.
>=20
> Eric, any ideas?

Hum... 2.6.25 is certainly better in this aspect, but I remember we lef=
t=20
something to finish :)

We currently can have a worker doing the automatic flush every 600 seco=
nds,=20
and another task doing a rt_cache_flush(...)

On very loaded machines (DDOS), routes might be added faster than delet=
ed.

Also, each change in routes must invalidate rtcache, and/but full scan =
of this=20
cache is way too expensive (huge amount of MBytes must me read/written)

One possibility is to use a genid marker so that each entry can be thro=
wn away=20
   if its genid is different than the global one.

rt_cache_flush(-1) or rt_secret_build() would just have to increment th=
e=20
global genid.

