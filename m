From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 8/8] d80211/bcm43xx: Modify ieee80211_ioctl.c for	wireless
 statistics.
Date: Wed, 09 Aug 2006 10:27:04 -0500
Message-ID: <44D9FEC8.9000409@lwfinger.net>
References: <44D92588.5070102@lwfinger.net> <1155133698.3615.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:17811 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751001AbWHIP1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 11:27:08 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1155133698.3615.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Tue, 2006-08-08 at 19:00 -0500, Larry Finger wrote:
>> Part 8 of 8 to add wireless statistics to the bcm43xx-d80211 system.
>> This patch adds the appropriate range parameters and routine
>> ieee80211_get_wireless_stats to ieee80211_ioctl.c.
>>
>> The patch is for the August 8 version of Linville's wireless-dev tree.
>>
>> Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>
>>
>>
>> diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
>> index dd52555..3a1b97f 100644
>> --- a/net/d80211/ieee80211_ioctl.c
>> +++ b/net/d80211/ieee80211_ioctl.c
>> @@ -1525,6 +1525,16 @@ static int ieee80211_ioctl_giwrange(stru
>>   	range->min_frag = 256;
>>   	range->max_frag = 2346;
>>
>> +	range->max_qual.qual = 100;
>> +	range->max_qual.level = 152;  /* set floor at -104 dBm (152 - 256) */
>> +	range->max_qual.noise = 152;
>> +	range->max_qual.updated = IW_QUAL_ALL_UPDATED;
>> +
>> +	range->avg_qual.qual = 50;
>> +	range->avg_qual.level = 0;
>> +	range->avg_qual.noise = 0;
>> +	range->avg_qual.updated = IW_QUAL_ALL_UPDATED;
>> +
>>   	return 0;
>>   }
>>
>> @@ -2963,6 +2973,39 @@ static int ieee80211_ioctl_giwauth(struc
>>   	return ret;
>>   }
>>
>> +/* Get wireless statistics.  Called by /proc/net/wireless and by SIOCGIWSTATS */
>> +static struct iw_statistics *ieee80211_get_wireless_stats(struct net_device *net_dev)
>> +{
>> +	struct ieee80211_local *local = net_dev->ieee80211_ptr;
>> +	struct iw_statistics * wstats = &local->wstats;
>> +	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(net_dev);
>> +	struct sta_info *sta;
>> +	static int tmp_level = 0;
>> +	static int tmp_qual = 0;
>> +
>> +	sta = sta_info_get(local, sdata->u.wds.remote_addr);
>> +	if (!sta) {
>> +		wstats->discard.fragment = 0;
>> +		wstats->discard.misc = 0;
>> +		wstats->qual.qual = 0;
>> +		wstats->qual.level = 0;
>> +		wstats->qual.noise = 0;
>> +		wstats->qual.updated |= IW_QUAL_ALL_UPDATED;
> 
> What does the 'if (!sta)' check do?  What's the case here?  If the card
> is not connected an access point or otherwise unconnected to anything
> else, you should use IW_QUAL_ALL_INVALID here I think, because signal
> quality has no meaning when you're disconnected (except possibly
> background noise).

The check is mostly to prevent NULL pointers in the else branch, but your 
suggestion of INVALID is good.

> 
>> +	} else {
>> +		if (!tmp_level) {       /* get initial values */
>> +			tmp_level = sta->last_signal;
>> +			tmp_qual = sta->last_rssi;
>> +		} else {                        /* smooth results */
>> +			tmp_level = (15 * tmp_level + sta->last_signal)/16;
>> +			tmp_qual = (15 * tmp_qual + sta->last_rssi)/16;
>> +		}
>> +		wstats->qual.level = tmp_level;
>> +		wstats->qual.qual = 100*tmp_qual/sta->max_rssi;
>> +		wstats->qual.noise = sta->last_noise;
>> +		wstats->qual.updated = IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
> 
> By using IW_QUAL_DBM, you're forcing all cards that use d80211 to report
> statistics in dBm.  I think that's a _good_ thing personally (it brings
> some consistency to the whole wireless quality pit-of-doom), but I want
> to make sure this is actually what you want to do here.

 From what I learned in our previous discussions, that is exactly what I meant.

Thanks for your comments.

Larry

