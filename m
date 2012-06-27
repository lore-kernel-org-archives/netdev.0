From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH net-next] em_canid: Ematch rule to match CAN frames
 according to their CAN IDs
Date: Wed, 27 Jun 2012 11:33:25 +0200
Message-ID: <20120627093325.GB410@vandijck-laurijssen.be>
References: <1340022131-7827-1-git-send-email-lisovy@gmail.com>
 <4FEA169C.1070709@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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

Oliver, Rostislav,

I was just looking into this. I think the matching itself
may be simplified by eliminating checks 'that have already been made'.

On Tue, Jun 26, 2012 at 10:07:56PM +0200, Oliver Hartkopp wrote:
> 
> > +static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
> > +			 struct tcf_pkt_info *info)
> > +{
> > +	struct canid_match *cm = em_canid_priv(m);
> > +	canid_t can_id;
> > +	unsigned int match = false;
> > +	int i;
> > +
> > +	can_id = em_canid_get_id(skb);
> > +
> > +	if (can_id & CAN_EFF_FLAG) {
> > +		can_id &= CAN_EFF_MASK;
Why clear the CAN_EFF_FLAG?
It needs an extra read-modify-write, and the CAN_EFF_FLAG is set in
the match rule too.
IMHO, you could leave can_id as it is.
> > +
> > +		for (i = 0; i < cm->eff_rules_count; i++) {

to speed things up manually, I tend to use a 'const struct can_filter *lp'
and do:
		for (i = 0, lp = cm->rules_raw; i < cm->eff_rules_count;
				++i, ++lp) {
The advantage depends on the compiler's optimizations, which I'm not really
aware of.
The next statement would then be:

			if (!((lp->can_id ^ can_id) & lp->can_mask)) {

for stripping & CAN_EFF_MASK, see below :-)


> > +			if (!(((cm->rules_raw[i].can_id ^ can_id) &
> > +			    cm->rules_raw[i].can_mask) & CAN_EFF_MASK)) {
> 
> 
> Looks really tricky. I'm still pondering if it does what it should do ...

I think it does, since:
	cm->rules_raw[i].can_id ^ can_id
gives an value where the bits that differ are set.
then:
	& cm->rules_raw[i].can_mask
will strip bits that you don't care.

But '& CAN_EFF_MASK' is not needed, since:
	* can_id will have CAN_EFF_FLAG (see comment above)
	* cm->rules_raw[i].can_id has CAN_EFF_FLAG, otherwise it would
	  not be in the list
	* can_id will not have CAN_ERR_FLAG
	* cm->rules_raw should not have CAN_ERR_FLAG
	  you can always clear CAN_ERR_FLAG from the rules during
	  em_canid_change below
	* maybe distinguishing on CAN_RTR_FLAG makes sense during
	  classification.
> 
> > +				match = true;
> > +				break;
> > +			}
> > +		}
> > +	} else { /* SFF */
> > +		can_id &= CAN_SFF_MASK;
> > +		match = test_bit(can_id, cm->match_sff);
> > +	}
> > +
> 
> 
> return match;
> 
> 
> > +}
> > +
