From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 4/8] net: ipv6: mld: implement RFC3810 MLDv2
 mode only
Date: Tue, 03 Sep 2013 23:16:27 +0200
Message-ID: <522651AB.1000504@redhat.com>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com> <1378195178-21002-5-git-send-email-dborkman@redhat.com> <20130903210011.GB28889@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761100Ab3ICVQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 17:16:35 -0400
In-Reply-To: <20130903210011.GB28889@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 11:00 PM, Hannes Frederic Sowa wrote:
> Hi Daniel!
>
> On Tue, Sep 03, 2013 at 09:59:34AM +0200, Daniel Borkmann wrote:
>> RFC3810, 10. Security Considerations says under subsection 10.1.
>> Query Message:
>>
>>    A forged Version 1 Query message will put MLDv2 listeners on that
>>    link in MLDv1 Host Compatibility Mode. This scenario can be avoided
>>    by providing MLDv2 hosts with a configuration option to ignore
>>    Version 1 messages completely.
>>
>> Hence, implement a MLDv2-only mode that will ignore MLDv1 traffic:
>>
>>    echo 2 > /proc/sys/net/ipv6/conf/ethX/force_mld_version
>
> I just played around with MLDv2-only mode and noticed that the commit message
> diverges from the code:
>
>> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
>> index 005b22f..02cd0c5 100644
>> --- a/net/ipv6/mcast.c
>> +++ b/net/ipv6/mcast.c
>> @@ -1112,9 +1112,21 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
>>   	return true;
>>   }
>>
>> +static bool mld_in_v2_mode_only(const struct inet6_dev *idev)
>> +{
>> +	return dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 2;
>
> Maybe something like
>
> int val = idev->cnf.force_mld_version ?: dev_net(idev->dev)->ipv6.devconf_all->force_mld_version;
> return val == 2;

Hm, true, thanks for spotting. I think it makes sense, first check for individual idev
setting, then for whole namespace. I will update the series and send v2.

>> +}
>> +
>> +static bool mld_in_v1_mode_only(const struct inet6_dev *idev)
>> +{
>> +	return dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 1;
>
> Likewise.
>
>> +}
>> +
>>   static bool mld_in_v1_mode(const struct inet6_dev *idev)
>>   {
>> -	if (dev_net(idev->dev)->ipv6.devconf_all->force_mld_version == 1)
>> +	if (mld_in_v2_mode_only(idev))
>> +		return false;
>> +	if (mld_in_v1_mode_only(idev))
>>   		return true;
>>   	if (idev->cnf.force_mld_version == 1)
>>   		return true;
>
> This last if statement could be dropped then.
>
> Thanks,
>
>    Hannes
>
