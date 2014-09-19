From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH/RFC repost 4/8] datapath: execution of select
	group action
Date: Fri, 19 Sep 2014 15:05:27 +0100
Message-ID: <20140919140527.GB8257@casper.infradead.org>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-5-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1411005311-11752-5-git-send-email-simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 09/18/14 at 10:55am, Simon Horman wrote:
> +const struct nlattr *bucket_actions(const struct nlattr *attr)
> +{
> +	const struct nlattr *a;
> +	int rem;
> +
> +	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
> +	     a = nla_next(a, &rem)) {
> +		if (nla_type(a) == OVS_BUCKET_ATTR_ACTIONS) {
> +			return a;
> +		}
> +	}
> +
> +	return NULL;
> +}

This is identical to nla_find(). I realize this is not the only
example but I think we should stop replicating existing Netlink
functionality and add missing pieces to lib/nlattr.c.

> +static u16 bucket_weight(const struct nlattr *attr)
> +{
> +	const struct nlattr *weight;
> +
> +	/* validate_and_copy_bucket() ensures that the first
> +	 * attribute is OVS_BUCKET_ATTR_WEIGHT */
> +	weight = nla_data(attr);
> +	BUG_ON(nla_type(weight) != OVS_BUCKET_ATTR_WEIGHT);
> +	return nla_get_u16(weight);
> +}
> +
> +static int select_group(struct datapath *dp, struct sk_buff *skb,
> +			const struct nlattr *attr)
> +{
> +	const struct nlattr *best_bucket = NULL;
> +	const struct nlattr *acts_list;
> +	const struct nlattr *bucket;
> +	struct sk_buff *sample_skb;
> +	u32 best_score = 0;
> +	u32 basis;
> +	u32 i = 0;
> +	int rem;
> +
> +	basis = skb_get_hash(skb);
> +
> +	/* Only possible type of attributes is OVS_SELECT_GROUP_ATTR_BUCKET */
> +	for (bucket = nla_data(attr), rem = nla_len(attr); rem > 0;
> +	     bucket = nla_next(bucket, &rem)) {
> +		uint16_t weight = bucket_weight(bucket);

I think we should validate only once when we copy then assume it is
correct.

> +		// XXX: This hashing seems expensive
> +		u32 score = (jhash_1word(i, basis) & 0xffff) * weight;

Maybe just calculate a weighted distribution table pointing to the
buckets which you index with 8 bits of the hash.

> +		if (score >= best_score) {
> +			best_bucket = bucket;
> +			best_score = score;
> +		}
> +		i++;
> +	}
> +
> +	acts_list = bucket_actions(best_bucket);
> +
> +	/* A select group action is always the final action so
> +	 * there is no need to clone the skb in case of side effects.
> +	 * Instead just take a reference to it which will be released
> +	 * by do_execute_actions(). */
> +	skb_get(skb);
> +
> +	return do_execute_actions(dp, skb, nla_data(acts_list),
> +				  nla_len(acts_list));

Do we need a recursion limit here?

> +}
