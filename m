From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 1/5] netdev: introduce ndo_set_rx_headroom
Date: Tue, 23 Feb 2016 11:20:31 -0800
Message-ID: <CAOrHB_DgzNed9bD6F1zytxq=0m+6oXECRokRvMuP0qa7Vu7NYw@mail.gmail.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	<ce1a9b0a33927547d0fbc659ac59dcf9fb7c3a33.1456163137.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:32856 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbcBWTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:20:35 -0500
Received: from mfilter10-d.gandi.net (mfilter10-d.gandi.net [217.70.178.139])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id 1B27DA80AA
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:20:34 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
	by mfilter10-d.gandi.net (mfilter10-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id A875bpJMvxJS for <netdev@vger.kernel.org>;
	Tue, 23 Feb 2016 20:20:32 +0100 (CET)
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	(Authenticated sender: pshelar@ovn.org)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 730A9A80C2
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:20:32 +0100 (CET)
Received: by mail-ig0-f169.google.com with SMTP id z8so15443003ige.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:20:32 -0800 (PST)
In-Reply-To: <ce1a9b0a33927547d0fbc659ac59dcf9fb7c3a33.1456163137.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> This method allows the controlling device (i.e. the bridge) to specify
> additional headroom to be allocated for skb head on frame reception.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  include/linux/netdevice.h | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 47671ce0..fb74277 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1093,6 +1093,12 @@ struct tc_to_netdev {
>   *     This function is used to get egress tunnel information for given skb.
>   *     This is useful for retrieving outer tunnel header parameters while
>   *     sampling packet.
...

>  /**
> @@ -1315,6 +1323,8 @@ struct net_device_ops {
>   * @IFF_L3MDEV_SLAVE: device is enslaved to an L3 master device
>   * @IFF_TEAM: device is a team device
>   * @IFF_RXFH_CONFIGURED: device has had Rx Flow indirection table configured
> + * @IFF_PHONY_HEADROOM: the headroom value is controlled by an external
> + *     entity (i.e. the master device for bridged veth)
>   */
>  enum netdev_priv_flags {
>         IFF_802_1Q_VLAN                 = 1<<0,
> @@ -1343,6 +1353,7 @@ enum netdev_priv_flags {
>         IFF_L3MDEV_SLAVE                = 1<<23,
>         IFF_TEAM                        = 1<<24,
>         IFF_RXFH_CONFIGURED             = 1<<25,
> +       IFF_PHONY_HEADROOM              = 1<<26,
>  };
>
>  #define IFF_802_1Q_VLAN                        IFF_802_1Q_VLAN
> @@ -1937,6 +1948,15 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
>                                     struct sk_buff *skb,
>                                     void *accel_priv);
>
> +/* returns the headroom that the master device needs to take in account
> + * when forwarding to this dev
> + */
> +static inline unsigned netdev_get_fwd_headroom(struct net_device *dev)
> +{
> +       return (dev->priv_flags && IFF_PHONY_HEADROOM) ? dev->needed_headroom :
> +               0;
> +}
> +
This looks like typo. It should '&' to check for the bitfield.
