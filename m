From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit.
Date: Thu, 24 Jan 2013 14:14:32 -0800
Message-ID: <87k3r2z0s7.fsf@xmission.com>
References: <51004F2D.9000405@fold.natur.cuni.cz>
	<1359043367-30180-1-git-send-email-vyasevich@gmail.com>
	<20130124164439.GB20658@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	mmokrejs@fold.natur.cuni.cz
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51216 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278Ab3AXWOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 17:14:47 -0500
In-Reply-To: <20130124164439.GB20658@hmsreliant.think-freely.org> (Neil
	Horman's message of "Thu, 24 Jan 2013 11:44:39 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> writes:

> On Thu, Jan 24, 2013 at 11:02:47AM -0500, Vlad Yasevich wrote:
>> Per-net sysctl table needs to be explicitly freed at
>> net exit.  Otherwise we see the following with kmemleak:
>> 
>> unreferenced object 0xffff880402d08000 (size 2048):
>>   comm "chrome_sandbox", pid 18437, jiffies 4310887172 (age 9097.630s)
>>   hex dump (first 32 bytes):
>>     b2 68 89 81 ff ff ff ff 20 04 04 f8 01 88 ff ff  .h...... .......
>>     04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
>>   backtrace:
>>     [<ffffffff815b4aad>] kmemleak_alloc+0x21/0x3e
>>     [<ffffffff81110352>] slab_post_alloc_hook+0x28/0x2a
>>     [<ffffffff81113fad>] __kmalloc_track_caller+0xf1/0x104
>>     [<ffffffff810f10c2>] kmemdup+0x1b/0x30
>>     [<ffffffff81571e9f>] sctp_sysctl_net_register+0x1f/0x72
>>     [<ffffffff8155d305>] sctp_net_init+0x100/0x39f
>>     [<ffffffff814ad53c>] ops_init+0xc6/0xf5
>>     [<ffffffff814ad5b7>] setup_net+0x4c/0xd0
>>     [<ffffffff814ada5e>] copy_net_ns+0x6d/0xd6
>>     [<ffffffff810938b1>] create_new_namespaces+0xd7/0x147
>>     [<ffffffff810939f4>] copy_namespaces+0x63/0x99
>>     [<ffffffff81076733>] copy_process+0xa65/0x1233
>>     [<ffffffff81077030>] do_fork+0x10b/0x271
>>     [<ffffffff8100a0e9>] sys_clone+0x23/0x25
>>     [<ffffffff815dda73>] stub_clone+0x13/0x20
>>     [<ffffffffffffffff>] 0xffffffffffffffff
>> 
>> Reported-by: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
>> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
>> CC: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  net/sctp/sysctl.c |    4 ++++
>>  1 files changed, 4 insertions(+), 0 deletions(-)
>> 
>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>> index 043889a..cd5712f 100644
>> --- a/net/sctp/sysctl.c
>> +++ b/net/sctp/sysctl.c
>> @@ -366,7 +366,11 @@ int sctp_sysctl_net_register(struct net *net)
>>  
>>  void sctp_sysctl_net_unregister(struct net *net)
>>  {
>> +	struct ctl_table *table;
>> +
>> +	table = net->sctp.sysctl_hdr->ctl_table_arg;
>>  	unregister_net_sysctl_table(net->sctp.sysctl_header);
>> +	kfree(table);
>>  }
>>  
>>  static struct ctl_table_header * sctp_sysctl_header;
>> -- 
>> 1.7.7.6
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

Doh.  I should have known better.

Eric
