From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] sctp: fix kfree static array pointer in sctp_sysctl_net_unregister
Date: Thu, 8 May 2014 19:26:31 +0800
Message-ID: <536B69E7.6080803@huawei.com>
References: <536B349A.7020306@huawei.com> <20140508111027.GB9696@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:52074 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbaEHL1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 07:27:01 -0400
In-Reply-To: <20140508111027.GB9696@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/8 19:10, Neil Horman wrote:
> On Thu, May 08, 2014 at 03:39:06PM +0800, Wang Weidong wrote:
>> As commit efb842c45e("sctp: optimize the sctp_sysctl_net_register"),
>> we don't kmemdup a sysctl_table for init_net, so the 
>> init_net->sctp.sysctl_header->ctl_table_arg points to sctp_net_table
>> which is a static array pointer. So when doing sctp_sysctl_net_unregister,
>> it will free sctp_net_table, then we will get a NULL pointer dereference
>> like that:
>>
>> [  262.948220] BUG: unable to handle kernel NULL pointer dereference at 000000000000006c
>> [  262.948232] IP: [<ffffffff81144b70>] kfree+0x80/0x420
>> [  262.948260] PGD db80a067 PUD dae12067 PMD 0
>> [  262.948268] Oops: 0000 [#1] SMP
>> [  262.948273] Modules linked in: sctp(-) crc32c_generic libcrc32c
>> ...
>> [  262.948338] task: ffff8800db830190 ti: ffff8800dad00000 task.ti: ffff8800dad00000
>> [  262.948344] RIP: 0010:[<ffffffff81144b70>]  [<ffffffff81144b70>] kfree+0x80/0x420
>> [  262.948353] RSP: 0018:ffff8800dad01d88  EFLAGS: 00010046
>> [  262.948358] RAX: 0100000000000000 RBX: ffffffffa0227940 RCX: ffffea0000707888
>> [  262.948363] RDX: ffffea0000707888 RSI: 0000000000000001 RDI: ffffffffa0227940
>> [  262.948369] RBP: ffff8800dad01de8 R08: 0000000000000000 R09: ffff8800d9e983a9
>> [  262.948374] R10: 0000000000000000 R11: 0000000000000000 R12: ffffffffa0227940
>> [  262.948380] R13: ffffffff8187cfc0 R14: 0000000000000000 R15: ffffffff8187da10
>> [  262.948386] FS:  00007fa2a2658700(0000) GS:ffff880112800000(0000) knlGS:0000000000000000
>> [  262.948394] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [  262.948400] CR2: 000000000000006c CR3: 00000000cddc0000 CR4: 00000000000006e0
>> [  262.948410] Stack:
>> [  262.948413]  ffff8800dad01da8 0000000000000286 0000000020227940 ffffffffa0227940
>> [  262.948422]  ffff8800dad01dd8 ffffffff811b7fa1 ffffffffa0227940 ffffffffa0227940
>> [  262.948431]  ffffffff8187d960 ffffffff8187cfc0 ffffffff8187d960 ffffffff8187da10
>> [  262.948440] Call Trace:
>> [  262.948457]  [<ffffffff811b7fa1>] ? unregister_sysctl_table+0x51/0xa0
>> [  262.948476]  [<ffffffffa020d1a1>] sctp_sysctl_net_unregister+0x21/0x30 [sctp]
>> [  262.948490]  [<ffffffffa020ef6d>] sctp_net_exit+0x12d/0x150 [sctp]
>> [  262.948512]  [<ffffffff81394f49>] ops_exit_list+0x39/0x60
>> [  262.948522]  [<ffffffff813951ed>] unregister_pernet_operations+0x3d/0x70
>> [  262.948530]  [<ffffffff81395292>] unregister_pernet_subsys+0x22/0x40
>> [  262.948544]  [<ffffffffa020efcc>] sctp_exit+0x3c/0x12d [sctp]
>> [  262.948562]  [<ffffffff810c5e04>] SyS_delete_module+0x194/0x210
>> [  262.948577]  [<ffffffff81240fde>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>> [  262.948587]  [<ffffffff815217a2>] system_call_fastpath+0x16/0x1b
>>
>> So add a check net_namespace init_net before kfree the sysctl_table.
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  net/sctp/sysctl.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>> index c82fdc1..844d2b0 100644
>> --- a/net/sctp/sysctl.c
>> +++ b/net/sctp/sysctl.c
>> @@ -459,7 +459,8 @@ void sctp_sysctl_net_unregister(struct net *net)
>>  
>>  	table = net->sctp.sysctl_header->ctl_table_arg;
>>  	unregister_net_sysctl_table(net->sctp.sysctl_header);
>> -	kfree(table);
>> +	if (!net_eq(net, &init_net))
>> +		kfree(table);
>>  }
>>  
>>  static struct ctl_table_header *sctp_sysctl_header;
>> -- 
>> 1.7.12
>>
>>
>>
> The size of of the sysctl table is 1.6k at the moment. Is it really worth having
> to special case this in two location just to save that space?  It almost seems
> better just to revert the origonal commit.
> 
I am not sure for that. In kernel, some do with this while others don't.
Add the special case, avoid to do kmemdup and reinitialization as well.

Regards
Wang

> Neil
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
