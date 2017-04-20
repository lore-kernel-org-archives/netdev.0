From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] netdevice: Prefer NETIF_F_HW_CSUM when intersecting
 features
Date: Thu, 20 Apr 2017 11:20:19 -0400
Message-ID: <4e31097d-3cfd-27ee-ad99-8a120c1eaf43@redhat.com>
References: <1492650743-28164-1-git-send-email-vyasevic@redhat.com>
 <20170420061312.GF13789@unicorn.suse.cz>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: Michal Kubecek <mkubecek@suse.cz>,
        Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60554 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970385AbdDTPUV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 11:20:21 -0400
In-Reply-To: <20170420061312.GF13789@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 02:13 AM, Michal Kubecek wrote:
> On Wed, Apr 19, 2017 at 09:12:23PM -0400, Vladislav Yasevich wrote:
>> While hardware device use either NETIF_F_(IP|IPV6)_CSUM or
>> NETIF_F_HW_CSUM, all of the software devices use HW_CSUM.
>> This results in an interesting situation when the software
>> device is configured on top of hw device using (IP|IPV6)_CSUM.
>> In this situation, the user can't turn off checksum offloading
>> features on the software device.
>>
>> This patch resolves that by prefering the NETIF_F_HW_CSUM setting
>> when computing a feature intersect.
> 
> The reasoning makes sense to me but perhaps we should rename the helper
> then to make it obvious that it doesn't work like intersection anymore
> (not even in the logical sense).

It's still an intersect in the end since we return (f1 & f2).  We are just
munging checksum so that we get a HW_CSUM in the end if one of the devices supported
it.

> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 97456b25..3d811c1 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -4019,9 +4019,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
>>  {
>>  	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
>>  		if (f1 & NETIF_F_HW_CSUM)
>> -			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>> +			f2 |= NETIF_F_HW_CSUM;
>>  		else
>> -			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>> +			f1 |= NETIF_F_HW_CSUM;
>>  	}
>>  
>>  	return f1 & f2;
> 
> I hope I didn't miss something but it seems we can avoid nested ifs now:
> 
>  	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
> 		f1 |= NETIF_F_HW_CSUM;
> 		f2 |= NETIF_F_HW_CSUM;
>  	}
> 

Yes, we can do that.  We could have done something like this before as well, I suppose.

Thanks
-vlad

> Michal Kubecek
> 
