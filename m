From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] meta ematch
Date: 16 Jan 2005 11:11:11 -0500
Message-ID: <1105891871.1097.647.camel@jzny.localdomain>
References: <20050106194102.GW26856@postel.suug.ch>
	 <1105105511.1046.77.camel@jzny.localdomain>
	 <20050108145457.GZ26856@postel.suug.ch>
	 <1105363582.1041.162.camel@jzny.localdomain>
	 <20050110211747.GA26856@postel.suug.ch>
	 <1105394738.1085.63.camel@jzny.localdomain>
	 <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net>
	 <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net>
	 <20050114151407.GR26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050114151407.GR26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-14 at 10:14, Thomas Graf wrote:
 
> diff -Nru linux-2.6.10-bk14.orig/include/linux/tc_ematch/tc_em_meta.h linux-2.6.10-bk14/include/linux/tc_ematch/tc_em_meta.h
[..]
> +struct tcf_meta_val
> +{
> +	__u16			kind;
> +	__u8			shift;
> +	__u8			op;
> +};
> +
> +#define TCF_META_TYPE_MASK	(0xf << 12)
> +#define TCF_META_TYPE(kind)	(((kind) & TCF_META_TYPE_MASK) >> 12)
> +#define TCF_META_ID_MASK	0x7ff
> +#define TCF_META_ID(kind)	((kind) & TCF_META_ID_MASK)

Does it smell like there may be endianess issues? Probably not.

> +enum
> +{
> +	TCF_META_TYPE_VAR,
> +	TCF_META_TYPE_INT,
> +	__TCF_META_TYPE_MAX
> +};
> +#define TCF_META_TYPE_MAX (__TCF_META_TYPE_MAX - 1)
> +
> +enum
> +{
> +	TCF_META_ID_VALUE,
> +	TCF_META_ID_RANDOM,
> +	TCF_META_ID_LOADAVG_0,
> +	TCF_META_ID_LOADAVG_1,
> +	TCF_META_ID_LOADAVG_2,
> +	TCF_META_ID_DEV,

Since filters are attached to devices - is TCF_META_ID_DEV of any value?

> diff -Nru linux-2.6.10-bk14.orig/net/sched/em_meta.c linux-2.6.10-bk14/net/sched/em_meta.c

> +
> +struct meta_obj
> +{
> +	unsigned long		value;
> +	unsigned int		len;
> +};
> +
> +struct meta_value
> +{
> +	struct tcf_meta_val	hdr;
> +	unsigned long		val;
> +	unsigned int		len;

Those last two look like meta_obj you defined above


> +/**************************************************************************
> + * System status & misc
> + **************************************************************************/
> +
> +static int meta_int_random(struct sk_buff *skb, struct tcf_pkt_info *info,
> +			   struct meta_value *v, struct meta_obj *dst)
> +{
> +	get_random_bytes(&dst->value, sizeof(dst->value));
> +	return 0;
> +}
> +
> +static inline unsigned long fixed_loadavg(unsigned long v)
> +{
> +	return (v + (FIXED_1/200)) >> FSHIFT;

200 has some magic connotation to it - a define somewhere perhaps?

> +}
> +
> +static int meta_int_loadavg_0(struct sk_buff *skb, struct tcf_pkt_info *info,
> +			      struct meta_value *v, struct meta_obj *dst)
> +{
> +	dst->value = fixed_loadavg(avenrun[0]);
> +	return 0;
> +}
> +
> +static int meta_int_loadavg_1(struct sk_buff *skb, struct tcf_pkt_info *info,
> +			      struct meta_value *v, struct meta_obj *dst)
> +{
> +	dst->value = fixed_loadavg(avenrun[1]);
> +	return 0;
> +}
> +
> +static int meta_int_loadavg_2(struct sk_buff *skb, struct tcf_pkt_info *info,
> +			      struct meta_value *v, struct meta_obj *dst)
> +{
> +	dst->value = fixed_loadavg(avenrun[2]);
> +	return 0;
> +}

Theres a lot of parameters not used at all in these calls .get calls. So
far i have seen dst->value and some of the skb fields used. I apologize,
I normally dont pick on these things - so if you have future plans for
why you are passing those, keep them and ignore the comment.
BTW, it would probably be useful to return some mnemonic instead of 0.

> +/**************************************************************************
> + * Device names & indices
> + **************************************************************************/
> +
> +static inline int int_dev(struct net_device *dev, struct meta_obj *dst)
> +{
> +	if (unlikely(dev == NULL))
> +		return -1;
> +
> +	dst->value = dev->ifindex;
> +	return 0;
> +}
> +
> +static inline int var_dev(struct net_device *dev, struct meta_obj *dst)
> +{
> +	if (unlikely(dev == NULL))
> +		return -1;
> +
> +	dst->value = (unsigned long) dev->name;
> +	dst->len = strlen(dev->name);

So if device dissapears ... what happens to the pointer?
[..]

> +static inline struct meta_ops * meta_ops(struct meta_value *v)
> +{
> +	return &__meta_ops[meta_type(v)][meta_id(v)];
> +}
> +
> +static int meta_var_compare(struct meta_obj *a, struct meta_obj *b)
> +{
> +	int r = a->len - b->len;
> +
> +	if (r == 0)
> +		r = memcmp((void *) a->value, (void *) b->value, a->len);
> +
> +	return r;
> +}

clever

> +static void meta_var_apply_extras(struct meta_value *v,
> +				  struct meta_obj *dst)
> +{
> +	int shift = v->hdr.shift;
> +
> +	if (shift && shift < dst->len)
> +		dst->len -= shift;
> +}

whats the purpose to the extras?

> +static int meta_int_compare(struct meta_obj *a, struct meta_obj *b)
> +{
> +	/* Let gcc optimize it, the unlikely is not really based on
> +	 * some numbers but jump free code for missmatches seems
> +	 * more logical.
> +	 */
> +	if (unlikely(a == b))
> +		return 0;
> +	else if (a < b)
> +		return -1;
> +	else
> +		return 1;
> +}

Would be very useful to return mnemonics for readability.


> +static int em_meta_match(struct sk_buff *skb, struct tcf_ematch *m,
> +			 struct tcf_pkt_info *info)
> +{
> +	int r;
> +	struct meta_match *meta = (struct meta_match *) m->data;
> +	struct meta_obj l_value, r_value;
> +
> +	if (meta_get(skb, info, &meta->lvalue, &l_value) < 0 ||
> +	    meta_get(skb, info, &meta->rvalue, &r_value) < 0)
> +		return 0;

This is one part that confused me in my earlier email

> +	r = meta_type_ops(&meta->lvalue)->compare(&l_value, &r_value);

And this is where it started 

Overall comment: Well done
usability comment:
Ok, I have to admit I am not a friend of too-friendly, which is one of
the faults IMO with netfilter; however, this would have
joenetfilterfireman sweat a little too profusely.
I think you could add a new metafield in 31 seconds. I could probably do
it in 95 seconds. Would be ideal to get average
janeorjoenetfilterfireman to do it in 30 minutes - I dont think you are
there.

cheers,
jamal
