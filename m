From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] meta ematch
Date: Sun, 16 Jan 2005 17:32:12 +0100
Message-ID: <20050116163212.GW26856@postel.suug.ch>
References: <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain> <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain> <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net> <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net> <20050114151407.GR26856@postel.suug.ch> <1105891871.1097.647.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105891871.1097.647.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105891871.1097.647.camel@jzny.localdomain> 2005-01-16 11:11
> On Fri, 2005-01-14 at 10:14, Thomas Graf wrote:
>  
> > diff -Nru linux-2.6.10-bk14.orig/include/linux/tc_ematch/tc_em_meta.h linux-2.6.10-bk14/include/linux/tc_ematch/tc_em_meta.h
> [..]
> > +struct tcf_meta_val
> > +{
> > +	__u16			kind;
> > +	__u8			shift;
> > +	__u8			op;
> > +};
> > +
> > +#define TCF_META_TYPE_MASK	(0xf << 12)
> > +#define TCF_META_TYPE(kind)	(((kind) & TCF_META_TYPE_MASK) >> 12)
> > +#define TCF_META_ID_MASK	0x7ff
> > +#define TCF_META_ID(kind)	((kind) & TCF_META_ID_MASK)
> 
> Does it smell like there may be endianess issues? Probably not.

Not really as long as iproute2 uses the same byte ordering. It has the
same issues as all other rtnetlink users.

> > +	TCF_META_ID_DEV,
> 
> Since filters are attached to devices - is TCF_META_ID_DEV of any value?

Yes, to compare against realdev and indev.

> > +struct meta_value
> > +{
> > +	struct tcf_meta_val	hdr;
> > +	unsigned long		val;
> > +	unsigned int		len;
> 
> Those last two look like meta_obj you defined above

Yes, they once were but the code is more readable this way
because one cannot mistake meta_obj (temporary data) with
the data/len in meta_value (persistent).

> > +	return (v + (FIXED_1/200)) >> FSHIFT;
> 
> 200 has some magic connotation to it - a define somewhere perhaps?

I coped this from the code for procfs ;->

> Theres a lot of parameters not used at all in these calls .get calls. So
> far i have seen dst->value and some of the skb fields used. I apologize,
> I normally dont pick on these things - so if you have future plans for
> why you are passing those, keep them and ignore the comment.

I do have plans but for more complicated meta matches and they will
take some time and will get pushed in a second iteration.

> > +static inline int var_dev(struct net_device *dev, struct meta_obj *dst)
> > +{
> > +	if (unlikely(dev == NULL))
> > +		return -1;
> > +
> > +	dst->value = (unsigned long) dev->name;
> > +	dst->len = strlen(dev->name);
> 
> So if device dissapears ... what happens to the pointer?

Not possible, the pointer is only legal to use while classifying,
dst is on the stack of meta_match and the device cannot
disappear while classyfing.

> > +static void meta_var_apply_extras(struct meta_value *v,
> > +				  struct meta_obj *dst)
> > +{
> > +	int shift = v->hdr.shift;
> > +
> > +	if (shift && shift < dst->len)
> > +		dst->len -= shift;
> > +}
> 
> whats the purpose to the extras?

"eth0" shift 1 gets "eth" so we can emulate eth%. It will
also get useful for ipv6 routing bits to implement the
prefix.

> > +static int em_meta_match(struct sk_buff *skb, struct tcf_ematch *m,
> > +			 struct tcf_pkt_info *info)
> > +{
> > +	int r;
> > +	struct meta_match *meta = (struct meta_match *) m->data;
> > +	struct meta_obj l_value, r_value;
> > +
> > +	if (meta_get(skb, info, &meta->lvalue, &l_value) < 0 ||
> > +	    meta_get(skb, info, &meta->rvalue, &r_value) < 0)
> > +		return 0;
> 
> This is one part that confused me in my earlier email

It transforms the meta data info in (l|r)value into 2 temporary
meta objects for comparing. mgiht help if i  find a better
name.

> Ok, I have to admit I am not a friend of too-friendly, which is one of
> the faults IMO with netfilter; however, this would have
> joenetfilterfireman sweat a little too profusely.
> I think you could add a new metafield in 31 seconds. I could probably do
> it in 95 seconds. Would be ideal to get average
> janeorjoenetfilterfireman to do it in 30 minutes - I dont think you are
> there.

ideas? a step-by-step guide in Documentation/? ;->
