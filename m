From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 14:50:19 +0200
Message-ID: <4857B30B.8020809@trash.net>
References: <20080616213417.GA14988@ami.dom.local>	 <4856DF91.30606@trash.net> <1213667154.21932.47.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63191 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845AbYFQMu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 08:50:26 -0400
In-Reply-To: <1213667154.21932.47.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi Patrick,
> 
>> So we have:
>>
>> genl_rcv()            : take genl_mutex
>> genl_rcv_msg()        : call netlink_dump_start() while holding genl_mutex
>> netlink_dump_start(),
>> netlink_dump()        : take nlk->cb_mutex
>> ctrl_dumpfamily()     : try to detect this case and not take genl_mutex a
>>                         second time
>>
>> netlink_rcv()         : call netlink_dump
>> netlink_dump          : take nlk->cb_mutex
>> ctrl_dumpfamily()     : take genl_mutex
>>
>> which is a real bug.
>>
>> It seems the best fix is to use genl_mutex for the netlink cb_mutex,
>> drop genl_mutex before calling netlink_dump_start and don't take it
>> in ctrl_dumpfamily, relying completely on af_netlink.c for dump
>> locking. Unfortunately this creates a race since the ops passed to
>> netlink_dump_start are also protect by the mutex, so this patch
>> is just for testing whether it fixes the warning.
> 
> I updated my test kernel to 2.6.26-rc6 and then applied your patch and
> the lockdep warning goes away.


Thanks for testing. Unfortunately the module unload races look
more complicated to fix and I'm busy with other things, so it
would great if someone else could fix this.




