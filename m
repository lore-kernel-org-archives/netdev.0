From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 08/10] mac80211: Support on-channel scan option.
Date: Thu, 12 Apr 2012 08:03:40 -0700
Message-ID: <4F86EECC.4090805@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>  <1334166738-28243-9-git-send-email-greearb@candelatech.com>  (sfid-20120411_195349_401873_95D8A0F4) <1334202356.3788.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50663 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab2DLPDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 11:03:46 -0400
In-Reply-To: <1334202356.3788.7.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2012 08:45 PM, Johannes Berg wrote:
> On Wed, 2012-04-11 at 10:52 -0700, greearb@candelatech.com wrote:
>
>>   static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
>>   				  struct cfg80211_scan_request *req)
>> @@ -438,10 +461,43 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
>>   	local->scan_req = req;
>>   	local->scan_sdata = sdata;
>>
>> -	if (local->ops->hw_scan)
>> +	if (local->ops->hw_scan) {
>>   		__set_bit(SCAN_HW_SCANNING,&local->scanning);
>> -	else
>> -		__set_bit(SCAN_SW_SCANNING,&local->scanning);
>> +	} else {
>> +		/* If we are scanning only on the current channel, then
>> +		 * we do not need to stop normal activities
>> +		 */
>> +		if ((req->n_channels == 1)&&
>> +		    (req->channels[0]->center_freq ==
>> +		     local->hw.conf.channel->center_freq)) {
>
> how about "else if {", then the indentation isn't so deep and you can
> have much nicer code in the entire block :)
>
>> +			unsigned long next_delay;
>
> please add a blank line after variable declarations.
>
>> +		}
>> +		else {
>
> please read the coding style documentation
>
>> @@ -672,6 +704,12 @@ void ieee80211_scan_work(struct work_struct *work)
>>
>>   	sdata = local->scan_sdata;
>>
>> +	/* When scanning on-channel, the first-callback means completeed. */
>
> typo "completed"

Ok, will fix all of that.


>> +	if (test_bit(SCAN_ONCHANNEL_SCANNING,&local->scanning)) {
>> +		aborted = test_and_clear_bit(SCAN_ABORTED,&local->scanning);
>> +		goto out_complete;
>> +	}
>
> how does the onchannel bit get cleared?

__ieee80211_scan_completed sets local->scanning to 0, and it
will WARN_ON if local->scanning is NOT zero when entering
the method, so I don't think I should clear it earlier.

> Shouldn't you be calling pre/post scan hooks?

Probably so...I'll add that.  Doesn't look like ath9k uses
it, but maybe some other NIC does need it.

> I'm a bit divided over this. On the one hand, it seems like a mildly
> useful optimisation, on the other though it adds a bunch of complexity
> for multi-channel we've been thinking about... Not that we want to
> support multi-channel with SW scan anyway, but still.

It's just an optimization...maybe just add a check and do a regular scan
if multi-channel is active if it's difficult to just make it work with
multi-channel?

Thanks,
Ben

>
> johannes


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
