From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH net-next 01/11] netns: Fix race between put_net() and netlink_kernel_create()
Date: Thu, 7 May 2015 10:19:12 -0700
Message-ID: <CAHA+R7Mc==jHi-vtyNwboYW-ysacgbA-yAG+tetx8HJFUrrf9Q@mail.gmail.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<1430988770-28907-2-git-send-email-ying.xue@windriver.com>
	<20150507090450.GA31792@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ying Xue <ying.xue@windriver.com>, netdev <netdev@vger.kernel.org>,
	xemul@openvz.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, maxk@qti.qualcomm.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, jon.maloy@ericsson.com,
	horms@verge.net.au
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33018 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbEGRTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 13:19:13 -0400
Received: by wief7 with SMTP id f7so18885492wie.0
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 10:19:12 -0700 (PDT)
In-Reply-To: <20150507090450.GA31792@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 7, 2015 at 2:04 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Thu, May 07, 2015 at 04:52:40PM +0800, Ying Xue wrote:
>>
>> @@ -409,12 +410,17 @@ void __put_net(struct net *net)
>>  {
>>       /* Cleanup the network namespace in process context */
>>       unsigned long flags;
>> +     bool added = false;
>>
>>       spin_lock_irqsave(&cleanup_list_lock, flags);
>> -     list_add(&net->cleanup_list, &cleanup_list);
>> +     if (list_empty(&net->cleanup_list)) {
>> +             list_add(&net->cleanup_list, &cleanup_list);
>> +             added = true;
>> +     }
>
> Stop right there.  If a ref count is hitting zero twice you've
> got big problems.  Because it means that after hitting zero the
> first time it'll become positive again (if only briefly) which
> opens you up to a race against the cleanup.

That is true.

>
> So this idea is a non-starter.
>
> The rules for ref counts are really simple, if you hit zero then
> you're dead.  Can someone explain to me in simple terms why this
> ref count is special and needs to hit zero twice?

Because after it hits zero, it queues the final cleanup to a workqueue,
which could be delayed (depends on when the worker will be scheduled),
therefore there is a small window that new ->init() could come in.

You can argue that netns->init() should not see a dead netns, but
unfortunately that seems even harder since removing netns from global
netns list requires rtnl lock which is not doable in __put_net().
