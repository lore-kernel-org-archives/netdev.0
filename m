From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: systemport: Fix 64-bit stats deadlock
Date: Tue, 12 Sep 2017 14:48:25 -0700
Message-ID: <23e3924f-7efc-efe5-4866-f552b1b0c97e@gmail.com>
References: <1505247266-42195-1-git-send-email-f.fainelli@gmail.com>
 <1505252293.15310.151.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
        jqiaoulk@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36350 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751477AbdILVsb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 17:48:31 -0400
Received: by mail-qk0-f196.google.com with SMTP id i14so7951641qke.3
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 14:48:30 -0700 (PDT)
In-Reply-To: <1505252293.15310.151.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2017 02:38 PM, Eric Dumazet wrote:
> On Tue, 2017-09-12 at 13:14 -0700, Florian Fainelli wrote:
>> We can enter a deadlock situation because there is no sufficient protection
>> when ndo_get_stats64() runs in process context to guard against RX or TX NAPI
>> contexts running in softirq, this can lead to the following lockdep splat and
>> actual deadlock was experienced as well with an iperf session in the background
>> and a while loop doing ifconfig + ethtool.
> 
>> So just remove the u64_stats_update_begin()/end() pair in ndo_get_stats64()
>> since it does not appear to be useful for anything. No inconsistency was
>> observed with either ifconfig or ethtool, global TX counts equal the sum of
>> per-queue TX counts on a 32-bit architecture.
>>
>> Fixes: 10377ba7673d ("net: systemport: Support 64bit statistics")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/bcmsysport.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
>> index a6572b51435a..c3c53f6cd9e6 100644
>> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
>> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
>> @@ -1735,11 +1735,8 @@ static void bcm_sysport_get_stats64(struct net_device *dev,
>>  		stats->tx_packets += tx_packets;
>>  	}
>>  
>> -	/* lockless update tx_bytes and tx_packets */
>> -	u64_stats_update_begin(&priv->syncp);
> 
> Yes, this u64_stats_update_begin()/u64_stats_update_end() is bogus
> 
> But why do we even write on tx_bytes/tx_packets here ??? 

That's for the ethtool -S netdev stats copy (that's on me, I added that
in the driver initial version), so yes, not very robust...

> 
> Seems very wrong anyway.
> 
> (ethtool -S does not call bcm_sysport_get_stats64() to refresh them )

Yes that might actually be the simplest way to get this fixed.

> 
>>  	stats64->tx_bytes = stats->tx_bytes;
>>  	stats64->tx_packets = stats->tx_packets;
>> -	u64_stats_update_end(&priv->syncp);
>>  
>>  	do {
>>  		start = u64_stats_fetch_begin_irq(&priv->syncp);
> 
> 


-- 
Florian
