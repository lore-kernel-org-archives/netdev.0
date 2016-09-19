From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/2] fib: introduce fib notification
 infrastructure
Date: Mon, 19 Sep 2016 17:08:32 +0200
Message-ID: <20160919150832.GD1846@nanopsycho.orion>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <1473163300-2045-2-git-send-email-jiri@resnulli.us>
 <57DF2203.4000903@cumulusnetworks.com>
 <20160919060610.GA1846@nanopsycho.orion>
 <57DFFBD3.9040906@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34524 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcISPIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 11:08:36 -0400
Received: by mail-wm0-f66.google.com with SMTP id l132so14291034wmf.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 08:08:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57DFFBD3.9040906@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 19, 2016 at 04:53:07PM CEST, roopa@cumulusnetworks.com wrote:
>On 9/18/16, 11:06 PM, Jiri Pirko wrote:
>> Mon, Sep 19, 2016 at 01:23:47AM CEST, roopa@cumulusnetworks.com wrote:
>>> On 9/6/16, 5:01 AM, Jiri Pirko wrote:
>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>> This allows to pass information about added/deleted fib entries to
>>>> whoever is interested. This is done in a very similar way as devinet
>>>> notifies address additions/removals.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>
>[snip]
>>>>  
>>>>  #define KEYLENGTH	(8*sizeof(t_key))
>>>> @@ -1190,6 +1221,10 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>>>>  			fib_release_info(fi_drop);
>>>>  			if (state & FA_S_ACCESSED)
>>>>  				rt_cache_flush(cfg->fc_nlinfo.nl_net);
>>>> +
>>>> +			call_fib_notifiers(FIB_EVENT_TYPE_ADD, key, plen, fi,
>>>> +					   new_fa->fa_tos, cfg->fc_type,
>>>> +					   tb->tb_id, cfg->fc_nlflags);
>>>>  			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
>>>>  				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
>>>>  
>>>> @@ -1241,6 +1276,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>>>>  		tb->tb_num_default++;
>>>>  
>>>>  	rt_cache_flush(cfg->fc_nlinfo.nl_net);
>>>> +	call_fib_notifiers(FIB_EVENT_TYPE_ADD, key, plen, fi, tos,
>>>> +			   cfg->fc_type, tb->tb_id, cfg->fc_nlflags);
>>>
>>> It appears that this is in addition to the existing switchdev_fib_ipv4_add call right above this.
>>> Is the intent to do both ?. i don't see a need to do both.
>> I already have patchset improved that it removes the switchdev fib code.
>> Have to do some more testing, will send it soon.
>
>ok, ack.
>>
>>
>>> and switchdev_fib_ipv4_add  offloads before the route is added to the kernel.
>>> But the notifier seems to fire after the route is added to the kernel.
>> Yeah, I wanted to align it with rtmsg_fib calls. Also I think it makes
>> sense to have slowpath ready before offload.
>>
>
>ok, ..but..that changes existing behavior though. and if the hw route add fails...,
>you may have inconsistent state between hw and sw.

If the hw route add fails, driver will be responsible for abort,
cleanining up hw and set appropriate traps to get packets to cpu
processing.
