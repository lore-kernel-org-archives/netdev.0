From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Mon, 08 Jul 2013 13:17:45 -0700
Message-ID: <51DB1E69.2080208@candelatech.com>
References: <51BF50B3.1080403@candelatech.com>       <1371493059.3252.200.camel@edumazet-glaptop>       <51D1C620.8030007@candelatech.com>      <1372813467.4979.46.camel@edumazet-glaptop>      <51D398C0.5060802@candelatech.com>     <1372826512.4979.49.camel@edumazet-glaptop>     <51D3AD66.8030506@candelatech.com>    <1372827749.4979.52.camel@edumazet-glaptop>    <51DAF5A7.60505@candelatech.com>   <1373307702.4979.116.camel@edumazet-glaptop>   <51DB054D.6060507@candelatech.com>  <1373310119.4979.119.camel@edumazet-glaptop>  <51DB1A0C.3080807@candelatech.com> <1373314235.4979.121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46950 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613Ab3GHURq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 16:17:46 -0400
In-Reply-To: <1373314235.4979.121.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2013 01:10 PM, Eric Dumazet wrote:
> On Mon, 2013-07-08 at 12:59 -0700, Ben Greear wrote:
>
>>> There is this thing in ath9k about aggregating two frags
>>>
>>> drivers/net/wireless/ath/ath9k/recv.c line 1298 contains :
>>>
>>> RX_STAT_INC(rx_frags);
>>>
>>> Could you check these stats (I do not know if they are reported by
>>> ethtool -S or another debugging facility) and check if rx_frags is ever
>>> increasing ?
>>
>> They are in debugfs, and they appear to increase fairly often, for
>> instance:
>>
>> [root@lec2010-ath9k-1 lanforge]# cat /debug/ieee80211/wiphy0/ath9k/recv|tail -5
>>              RX-Pkts-All :  288009442
>>             RX-Bytes-All : 4067932166
>>               RX-Beacons :   14826735
>>                 RX-Frags :       3944
>>              RX-Spectral :          0
>>
>> I don't have the stats from the system that reproduced the bug
>> (it has been rebooted), but if I do see the bug again, I'll
>> grab the rx-frags and other stats just in case it shows
>> some anomaly.
>>
>
> Reading this code again, I believe following patch is needed.
>
> Could you test it ?

Sure, will do.  Adding the linux-wireless mailing list as well.

Thanks,
Ben

>
> Thanks
>
> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
> index 8be2b5d..f642f04 100644
> --- a/drivers/net/wireless/ath/ath9k/recv.c
> +++ b/drivers/net/wireless/ath/ath9k/recv.c
> @@ -1317,7 +1317,8 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
>   		if (sc->rx.frag) {
>   			int space = skb->len - skb_tailroom(hdr_skb);
>
> -			if (pskb_expand_head(hdr_skb, 0, space, GFP_ATOMIC) < 0) {
> +			if (space > 0 &&
> +			    pskb_expand_head(hdr_skb, 0, space, GFP_ATOMIC) < 0) {
>   				dev_kfree_skb(skb);
>   				RX_STAT_INC(rx_oom_err);
>   				goto requeue_drop_frag;
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
