From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [RFC PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Tue, 29 Dec 2015 14:56:18 +0100
Message-ID: <20151229135618.GA28245@bistromath.redhat.com>
References: <cover.1450964358.git.sd@queasysnail.net>
 <1910d94579a647d1c3b23a348778458d2f1f97a1.1450964358.git.sd@queasysnail.net>
 <20151229011406.GA21112@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752500AbbL2N4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 08:56:21 -0500
Content-Disposition: inline
In-Reply-To: <20151229011406.GA21112@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-12-29, 02:14:06 +0100, Florian Westphal wrote:
> Sabrina Dubroca <sd@queasysnail.net> wrote:
> > +		if (h->short_length)
> > +			return len == h->short_length + 24;
> > +		else
> > +			return len >= 72;
> [..]
> > +			return len == h->short_length + 32;
> [..]
> > +			return len >= 80;
> [..]
> > +			return len == 8 + icv_len + h->short_length;
> > +		else
> > +			return len >= 8 + icv_len + 48;
> [..]
> > +		if (h->short_length)
> > +			return len == 16 + icv_len + h->short_length;
> > +		else
> > +			return len >= 16 + icv_len + 48;
> 
> Could you add some defines instead of magic numbers?

Sure.


> > +	tx_sa->next_pn++;
> > +	if (tx_sa->next_pn == 0) {
> > +		pr_notice("PN wrapped, transitionning to !oper\n");
> 
> Is that _notice intentional?
> I'm only asking because it seems we printk unconditionally in response
> to network traffic & I don't get what operator should do in response to
> that message.

The operator should install a new tx_sa, or MKA should have already
installed a new one and switched to it.
I can remove this message, or make it a pr_debug.


> > +static void macsec_encrypt_done(struct crypto_async_request *base, int err)
> > +{
> > +	struct sk_buff *skb = base->data;
> > +	struct net_device *dev = skb->dev;
> > +	struct macsec_dev *macsec = macsec_priv(dev);
> > +	struct macsec_tx_sa *sa = macsec_skb_cb(skb)->tx_sa;
> > +	int len, ret;
> > +
> > +	aead_request_free(macsec_skb_cb(skb)->req);
> > +
> > +	rcu_read_lock_bh();
> > +	macsec_encrypt_finish(skb, dev);
> > +	macsec_count_tx(skb, &macsec->secy.tx_sc, macsec_skb_cb(skb)->tx_sa);
> > +	len = skb->len;
> > +	ret = dev_queue_xmit(skb);
> > +	count_tx(dev, ret, len);
> > +	rcu_read_unlock_bh();
> 
> What was the rcu_read_lock_bh protecting?

this_cpu_ptr in macsec_count_tx and count_tx.  Separate get_cpu_ptr in
both functions seem a bit wasteful, and dev_queue_xmit will also
disable bh.

I could turn that into a preempt_disable with a comment (something
like "covers multiple accesses to pcpu variables").  Or I could get
rid of it, and use get/put_cpu_ptr in macsec_count_tx/count_tx.
Note that macsec_count_tx/count_tx (and count_rx below) are also
called from the normal packet processing path, where we already run
under rcu_read_lock_bh anyway, so avoiding the overhead of an extra
get_cpu_ptr seems preferable.


> > +static void macsec_decrypt_done(struct crypto_async_request *base, int err)
> > +{
> > +	struct sk_buff *skb = base->data;
> > +	struct net_device *dev = skb->dev;
> > +	struct macsec_dev *macsec = macsec_priv(dev);
> > +	struct macsec_rx_sa *rx_sa = macsec_skb_cb(skb)->rx_sa;
> > +	int len, ret;
> > +
> > +	aead_request_free(macsec_skb_cb(skb)->req);
> > +
> > +	rcu_read_lock_bh();
> > +	macsec_finalize_skb(skb, macsec->secy.icv_len,
> > +			    macsec_extra_len(macsec_skb_cb(skb)->has_sci));
> > +	macsec_reset_skb(skb, macsec->secy.netdev);
> > +
> > +	macsec_rxsa_put(rx_sa);
> > +	len = skb->len;
> > +	ret = netif_rx(skb);
> > +	if (ret == NET_RX_SUCCESS)
> > +		count_rx(dev, len);
> > +	else
> > +		macsec->secy.netdev->stats.rx_dropped++;
> > +
> > +	rcu_read_unlock_bh();
> 
> Same question.

Yes, that's pretty much the same situation.


> > +static void handle_not_macsec(struct sk_buff *skb)
> > +{
> > +	struct macsec_rxh_data *rxd = macsec_data_rcu(skb->dev);
> > +	struct macsec_dev *macsec;
> > +
> > +	/* 10.6 If the management control validateFrames is not
> > +	 * Strict, frames without a SecTAG are received, counted, and
> > +	 * delivered to the Controlled Port
> > +	 */
> > +	list_for_each_entry_rcu(macsec, &rxd->secys, secys) {
> > +		struct sk_buff *nskb;
> > +		int ret;
> > +		struct pcpu_secy_stats *secy_stats = this_cpu_ptr(macsec->stats);
> > +
> > +		if (macsec->secy.validate_frames == MACSEC_VALIDATE_STRICT) {
> > +			u64_stats_update_begin(&secy_stats->syncp);
> > +			secy_stats->stats.InPktsNoTag++;
> > +			u64_stats_update_end(&secy_stats->syncp);
> > +			continue;
> > +		}
> > +
> > +		/* deliver on this port */
> > +		nskb = skb_clone(skb, GFP_ATOMIC);
> > +		nskb->dev = macsec->secy.netdev;
> 
> nskb == NULL handling?

Right, I'll take care of both of these, thanks.


> > +static rx_handler_result_t macsec_handle_frame(struct sk_buff **pskb)
> > +{
> > +	struct sk_buff *skb = *pskb;
> > +	struct net_device *dev = skb->dev;
> > +	struct macsec_eth_header *hdr;
> > +	struct macsec_secy *secy = NULL;
> > +	struct macsec_rx_sc *rx_sc;
> > +	struct macsec_rx_sa *rx_sa;
> > +	struct macsec_rxh_data *rxd;
> > +	struct macsec_dev *macsec;
> > +	sci_t sci;
> > +	u32 pn, lowest_pn;
> > +	bool cbit;
> > +	struct pcpu_rx_sc_stats *rxsc_stats;
> > +	struct pcpu_secy_stats *secy_stats;
> > +	bool pulled_sci;
> > +
> > +	rcu_read_lock_bh();
> 
> Why?  Seems its because of
> 
> > +	if (skb_headroom(skb) < ETH_HLEN)
> > +		goto drop_nosa;
> > +
> > +	rxd = macsec_data_rcu(skb->dev);
> 
> this, but rxd isn't dereferenced until a lot later in the function.

I'll move it down.


> Also: macsec_data_rcu uses rcu_dereference() but this used
> rcu_read_lock_bh, is that structure protected by RCU or RCU-bh?

I'll turn that into a rcu_dereference_bh for the next submission.


> > +	pn = ntohl(hdr->packet_number);
> > +	if (secy->replay_protect) {
> > +		bool late;
> > +
> > +		spin_lock(&rx_sa->lock);
> > +		late = rx_sa->next_pn >= secy->replay_window &&
> > +		       pn < (rx_sa->next_pn - secy->replay_window);
> > +		spin_unlock(&rx_sa->lock);
> > +
> > +		if (late) {
> > +			u64_stats_update_begin(&rxsc_stats->syncp);
> > +			rxsc_stats->stats.InPktsLate++;
> > +			u64_stats_update_end(&rxsc_stats->syncp);
> > +			goto drop;
> > +		}
> > +	}
> 
> [..]
> 
> > +	spin_lock(&rx_sa->lock);
> > +	if (rx_sa->next_pn >= secy->replay_window)
> > +		lowest_pn = rx_sa->next_pn - secy->replay_window;
> > +	else
> > +		lowest_pn = 0;
> > +
> > +	if (secy->replay_protect && pn < lowest_pn) {
> > +		spin_unlock(&rx_sa->lock);
> > +		pr_debug("packet_number too small: %u < %u\n", pn, lowest_pn);
> > +		u64_stats_update_begin(&rxsc_stats->syncp);
> > +		rxsc_stats->stats.InPktsLate++;
> > +		u64_stats_update_end(&rxsc_stats->syncp);
> > +		goto drop;
> > +	}
> 
> I don't understand why this seems to perform replay check twice?

This is part of the specification (802.1AE-2006 figure 10-5).
The first check is done before attempting to decrypt the packet, then
once again after decrypting.
This part (and the other checks until deliver:) are missing in the
macsec_decrypt_done callback, I need to add this.


> > +	if (secy->validate_frames != MACSEC_VALIDATE_DISABLED) {
> > +		u64_stats_update_begin(&rxsc_stats->syncp);
> > +		if (hdr->tci_an & MACSEC_TCI_E)
> > +			rxsc_stats->stats.InOctetsDecrypted += skb->len;
> > +		else
> > +			rxsc_stats->stats.InOctetsValidated += skb->len;
> > +		u64_stats_update_end(&rxsc_stats->syncp);
> > +	}
> 
> > +	if (!macsec_skb_cb(skb)->valid) {
> > +		spin_unlock(&rx_sa->lock);
> > +
> > +		/* 10.6.5 */
> > +		if (hdr->tci_an & MACSEC_TCI_C ||
> > +		    secy->validate_frames == MACSEC_VALIDATE_STRICT) {
> > +			u64_stats_update_begin(&rxsc_stats->syncp);
> > +			rxsc_stats->stats.InPktsNotValid++;
> > +			u64_stats_update_end(&rxsc_stats->syncp);
> > +			goto drop;
> > +		}
> > +
> > +		u64_stats_update_begin(&rxsc_stats->syncp);
> > +		if (secy->validate_frames == MACSEC_VALIDATE_CHECK) {
> > +			rxsc_stats->stats.InPktsInvalid++;
> > +			this_cpu_inc(rx_sa->stats->InPktsInvalid);
> > +		} else if (pn < lowest_pn) {
> > +			rxsc_stats->stats.InPktsDelayed++;
> > +		} else {
> > +			rxsc_stats->stats.InPktsUnchecked++;
> > +		}
> > +		u64_stats_update_end(&rxsc_stats->syncp);
> > +	} else {
> > +		u64_stats_update_begin(&rxsc_stats->syncp);
> > +		if (pn < lowest_pn) {
> > +			rxsc_stats->stats.InPktsDelayed++;
> > +		} else {
> > +			rxsc_stats->stats.InPktsOK++;
> > +			this_cpu_inc(rx_sa->stats->InPktsOK);
> > +		}
> > +		u64_stats_update_end(&rxsc_stats->syncp);
> > +
> > +		if (pn >= rx_sa->next_pn)
> > +			rx_sa->next_pn = pn + 1;
> > +		spin_unlock(&rx_sa->lock);
> 
> Do you think its feasible to rearrange the above so that
> rx_sa->lock/unlock (next_pn test and increment) are grouped more closesly?

Not if we want to follow the order of the checks in the specification.
You don't want to update the PN counter if the packet was not valid,
but you need to perform replay protection before accepting the packet.

And it's a lot of code, but there isn't that much happening.


> > +		/* not strict, the frame (with the SecTAG and ICV
> > +		 * removed) is delivered to the Controlled Port.
> > +		 */
> > +		nskb = skb_clone(skb, GFP_ATOMIC);
> > +		macsec_reset_skb(nskb, macsec->secy.netdev);
> 
> nskb == NULL handling?

Yes, as above.


> I'll have another look at your patch set later this week.
> 
> Thanks,
> Florian

Thanks.

-- 
Sabrina
