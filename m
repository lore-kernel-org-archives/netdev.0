From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Wed, 17 Jun 2015 10:31:47 -0700
Message-ID: <5581AF03.8010501@redhat.com>
References: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bDnVEq1mqUmmYMFAd9CeEbn9tTzD_UnoDKYVScT5G=QJA@mail.gmail.com> <5581893E.3070609@cumulusnetworks.com> <558193C1.70001@gmail.com> <55819E5A.8020801@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755588AbbFQRbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 13:31:48 -0400
In-Reply-To: <55819E5A.8020801@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2015 09:20 AM, roopa wrote:
> On 6/17/15, 8:35 AM, Alexander Duyck wrote:
>>
>>> @@ -1189,8 +1190,9 @@ int fib_table_insert(struct fib_table *tb, struct
>>> fib_config *cfg)
>>>                          fib_release_info(fi_drop);
>>>                          if (state & FA_S_ACCESSED)
>>> rt_cache_flush(cfg->fc_nlinfo.nl_net);
>>> +                       nlflags |= NLM_F_REPLACE;
>>>                          rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, 
>>> plen,
>>> -                               tb->tb_id, &cfg->fc_nlinfo, 
>>> NLM_F_REPLACE);
>>> +                               tb->tb_id, &cfg->fc_nlinfo, nlflags);
>>>
>>>                          goto succeeded;
>>>
>>
>> Why even bother modifying this part?  Is this actually needed at all, 
>> are there some other flags you plan to drop into nlflags as well that 
>> would be passed as a part of this message?
>
> agreed, for the same reason my initial patch did not touch this part. 
> Nope, no other flags. I was trying to meet scotts concerns.
>>
>>> @@ -1201,7 +1203,9 @@ int fib_table_insert(struct fib_table *tb, struct
>>> fib_config *cfg)
>>>                  if (fa_match)
>>>                          goto out;
>>>
>>> -               if (!(cfg->fc_nlflags & NLM_F_APPEND))
>>> +               if (cfg->fc_nlflags & NLM_F_APPEND)
>>> +                       nlflags |= NLM_F_APPEND;
>>> +               else
>>>                          fa = fa_first;
>>>          }
>>>          err = -ENOENT;
>>
>> I'm not sure I see the point of using the |=.   Why not just use a = 
>> and save yourself an instruction or two since you don't really need 
>> the OR operator in this case.
>>
> ack,
>
> I would prefer keeping my initial patch which was pretty non-intrusive.

I'd say go with something closer to the original patch, but flip the 
logic like you have here, and lose the "|=" in favor of an "=" since you 
are either sending a message with 0 or NLM_F_APPEND.

Anyway that is just my $.02.

- Alex
