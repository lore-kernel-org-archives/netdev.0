From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 17:06:08 -0800
Message-ID: <51008900.2010803@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop>  <1358875607.3464.4020.camel@edumazet-glaptop>  <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>  <5100785D.8040101@candelatech.com>  <1358985688.12374.1247.camel@edumazet-glaptop>  <51007CA8.2050105@candelatech.com>  <1358987031.12374.1276.camel@edumazet-glaptop>  <51008294.2010201@candelatech.com>  <1358988358.12374.1303.camel@edumazet-glaptop>  <51008598.4000603@candelatech.com> <1358989242.12374.1323.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49430 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805Ab3AXBGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 20:06:11 -0500
In-Reply-To: <1358989242.12374.1323.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2013 05:00 PM, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 16:51 -0800, Ben Greear wrote:
>
>>
>> I was poking around in drivers/net/loopback.c.  Maybe it needs
>> to clean up the skb_dst() before calling the rx logic in the
>> loopback_xmit method?
>
> Nope. Its ok there. We need a dst for loopback

Here's the crash with the BUG_ON().  Did I understand your
suggestion properly?  This hit immediately when booting.


int netif_rx(struct sk_buff *skb)
{
	int ret;

	BUG_ON(skb->_skb_refdst & SKB_DST_NOREF);
	
	/* if netpoll wants it, pretend we never saw it */
	if (netpoll_rx(skb))
		return NET_RX_DROP;


kernel BUG at /home/greearb/git/linux-3.7.dev.y/net/core/dev.c:2982!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: lockd sunrpc macvlan pktgen uinput coretemp hwmon kvm_intel kvm iTCO_wdt iTCO_vendor_e
CPU 0
Pid: 1554, comm: btserver Tainted: G         C O 3.7.3+ #51 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<ffffffff8147685a>]  [<ffffffff8147685a>] netif_rx+0x14/0x109
RSP: 0018:ffff8804030359a8  EFLAGS: 00010202
RAX: 0000000000000000 RBX: ffff8803fff3a2f0 RCX: ffff88040d3b4490
RDX: ffff880403035a08 RSI: ffff88040d3f8000 RDI: ffff8803fff3a2f0
RBP: ffff8804030359d8 R08: 0000000000000001 R09: 0000000000000000
R10: ffffffff81472e61 R11: ffff8803fff62cc0 R12: 0000000000016ff0
R13: 000000000000003c R14: ffff88041fc00000 R15: ffffffff81670560
FS:  00007fcbd5c01740(0000) GS:ffff88041fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000439004 CR3: 00000003ff68d000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process btserver (pid: 1554, threadinfo ffff880403034000, task ffff880407e09f50)
Stack:
  ffff8804030359d8 ffffffff814c0290 ffff880403035a08 ffff8803fff3a2f0
  ffff8803fff3a2f0 0000000000016ff0 ffff880403035a08 ffffffff813a3c4d
  ffff8803fff3a2f0 ffff88040d3f8000 00000000a01b7c08 ffff88040d0b7400
Call Trace:
  [<ffffffff814c0290>] ? tcp_wfree+0xc0/0xc8
  [<ffffffff813a3c4d>] loopback_xmit+0x64/0x83
  [<ffffffff81477364>] dev_hard_start_xmit+0x26c/0x35e
  [<ffffffff8147771a>] dev_queue_xmit+0x2c4/0x37c
  [<ffffffff81477456>] ? dev_hard_start_xmit+0x35e/0x35e
  [<ffffffff8148cfa6>] ? eth_header+0x28/0xb6
  [<ffffffff81480f09>] neigh_resolve_output+0x176/0x1a7
  [<ffffffff814ad835>] ip_finish_output2+0x297/0x30d
  [<ffffffff814ad6d5>] ? ip_finish_output2+0x137/0x30d
  [<ffffffff814ad90e>] ip_finish_output+0x63/0x68
  [<ffffffff814ae412>] ip_output+0x61/0x67
  [<ffffffff814ab904>] dst_output+0x17/0x1b
  [<ffffffff814adb6d>] ip_local_out+0x1e/0x23
  [<ffffffff814ae1c4>] ip_queue_xmit+0x315/0x353
  [<ffffffff814adeaf>] ? ip_send_unicast_reply+0x2cc/0x2cc
  [<ffffffff814c018f>] tcp_transmit_skb+0x7ca/0x80b
  [<ffffffff814c3571>] tcp_connect+0x53c/0x587
  [<ffffffff810c2f0c>] ? getnstimeofday+0x44/0x7d
  [<ffffffff810c2f56>] ? ktime_get_real+0x11/0x3e
  [<ffffffff814c6f9b>] tcp_v4_connect+0x3c2/0x431
  [<ffffffff814d6913>] __inet_stream_connect+0x84/0x287
  [<ffffffff814d6b38>] ? inet_stream_connect+0x22/0x49
  [<ffffffff8108d695>] ? _local_bh_enable_ip+0x84/0x9f
  [<ffffffff8108d6c8>] ? local_bh_enable+0xd/0x11
  [<ffffffff8146763c>] ? lock_sock_nested+0x6e/0x79
  [<ffffffff814d6b38>] ? inet_stream_connect+0x22/0x49
  [<ffffffff814d6b49>] inet_stream_connect+0x33/0x49
  [<ffffffff814632c6>] sys_connect+0x75/0x98
  [<ffffffff811551fd>] ? path_put+0x1d/0x21
  [<ffffffff810e8d06>] ? __audit_syscall_entry+0x11c/0x148
  [<ffffffff8128a509>] ? lockdep_sys_exit_thunk+0x35/0x67
  [<ffffffff81162f8b>] ? __fd_install+0x26/0x52
  [<ffffffff81537e69>] system_call_fastpath+0x16/0x1b
Code: 49 8b 5c 24 10 48 8b 43 68 48 85 c0 0f 85 5e fe ff ff e9 79 fe ff ff 55 48 89 e5 41 54 53 48 89 fb
RIP  [<ffffffff8147685a>] netif_rx+0x14/0x109
  RSP <ffff8804030359a8>
... DONE

>
>
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
