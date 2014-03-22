From: Alon Nafta <alon@privatecore.com>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3 buffer
 overflows triggered by hardware devices
Date: Fri, 21 Mar 2014 18:51:43 -0700
Message-ID: <CAKPWWNHc8q-evx7TaTWX5SObd3iVm6YpFmepajRHgXmVgC713g@mail.gmail.com>
References: <CAKPWWNHxTaTRLrAV2_u--cq+jUkqWAoA56qJnassaxhgcVL+yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Grant Grundler <grantgrundler@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:41732 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaCVBvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 21:51:44 -0400
Received: by mail-la0-f50.google.com with SMTP id y1so2253529lam.9
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 18:51:43 -0700 (PDT)
In-Reply-To: <CAKPWWNHxTaTRLrAV2_u--cq+jUkqWAoA56qJnassaxhgcVL+yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Has anyone looked at this patch?

Thanks,
Alon

On Mon, Feb 24, 2014 at 10:11 AM, Alon Nafta <alon@privatecore.com> wrote:
> From: Alon Nafta <alon@privatecore.com>
>
> Linux Kernel 3.14 contains multiple overflow conditions that are triggered
> as hardware inputs are not properly validated when parsing Ethernet packets.
> This may allow a local attacker to cause an overflow, resulting in a denial
> of service or potentially allowing the execution of arbitrary code.
>
> The programmatic error resides in the use of an integer type to describe
> packet lengths, without proper validation to disallow negative values. In
> all three (3) bugs this patch fixes, a value of 0x30000 of the hardware
> signal, named status, will result in a value of 0xffffffff for pkt_len, and
> an allocation of a socket buffer with size of 0x1. This results in an
> overflow when data is copied into that buffer.
>
> Signed-off-by: Alon Nafta <alon@privatecore.com>
> Reviewed-by: Grant Grundler <grantgrundler@gmail.com>
> ---
> diff -uprN -X linux-3.14-rc3/Documentation/dontdiff
> linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/de4x5.c
> linux-3.14-rc3/drivers/net/ethernet/dec/tulip/de4x5.c
> --- linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/de4x5.c 2014-02-20
> 17:59:14.704084300 -0800
> +++ linux-3.14-rc3/drivers/net/ethernet/dec/tulip/de4x5.c 2014-02-20
> 18:23:08.987749400 -0800
> @@ -1635,8 +1635,8 @@ de4x5_rx(struct net_device *dev)
>   if (status & RD_OF)           lp->pktStats.rx_overflow++;
>       } else {                          /* A valid frame received */
>   struct sk_buff *skb;
> - short pkt_len = (short)(le32_to_cpu(lp->rx_ring[entry].status)
> -                             >> 16) - 4;
> + short pkt_len = (short)((le32_to_cpu(lp->rx_ring[entry].status)
> +                             >> 16) - 4) & 0x7fff;
>
>   if ((skb = de4x5_alloc_rx_buff(dev, entry, pkt_len)) == NULL) {
>       printk("%s: Insufficient memory; nuking packet.\n",
> diff -uprN -X linux-3.14-rc3/Documentation/dontdiff
> linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/winbond-840.c
> linux-3.14-rc3/drivers/net/ethernet/dec/tulip/winbond-840.c
> --- linux-3.14-rc3-orig/drivers/net/ethernet/dec/tulip/winbond-840.c
> 2014-02-20 17:59:14.757666100 -0800
> +++ linux-3.14-rc3/drivers/net/ethernet/dec/tulip/winbond-840.c 2014-02-20
> 18:22:19.419612200 -0800
> @@ -1218,7 +1218,7 @@ static int netdev_rx(struct net_device *
>   } else {
>   struct sk_buff *skb;
>   /* Omit the four octet CRC from the length. */
> - int pkt_len = ((status >> 16) & 0x7ff) - 4;
> + int pkt_len = ((status >> 16) - 4) & 0x7ff;
>
>  #ifndef final_version
>   if (debug > 4)
> diff -uprN -X linux-3.14-rc3/Documentation/dontdiff
> linux-3.14-rc3-orig/drivers/net/ethernet/smsc/epic100.c
> linux-3.14-rc3/drivers/net/ethernet/smsc/epic100.c
> --- linux-3.14-rc3-orig/drivers/net/ethernet/smsc/epic100.c 2014-02-20
> 17:59:17.844045500 -0800
> +++ linux-3.14-rc3/drivers/net/ethernet/smsc/epic100.c 2014-02-20
> 18:21:13.196237400 -0800
> @@ -1172,7 +1172,7 @@ static int epic_rx(struct net_device *de
>   } else {
>   /* Malloc up new buffer, compatible with net-2e. */
>   /* Omit the four octet CRC from the length. */
> - short pkt_len = (status >> 16) - 4;
> + short pkt_len = ((status >> 16) - 4) & 0x7fff;
>   struct sk_buff *skb;
>
>   if (pkt_len > PKT_BUF_SZ - 4) {
