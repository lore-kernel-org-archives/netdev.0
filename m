From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 05 Jan 2005 08:33:11 -0500
Message-ID: <1104931991.1117.152.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <20050104223612.GN26856@postel.suug.ch>
	 <1104894728.1117.56.camel@jzny.localdomain>
	 <20050105110048.GO26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050105110048.GO26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-05 at 06:00, Thomas Graf wrote:
> * jamal <1104894728.1117.56.camel@jzny.localdomain> 2005-01-04 22:12

> > Why do i need to signal something as simple? AND why does it have to be
> > 32 bit type - what edge does that give you?
> 
> You don't have to, providing a 32bit data chunk without TCF_EM_SIMPLE
> set will simply result in allocating & copy. It's an optimization,
> nothing more.

Sorry i missed that. Isnt it still unecessary though? You should be able
to pass L=4 and not need the speacial treatment, no?

> > Not a very good example - but you can see how powerfull this is when you
> > can quickly use a string scanner such as the one you have as an ematch
> > while maintaining u32 as is.
> 
> Basically you could do that already with the basic classifier but
> I understand your concern and it would be neat to benefit from u32's
> hashing. There are 2 options:
>   1) We make u32 hold multiple ematch trees, a u32 key can be of 3
>      kinds: u32/ematch/container. It's kind of a hack and not very
>      fast due to a lot of stack movement.

Indeed this is what i was thinking of. 
The only added overhead I can think of is when processing a series of
u32 keys _within the same selector_ (not across selectors), you check if
its u32 native and execute localy (as is done now) or transfer the check
to the ematch defined in that key and continue to next key based on the
ematchs return code + the logical operation.

>   2) We make the existing u32 match be an ematch which I already did
>      expect for the nexthdr bits. That is the select will simply be
>      replaced by an ematch tree. I'll take a look into how we could
>      have the classifier take influence on the ematches config data.
>      One possibiliy is to have a struct transfered via map which
>      contains useful data such as offset to next header (u32/rsvp).
>      I have to think about this a little more though.

This could be done in addition to #1. I see #1 as more important for u32
but not so for things like fwmark, tcindex which should fizzle away with
meta ematch. I think the danger is in trying to replicate u32 as an
ematch; if somehow you can loop back and use the real u32 code, then
fine. I feel it being non-trivial to do so.
Like i said earlier, theres a lot of power in u32 other than in basic
matching.

> Personally I'm all for 2) because it's just cleaner and easier to
> maintain. 

Aha, thats why we were not converging then ;->
I think #2 is better for other classifiers which were already doomed
anyways. #1 is important for u32 and perhaps other classifiers like rsvp
and route. And yes, #1 is more work ;->

> It's probably the best to not to use the u32 ematch I
> wrote (which I renamed to cmp) but to write a new one behaving
> exactly the same as the existing u32 match.
> 

hang on:-> No dont rewrite u32 please. Your cmp is good for the basic
matches that u32 does, but is _nowhere_ close to being able to do what
u32 can when used properly.

> Attached cmp ematch (formerly u32), it was on diet for a while
> and is quite smallish now.

Looks very appetizing. Two general comments:

> diff -Nru linux-2.6.10-bk6.orig/include/linux/pkt_cls.h linux-2.6.10-bk6/include/linux/pkt_cls.h
> --- linux-2.6.10-bk6.orig/include/linux/pkt_cls.h	2005-01-05 01:09:29.000000000 +0100
> +++ linux-2.6.10-bk6/include/linux/pkt_cls.h	2005-01-05 01:46:34.000000000 +0100
> @@ -349,6 +349,7 @@
>  enum
>  {
>  	TCF_EM_CONTAINER,
> +	TCF_EM_CMP,
>  	__TCF_EM_MAX
>  };


I Should be able to compile a new ematch as a module in an already
running kernel. So, other than generic stuff for ematches, things like 
TCF_EM_CMP should not be in that enumeration.

> @@ -366,4 +367,28 @@
>  #define TCF_EM_INVERT	(1<<3)
>  #define TCF_EM_SIMPLE	(1<<4)
>  
> +struct tcf_em_cmp
> +{
> +	__u32		val;
> +	__u32		mask;
> +	__u16		off;
> +	__u8		align;
> +	__u8		layer:4;
> +	__u8		opnd:4;
> +};
> +
> +enum
> +{
> +	TCF_EM_ALIGN_U8  = 1,
> +	TCF_EM_ALIGN_U16 = 2,
> +	TCF_EM_ALIGN_U32 = 4
> +};
> +
> +enum
> +{
> +	TCF_EM_OPND_EQ,
> +	TCF_EM_OPND_GT,
> +	TCF_EM_OPND_LT
> +};
> +

Which means the above should go in its own file; probably create a
include/linux/tc_ematch directory with a file of sort tcf_em_cmp.h
which holds all the above.

>  #endif
> diff -Nru linux-2.6.10-bk6.orig/include/net/pkt_cls.h linux-2.6.10-bk6/include/net/pkt_cls.h
> --- linux-2.6.10-bk6.orig/include/net/pkt_cls.h	2005-01-05 01:09:29.000000000 +0100
> +++ linux-2.6.10-bk6/include/net/pkt_cls.h	2005-01-05 01:26:03.000000000 +0100
> @@ -270,6 +270,36 @@
>  
>  #endif /* CONFIG_NET_EMATCH */
>  
> +static inline u32 tcf_read_bucket(u8 *ptr, u8 align)
> +{
> +	switch (align) {
> +		case TCF_EM_ALIGN_U8:
> +			return *ptr;
> +		case TCF_EM_ALIGN_U16:
> +			return (*ptr << 8) | *(ptr+1);
> +		case TCF_EM_ALIGN_U32:
> +			return (*ptr << 24) | (*(ptr+1) << 16) |
> +				(*(ptr+2) << 8) | *(ptr+3);
> +	}
> +	return 0;
> +}
> +
> +static inline u8 * tcf_get_base_ptr(struct sk_buff *skb, u8 layer)
> +{
> +	switch (layer) {
> +		case 0:
> +			return skb->data;
> +		case 1:
> +			return skb->nh.raw;
> +		case 2:
> +			return skb->h.raw;
> +	}
> +	return NULL;
> +}
> +
> +#define tcf_valid_offset(skb, ptr, off, len) \
> +	((ptr + off + len) < skb->tail && (ptr + off) > skb->head)
> +

And all this also goes in that header file as well.

cheers,
jamal
