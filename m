From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH 1/4] Ethernet drivers in 3.14-rc3 kernel: fix 3 buffer
 overflows triggered by hardware devices
Date: Fri, 21 Feb 2014 19:12:08 -0800
Message-ID: <CAP6odji314zs8cOmYdvYgFcoJy5ggqPXfNJMrDH8R1m6a3Y_cA@mail.gmail.com>
References: <CAKPWWNHiA3D1e4hL-eCMjU6sAEjHainRTs01rzGQYi1GVObSkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Alon Nafta <alon@privatecore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:49720 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbaBVDMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 22:12:08 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so5178189oag.26
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 19:12:08 -0800 (PST)
In-Reply-To: <CAKPWWNHiA3D1e4hL-eCMjU6sAEjHainRTs01rzGQYi1GVObSkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 4:02 PM, Alon Nafta <alon@privatecore.com> wrote:
> From: Alon Nafta <alon@privatecore.com>
>
> Linux Kernel contains multiple overflow conditions that are triggered as
> hardware-supplied inputs are not properly validated when parsing Ethernet
> packets. This may allow a local attacker to cause an overflow, resulting in
> a denial of service or potentially allowing the execution of arbitrary code.
>
> The programmatic error resides in the use of an integer type to describe
> packet length, without proper validation for negative values. In all three
> (3) bugs this patch fixes, a value of 0x30000 for the hardware signal, named
> status, will result in the value of 0xffffffff for pkt_len, and an
> allocation of a socket buffer with size of 0x1. This result in an overflow
> when data is copied into that buffer.
>
> Signed-off-by: Alon Nafta <alon@privatecore.com>

LGTM.  Thanks! :)

Reviewed-by: Grant Grundler <grundler@parisc-linux.org>

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
