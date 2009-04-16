From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 14:12:46 +0200
Message-ID: <49E720BE.2000200@trash.net>
References: <20090411174801.GG6822@linux.vnet.ibm.com> <18913.53699.544083.320542@cargo.ozlabs.ibm.com> <20090412173108.GO6822@linux.vnet.ibm.com> <20090412.181330.23529546.davem@davemloft.net> <20090413040413.GQ6822@linux.vnet.ibm.com> <20090413095309.631cf395@nehalam> <49E48136.5060700@trash.net> <49E49C65.8060808@cosmosbay.com> <20090414074554.7fa73e2f@nehalam> <49E4B0A5.70404@cosmosbay.com> <b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com> <20090414111716.28585806@nehalam> <49E4E3E8.5090201@cosmosbay.com> <20090414141351.0f63ac98@nehalam> <49E502B5.7070700@cosmosbay.com> <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <alpine.LSU.2.00.0904152354330.5844@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54559 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbZDPMMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 08:12:51 -0400
In-Reply-To: <alpine.LSU.2.00.0904152354330.5844@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Wednesday 2009-04-15 23:07, Eric Dumazet wrote:
>> Stephen Hemminger a =E9crit :
>>> Looks like there is some recursive path into ip_tables that makes t=
he
>>> per-cpu spinlock break.  I get lockup's with KVM networking.
>>>
>>> Suggestions?
>> Well, it seems original patch was not so bad after all
>>
>> http://lists.netfilter.org/pipermail/netfilter-devel/2006-January/02=
3175.html
>>
>> So change per-cpu spinlocks to per-cpu rwlocks=20
>>
>> and use read_lock() in ipt_do_table() to allow recursion...
>>
> iptables cannot quite recurse into itself due to the comefrom stuff.

Actually it can by using the REJECT target:

> [ 2106.068550]  [<ffffffff804b0195>] ? nf_hook_slow+0x89/0x104
> [ 2106.068552]  [<ffffffff804b8ed0>] ? dst_output+0x0/0xb
> [ 2106.068555]  [<ffffffff80393925>] ? _raw_spin_unlock+0x8b/0x92
> [ 2106.068557]  [<ffffffff804ba8c7>] ? __ip_local_out+0x98/0x9a
> [ 2106.068559]  [<ffffffff804ba8d2>] ? ip_local_out+0x9/0x1f
> [ 2106.068562]  [<ffffffff804babb4>] ? ip_push_pending_frames+0x2cc/0=
x33e
> [ 2106.068566]  [<ffffffff804dac79>] ? icmp_send+0x559/0x588
> [ 2106.068569]  [<ffffffff8022d3a0>] ? task_rq_lock+0x46/0x79
> [ 2106.068571]  [<ffffffff8023004f>] ? enqueue_task_fair+0x23b/0x293
> [ 2106.068575]  [<ffffffffa00f5083>] ? reject_tg+0x41/0x30e [ipt_REJE=
CT]
> [ 2106.068578]  [<ffffffffa024084f>] ? ipt_do_table+0x534/0x5f1 [ip_t=
ables]



