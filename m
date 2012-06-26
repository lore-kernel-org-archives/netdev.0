From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] em_canid: Ematch rule to match CAN frames
 according to their CAN IDs
Date: Tue, 26 Jun 2012 17:32:55 -0400
Message-ID: <20120626213255.GC31808@canuck.infradead.org>
References: <1340022131-7827-1-git-send-email-lisovy@gmail.com>
 <4FEA169C.1070709@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rostislav Lisovy <lisovy@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FEA169C.1070709@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 26, 2012 at 10:07:56PM +0200, Oliver Hartkopp wrote:
> > With no extra filter/qdisc configured, median of the time spent in can_send()
> > was about 27 us -- with prio qdisc with 5 bands and 5 appropriate cls_can
> > filters (previous patch), it was about 30 us -- with prio qdisc with 5 bands
> > and 5 appropriate em_can filters (this patch), it was about 34 us.
> 
> 
> Hm that's more than twice the time consumed for classification ...
> 
> cls_can: 3 us more
> em_can:  7 us more
> 
> @Eric: Is this still the better approach then?

If there is overhead, we should get rid of that overhead and not
abandon an established subsystem.

Rostislav: Can you provide some details on where the time is spent?

> > +	/* Process EFF frame rules*/
> > +	for (i = 0; i < cm->rules_count; i++) {
> > +		if ((conf[i].can_id & CAN_EFF_FLAG) &&
> > +		    (conf[i].can_mask & CAN_EFF_FLAG)) {
> > +			memcpy(cm->rules_raw + cm->eff_rules_count,
> 
> 
> Oops. Shouldn't this be
> 
> cm->rules_raw + cm->eff_rules_count * sizeof(struct can_filter),
> 
> ???

Looks like correct pointer arithmetic to me. Your suggestion
would only be valid if rules_raw was a void pointer.

> > +static void em_canid_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
> > +{
> > +	struct canid_match *cm = em_canid_priv(m);
> > +
> 
> 
> Check for cm == NULL not needed ?

kfree() has that check embeddded. Also, for destroy() can only be called
if the match was added to the tree and that requires a successful call
to ->change(). Therefore it will never be NULL.

> > +static int em_canid_dump(struct sk_buff *skb, struct tcf_ematch *m)
> > +{
> > +	struct canid_match *cm = em_canid_priv(m);
> > +
> 
> 
> Check for cm == NULL not needed ?
> 
> Can a dump happen before the matches are added??

Nope, ->dump() is only ever called if the match has been added to the tree.

> > +	/*
> > +	 * When configuring this ematch 'rules_count' is set not to exceed
> > +	 * 'rules_raw' array size
> > +	 */
> > +	if (nla_put_nohdr(skb, sizeof(cm->rules_raw[0]) * cm->rules_count,
> 
> 
> better sizeof(struct can_filter) instead of sizeof(cm->rules_raw[0]) ??
> 
> > +	    &cm->rules_raw) < 0)
> > +		goto nla_put_failure;

No need for a goto here, just return -EMSGSIZE.
