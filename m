From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Tue, 05 Jan 2016 11:04:40 +0100
Message-ID: <1451988280.7710.28.camel@redhat.com>
References: <cover.1450964358.git.sd@queasysnail.net>
	 <1910d94579a647d1c3b23a348778458d2f1f97a1.1450964358.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbcAEKEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2016 05:04:44 -0500
In-Reply-To: <1910d94579a647d1c3b23a348778458d2f1f97a1.1450964358.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-28 at 13:38 +0100, Sabrina Dubroca wrote:
> +#define MACSEC_SCI_LEN 8
> +
> +/* SecTAG length = macsec_eth_header without the optional SCI */
> +#define MACSEC_TAG_LEN 6
> +
> +struct macsec_eth_header {
> +	struct ethhdr eth;
> +	/* SecTAG */
> +	u8  tci_an;
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> +	u8  short_length:6,
> +		  unused:2;
> +#elif defined(__BIG_ENDIAN_BITFIELD)
> +	u8        unused:2,
> +	    short_length:6;
> +#else
> +#error	"Please fix <asm/byteorder.h>"
> +#endif
> +	__be32 packet_number;
> +	u8 secure_channel_id[8]; /* optional */
> +} __packed;

> +#define MACSEC_NEEDED_HEADROOM sizeof(struct macsec_eth_header)

The needed_headroom field does not need to include the hard_header_len,
which, for macsec devices, is set to ETH_HLEN by ether_setup().

Since on xmit path you can push up to MACSEC_TAG_LEN + MACSEC_SCI_LEN +
sizeof(__be16) bytes on the skb head, possibly that should be a better
MACSEC_NEEDED_HEADROOM value.

> +static void macsec_count_tx(struct sk_buff *skb, struct macsec_tx_sc *tx_sc,
> +			    struct macsec_tx_sa *tx_sa)
> +{
> +	struct pcpu_tx_sc_stats *txsc_stats = this_cpu_ptr(tx_sc->stats);
> +
> +	u64_stats_update_begin(&txsc_stats->syncp);
> +	if (tx_sc->encrypt) {
> +		txsc_stats->stats.OutOctetsEncrypted += skb->len;
> +		txsc_stats->stats.OutPktsEncrypted++;
> +		this_cpu_inc(tx_sa->stats->OutPktsEncrypted);

The last line is probably a duplicate

> +	} else {
> +		txsc_stats->stats.OutOctetsProtected += skb->len;
> +		txsc_stats->stats.OutPktsProtected++;
> +		this_cpu_inc(tx_sa->stats->OutPktsProtected);

Same as above.

> +		struct pcpu_secy_stats *secy_stats = this_cpu_ptr(macsec->stats);
> +
> +		if (macsec->secy.validate_frames == MACSEC_VALIDATE_STRICT) {
> +			u64_stats_update_begin(&secy_stats->syncp);
> +			secy_stats->stats.InPktsNoTag++;
> +			u64_stats_update_end(&secy_stats->syncp);
> +			continue;
> +		}

Can the 64_stats_update block be replaced by a single:
this_cpu_inc(macsec->stats->InPktsNoTag) ?

There are a few others similar blocks below.

Thanks,

Paolo
