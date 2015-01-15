From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 03/12] net: flow: implement flow cache for
 get routines
Date: Wed, 14 Jan 2015 19:21:33 -0800
Message-ID: <54B7323D.9030506@gmail.com>
References: <20150113212941.13874.48692.stgit@nitbit.x32> <20150113213621.13874.40461.stgit@nitbit.x32> <20150114215232.GF2105@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:40072 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbAODV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 22:21:57 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so11546505obc.0
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 19:21:56 -0800 (PST)
In-Reply-To: <20150114215232.GF2105@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 01:52 PM, Thomas Graf wrote:
> On 01/13/15 at 01:36pm, John Fastabend wrote:
>> I chose rhashtable to get the dynamic resizing. I could use arrays
>> but I don't want to pre-allocate large cache tables when we may
>> never use them.
>>
>> One oddity in the rhashtable implementation is there is no way
>> AFAICS to do delayed free's so we use rcu_sync heavily. This should be
>> fine, get operations shouldn't be a used heavily.
>
> John, can you please clarify a bit, I'm not sure I understand. Are you
> talking about delayed freeing of the table itself or elements?
>
> The Netlink usage would be an example of a user with delayed element
> freeing.
>
> I'm glad to add whatever is required.
>

Took another look at the netlink code looks like this is the correct
pattern where the call_rcu implements the delayed freeing after a grace
period.

	mutex_lock(&my_hash_lock);
	rhashtable_remove(&my_hash, &my_obj->rhash_head);
	mutex_unlock(&my_hash_lock)

	[...]

	call_rcu(&my_obj->rcu, deferred_my_obj_free);

anyways it looks like it is there no problem after all and I don't
recall what I was thinking thanks for bearing with me. I'll convert
this code to avoid the over-use of rcu_sync.

Thanks,
John

-- 
John Fastabend         Intel Corporation
