From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Sat, 14 May 2016 21:11:20 -0700
Message-ID: <5737F6E8.3040002@cumulusnetworks.com>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us> <1463053730-14991-2-git-send-email-jiri@resnulli.us> <5734F130.3050303@cumulusnetworks.com> <20160513060348.GA2060@nanopsycho.orion> <57362154.8040500@cumulusnetworks.com> <20160514124917.GA1957@nanopsycho.orion> <5737489D.4090800@cumulusnetworks.com> <20160514184629.GA2176@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34679 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbcEOELX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 00:11:23 -0400
Received: by mail-pf0-f181.google.com with SMTP id y69so55349254pfb.1
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 21:11:22 -0700 (PDT)
In-Reply-To: <20160514184629.GA2176@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/16, 11:46 AM, Jiri Pirko wrote:
> Sat, May 14, 2016 at 05:47:41PM CEST, roopa@cumulusnetworks.com wrote:
>> On 5/14/16, 5:49 AM, Jiri Pirko wrote:
>>> Fri, May 13, 2016 at 08:47:48PM CEST, roopa@cumulusnetworks.com wrote:
>>>>
[snip]
>>>>  Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>>
>>>>>> To me netdev stats is  combined 'SW + HW' stats for that netdev.
>>>>>> ndo_get_stats64 callback into the drivers does the magic of adding HW stats
>>>>>> to SW (netdev) stats and returning (see enic_get_stats). HW stats is available for netdevs
>>>>>> that are offloaded or are backed by hardware. SW stats is the stats that the driver maintains
>>>>>> (logical or physical). HW stats is queried and added to the SW stats.
>>>>> I'm not sure I follow. HW stats already contain SW stats. Because on
>>>>> slow path every packet that is not offloaded and goes through kernel is
>>>>> counted into HW stats as well (because it goes through HW port). 
>>>> yes, correct... we don't want to double count those. But since these stats are
>>>> generally queried from hw, I am calling them HW stats.
>>>> you will not really maintain a software counter for this. But, the driver can maintain its own
>>>> counters for rx and tx errors etc and I call these SW stats. They are counted at the driver.
>>>>
>>>>> If you
>>>>> do HW stats + SW stats, what you get makes no sense. Am I missing something?
>>>> If you go by my definition of HW and SW stats above, on a ndo_get_stats64() call,
>>>> you will add the SW counters + HW counters and return. In my definition, the pkts
>>>> that was rx'ed or tx'ed successfully are always in the HW count.
>>>>
>>>>> Btw, looking at enic_get_stats, looks exactly what we introduce for
>>>>> mlxsw in this patchset.
>>>> In enic_get_stats, the ones counted in software are the ones taken from 'enic->'
>>>>     net_stats->rx_over_errors = enic->rq_truncated_pkts;
>>>>     net_stats->rx_crc_errors = enic->rq_bad_fcs;
>>>>
>>>>> With this patchset, we only allow user to se the actual stats for
>>>>> slow-path aka SW stats.
>>>> hmm...ok. But i am not sure how many will use this new attribute.
>>>> When you do 'ip -s link show' you really want all counters on that port
>>>> hardware or software does not matter at that point.
>>>>
>>>> My suggestion to move this to ethtool like attribute is because that is an existing
>>>> way to break down your stats which ever way you want. And the best part is it can be
>>>> customized (say rx_pkts_cpu_saw)
>>> I bevieve that ethtool is really not a place to expose sw stats. Does
>>> not make sense.
>> 2 things:
>> - i was surprised you don't want your ndo_get_stats64 to be a unified view of HW and SW stats
> Roopa, please, look at the patch 4/4. That is exactly what we are doing.
> We expose HW stats via ndo_get_stats64 and that is of course including
> whatever comes through slowpath (non-forwarded in HW).

Maybe i missed it but i did not think it included any rx or tx err counters counted solely
by the driver.
>
>
>> - by bringing up ethtool like stats (IFLA_STATS_LINK_HW_EXTENDED) I am just saying
>> it has always been a way to breakdown stats. If you don't want to show explicit SW stats there,
>> there is always a way to show HW only stats....and now you know the delta between the unified stats
>> and the HW only stats is your SW stats.
> I think we don/t understand each other. HW stats always include SW
> stats. Because whatever goes in or out goes through HW. Therefore, the
> "unified stats" you mention are exactly HW stats.
>
> This is fine, Patch 4/4 would do to make this correct. However, I think
> it has value for user to know what went via slowpath (non-forwarded in HW).
> And that is exacly exposed by the SW stats we try to add.
>
> Is that confusing?

Its not confusing. I understand what you are doing.
The only point I was making was that most drivers have unified stats via ndo
and there are also hw stats via ethtool like api (which will also be part of the stats
api in the future). And sw only stats can be derived from that...which is the way most
people do today.
But that's fine. If you think it will be useful/easier to have a new api/attribute
for software only stats for some drivers, sure, fine. Lets move on.
