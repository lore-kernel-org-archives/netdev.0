From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCHv3] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 31 Mar 2017 10:48:02 +0200
Message-ID: <8737dt25od.fsf@miraculix.mork.no>
References: <1490941561-20502-1-git-send-email-gerg@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: oneukum@suse.com, eric.dumazet@gmail.com,
        stephen@networkplumber.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Greg Ungerer <gerg@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43529 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751947AbdCaIsW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 04:48:22 -0400
In-Reply-To: <1490941561-20502-1-git-send-email-gerg@linux-m68k.org> (Greg
        Ungerer's message of "Fri, 31 Mar 2017 16:26:01 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg Ungerer <gerg@linux-m68k.org> writes:

> Add support for the net stats64 counters to the usbnet core and then to
> the qmi_wwan driver.
>
> This is a strait forward addition of 64bit counters for RX and TX packets
> and byte counts. It is done in the same style as for the other net drivers
> that support stats64.
>
> The bulk of the change is to the usbnet core. Then it is trivial to use
> that in the qmi_wwan.c driver. It would be very simple to extend this
> support to other usbnet based drivers.

Sorry, but I am starting to have my doubts about this partial conversion
of the usbnet stats.  I don't have any problem with doing incremental
changes.  But in this case it means running duplicate code. And I see no
reasons to justify doing this incrementally.  As you say: It is very
simple to extend it to all usbnet drivers when the basic infrastructure
is in place.

You alreay do most of that work. So why not just update the other
drivers too, allowing us to drop the legacy counters?  Deleting code is
always good :)


> +void usbnet_get_stats64(struct net_device *net, struct rtnl_link_stats64=
 *stats)
> +{
> +	struct usbnet *dev =3D netdev_priv(net);
> +	unsigned int start;
> +	int cpu;
> +
> +	netdev_stats_to_stats64(stats, &net->stats);
> +
> +	for_each_possible_cpu(cpu) {
> +		struct pcpu_sw_netstats *stats64;
> +		u64 rx_packets, rx_bytes;
> +		u64 tx_packets, tx_bytes;
> +
> +		stats64 =3D per_cpu_ptr(dev->stats64, cpu);
> +
> +		do {
> +			start =3D u64_stats_fetch_begin_irq(&stats64->syncp);
> +			rx_packets =3D stats64->rx_packets;
> +			rx_bytes =3D stats64->rx_bytes;
> +			tx_packets =3D stats64->tx_packets;
> +			tx_bytes =3D stats64->tx_bytes;
> +		} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
> +
> +		stats->rx_packets +=3D rx_packets;
> +		stats->rx_bytes +=3D rx_bytes;
> +		stats->tx_packets +=3D tx_packets;
> +		stats->tx_bytes +=3D tx_bytes;
> +	}
> +}

So we only count packets and bytes.  No errors.  Why?

> @@ -1212,8 +1249,15 @@ static void tx_complete (struct urb *urb)
>  	struct usbnet		*dev =3D entry->dev;
>=20=20
>  	if (urb->status =3D=3D 0) {
> +		struct pcpu_sw_netstats *stats64 =3D this_cpu_ptr(dev->stats64);
> +
>  		dev->net->stats.tx_packets +=3D entry->packets;
>  		dev->net->stats.tx_bytes +=3D entry->length;
> +
> +		u64_stats_update_begin(&stats64->syncp);
> +		stats64->tx_packets +=3D entry->packets;
> +		stats64->tx_bytes +=3D entry->length;
> +		u64_stats_update_end(&stats64->syncp);
>  	} else {
>  		dev->net->stats.tx_errors++;
>=20=20


This is one place where the old stats counted errors too.  But there are mo=
re:

bjorn@miraculix:/usr/local/src/git/linux$ git grep -E -- '->stats.*\+' driv=
ers/net/usb/usbnet.c|grep -Ev '(bytes|packet)'
drivers/net/usb/usbnet.c:                       dev->net->stats.rx_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.rx_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.rx_length_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.rx_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.rx_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.rx_over_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.rx_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.tx_errors++;
drivers/net/usb/usbnet.c:               dev->net->stats.tx_dropped++;


Personally, I'd rather have incorrect byte counters than losing these
error counters. They are valuable debugging aids. I don't see why they
cannot be converted to 64bit stats right away.  Except that it makes the
amount of double accounting much more obvious...

Which is why I have landed on on a request to convert all the usbnet
drivers in one go.  There aren't that many of them, and even fewer
touching the stats outside of usbnet.c.  Among those few, none have more
than 6 lines currently touching "stats":

bjorn@miraculix:/usr/local/src/git/linux$ for f in `git grep -l -- 'usbnet_=
probe' drivers/net/usb/`; do grep -Hc -- '->stats' $f; done
drivers/net/usb/asix_devices.c:0
drivers/net/usb/ax88179_178a.c:0
drivers/net/usb/cdc_eem.c:1
drivers/net/usb/cdc_ether.c:0
drivers/net/usb/cdc_mbim.c:0
drivers/net/usb/cdc_ncm.c:4
drivers/net/usb/cdc_subset.c:0
drivers/net/usb/ch9200.c:0
drivers/net/usb/cx82310_eth.c:0
drivers/net/usb/dm9601.c:5
drivers/net/usb/gl620a.c:0
drivers/net/usb/huawei_cdc_ncm.c:0
drivers/net/usb/int51x1.c:0
drivers/net/usb/kalmia.c:0
drivers/net/usb/lg-vl600.c:4
drivers/net/usb/mcs7830.c:4
drivers/net/usb/net1080.c:6
drivers/net/usb/plusb.c:0
drivers/net/usb/qmi_wwan.c:0
drivers/net/usb/rndis_host.c:1
drivers/net/usb/sierra_net.c:6
drivers/net/usb/smsc75xx.c:4
drivers/net/usb/smsc95xx.c:5
drivers/net/usb/sr9700.c:0
drivers/net/usb/sr9800.c:0
drivers/net/usb/usbnet.c:15
drivers/net/usb/zaurus.c:0

You get *all* the "0" line drivers for free, not only "qmi_wwan".  No
code changes needed, except for adding the single .ndo line to drivers
overriding the usbnet default net_device_ops. And even that only applies
to a few of them.  Most will be OK if you just change the usbnet
default.

I don't think the size of a complete series will be terrifying to
anyone.



Bj=C3=B8rn
