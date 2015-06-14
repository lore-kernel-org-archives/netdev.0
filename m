From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 1/4] net: don't reforward packets already
 forwarded by offload device
Date: Sun, 14 Jun 2015 08:51:53 +0200
Message-ID: <20150614065153.GA2105@nanopsycho.orion>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
 <1434218670-43821-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36407 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbFNGv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 02:51:56 -0400
Received: by wigg3 with SMTP id g3so48367296wig.1
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 23:51:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434218670-43821-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jun 13, 2015 at 08:04:27PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Just before queuing skb for xmit on port, check if skb has been marked by
>switchdev port driver as already fordwarded by device.  If so, drop skb.  A
>non-zero skb->fwd_mark field is set by the switchdev port driver/device on
>ingress to indicate the skb has already been forwarded by the device to
>egress ports with matching dev->skb_mark.  The switchdev port driver would
>assign a non-zero dev->skb_mark for each device port netdev during
>registration, for example.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> include/linux/netdevice.h |    6 ++++++
> include/linux/skbuff.h    |    4 ++++
> net/core/dev.c            |    9 +++++++++
> 3 files changed, 19 insertions(+)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 6f5f71f..181b08f 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1444,6 +1444,8 @@ enum netdev_priv_flags {
>  *
>  *	@xps_maps:	XXX: need comments on this one
>  *
>+ *	@fwd_mark:		Offload device fwding mark
>+ *

How about to say this is an offloading/switchdev stuff?
"offload_fwd_mark" ?


<snip>

>diff --git a/net/core/dev.c b/net/core/dev.c
>index 6778a99..558bf33 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3065,6 +3065,15 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
> 	else
> 		skb_dst_force(skb);
> 
>+#ifdef CONFIG_NET_SWITCHDEV
>+	/* Don't forward if offload device already forwarded */
>+	if (skb->fwd_mark && skb->fwd_mark == dev->fwd_mark) {
>+		kfree_skb(skb);

You should use consume_skb here to do not indicate skb was dropped after
failure.
