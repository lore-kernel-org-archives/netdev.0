From: Ben Greear <greearb@candelatech.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Thu, 8 Jun 2017 14:27:31 -0700
Message-ID: <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
 <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
 <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:41280 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdFHV1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 17:27:32 -0400
In-Reply-To: <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 09:19 PM, Eric Dumazet wrote:
> On Tue, 2017-06-06 at 18:34 -0600, David Ahern wrote:
>> On 6/6/17 6:27 PM, Eric Dumazet wrote:
>>> Good catch, but it looks like similar fix is needed a few lines before.
>>>
>>> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
>>> index deea901746c8570c5e801e40592c91e3b62812e0..b214443dc8346cef3690df7f27cc48a864028865 100644
>>> --- a/net/ipv6/ip6_fib.c
>>> +++ b/net/ipv6/ip6_fib.c
>>> @@ -372,12 +372,13 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
>>>
>>>  		read_lock_bh(&table->tb6_lock);
>>>  		res = fib6_walk(net, w);
>>> -		read_unlock_bh(&table->tb6_lock);
>>>  		if (res > 0) {
>>>  			cb->args[4] = 1;
>>>  			cb->args[5] = w->root->fn_sernum;
>>>  		}
>>> +		read_unlock_bh(&table->tb6_lock);
>>
>> indeed. tunnel vision on Ben's problem
>
> BTW, bug was already Ben's problem when Patrick tried to fix it
> in commit 2bec5a369ee79 ("ipv6: fib: fix crash when changing large fib
> while dumping it")  seven years ago ;)

As far as I can tell, the patch did not help, or at least we still reproduce the
crash easily.

ct524-ffb0 login: BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
IP: fib6_walk_continue+0x76/0x180 [ipv6]
PGD 3ec59a067
P4D 3ec59a067
PUD 3eb939067
PMD 0

Oops: 0000 [#1] PREEMPT SMP
Modules linked in: nf_conntrack_netlink nf_conntrack nfnetlink nf_defrag_ipv4 libcrc32c bridge stp llc veth bnep fuse macvlan pktgen cfg80211 ipmi_ssif iTCO_wdt 
iTCO_vendor_support coretemp intel_rapl x86_pkg_temp_thermal intel_powerclamp kvm_intel kvm irqbypass joydev i2c_i801 ie31200_edac intel_pch_thermal shpchp 
hci_uart ipmi_si btbcm btqca ipmi_devintf btintel ipmi_msghandler pinctrl_sunrisepoint bluetooth intel_lpss_acpi acpi_als video pinctrl_intel intel_lpss 
kfifo_buf tpm_tis tpm_tis_core industrialio acpi_power_meter tpm acpi_pad sch_fq_codel nfsd auth_rpcgss nfs_acl lockd grace sunrpc ast drm_kms_helper ttm drm 
igb hwmon ptp pps_core dca i2c_algo_bit i2c_hid i2c_core ipv6 crc_ccitt [last unloaded: nfnetlink]
CPU: 3 PID: 2185 Comm: ip Not tainted 4.12.0-rc4+ #32
Hardware name: Supermicro Super Server/X11SSM-F, BIOS 1.0b 12/29/2015
task: ffff8803e87fd940 task.stack: ffffc90009ae8000
RIP: 0010:fib6_walk_continue+0x76/0x180 [ipv6]
RSP: 0018:ffffc90009aebbc0 EFLAGS: 00010287
RAX: ffff880460df8ca0 RBX: ffff8803f20a2c60 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffc90009aebc00 RDI: ffffffff81eee280
RBP: ffffc90009aebbc8 R08: 0000000000000008 R09: ffff8803e87b47cd
R10: ffffc90009aebb70 R11: 0000000000000000 R12: 0000000000000001
R13: 0000000000000001 R14: ffff8803f20a2c60 R15: ffff8803ec601f80
FS:  00007f43520ee700(0000) GS:ffff8804778c0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000018 CR3: 00000003ebb46000 CR4: 00000000003406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  inet6_dump_fib+0x1ab/0x2a0 [ipv6]
  netlink_dump+0x11d/0x290
  netlink_recvmsg+0x260/0x3f0
  sock_recvmsg+0x38/0x40
  ___sys_recvmsg+0xe9/0x230
  ? alloc_pages_vma+0x9d/0x260
  ? page_add_new_anon_rmap+0x88/0xc0
  ? lru_cache_add_active_or_unevictable+0x31/0xb0
  ? __handle_mm_fault+0xce3/0xf70
  __sys_recvmsg+0x3d/0x70
  ? __sys_recvmsg+0x3d/0x70
  SyS_recvmsg+0xd/0x20
  do_syscall_64+0x56/0xc0
  entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f4351a23050
RSP: 002b:00007ffdb1bfafb8 EFLAGS: 00000246 ORIG_RAX: 000000000000002f
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f4351a23050
RDX: 0000000000000000 RSI: 00007ffdb1bfb020 RDI: 0000000000000004
RBP: 00007ffdb1bff044 R08: 0000000000003fe4 R09: 0000000000000000
R10: 00007ffdb1bfb060 R11: 0000000000000246 R12: 000000000064f360
R13: 00007ffdb1bff0b0 R14: 0000000000003fe4 R15: 0000000000000000
Code: f6 40 2a 04 74 11 8b 53 30 85 d2 0f 84 02 01 00 00 83 ea 01 89 53 30 c7 43 28 04 00 00 00 48 39 43 10 74 33 48 8b 10 48 89 53 18 <48> 39 42 18 0f 84 a3 00 
00 00 48 39 42 08 0f 84 ae 00 00 00 48
RIP: fib6_walk_continue+0x76/0x180 [ipv6] RSP: ffffc90009aebbc0
CR2: 0000000000000018
---[ end trace 06ac9dee8b14db6b ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: disabled



(gdb) l *(fib6_walk_continue+0x76)
0x188c6 is in fib6_walk_continue (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:1593).
1588				if (fn == w->root)
1589					return 0;
1590				pn = fn->parent;
1591				w->node = pn;
1592	#ifdef CONFIG_IPV6_SUBTREES
1593				if (FIB6_SUBTREE(pn) == fn) {
1594					WARN_ON(!(fn->fn_flags & RTN_ROOT));
1595					w->state = FWS_L;
1596					continue;
1597				}
(gdb) l *(inet6_dump_fib+0x1ab)
0x1939b is in inet6_dump_fib (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:392).
387				w->skip = w->count;
388			} else
389				w->skip = 0;
390	
391			res = fib6_walk_continue(w);
392			read_unlock_bh(&table->tb6_lock);
393			if (res <= 0) {
394				fib6_walker_unlink(net, w);
395				cb->args[4] = 0;
396			}
(gdb)

[greearb@ben-dt3 linux-2.6]$ git diff
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d4bf2c6..4e32a16 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -372,12 +372,13 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,

                 read_lock_bh(&table->tb6_lock);
                 res = fib6_walk(net, w);
-               read_unlock_bh(&table->tb6_lock);
                 if (res > 0) {
                         cb->args[4] = 1;
                         cb->args[5] = w->root->fn_sernum;
                 }
+               read_unlock_bh(&table->tb6_lock);
         } else {
+               read_lock_bh(&table->tb6_lock);
                 if (cb->args[5] != w->root->fn_sernum) {
                         /* Begin at the root if the tree changed */
                         cb->args[5] = w->root->fn_sernum;
@@ -387,7 +388,6 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
                 } else
                         w->skip = 0;

-               read_lock_bh(&table->tb6_lock);
                 res = fib6_walk_continue(w);
                 read_unlock_bh(&table->tb6_lock);
                 if (res <= 0) {


Thanks,
Ben



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
