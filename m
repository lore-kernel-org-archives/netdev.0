From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] bgmac: Add support for ethtool statistics
Date: Fri, 3 Jun 2016 11:10:10 -0700
Message-ID: <5751C802.1050008@gmail.com>
References: <1464973621-14794-1-git-send-email-f.fainelli@gmail.com>
 <1464973621-14794-3-git-send-email-f.fainelli@gmail.com>
 <1464976668.2847.117.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zajec5@gmail.com, nbd@nbd.name,
	hauke@hauke-m.de, jon.mason@broadcom.com
To: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:32926 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074AbcFCSKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:10:13 -0400
Received: by mail-pa0-f68.google.com with SMTP id di3so6479019pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:10:13 -0700 (PDT)
In-Reply-To: <1464976668.2847.117.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 10:57 AM, Ben Hutchings wrote:
> On Fri, 2016-06-03 at 10:07 -0700, Florian Fainelli wrote:
> [...]
>> +static void bgmac_get_strings(struct net_device *dev, u32 stringset,
>> +			      u8 *data)
>> +{
>> +	int i;
>> +
>> +	if (stringset != ETH_SS_STATS)
>> +		return;
>> +
>> +	for (i = 0; i < BGMAC_STATS_LEN; i++)
>> +		memcpy(data + i * ETH_GSTRING_LEN,
>> +		       bgmac_get_strings_stats[i].name,
>> +		       ETH_GSTRING_LEN);
> 
> These strings are null-terminated, not padded to ETH_GSTRING_LEN.  So
> here you should be using strlcpy() instead of memcpy().
> 
>> +}
>> +
>> +static void bgmac_get_ethtool_stats(struct net_device *dev,
>> +				    struct ethtool_stats *ss, uint64_t *data)
>> +{
>> +	struct bgmac *bgmac = netdev_priv(dev);
>> +	const struct bgmac_stat *s;
>> +	unsigned int i;
>> +	u64 val;
>> +
>> +	if (!netif_running(dev))
>> +		return;
>> +
>> +	for (i = 0; i < BGMAC_STATS_LEN; i++) {
>> +		s = &bgmac_get_strings_stats[i];
>> +		val = 0;
>> +		if (s->size == 8)
>> +			val = (u64)bgmac_read(bgmac, s->offset + 4);
> 
> Isn't this missing a << 32?

It is, guess I should have made sure there was 4GB+ worth of traffic to
make sure this seemed reasonable.
> 
> Does reading the high 32 bits latch the value of the low 32 bits?  If
> not, you need to read the high bits again after the low bits and retry
> if they changed.

Yes these registers are latched.

> 
>> +		val |= bgmac_read(bgmac, s->offset);
>> +		data[i] = (u64)val;
> 
> Redundant cast.

Indeed, thanks.
-- 
Florian
