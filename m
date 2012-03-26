From: Ben Greear <greearb@candelatech.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL dereferences
 in check_peer_redir)
Date: Mon, 26 Mar 2012 16:06:48 -0700
Message-ID: <4F70F688.6050108@candelatech.com>
References: <4F70E308.7070908@candelatech.com> <20120326.174945.1186427809261872546.davem@davemloft.net> <4F70E560.3020102@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57721 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab2CZXGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 19:06:53 -0400
In-Reply-To: <4F70E560.3020102@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2012 02:53 PM, Ben Greear wrote:
> On 03/26/2012 02:49 PM, David Miller wrote:
>>
>> Looks like all of those strange undiagnosable reported Dave Jones
>> has been feeding us. Something in one part of the kernel leaves
>> a lock held, and this shows up as a warning elsewhere.
>
> Every (initial) bug printout fingers ipv6 and the 'ip' tool on my system.

I added a patch to convert rcu_read_lock/unlock to macros so
that I could automatically grab the call site (_THIS_IP_)
and pass it into the lockdep framework instead of the (useless)
_THIS_IP_ in the old rcu_read_lock method which at best seems to
only indicate which module the issue relates to...

Here's it's output:

BUG: sleeping function called from invalid context at /home/greearb/git/linux-3.0.dev.y/mm/memory.c:3904
in_atomic(): 0, irqs_disabled(): 0, pid: 4975, name: ip
1 lock held by ip/4975:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffffa032081a>] inet6_dump_fib+0x6c/0x233 [ipv6]
Pid: 4975, comm: ip Tainted: G         C  3.0.20+ #11
Call Trace:
  [<ffffffff8103e515>] __might_sleep+0x111/0x115
  [<ffffffff810c9e9f>] might_fault+0x2f/0x9e
  [<ffffffff81387332>] ? copy_from_user+0x2a/0x2c
  [<ffffffff810c9ebe>] ? might_fault+0x4e/0x9e
  [<ffffffff8137d5c0>] move_addr_to_user+0x21/0x8e
  [<ffffffff8137d7ac>] __sys_recvmsg+0x17f/0x21e
  [<ffffffff81063850>] ? up_read+0x1e/0x36
  [<ffffffff810fc727>] ? fcheck_files+0xb7/0xee
  [<ffffffff810fc85c>] ? fget_light+0x3b/0xbc
  [<ffffffff8137df50>] sys_recvmsg+0x3d/0x5b
  [<ffffffff8144fcd2>] system_call_fastpath+0x16/0x1b

================================================
[ BUG: lock held when returning to user space! ]
------------------------------------------------
ip/4975 is leaving the kernel with locks still held!
1 lock held by ip/4975:
  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffffa032081a>] inet6_dump_fib+0x6c/0x233 [ipv6]


(gdb) l *(inet6_dump_fib+0x6c)
0x1181a is in inet6_dump_fib (/home/greearb/git/linux-3.0.dev.y/net/ipv6/ip6_fib.c:395).
390		}
391	
392		arg.skb = skb;
393		arg.cb = cb;
394		arg.net = net;
395		w->args = &arg;
396	
397		rcu_read_lock();
398		for (h = s_h; h < FIB6_TABLE_HASHSZ; h++, s_e = 0) {
399			e = 0;
(gdb)


That said, I don't see any issues with the inet6_dump_fib
method, so maybe my debug attempt is not valid..or lockdep debugging
has issues of some sort.

Off to do more poking around.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
