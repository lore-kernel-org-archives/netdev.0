From: Daniel Petre <daniel.petre@rcs-rds.ro>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Thu, 23 May 2013 11:47:32 +0300
Message-ID: <519DD7A4.9090801@rcs-rds.ro>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>   <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>  <1369222666.3301.304.camel@edumazet-glaptop> <519CB0D3.8000406@rcs-rds.ro> <1369230739.3301.334.camel@edumazet-glaptop> <519CE6F0.3040703@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy.rcs-rds.ro ([212.54.120.14]:58627 "EHLO
	mailproxy.rcs-rds.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477Ab3EWIrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 04:47:35 -0400
In-Reply-To: <519CE6F0.3040703@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2013 06:40 PM, Daniel Petre wrote:
> On 05/22/2013 04:52 PM, Eric Dumazet wrote:
>> On Wed, 2013-05-22 at 14:49 +0300, Daniel Petre wrote:
>>
>>> Hello Eric,
>>> some machines have e1000e others have tg3 (with mtu 1524) then we have
>>> few gre tunnels on top of the downlink ethernet and the traffic goes up
>>> the router via the second ethernet interface, nothing complicated.
>>>
>>
>> The crash by the way is happening in icmp_send() called from
>> ipv4_link_failure(), called from ip_tunnel_xmit() when IPv6 destination
>> cannot be reached.
>>
>> Your patch therefore should not 'avoid' the problem ...
>>
>> My guess is kernel stack is too small to afford icmp_send() being called
>> twice (recursively)
>>
>> Could you try :
>>
> 
> Hello Eric,
> thanks for the patch, we managed to compile and push the kernel live,
> it went in panic when we shut the port to the server..

Hello again Eric,
we applied the little patch from:
http://lkml.indiana.edu/hypermail/linux/kernel/1007.0/00961.html
we have flapped the link few times and everything recovered smooth.

> 
> crash> bt
> PID: 0      TASK: ffffffff81813420  CPU: 0   COMMAND: "swapper/0"
>  #0 [ffff88003fc05df0] machine_kexec at ffffffff81027430
>  #1 [ffff88003fc05e40] crash_kexec at ffffffff8107da80
>  #2 [ffff88003fc05f10] oops_end at ffffffff81005bf8
>  #3 [ffff88003fc05f30] do_stack_segment at ffffffff8100365f
>  #4 [ffff88003fc05f50] retint_signal at ffffffff81542d12
>     [exception RIP: __kmalloc+144]
>     RIP: ffffffff810d0a20  RSP: ffff88003fc03a30  RFLAGS: 00010202
>     RAX: 0000000000000000  RBX: ffff88003d672a00  RCX: 00000000003c1bf9
>     RDX: 00000000003c1bf8  RSI: 0000000000008020  RDI: 0000000000013ba0
>     RBP: 37f5089fae060a80   R8: ffffffff814d5def   R9: ffff88003fc03a80
>     R10: 00000000557809c3  R11: ffff88003e1053c0  R12: ffff88003e001240
>     R13: 0000000000008020  R14: 0000000000000000  R15: 0000000000000001
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
> --- <STACKFAULT exception stack> ---
>  #5 [ffff88003fc03a30] __kmalloc at ffffffff810d0a20
>  #6 [ffff88003fc03a58] icmp_send at ffffffff814d5def
>  #7 [ffff88003fc03bc8] sch_direct_xmit at ffffffff81487d66
>  #8 [ffff88003fc03c08] __qdisc_run at ffffffff81487efd
>  #9 [ffff88003fc03c48] dev_queue_xmit at ffffffff8146e5a7
> #10 [ffff88003fc03c88] ip_finish_output at ffffffff814ab596
> #11 [ffff88003fc03ce8] __netif_receive_skb at ffffffff8146ed13
> #12 [ffff88003fc03d88] napi_gro_receive at ffffffff8146fc50
> #13 [ffff88003fc03da8] e1000_clean_rx_irq at ffffffff813bc67b
> #14 [ffff88003fc03e48] e1000e_poll at ffffffff813c3a20
> #15 [ffff88003fc03e98] net_rx_action at ffffffff8146f796
> #16 [ffff88003fc03ee8] __do_softirq at ffffffff8103ebb9
> #17 [ffff88003fc03f38] segment_not_present at ffffffff8154438c
> #18 [ffff88003fc03f70] irq_exit at ffffffff8103e9cd
> #19 [ffff88003fc03f80] do_IRQ at ffffffff81003f6c
> #20 [ffff88003fc03fb0] save_paranoid at ffffffff81542b6a
> --- <IRQ stack> ---
> #21 [ffffffff81801ea8] save_paranoid at ffffffff81542b6a
>     [exception RIP: mwait_idle+95]
>     RIP: ffffffff8100ad8f  RSP: ffffffff81801f50  RFLAGS: 00000246
>     RAX: 0000000000000000  RBX: ffffffff8154189e  RCX: 0000000000000000
>     RDX: 0000000000000000  RSI: ffffffff81801fd8  RDI: ffff88003fc0d840
>     RBP: ffffffff8185be80   R8: 0000000000000000   R9: 0000000000000001
>     R10: 0000000000000000  R11: 0000000000000000  R12: 0000000000000000
>     R13: ffffffff81813420  R14: ffff88003fc11000  R15: ffffffff81813420
>     ORIG_RAX: ffffffffffffff1e  CS: 0010  SS: 0018
> #22 [ffffffff81801f50] cpu_idle at ffffffff8100b126
> 
> ---------------------
> 
> [  645.650121] e1000e: eth3 NIC Link is Down
> [  664.596968] stack segment: 0000 [#1] SMP
> [  664.597121] Modules linked in: coretemp
> [  664.597264] CPU 0
> [  664.597309] Pid: 0, comm: swapper/0 Not tainted 3.8.13 #4 IBM IBM
> System x3250 M2
> [  664.597447] RIP: 0010:[<ffffffff810d0a20>]  [<ffffffff810d0a20>]
> __kmalloc+0x90/0x180
> [  664.597559] RSP: 0018:ffff88003fc03a30  EFLAGS: 00010202
> [  664.597621] RAX: 0000000000000000 RBX: ffff88003d672a00 RCX:
> 00000000003c1bf9
> [  664.597687] RDX: 00000000003c1bf8 RSI: 0000000000008020 RDI:
> 0000000000013ba0
> [  664.597752] RBP: 37f5089fae060a80 R08: ffffffff814d5def R09:
> ffff88003fc03a80
> [  664.597817] R10: 00000000557809c3 R11: ffff88003e1053c0 R12:
> ffff88003e001240
> [  664.597882] R13: 0000000000008020 R14: 0000000000000000 R15:
> 0000000000000001
> [  664.597948] FS:  0000000000000000(0000) GS:ffff88003fc00000(0000)
> knlGS:0000000000000000
> [  664.598015] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  664.598077] CR2: 00007fefa9e458e0 CR3: 000000003d848000 CR4:
> 00000000000007f0
> [  664.598143] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  664.598208] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  664.598273] Process swapper/0 (pid: 0, threadinfo ffffffff81800000,
> task ffffffff81813420)
> [  664.598340] Stack:
> [  664.598396]  00000000c3097855 ffff88003d672a00 0000000000000003
> 0000000000000001
> [  664.598627]  ffff880039ead70e ffffffff814d5def ffff88003ce11840
> 0000000000000246
> [  664.598859]  ffff88003d0b4000 ffffffff814a2beb 0000000000010018
> ffff88003e1053c0
> [  664.599090] Call Trace:
> [  664.599147]  <IRQ>
> [  664.599190]
> [  664.599289]  [<ffffffff814d5def>] ? icmp_send+0x11f/0x390
> [  664.599353]  [<ffffffff814a2beb>] ? __ip_rt_update_pmtu+0xbb/0x110
> [  664.599418]  [<ffffffff814a1795>] ? ipv4_link_failure+0x15/0x60
> [  664.599482]  [<ffffffff814e78b5>] ? ipgre_tunnel_xmit+0x7f5/0x9f0
> [  664.599547]  [<ffffffff8146e032>] ? dev_hard_start_xmit+0x102/0x490
> [  664.599612]  [<ffffffff81487d66>] ? sch_direct_xmit+0x106/0x1e0
> [  664.599676]  [<ffffffff81487efd>] ? __qdisc_run+0xbd/0x150
> [  664.599739]  [<ffffffff8146e5a7>] ? dev_queue_xmit+0x1e7/0x3a0
> [  664.600002]  [<ffffffff814ab596>] ? ip_finish_output+0x2e6/0x3e0
> [  664.600002]  [<ffffffff8146ed13>] ? __netif_receive_skb+0x5b3/0x7c0
> [  664.600002]  [<ffffffff8146f114>] ? netif_receive_skb+0x24/0x80
> [  664.600002]  [<ffffffff8146fc50>] ? napi_gro_receive+0x110/0x140
> [  664.600002]  [<ffffffff813bc67b>] ? e1000_clean_rx_irq+0x29b/0x490
> [  664.600002]  [<ffffffff813c3a20>] ? e1000e_poll+0x90/0x3a0
> [  664.600002]  [<ffffffff8146f796>] ? net_rx_action+0xc6/0x1e0
> [  664.600002]  [<ffffffff8103ebb9>] ? __do_softirq+0xa9/0x170
> [  664.600002]  [<ffffffff8154438c>] ? call_softirq+0x1c/0x30
> [  664.600002]  [<ffffffff810047dd>] ? do_softirq+0x4d/0x80
> [  664.600002]  [<ffffffff8103e9cd>] ? irq_exit+0x7d/0x90
> [  664.600002]  [<ffffffff81003f6c>] ? do_IRQ+0x5c/0xd0
> [  664.600002]  [<ffffffff81542b6a>] ? common_interrupt+0x6a/0x6a
> [  664.600002]  <EOI>
> [  664.600002]
> [  664.600002]  [<ffffffff8154189e>] ? __schedule+0x26e/0x5b0
> [  664.600002]  [<ffffffff8100ad8f>] ? mwait_idle+0x5f/0x70
> [  664.600002]  [<ffffffff8100b126>] ? cpu_idle+0xf6/0x110
> [  664.600002]  [<ffffffff81875c58>] ? start_kernel+0x33d/0x348
> [  664.600002]  [<ffffffff8187573b>] ? repair_env_string+0x5b/0x5b
> [  664.600002]  [<ffffffff8187541d>] ? x86_64_start_kernel+0xee/0xf2
> [  664.600002] Code: 28 49 8b 0c 24 65 48 03 0c 25 88 cc 00 00 48 8b 51
> 08 48 8b 29 48 85 ed 0f 84 d3 00 00 00 49 63 44 24 20 49 8b 3c 24 48 8d
> 4a 01 <48> 8b 5c 05 00 48 89 e8 65 48 0f c7 0f 0f 94 c0 3c 01 75 c2 49
> [  664.600002] RIP  [<ffffffff810d0a20>] __kmalloc+0x90/0x180
> [  664.600002]  RSP <ffff88003fc03a30>
> 
> 
>>  net/ipv4/icmp.c |   72 ++++++++++++++++++++++++----------------------
>>  1 file changed, 38 insertions(+), 34 deletions(-)
>>
>> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
>> index 76e10b4..e33f3b0 100644
>> --- a/net/ipv4/icmp.c
>> +++ b/net/ipv4/icmp.c
>> @@ -208,7 +208,7 @@ static struct sock *icmp_sk(struct net *net)
>>  	return net->ipv4.icmp_sk[smp_processor_id()];
>>  }
>>  
>> -static inline struct sock *icmp_xmit_lock(struct net *net)
>> +static struct sock *icmp_xmit_lock(struct net *net)
>>  {
>>  	struct sock *sk;
>>  
>> @@ -226,7 +226,7 @@ static inline struct sock *icmp_xmit_lock(struct net *net)
>>  	return sk;
>>  }
>>  
>> -static inline void icmp_xmit_unlock(struct sock *sk)
>> +static void icmp_xmit_unlock(struct sock *sk)
>>  {
>>  	spin_unlock_bh(&sk->sk_lock.slock);
>>  }
>> @@ -235,8 +235,8 @@ static inline void icmp_xmit_unlock(struct sock *sk)
>>   *	Send an ICMP frame.
>>   */
>>  
>> -static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
>> -				      struct flowi4 *fl4, int type, int code)
>> +static bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
>> +			       struct flowi4 *fl4, int type, int code)
>>  {
>>  	struct dst_entry *dst = &rt->dst;
>>  	bool rc = true;
>> @@ -375,19 +375,22 @@ out_unlock:
>>  	icmp_xmit_unlock(sk);
>>  }
>>  
>> -static struct rtable *icmp_route_lookup(struct net *net,
>> -					struct flowi4 *fl4,
>> -					struct sk_buff *skb_in,
>> -					const struct iphdr *iph,
>> -					__be32 saddr, u8 tos,
>> -					int type, int code,
>> -					struct icmp_bxm *param)
>> +struct icmp_send_data {
>> +	struct icmp_bxm icmp_param;
>> +	struct ipcm_cookie ipc;
>> +	struct flowi4 fl4;
>> +};
>> +
>> +static noinline_for_stack struct rtable *
>> +icmp_route_lookup(struct net *net, struct flowi4 *fl4,
>> +		  struct sk_buff *skb_in, const struct iphdr *iph,
>> +		  __be32 saddr, u8 tos, int type, int code,
>> +		  struct icmp_bxm *param)
>>  {
>>  	struct rtable *rt, *rt2;
>>  	struct flowi4 fl4_dec;
>>  	int err;
>>  
>> -	memset(fl4, 0, sizeof(*fl4));
>>  	fl4->daddr = (param->replyopts.opt.opt.srr ?
>>  		      param->replyopts.opt.opt.faddr : iph->saddr);
>>  	fl4->saddr = saddr;
>> @@ -482,14 +485,12 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>>  {
>>  	struct iphdr *iph;
>>  	int room;
>> -	struct icmp_bxm icmp_param;
>>  	struct rtable *rt = skb_rtable(skb_in);
>> -	struct ipcm_cookie ipc;
>> -	struct flowi4 fl4;
>>  	__be32 saddr;
>>  	u8  tos;
>>  	struct net *net;
>>  	struct sock *sk;
>> +	struct icmp_send_data *data = NULL;
>>  
>>  	if (!rt)
>>  		goto out;
>> @@ -585,7 +586,11 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>>  					   IPTOS_PREC_INTERNETCONTROL) :
>>  					  iph->tos;
>>  
>> -	if (ip_options_echo(&icmp_param.replyopts.opt.opt, skb_in))
>> +	data = kzalloc(sizeof(*data), GFP_ATOMIC);
>> +	if (!data)
>> +		goto out_unlock;
>> +
>> +	if (ip_options_echo(&data->icmp_param.replyopts.opt.opt, skb_in))
>>  		goto out_unlock;
>>  
>>  
>> @@ -593,23 +598,21 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>>  	 *	Prepare data for ICMP header.
>>  	 */
>>  
>> -	icmp_param.data.icmph.type	 = type;
>> -	icmp_param.data.icmph.code	 = code;
>> -	icmp_param.data.icmph.un.gateway = info;
>> -	icmp_param.data.icmph.checksum	 = 0;
>> -	icmp_param.skb	  = skb_in;
>> -	icmp_param.offset = skb_network_offset(skb_in);
>> +	data->icmp_param.data.icmph.type	 = type;
>> +	data->icmp_param.data.icmph.code	 = code;
>> +	data->icmp_param.data.icmph.un.gateway = info;
>> +	data->icmp_param.skb	  = skb_in;
>> +	data->icmp_param.offset = skb_network_offset(skb_in);
>>  	inet_sk(sk)->tos = tos;
>> -	ipc.addr = iph->saddr;
>> -	ipc.opt = &icmp_param.replyopts.opt;
>> -	ipc.tx_flags = 0;
>> +	data->ipc.addr = iph->saddr;
>> +	data->ipc.opt = &data->icmp_param.replyopts.opt;
>>  
>> -	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos,
>> -			       type, code, &icmp_param);
>> +	rt = icmp_route_lookup(net, &data->fl4, skb_in, iph, saddr, tos,
>> +			       type, code, &data->icmp_param);
>>  	if (IS_ERR(rt))
>>  		goto out_unlock;
>>  
>> -	if (!icmpv4_xrlim_allow(net, rt, &fl4, type, code))
>> +	if (!icmpv4_xrlim_allow(net, rt, &data->fl4, type, code))
>>  		goto ende;
>>  
>>  	/* RFC says return as much as we can without exceeding 576 bytes. */
>> @@ -617,19 +620,20 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>>  	room = dst_mtu(&rt->dst);
>>  	if (room > 576)
>>  		room = 576;
>> -	room -= sizeof(struct iphdr) + icmp_param.replyopts.opt.opt.optlen;
>> +	room -= sizeof(struct iphdr) + data->icmp_param.replyopts.opt.opt.optlen;
>>  	room -= sizeof(struct icmphdr);
>>  
>> -	icmp_param.data_len = skb_in->len - icmp_param.offset;
>> -	if (icmp_param.data_len > room)
>> -		icmp_param.data_len = room;
>> -	icmp_param.head_len = sizeof(struct icmphdr);
>> +	data->icmp_param.data_len = skb_in->len - data->icmp_param.offset;
>> +	if (data->icmp_param.data_len > room)
>> +		data->icmp_param.data_len = room;
>> +	data->icmp_param.head_len = sizeof(struct icmphdr);
>>  
>> -	icmp_push_reply(&icmp_param, &fl4, &ipc, &rt);
>> +	icmp_push_reply(&data->icmp_param, &data->fl4, &data->ipc, &rt);
>>  ende:
>>  	ip_rt_put(rt);
>>  out_unlock:
>>  	icmp_xmit_unlock(sk);
>> +	kfree(data);
>>  out:;
>>  }
>>  EXPORT_SYMBOL(icmp_send);
>>
>>
> 
