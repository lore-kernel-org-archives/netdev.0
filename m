From: Liu Yu <allanliuyu@gmail.com>
Subject: Re: [PATCH] tcp_cubic: fix divide error when SYN flood
Date: Tue, 22 Apr 2014 11:27:23 +0800
Message-ID: <5355E19B.1040702@gmail.com>
References: <5355CBB0.7020905@gmail.com> <1398133717.29946.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:63122 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbaDVDZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 23:25:41 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so4426417pbc.2
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 20:25:40 -0700 (PDT)
In-Reply-To: <1398133717.29946.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Eric Dumazet said, at 2014/4/22 10:28:
> On Tue, 2014-04-22 at 09:53 +0800, Liu Yu wrote:
>> From: Liu Yu <allanyuliu@tencent.com>
>>
>> commit b9f47a3aaeab (tcp_cubic: limit delayed_ack ratio to prevent
>> divide error) try to prevent divide error, but it still has a little
>> chance that delayed_ack can reach zero. In case machine sufferring
>> continuous SYN flood, the argument cnt could be big, and so that
>> ratio+cnt could get overflow and may happen to be zero. If so,
>> min(ratio, ACK_RATIO_LIMIT) will calculate to be zero.
>>
>> The crash log may like this:
>> ..
>> <6>[27536.083145] possible SYN flooding on port 8080. Sending cookies.
>> <6>[27596.092124] possible SYN flooding on port 8080. Sending cookies.
>> <6>[27656.109832] possible SYN flooding on port 8080. Sending cookies.
>> <0>[27676.940730] divide error: 0000 [#1] SMP
>> <0>[27676.987890] last sysfs file: /sys/class/scsi_host/host0/proc_name
>> ..
>>
>> CC: Stephen Hemminger <shemminger@vyatta.com>
>> Signed-off-by: Liu Yu <allanyuliu@tencent.com>
>> ---
>> net/ipv4/tcp_cubic.c | 4 ++--
>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
>> index 8bf2245..9d332b9 100644
>> --- a/net/ipv4/tcp_cubic.c
>> +++ b/net/ipv4/tcp_cubic.c
>> @@ -404,12 +404,12 @@ static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
>> u32 delay;
>>
>> if (icsk->icsk_ca_state == TCP_CA_Open) {
>> - u32 ratio = ca->delayed_ack;
>> + u64 ratio = ca->delayed_ack;
>>
>> ratio -= ca->delayed_ack >> ACK_RATIO_SHIFT;
>> ratio += cnt;
>>
>> - ca->delayed_ack = min(ratio, ACK_RATIO_LIMIT);
>> + ca->delayed_ack = min_t(u64, ratio, ACK_RATIO_LIMIT);
>> }
>>
>> /* Some calls are for duplicates without timetamps */
> 
> Hi Liu
> 
> Your patch is mangled. Check Documentation/email-clients.txt
> 
> I do not see how a SYN (flood or not) can be cause of the crash you
> have.
> 
> Please provide full stack trace.
> 


Hi Eric

below is the stack

<6>[27292.140097] possible SYN flooding on port 8080. Sending cookies.
<6>[27352.212394] possible SYN flooding on port 8080. Sending cookies.
<6>[27412.211454] possible SYN flooding on port 8080. Sending cookies.
<6>[27472.212504] possible SYN flooding on port 8080. Sending cookies.
<6>[27536.083145] possible SYN flooding on port 8080. Sending cookies.
<6>[27596.092124] possible SYN flooding on port 8080. Sending cookies.
<6>[27656.109832] possible SYN flooding on port 80. Sending cookies.
<0>[27676.940730] divide error: 0000 [#1] SMP
<0>[27676.987890] last sysfs file: /sys/class/scsi_host/host0/proc_name
<4>[27677.060792] CPU 0
0
<6>[27677.198382] RIP: 0010:[<ffffffff8176940d>]  [<ffffffff8176940d>] bictcp_cong_avoid+0x14d/0x2a0
<6>[27677.301544] RSP: 0018:ffff8800282039e0  EFLAGS: 00010246
<6>[27677.365088] RAX: 0000000000000e80 RBX: ffff88010eefd340 RCX: 0000000000000000
<6>[27677.450468] RDX: 0000000000000000 RSI: ffff88010eefd6b8 RDI: 0000000000000367
<6>[27677.535850] RBP: ffff8800282039f0 R08: 00000000000001d1 R09: 0000000000000004
<6>[27677.621232] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000042e1612d
<6>[27677.706612] R13: 0000000000000506 R14: 0000000042e1612d R15: 0000000000000004
<6>[27677.791993] FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
<6>[27677.888815] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
<6>[27677.957556] CR2: 00007f9d7a94b000 CR3: 0000000001001000 CR4: 00000000000406f0
<6>[27678.042938] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<6>[27678.128317] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[27678.213700] Process swapper (pid: 0, threadinfo ffffffff81c3e000, task ffffffff81c413e0)
<0>[27678.310520] Stack:
<4>[27678.334544]  ffff88010eefd340 ffff88010eefd340 ffff880028203a10 ffffffff8173b286
<4>[27678.421276] <0> 0000000042e1612d 0000000000000006 ffff880028203ad0 ffffffff81740970
<4>[27678.513416] <0> ffff88010eefd3f0 0000000000000000 0000015128203b10 42e1612d42e160c5
<0>[27678.607743] Call Trace:
<0>[27678.636965]  <IRQ>
<4>[27678.662136]  [<ffffffff8173b286>] tcp_cong_avoid+0x16/0x30
<4>[27678.727754]  [<ffffffff81740970>] tcp_ack+0xd50/0x1270
<4>[27678.789219]  [<ffffffff81741400>] ? tcp_validate_incoming+0x220/0x350
<4>[27678.866280]  [<ffffffff81742863>] tcp_rcv_established+0x203/0x660
<4>[27678.939181]  [<ffffffff81748daf>] tcp_v4_do_rcv+0x11f/0x290
<4>[27679.005844]  [<ffffffff8170d51f>] ? nf_iterate+0x5f/0x90
<4>[27679.069384]  [<ffffffff8174ae73>] tcp_v4_rcv+0x583/0x6e0
<4>[27679.132925]  [<ffffffff8170d5be>] ? nf_hook_slow+0x6e/0xe0
<4>[27679.198553]  [<ffffffff8172c080>] ? ip_local_deliver_finish+0x0/0x120
<4>[27679.275610]  [<ffffffff8172c0df>] ip_local_deliver_finish+0x5f/0x120
<4>[27679.351632]  [<ffffffff8172c66b>] ip_local_deliver+0x3b/0x90
<4>[27679.419333]  [<ffffffff8172be52>] ip_rcv_finish+0x152/0x380
<4>[27679.485995]  [<ffffffff8172c531>] ip_rcv+0x251/0x350
<4>[27679.545376]  [<ffffffff816f17c7>] __netif_receive_skb+0x267/0x31
