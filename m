From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [RFC PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Fri, 8 Jan 2016 19:06:48 +0100
Message-ID: <20160108180648.GA30814@bistromath.redhat.com>
References: <cover.1450964358.git.sd@queasysnail.net>
 <1910d94579a647d1c3b23a348778458d2f1f97a1.1450964358.git.sd@queasysnail.net>
 <1451988280.7710.28.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972AbcAHSGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 13:06:51 -0500
Content-Disposition: inline
In-Reply-To: <1451988280.7710.28.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paolo,

2016-01-05, 11:04:40 +0100, Paolo Abeni wrote:
> On Mon, 2015-12-28 at 13:38 +0100, Sabrina Dubroca wrote:
> > +#define MACSEC_SCI_LEN 8
> > +
> > +/* SecTAG length = macsec_eth_header without the optional SCI */
> > +#define MACSEC_TAG_LEN 6
> > +
> > +struct macsec_eth_header {
> > +	struct ethhdr eth;
> > +	/* SecTAG */
> > +	u8  tci_an;
> > +#if defined(__LITTLE_ENDIAN_BITFIELD)
> > +	u8  short_length:6,
> > +		  unused:2;
> > +#elif defined(__BIG_ENDIAN_BITFIELD)
> > +	u8        unused:2,
> > +	    short_length:6;
> > +#else
> > +#error	"Please fix <asm/byteorder.h>"
> > +#endif
> > +	__be32 packet_number;
> > +	u8 secure_channel_id[8]; /* optional */
> > +} __packed;
> 
> > +#define MACSEC_NEEDED_HEADROOM sizeof(struct macsec_eth_header)
> 
> The needed_headroom field does not need to include the hard_header_len,
> which, for macsec devices, is set to ETH_HLEN by ether_setup().
> 
> Since on xmit path you can push up to MACSEC_TAG_LEN + MACSEC_SCI_LEN +
> sizeof(__be16) bytes on the skb head, possibly that should be a better
> MACSEC_NEEDED_HEADROOM value.

It seems you're right, I will change that.


> > +static void macsec_count_tx(struct sk_buff *skb, struct macsec_tx_sc *tx_sc,
> > +			    struct macsec_tx_sa *tx_sa)
> > +{
> > +	struct pcpu_tx_sc_stats *txsc_stats = this_cpu_ptr(tx_sc->stats);
> > +
> > +	u64_stats_update_begin(&txsc_stats->syncp);
> > +	if (tx_sc->encrypt) {
> > +		txsc_stats->stats.OutOctetsEncrypted += skb->len;
> > +		txsc_stats->stats.OutPktsEncrypted++;
> > +		this_cpu_inc(tx_sa->stats->OutPktsEncrypted);
> 
> The last line is probably a duplicate

Actually no, we keep separate stats for the secure channel (SC) and
each individual secure association (SA) within the channel.


> > +		struct pcpu_secy_stats *secy_stats = this_cpu_ptr(macsec->stats);
> > +
> > +		if (macsec->secy.validate_frames == MACSEC_VALIDATE_STRICT) {
> > +			u64_stats_update_begin(&secy_stats->syncp);
> > +			secy_stats->stats.InPktsNoTag++;
> > +			u64_stats_update_end(&secy_stats->syncp);
> > +			continue;
> > +		}
> 
> Can the 64_stats_update block be replaced by a single:
> this_cpu_inc(macsec->stats->InPktsNoTag) ?
> 
> There are a few others similar blocks below.

I don't think so.  this_cpu_inc doesn't include the protection that
u64_stats_update_begin provides.


Thanks.

-- 
Sabrina
