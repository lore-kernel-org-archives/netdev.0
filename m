From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 4 Dec 2013 09:59:44 +0800
Message-ID: <529E8C90.3050902@huawei.com>
References: <529DE13D.2070509@huawei.com> <1386088121.30495.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Joe Perches" <joe@perches.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:36328 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817Ab3LDCBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 21:01:09 -0500
In-Reply-To: <1386088121.30495.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/4 0:28, Eric Dumazet wrote:
> On Tue, 2013-12-03 at 21:48 +0800, Ding Tianhong wrote:
>> I have met the oops in Suse11 SP2, the kernel is 2.6.32.59-0.7-default:
>>
>> [64306.089036] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>> [64306.089343] IP: [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
>> [64306.089535] PGD 0
>> [64306.089706] Oops: 0000 [#1] SMP
>> [64306.089935] last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0/host0/target0:1:0/0:1:0:0/scsi_generic/sg0/dev
>> [64306.090142] Die func triggered, code:1
>> [64306.090147] CPU 1
>> [64306.090258] Supported: Yes, External
>> [64306.090262] Pid: 58359, comm: socknal_cd04 Tainted: P          N  2.6.32.59-0.7-default #1 T3500 G3
>> [64306.090266] RIP: 0010:[<ffffffff812f8e36>]  [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
>> [64306.090272] RSP: 0018:ffff880c273499d8  EFLAGS: 00010206
>> [64306.090275] RAX: 0000000000000000 RBX: ffff8801cddf1500 RCX: ffff8801cddf14f2
>> [64306.090278] RDX: 0000000000000000 RSI: ffff8805e40d3a28 RDI: ffff8801cddf1500
>> [64306.090281] RBP: ffff8805e40d3a28 R08: ffff8801cddf1530 R09: ffff880c27349b17
>> [64306.090284] R10: 000000000000000e R11: ffffffff812f8e22 R12: ffff880185c0e840
>> [64306.090287] R13: 0000000000000000 R14: ffff8805e40d3a60 R15: 0000000003484560
>> [64306.090291] FS:  00007f081210e700(0000) GS:ffff880036420000(0000) knlGS:0000000000000000
>> [64306.090295] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [64306.090297] CR2: 0000000000000008 CR3: 0000000001804000 CR4: 00000000000406e0
>> [64306.090301] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [64306.090304] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [64306.090308] Process socknal_cd04 (pid: 58359, threadinfo ffff880c27348000, task ffff880c25d02300)
>> [64306.090310] Stack:
>> [64306.090426]  ffffffff8131f8e0 0000000000000003 ffff8801c189eb40 000000000000000a
>> [64306.090437] <0> ffffffff00000000 0000000000000002 ffff880c27349a30 ffffffffa304790c
>> [64306.090444] <0> 0000000000000246 000051010a010000 ffffffff81318357 31312d3300007fff
>> [64306.090450] <0> ffff880c27349bb8 0248456003484560 ffff8801c189eb40 ffffffff81869300
>> [64306.090456] <0> ffff880185c0e840 ffff8801cddf1514 ffff8805e40d3a28 00000000000000d0
>> [64306.090464] Call Trace:
>>
>> --------------------------- cut here -------------------------------------
>>
>> I found the NULL place int the neigh_timer_handler, the neigh->ops is NULL,
>> so the calling of neigh->ops->solicit(neigh, skb) will panic, I found the
>> neigh has been freed via the kdump, the so I think the neigh was kfreed while
>> the neigh timer handler is running.
>>
>> The situation is that there are several server in the local lan:
>> A: 128.5.10.83
>> B: 128.5.10.85
>> C: 128.5.10.xx
>>
>> I panic the A by manual, and set B's IP to 128.5.10.83, so send broadcast to tell
>> the lan that B is 128.5.10.83, then the B panic, it is hard to appeared again, so
>> I only met once.
>>
>> I think the reason is that:
>>
>> 	CPU0					CPU1
>> 	-----					-----
>> 						<SOFTIRQ>
>> 						call_timer_fn();
>> 						base->running_timer = neigh->timer;
>> 						neigh_timer_handler();
>> 	neigh_release();
>> 	write_lock(&neigh->lock);
>> 	del_timer(neigh->timer);
>> 	write_unlock(&neigh->lock);
>> 						write_lock(&neigh->lock);
>> 	kfree(neigh);
> 
> Your patch would not help if the previous 2 actions are ordered like
> that :
> 
>        kfree(neigh)
>                                                write_lock(&neigh->lock);
> 

> I do not think this patch is correct.
> 
> You need to test _before_ the write_lock() call.
> 
>

Agree, I miss it, thanks.

I must make sure all pending timer is complete finished and not running on CPUs before kfree the neigh.

Regards
Ding

> 
> 
> .
> 
