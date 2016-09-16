From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v9 2/3] net: core: Add offload stats to
 if_stats_msg
Date: Fri, 16 Sep 2016 10:07:03 +0200
Message-ID: <20160916080703.GB1861@nanopsycho.orion>
References: <1473845322-16679-1-git-send-email-jiri@resnulli.us>
 <1473845322-16679-3-git-send-email-jiri@resnulli.us>
 <6226A529-D83B-4B77-8091-E6E8528B0063@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, nogahf@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
        yotamg@mellanox.com, ogerlitz@mellanox.com,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        linville@tuxdriver.com, tgraf@suug.ch,
        Andy Gospodarek <gospo@cumulusnetworks.com>, sfeldma@gmail.com,
        sd@queasysnail.net, eranbe@mellanox.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33584 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754476AbcIPIHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 04:07:07 -0400
Received: by mail-wm0-f65.google.com with SMTP id b187so2423897wme.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 01:07:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6226A529-D83B-4B77-8091-E6E8528B0063@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 16, 2016 at 10:00:46AM CEST, nikolay@cumulusnetworks.com wrote:
>
>> On Sep 14, 2016, at 12:28 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> 
>> From: Nogah Frankel <nogahf@mellanox.com>
>> 
>> Add a nested attribute of offload stats to if_stats_msg
>> named IFLA_STATS_LINK_OFFLOAD_XSTATS.
>> Under it, add SW stats, meaning stats only per packets that went via
>> slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.
>> 
>> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> include/uapi/linux/if_link.h |   9 ++++
>> net/core/rtnetlink.c         | 111 +++++++++++++++++++++++++++++++++++++++++--
>> 2 files changed, 116 insertions(+), 4 deletions(-)
>> 
>[snip]
>> @@ -3655,6 +3737,24 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
>> 		}
>> 	}
>> 
>> +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS,
>> +			     *idxattr)) {
>> +		*idxattr = IFLA_STATS_LINK_OFFLOAD_XSTATS;
>> +		attr = nla_nest_start(skb, IFLA_STATS_LINK_OFFLOAD_XSTATS);
>> +		if (!attr)
>> +			goto nla_put_failure;
>> +
>> +		err = rtnl_get_offload_stats(skb, dev, prividx);
>> +		if (err == -ENODATA)
>> +			nla_nest_cancel(skb, attr);
>> +		else
>> +			nla_nest_end(skb, attr);
>> +
>> +		if ((err) && (err != -ENODATA))
>                       ^^^^       ^^^^^^^^^^^^^^^^^^
>The extra braces are still there. [1]

:( Will fix. Thanks.

>The rest looks good to me.
>
>Thanks,
> Nik
>
>[1] http://www.spinics.net/lists/netdev/msg394257.html
>
>> +			goto nla_put_failure;
>> +		*idxattr = 0;
>> +	}
>> +
>> 	nlmsg_end(skb, nlh);
>> 
>> 	return 0;
>> @@ -3708,6 +3808,9 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
>> 		}
>> 	}
>> 
>> +	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS, 0))
>> +		size += rtnl_get_offload_stats_size(dev);
>> +
>> 	return size;
>> }
>> 
>> -- 
>> 2.5.5
>> 
>
