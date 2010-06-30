From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH] s2io: read rx_packets count from the hardware stats
Date: Tue, 29 Jun 2010 19:54:54 -0500
Message-ID: <20100630005454.GJ21324@exar.com>
References: <20100624233230.5864.67401.stgit@leela.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:43027 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751680Ab0F3A7x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 20:59:53 -0400
Content-Disposition: inline
In-Reply-To: <20100624233230.5864.67401.stgit@leela.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 24, 2010 at 04:32:32PM -0700, Michal Schmidt wrote:
> Most of the statistics the s2io driver provides in /proc/net/dev
> it reads directly from the hardware counters. For some reason it does
> not do that for rx_packets. It counts rx_packets purely in software.
>
> A customer reported a bug where in /proc/net/dev the 'multicast' counter
> was increasing faster than 'packets' ( = rx_packets in the source code).
> This confuses userspace, especially snmpd.
>
> The hardware provides a counter for the total number of received
> frames (RMAC_VLD_FRMS) which the driver can use for the rx_packets
> statistic. By reading both statistics from the hardware it makes sure
> that all multicast frames are included in the total.

On the Xframe adapter, there is a issue with the multicast statistics
counter.  It includes broadcast and pause frames in its count.  This
is most likely the cause of the issue you are seeing.

While, looking over the patch you submitted, I noticed other issues
with the s2io_get_stats function.  I have a patch that I will push
soon that addresses the multicast issue, the issues I discovered, and
the octet issues Dave suggested.

Thanks,
Jon

>
> The customer tested a patch like this (only modified for RHEL5) with
> S2io Inc. Xframe II 10Gbps Ethernet (rev 02)
> and it fixed the problem.
>
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>
>  drivers/net/s2io.c |   11 ++++++-----
>  drivers/net/s2io.h |    1 -
>  2 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 668327c..eefc4b2 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -4919,6 +4919,10 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
>               sp->stats.tx_packets;
>       sp->stats.tx_packets = le32_to_cpu(stats->tmac_frms);
>
> +     dev->stats.rx_packets += le32_to_cpu(stats->rmac_vld_frms) -
> +             sp->stats.rx_packets;
> +     sp->stats.rx_packets = le32_to_cpu(stats->rmac_vld_frms);
> +
>       dev->stats.tx_errors += le32_to_cpu(stats->tmac_any_err_frms) -
>               sp->stats.tx_errors;
>       sp->stats.tx_errors = le32_to_cpu(stats->tmac_any_err_frms);
> @@ -4935,12 +4939,11 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
>               sp->stats.rx_length_errors;
>       sp->stats.rx_length_errors = le64_to_cpu(stats->rmac_long_frms);
>
> -     /* collect per-ring rx_packets and rx_bytes */
> -     dev->stats.rx_packets = dev->stats.rx_bytes = 0;
> +     /* collect per-ring rx_bytes */
> +     dev->stats.rx_bytes = 0;
>       for (i = 0; i < config->rx_ring_num; i++) {
>               struct ring_info *ring = &mac_control->rings[i];
>
> -             dev->stats.rx_packets += ring->rx_packets;
>               dev->stats.rx_bytes += ring->rx_bytes;
>       }
>
> @@ -7455,8 +7458,6 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
>               }
>       }
>
> -     /* Updating statistics */
> -     ring_data->rx_packets++;
>       rxdp->Host_Control = 0;
>       if (sp->rxd_mode == RXD_MODE_1) {
>               int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
> diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
> index 47c36e0..4da9ab8 100644
> --- a/drivers/net/s2io.h
> +++ b/drivers/net/s2io.h
> @@ -747,7 +747,6 @@ struct ring_info {
>       struct buffAdd **ba;
>
>       /* per-Ring statistics */
> -     unsigned long rx_packets;
>       unsigned long rx_bytes;
>  } ____cacheline_aligned;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
