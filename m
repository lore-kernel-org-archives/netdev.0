From: mabbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW, SIOCSIWPOWER
 and SIOCGIWPOWER
Date: Thu, 21 Sep 2006 09:43:31 -0700
Message-ID: <4512C133.7010509@linux.intel.com>
References: <44F355DE.3000206@linux.intel.com> <20060921183040.12d679f2@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:48406 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S1751327AbWIUQpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 12:45:39 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060921183040.12d679f2@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> Hi,
>
> sorry for the long delay.
>
> On Mon, 28 Aug 2006 13:45:18 -0700, mabbas wrote:
>   
>> [...]
>> +static int ieee80211_ioctl_siwtxpow(struct net_device *dev,
>> +				    struct iw_request_info *info,
>> +				    union iwreq_data *wrqu, 
>> +				    char *extra)
>> +{
>> +	int rc = 0;
>> +	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
>> +
>> +	if (wrqu->txpower.flags != IW_TXPOW_DBM)
>> +		rc = -EINVAL;
>> +	else
>> +		conf->power_level = wrqu->txpower.value;
>> +
>> +
>> +	ieee80211_ioctl_set_radio_enabled(dev, !wrqu->txpower.disabled);
>>     
>
> Expecting implicit call of ieee80211_hw_config in
> ieee80211_ioctl_set_radio_enabled doesn't look like a good idea. If the
> latter function is changed (to call hw_config only if the radio_enabled
> field isn't the same as before), the SIOCSIWTXPOW ioctl won't have any
> effect.
>
> I'd prefer setting conf->radio_enabled directly and calling of
> ieee80211_hw_config explicitly.
>
> Also, always double check that you do error handling correctly (functions
> usually return something on purpose). (Hm, I already told you in this
> specific case. Please also double check that you haven't missed any comment
> before resending patches.)
>
>   
What about adding a new callback function fot txpower. 
ieee80211_hw_config callback still confusing if txpower was
changed for channel change or because the user setting txpower limit.
>> +	return rc;
>> +}
>> +
>> +static int ieee80211_ioctl_siwpower(struct net_device *dev,
>> +				    struct iw_request_info *info,
>> +				    union iwreq_data *wrqu, 
>> +				    char *extra)
>> +{
>> +	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
>> +
>> +	if (wrqu->power.disabled) {
>> +		conf->power_management_enable = 0;
>> +		if (ieee80211_hw_config(dev))
>> +			return -EINVAL;
>> +		return 0;
>>     
>
> This is wrong. Return the error code you've got from ieee80211_hw_config.
>   
Ok
>   
>> +	}
>> +
>> +	if (wrqu->power.flags & IW_POWER_TYPE)
>> +		return -EINVAL;
>> +
>> +	switch (wrqu->power.flags & IW_POWER_MODE) {
>> +	case IW_POWER_ON:       /* If not specified */
>> +	case IW_POWER_MODE:     /* If set all mask */
>> +	case IW_POWER_ALL_R:    /* If explicitely state all */
>> +		break;
>> +	default:                /* Otherwise we don't support it */
>> +		return -EINVAL;
>> +	}
>> +
>> +	conf->power_management_enable = 1;
>> +
>> +	if (ieee80211_hw_config(dev))
>> +		return -EINVAL;
>>     
>
> Ditto.
>
> Thanks,
>
>  Jiri
>
>   
