From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 1/2] fib: introduce fib notification infrastructure
Date: Mon, 19 Sep 2016 07:53:07 -0700
Message-ID: <57DFFBD3.9040906@cumulusnetworks.com>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us> <1473163300-2045-2-git-send-email-jiri@resnulli.us> <57DF2203.4000903@cumulusnetworks.com> <20160919060610.GA1846@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35297 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbcISOxL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:53:11 -0400
Received: by mail-pf0-f176.google.com with SMTP id z123so51736566pfz.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 07:53:10 -0700 (PDT)
In-Reply-To: <20160919060610.GA1846@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/18/16, 11:06 PM, Jiri Pirko wrote:
> Mon, Sep 19, 2016 at 01:23:47AM CEST, roopa@cumulusnetworks.com wrote:
>> On 9/6/16, 5:01 AM, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This allows to pass information about added/deleted fib entries to
>>> whoever is interested. This is done in a very similar way as devinet
>>> notifies address additions/removals.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---

[snip]
>>>  
>>>  #define KEYLENGTH	(8*sizeof(t_key))
>>> @@ -1190,6 +1221,10 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>>>  			fib_release_info(fi_drop);
>>>  			if (state & FA_S_ACCESSED)
>>>  				rt_cache_flush(cfg->fc_nlinfo.nl_net);
>>> +
>>> +			call_fib_notifiers(FIB_EVENT_TYPE_ADD, key, plen, fi,
>>> +					   new_fa->fa_tos, cfg->fc_type,
>>> +					   tb->tb_id, cfg->fc_nlflags);
>>>  			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
>>>  				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
>>>  
>>> @@ -1241,6 +1276,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>>>  		tb->tb_num_default++;
>>>  
>>>  	rt_cache_flush(cfg->fc_nlinfo.nl_net);
>>> +	call_fib_notifiers(FIB_EVENT_TYPE_ADD, key, plen, fi, tos,
>>> +			   cfg->fc_type, tb->tb_id, cfg->fc_nlflags);
>>
>> It appears that this is in addition to the existing switchdev_fib_ipv4_add call right above this.
>> Is the intent to do both ?. i don't see a need to do both.
> I already have patchset improved that it removes the switchdev fib code.
> Have to do some more testing, will send it soon.

ok, ack.
>
>
>> and switchdev_fib_ipv4_add  offloads before the route is added to the kernel.
>> But the notifier seems to fire after the route is added to the kernel.
> Yeah, I wanted to align it with rtmsg_fib calls. Also I think it makes
> sense to have slowpath ready before offload.
>

ok, ..but..that changes existing behavior though. and if the hw route add fails...,
you may have inconsistent state between hw and sw.
