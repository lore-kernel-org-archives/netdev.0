From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Mon, 4 Jan 2016 13:23:29 +0100
Message-ID: <20160104122329.GB470@breakpoint.cc>
References: <cover.1450964358.git.sd@queasysnail.net>
 <1910d94579a647d1c3b23a348778458d2f1f97a1.1450964358.git.sd@queasysnail.net>
 <20151229011406.GA21112@breakpoint.cc>
 <20151229135618.GA28245@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36049 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753318AbcADMXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:23:31 -0500
Content-Disposition: inline
In-Reply-To: <20151229135618.GA28245@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sabrina Dubroca <sd@queasysnail.net> wrote:

[ Sorry for long delay ]

> 2015-12-29, 02:14:06 +0100, Florian Westphal wrote:
> > > +	tx_sa->next_pn++;
> > > +	if (tx_sa->next_pn == 0) {
> > > +		pr_notice("PN wrapped, transitionning to !oper\n");
> > 
> > Is that _notice intentional?
> > I'm only asking because it seems we printk unconditionally in response
> > to network traffic & I don't get what operator should do in response to
> > that message.
> 
> The operator should install a new tx_sa, or MKA should have already
> installed a new one and switched to it.
> I can remove this message, or make it a pr_debug.

Ok, I'll leave it up to you since I don't know what makes more sense.
Basically just do whatever you think is right ;)

AFAIU this should not really happen in practice, right?

If so, pr_debug might be appropriate.

> > > +static void macsec_encrypt_done(struct crypto_async_request *base, int err)
> > > +{
> > > +	struct sk_buff *skb = base->data;
> > > +	struct net_device *dev = skb->dev;
> > > +	struct macsec_dev *macsec = macsec_priv(dev);
> > > +	struct macsec_tx_sa *sa = macsec_skb_cb(skb)->tx_sa;
> > > +	int len, ret;
> > > +
> > > +	aead_request_free(macsec_skb_cb(skb)->req);
> > > +
> > > +	rcu_read_lock_bh();
> > > +	macsec_encrypt_finish(skb, dev);
> > > +	macsec_count_tx(skb, &macsec->secy.tx_sc, macsec_skb_cb(skb)->tx_sa);
> > > +	len = skb->len;
> > > +	ret = dev_queue_xmit(skb);
> > > +	count_tx(dev, ret, len);
> > > +	rcu_read_unlock_bh();
> > 
> > What was the rcu_read_lock_bh protecting?
> 
> this_cpu_ptr in macsec_count_tx and count_tx.  Separate get_cpu_ptr in
> both functions seem a bit wasteful, and dev_queue_xmit will also
> disable bh.
> 
> I could turn that into a preempt_disable with a comment (something
> like "covers multiple accesses to pcpu variables").  Or I could get
> rid of it, and use get/put_cpu_ptr in macsec_count_tx/count_tx.
> Note that macsec_count_tx/count_tx (and count_rx below) are also
> called from the normal packet processing path, where we already run
> under rcu_read_lock_bh anyway, so avoiding the overhead of an extra
> get_cpu_ptr seems preferable.

Ah, I see.  In that case it seems preferrable to local_bh_dis/enable
here.  What do you think? (comment is still good to have wrt. pcpu and
packet processing path detail, I missed the latter).

> > > +		spin_unlock(&rx_sa->lock);
> > > +		pr_debug("packet_number too small: %u < %u\n", pn, lowest_pn);
> > > +		u64_stats_update_begin(&rxsc_stats->syncp);
> > > +		rxsc_stats->stats.InPktsLate++;
> > > +		u64_stats_update_end(&rxsc_stats->syncp);
> > > +		goto drop;
> > > +	}
> > 
> > I don't understand why this seems to perform replay check twice?
> 
> This is part of the specification (802.1AE-2006 figure 10-5).
> The first check is done before attempting to decrypt the packet, then
> once again after decrypting.

I see. Could you add a short comment?
("re-check post decryption as per $ref $figure" or something like that
 should suffice).

> > > +	if (secy->validate_frames != MACSEC_VALIDATE_DISABLED) {
> > > +		u64_stats_update_begin(&rxsc_stats->syncp);
> > > +		if (hdr->tci_an & MACSEC_TCI_E)
> > > +			rxsc_stats->stats.InOctetsDecrypted += skb->len;
> > > +		else
> > > +			rxsc_stats->stats.InOctetsValidated += skb->len;
> > > +		u64_stats_update_end(&rxsc_stats->syncp);
> > > +	}
[..]
> > Do you think its feasible to rearrange the above so that
> > rx_sa->lock/unlock (next_pn test and increment) are grouped more closesly?
> 
> Not if we want to follow the order of the checks in the specification.

Ok, thanks for explaining.
