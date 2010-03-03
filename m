From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-2.6 PATCH] af_packet: move strict addr_len check right
 before dev_[mc/unicast]_[add/del]
Date: Wed, 3 Mar 2010 10:05:13 +0100
Message-ID: <20100303090512.GB2961@psychotron.lab.eng.brq.redhat.com>
References: <1267578048.14049.11.camel@mj>
 <20100303064001.GB2648@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tcpdump-workers-YE1jQ5a0g24KACXWX4p+q9i2O/JbrIOy@public.gmane.org,
	proski-mXXj517/zsQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100303064001.GB2648-YzwxZg+R7et1/kRsl7OVgNvLeJWuRmrY@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wed, Mar 03, 2010 at 07:40:01AM CET, jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
>Subject: [net-2.6 PATCH] af_packet: move strict addr_len check right before dev_[mc/unicast]_[add/del]

Dave please apply this against net-next-2.6. I see that 914c8ad2d18b is still not in
net-2.6.

Thanks a lot

Jirka

>
>My previous patch 914c8ad2d18b62ad1420f518c0cab0b0b90ab308 incorrectly changed
>the length check in packet_mc_add to be more strict. The problem is that
>userspace is not filling this field (and it stays zeroed) in case of setting
>PACKET_MR_PROMISC or PACKET_MR_ALLMULTI. So move the strict check to the point
>in path where the addr_len must be set correctly.
>
>Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
>diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>index 031a5e6..1612d41 100644
>--- a/net/packet/af_packet.c
>+++ b/net/packet/af_packet.c
>@@ -1688,6 +1688,8 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
> {
> 	switch (i->type) {
> 	case PACKET_MR_MULTICAST:
>+		if (i->alen != dev->addr_len)
>+			return -EINVAL;
> 		if (what > 0)
> 			return dev_mc_add(dev, i->addr, i->alen, 0);
> 		else
>@@ -1700,6 +1702,8 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
> 		return dev_set_allmulti(dev, what);
> 		break;
> 	case PACKET_MR_UNICAST:
>+		if (i->alen != dev->addr_len)
>+			return -EINVAL;
> 		if (what > 0)
> 			return dev_unicast_add(dev, i->addr);
> 		else
>@@ -1734,7 +1738,7 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
> 		goto done;
> 
> 	err = -EINVAL;
>-	if (mreq->mr_alen != dev->addr_len)
>+	if (mreq->mr_alen > dev->addr_len)
> 		goto done;
> 
> 	err = -ENOBUFS;
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
