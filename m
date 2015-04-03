From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE tunnels
Date: Fri, 3 Apr 2015 14:05:20 -0700
Message-ID: <CAEP_g=9PbDO4qK-GaGosBAq1S5C5uWNR4-JN8=i158oYJUN4Bw@mail.gmail.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com> <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:54483 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751262AbbDCVFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 17:05:41 -0400
Received: by mail-lb0-f169.google.com with SMTP id c7so85036097lbo.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 14:05:40 -0700 (PDT)
In-Reply-To: <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 2, 2015 at 12:17 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> This is an initial implementation of a netdev driver for GENEVE
> tunnels.  This implementation uses a fixed UDP port, and only supports
> a single tunnel (and therefore only a single VNI) per net namespace.
> Only IPv4 links are supported at this time.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Thanks from me as well for working on this!

There is the common IP tunnel device code that GRE, IPIP, etc. use -
pretty much every tunnel except for VXLAN. Does it make sense to use
that? VXLAN doesn't because it has a fair amount of specialized logic
and perhaps Geneve will end up going down that path as well, so
perhaps it doesn't make sense but I wanted to make sure that you were
aware of it.

I also wanted to mention that Geneve (the protocol, not the current
implementation) can encapsulate protocols other than Ethernet, similar
to GRE. I don't think this is necessary for a first implementation but
it's worth keeping in mind in case there is anything that we end up
designing in the interfaces that can keep this clean in the future.

> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> new file mode 100644
> index 000000000000..fe8895487fc2
> --- /dev/null
> +++ b/drivers/net/geneve.c
> +/* geneve receive/decap routine */
> +static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
> +{
> +       struct genevehdr *gnvh = geneve_hdr(skb);
> +       struct geneve_dev *geneve;
> +       struct pcpu_sw_netstats *stats;
> +
> +       geneve = gs->rcv_data;
> +
> +       /* Does the VNI match the device? */
> +       if (memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)))
> +               goto drop;

Since Geneve packets can carry options and this doesn't currently
support any, I think we need to at least check the 'C' bit in the
header and drop packets if it is set to ensure that we don't
accidentally ignore critical options.

> +       /* force IP checksum recalculation */
> +       skb->ip_summed = CHECKSUM_NONE;

I don't think that this should be necessary. There has been a fair
amount of work to ensure that checksums carry over across
encapsulations where possible so we shouldn't have to blow away the
state. We just need to do a skb_postpull_rcsum() after the call to
eth_type_trans().

We probably should do ECN decapsulate in here somewhere as well.

> +/* Initialize the device structure. */
> +static void geneve_setup(struct net_device *dev)
> +{
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +
> +       ether_setup(dev);
> +
> +       dev->netdev_ops = &geneve_netdev_ops;
> +       dev->destructor = free_netdev;
> +       SET_NETDEV_DEVTYPE(dev, &geneve_type);
> +
> +       INIT_WORK(&geneve->sock_work, geneve_sock_work);
> +
> +       dev->tx_queue_len = 0;
> +       dev->features = 0;
> +
> +       dev->vlan_features = dev->features;
> +       dev->hw_features = 0;

It should be possible to enable most features without a problem.
