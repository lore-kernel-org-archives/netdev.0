From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 01 Jan 2005 18:29:25 -0500
Message-ID: <1104622164.1048.444.camel@jzny.localdomain>
References: <20041229150140.GJ32419@postel.suug.ch>
	 <1104335620.1025.22.camel@jzny.localdomain>
	 <20041230174313.GB32419@postel.suug.ch>
	 <1104469111.1049.219.camel@jzny.localdomain>
	 <20041231110836.GD32419@postel.suug.ch>
	 <1104505142.1048.262.camel@jzny.localdomain>
	 <20041231153930.GN32419@postel.suug.ch>
	 <1104511494.1048.303.camel@jzny.localdomain>
	 <20041231181153.GP32419@postel.suug.ch>
	 <1104526311.1047.379.camel@jzny.localdomain>
	 <20050101121041.GR32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050101121041.GR32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-01-01 at 07:10, Thomas Graf wrote:
> * jamal <1104526311.1047.379.camel@jzny.localdomain> 2004-12-31 15:51

> > We need to know who installed the rule so we can intepret what the ID in
> > the match is.
> 
> Yes but this should go into the selector header.
> 

Agreed - PID needs to go into selector. The other ID is per match.

> > You may actually need those Ts enumerated as if they are array
> > indices. Look at the way i transfer actions using "order"
> 
> Right, order would be N-2. I don't see any reason for storing it, I
> didn't had need for it in EGP and I used exactly the same techniques
> as in the action code.
> 

If youve done it on EGP then go ahead and use that scheme since you are
comfortable with it.

> > My view was length is also a common field. Theres also another reason
> > why you want length viewable in a dumb way:
> > --> you dont really wanna force people to write dumpers for these
> > ematchers (goal: keep this interface as simple as it can be); i.e dont
> > need any pretty formater in the kernel.
> > If you have a length then you can reconstruct the TCA_EMATCH easily
> > without caring about the content. This is the path i started taking in 
> > eactions. Refer to my notes i sent earlier on the mythical one page
> > ematch/eaction.
> > If someone wants funky stuff - write a classifier.
> 
> Very simple ematches will only require a struct for configuration
> so the dumping is not more than 5 lines of code. The length can be
> calculated via RTA_PAYLOAD(ematch_tlv) - sizeof(ematch_hdr). This
> of course requires the struct to be aligned to RTA_ALIGN but
> that's generally not a problem at all.

Does the ematch API include a dump()? I dont think it should - thats the
point i was making. Should be simple.

> I understand your concern but I also want to allow a little bit
> more complicated ematches such as KMP or later a very simple
> regular expression implementation.
> 
> Here's some code from the simple_cmp key of EGP giving a good
> idea how a simple ematch will look like:
> 
> static int
> sc_match(struct egp_cls *cls, struct egp_key *k)
> {
>        struct egp_key_sc *sc = k->data;
>        u32 lvalue = cls->ops->read(cls, &sc->left);
>        u32 rvalue = cls->ops->read(cls, &sc->right);
> 
>        switch (sc->op) {
> #define SC(a, b) case EGP_OP_##a: return b
>                SC(NONE, 0);
>                SC(EQ, lvalue == rvalue);
>                SC(NE, lvalue != rvalue);
>                SC(LT, lvalue <  rvalue);
>                SC(LE, lvalue <= rvalue);
>                SC(GT, lvalue >  rvalue);
>                SC(GE, lvalue >= rvalue);
> #undef  SC
>        }
> 
>        BUG();
>        return 0;
> }
> 

nice and valid for API.

> static int
> sc_validate(struct egp_config *conf, struct egp_ops *ops, void *d, size_t len)
> {
>        int err;
>        struct egp_key_sc *sc = d;
> 
>        if (len != sizeof(*sc) || sc->op > EGP_OP_MAX)
>                return -EINVAL;
>        return 0;
> }
> 

Even this is too much for a simple ematch. Validation should happen in
user space or maybe at the mother clasifier. maybe a maxsize,minsize
attribute is needed in the ematch struct.

> static int
> sc_replace(struct egp_cls *cls, struct egp_key *k, void *d, size_t len)
> {
>        k->data = kmalloc(len, GFP_KERNEL);
>        if (NULL == k->data)
>                return -ENOBUFS;
>        memcpy(k->data, d, len);
>        return 0;
> }

Equivalent of this should be done by the mother classifier.
All it needs to know is the length (and no other details). And the
length is known from the L in TLV.

> static int
> sc_dump(struct egp_cls *cls, struct sk_buff *skb, struct egp_key *k)
> {
>        struct egp_key_sc *sc = k->data;
>        RTA_PUT(skb, TCA_EGP_KEY_DATA, sizeof(*sc), sc);
>        return 0;
> 
> rtattr_failure:
>        return -1;
> }
> 

Again if you store length, you dont need this. Mother classifier can do
it.

> static void
> sc_free_data(struct egp_cls *cls, struct egp_key *k)
> {
>        if (k->data)
>                kfree(k->data);
> }

Dont need this either; mother classifier can handle it.

> OTOH, on more complex ematches data might be nested TLVs with
> optional parameters. etc.
> 
> > Stats are the other thing that adds complexity to the API. If you can
> > make it optional then that would be best - I was thinking to not even
> > have it in.
> 
> It's probably enough to allow optional generic hits/success stats
> per match.

Even at the moment classifiers dont have stats. If you want stats
you could add a simple gact accept action. 
Note also: think of the 100K rules being added and amount of RAM used;

> > I thought we already agreed on the layout:
> > SEL2- which may nest E/MATCHEs TLVs. Sel2 not being very different from
> > original selector. May be i didnt follow. 
> 
> You did follow but I made the existing u32 match a ematch as well.
> Things like the program ID goes into the selector header T=1 and
> classifier specific selector bits such as the hashing bits goes
> into T=2. Thinking of it it's probably cleaner to put things like
> hmark, hoff into its own TLV. So the selector TLV contains the
> selector header at T=1 and nested ematch TLVs at T=2..T=N.
> 

Note that the ematch is supposed to be a very very simple thing...
Something a fireman who has implemented a iptables target can whip in an
hour. Keep in mind that design goal. Non trivial coding needed or poor
usability is the major problem with tc in general. Avoid that theme.
An ematch _needs_  a mother classifier such as u32. u32 has a very nice
and very flexible layout - it can be trained to build any sort of tree.
Maybe the first step should be to not even have u32 as an ematch ..

> I think we're mostly in sync so I'll start working on it and
> we can review again.

Maybe i will wait for the code. 

cheers,
jamal
