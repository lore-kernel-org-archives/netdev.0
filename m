From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 14:31:48 +0200
Message-ID: <49E72534.1060302@trash.net>
References: <20090411174801.GG6822@linux.vnet.ibm.com> <18913.53699.544083.320542@cargo.ozlabs.ibm.com> <20090412173108.GO6822@linux.vnet.ibm.com> <20090412.181330.23529546.davem@davemloft.net> <20090413040413.GQ6822@linux.vnet.ibm.com> <20090413095309.631cf395@nehalam> <49E48136.5060700@trash.net> <49E49C65.8060808@cosmosbay.com> <20090414074554.7fa73e2f@nehalam> <49E4B0A5.70404@cosmosbay.com> <b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com> <20090414111716.28585806@nehalam> <49E4E3E8.5090201@cosmosbay.com> <20090414141351.0f63ac98@nehalam> <49E502B5.7070700@cosmosbay.com> <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <alpine.LSU.2.00.0904152354330.5844@fbirervta.pbzchgretzou.qr> <49E720BE.2000200@trash.net> <alpine.LSU.2.00.0
 904161423240.22333@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0904161423240.22333@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2009-04-16 14:12, Patrick McHardy wrote:
>> Jan Engelhardt wrote:
>>>> So change per-cpu spinlocks to per-cpu rwlocks 
>>>> and use read_lock() in ipt_do_table() to allow recursion...
>>>>
>>> iptables cannot quite recurse into itself due to the comefrom stuff.
>> Actually it can by using the REJECT target:
> 
> Yes, but it has to return an absolute verdict (which REJECT does),
> so it's not really a recursion, it's more like a goto without return.

Its recursion in the sense that we reenter the same code path,
while holding a lock. The verdict is issued *after* recursing.

A (quite ugly) workaround would be to have ipt_REJECT queue
the packets to a temporary queue and have ipt_do_table call
dst_output() after dropping the lock.



