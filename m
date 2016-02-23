From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 3/5] ovs: propagate per dp max headroom to all vports
Date: Tue, 23 Feb 2016 11:20:56 -0800
Message-ID: <CAOrHB_DL0ALY64VWtKGQCY8efxFHEz1DsKzVGvbGk+8q=j1kzQ@mail.gmail.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	<4d34406afd196957f32adb69eae3489a05c34086.1456163137.git.pabeni@redhat.com>
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
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:37735 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbcBWTVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:21:02 -0500
Received: from mfilter43-d.gandi.net (mfilter43-d.gandi.net [217.70.178.174])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 33F2441C086
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:20:59 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter43-d.gandi.net (mfilter43-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 6_xAluJMPyfp for <netdev@vger.kernel.org>;
	Tue, 23 Feb 2016 20:20:57 +0100 (CET)
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id A150341C051
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 20:20:57 +0100 (CET)
Received: by mail-ig0-f169.google.com with SMTP id g6so119074176igt.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:20:57 -0800 (PST)
In-Reply-To: <4d34406afd196957f32adb69eae3489a05c34086.1456163137.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> This patch implements bookkeeping support to compute the maximum
> headroom for all the devices in each datapath. When said value
> changes, the underlying devs are notified via the
> ndo_set_rx_headroom method.
>
> This also increases the internal vports xmit performance.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/openvswitch/datapath.c           | 48 ++++++++++++++++++++++++++++++++++++
>  net/openvswitch/datapath.h           |  4 +++
>  net/openvswitch/vport-internal_dev.c | 10 +++++++-
>  3 files changed, 61 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index c4e8455..7b37288 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -1908,6 +1908,34 @@ static struct vport *lookup_vport(struct net *net,
>                 return ERR_PTR(-EINVAL);
>  }
>
> +/* Called with ovs_mutex */
> +static void update_headroom(struct datapath *dp)
> +{
> +       int i;
> +       struct vport *vport;
> +       struct net_device *dev;
> +       unsigned dev_headroom, max_headroom = 0;
> +
> +       for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
> +               hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node) {
> +                       dev = vport->dev;
> +                       dev_headroom = netdev_get_fwd_headroom(dev);
> +                       if (dev_headroom > max_headroom)
> +                               max_headroom = dev_headroom;
> +               }
> +       }
> +
> +       dp->max_headroom = max_headroom;
> +       for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
> +               hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node) {
> +                       dev = vport->dev;
> +                       if (dev->netdev_ops->ndo_set_rx_headroom)
> +                               dev->netdev_ops->ndo_set_rx_headroom(dev,
> +                                                                 max_headroom);
> +               }
> +       }
> +}
> +
Code looks fine. But It could be kept in sync with bridge code from patch 2.
