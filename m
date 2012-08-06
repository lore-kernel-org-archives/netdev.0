From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] net: Don't use ifindices in hash fns
Date: Mon, 06 Aug 2012 12:43:09 +0200
Message-ID: <1344249789.26674.8.camel@edumazet-glaptop>
References: <501F9CAF.3030605@parallels.com>
	 <501F9CDA.6040403@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63048 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab2HFKnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 06:43:14 -0400
Received: by bkwj10 with SMTP id j10so965471bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 03:43:13 -0700 (PDT)
In-Reply-To: <501F9CDA.6040403@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 14:30 +0400, Pavel Emelyanov wrote:
> Eric noticed, that when there will be devices with equal indices, some
> hash functions that use them will become less effective as they could.
> 
> Fix this in advance by taking the net_device address into calculations
> instead of the device index. Since the net_device is always aligned in
> memory, shift the pointer to eliminate always zero bits (like we do it
> in net_hash_mix).
> 
> This is true for arp and ndisc hash fns. The netlabel, can and llc ones
> are also ifindex-based, but that three are init_net-only, thus will not
> be affected.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> ---
>  include/linux/netdevice.h |    6 ++++++
>  include/net/arp.h         |    2 +-
>  include/net/ndisc.h       |    2 +-
>  3 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a9db4f3..6010b37 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1330,6 +1330,12 @@ struct net_device {
>  
>  #define	NETDEV_ALIGN		32
>  
> +static inline unsigned int netdev_hash_mix(const struct net_device *dev)
> +{
> +	return (unsigned int)(((unsigned long)dev) >>
> +			max(L1_CACHE_BYTES, NETDEV_ALIGN));
> +}
> +

I guess you didnt test this patch very well ...

This returns 0 as is

I would define a generic pointer hash mix instead of a 'net_device
thing'

static inline u32 ptr_hash_mix(void *ptr)
{
#if BITS_PER_LONG==32
	return (u32)(unsigned long)ptr;
#else
	return (u32)((unsigned long)ptr >> L1_CACHE_SHIFT);
#endif
}
