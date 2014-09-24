From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC repost 4/8] datapath: execution of select group action
Date: Wed, 24 Sep 2014 15:01:11 +0900
Message-ID: <20140924060107.GC13314@vergenet.net>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-5-git-send-email-simon.horman@netronome.com>
 <20140919140527.GB8257@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:56190 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaIXGBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 02:01:22 -0400
Received: by mail-pd0-f173.google.com with SMTP id y10so7916842pdj.4
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 23:01:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140919140527.GB8257@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 03:05:27PM +0100, Thomas Graf wrote:
> On 09/18/14 at 10:55am, Simon Horman wrote:
> > +const struct nlattr *bucket_actions(const struct nlattr *attr)
> > +{
> > +	const struct nlattr *a;
> > +	int rem;
> > +
> > +	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
> > +	     a = nla_next(a, &rem)) {
> > +		if (nla_type(a) == OVS_BUCKET_ATTR_ACTIONS) {
> > +			return a;
> > +		}
> > +	}
> > +
> > +	return NULL;
> > +}
> 
> This is identical to nla_find(). I realize this is not the only
> example but I think we should stop replicating existing Netlink
> functionality and add missing pieces to lib/nlattr.c.

Thanks. For starters I have removed bucket_actions() and replaced
its usage with a call to nla_find().

> > +static u16 bucket_weight(const struct nlattr *attr)
> > +{
> > +	const struct nlattr *weight;
> > +
> > +	/* validate_and_copy_bucket() ensures that the first
> > +	 * attribute is OVS_BUCKET_ATTR_WEIGHT */
> > +	weight = nla_data(attr);
> > +	BUG_ON(nla_type(weight) != OVS_BUCKET_ATTR_WEIGHT);
> > +	return nla_get_u16(weight);
> > +}
> > +
> > +static int select_group(struct datapath *dp, struct sk_buff *skb,
> > +			const struct nlattr *attr)
> > +{
> > +	const struct nlattr *best_bucket = NULL;
> > +	const struct nlattr *acts_list;
> > +	const struct nlattr *bucket;
> > +	struct sk_buff *sample_skb;
> > +	u32 best_score = 0;
> > +	u32 basis;
> > +	u32 i = 0;
> > +	int rem;
> > +
> > +	basis = skb_get_hash(skb);
> > +
> > +	/* Only possible type of attributes is OVS_SELECT_GROUP_ATTR_BUCKET */
> > +	for (bucket = nla_data(attr), rem = nla_len(attr); rem > 0;
> > +	     bucket = nla_next(bucket, &rem)) {
> > +		uint16_t weight = bucket_weight(bucket);
> 
> I think we should validate only once when we copy then assume it is
> correct.

That is the intention of this code, is it doing something else?

I think there is some scope to store the bucket in a more efficient
form for execution. But I'm not sure that any other actions
receive such treatment. So I postponed inventing that wheel.

> > +		// XXX: This hashing seems expensive
> > +		u32 score = (jhash_1word(i, basis) & 0xffff) * weight;
> 
> Maybe just calculate a weighted distribution table pointing to the
> buckets which you index with 8 bits of the hash.

Nice idea. I think that would work out quite well.

The main question for me would be where to store such a table,
which comes back to my remark above about more storing a more
efficient efficient form of the action.

> > +		if (score >= best_score) {
> > +			best_bucket = bucket;
> > +			best_score = score;
> > +		}
> > +		i++;
> > +	}
> > +
> > +	acts_list = bucket_actions(best_bucket);
> > +
> > +	/* A select group action is always the final action so
> > +	 * there is no need to clone the skb in case of side effects.
> > +	 * Instead just take a reference to it which will be released
> > +	 * by do_execute_actions(). */
> > +	skb_get(skb);
> > +
> > +	return do_execute_actions(dp, skb, nla_data(acts_list),
> > +				  nla_len(acts_list));
> 
> Do we need a recursion limit here?

I believe that is already handled by the depth check that occurs
when the actions are copied.
