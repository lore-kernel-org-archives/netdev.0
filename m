From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Sat, 1 Jan 2005 13:10:41 +0100
Message-ID: <20050101121041.GR32419@postel.suug.ch>
References: <20041229150140.GJ32419@postel.suug.ch> <1104335620.1025.22.camel@jzny.localdomain> <20041230174313.GB32419@postel.suug.ch> <1104469111.1049.219.camel@jzny.localdomain> <20041231110836.GD32419@postel.suug.ch> <1104505142.1048.262.camel@jzny.localdomain> <20041231153930.GN32419@postel.suug.ch> <1104511494.1048.303.camel@jzny.localdomain> <20041231181153.GP32419@postel.suug.ch> <1104526311.1047.379.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104526311.1047.379.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104526311.1047.379.camel@jzny.localdomain> 2004-12-31 15:51
> On Fri, 2004-12-31 at 13:11, Thomas Graf wrote:
> > * jamal <1104511494.1048.303.camel@jzny.localdomain> 2004-12-31 11:44
> 
> > Agreed I just don't get the reason for the PID. tc is usually called as
> > a new process instance when dumping. 
> 
> Indeed. A new instance of tc should be able to delete or understand
> what an old instance with different process ID installed.
> The P in pid here stands for "program" not "process". Looking at it from
> another angle it is the "owner" of that rule.

Ahh, now this makes sense. Sorry, I misunderstood you all the time.

> > u16 handle
> > u16 matchID
> > u16 kind
> > u8 flags
> > u8 pad
> 
> We need to know who installed the rule so we can intepret what the ID in
> the match is.

Yes but this should go into the selector header.

> You may actually need those Ts enumerated as if they are array
> indices. Look at the way i transfer actions using "order"

Right, order would be N-2. I don't see any reason for storing it, I
didn't had need for it in EGP and I used exactly the same techniques
as in the action code.

> My view was length is also a common field. Theres also another reason
> why you want length viewable in a dumb way:
> --> you dont really wanna force people to write dumpers for these
> ematchers (goal: keep this interface as simple as it can be); i.e dont
> need any pretty formater in the kernel.
> If you have a length then you can reconstruct the TCA_EMATCH easily
> without caring about the content. This is the path i started taking in 
> eactions. Refer to my notes i sent earlier on the mythical one page
> ematch/eaction.
> If someone wants funky stuff - write a classifier.

Very simple ematches will only require a struct for configuration
so the dumping is not more than 5 lines of code. The length can be
calculated via RTA_PAYLOAD(ematch_tlv) - sizeof(ematch_hdr). This
of course requires the struct to be aligned to RTA_ALIGN but
that's generally not a problem at all.

I understand your concern but I also want to allow a little bit
more complicated ematches such as KMP or later a very simple
regular expression implementation.

Here's some code from the simple_cmp key of EGP giving a good
idea how a simple ematch will look like:

static int
sc_match(struct egp_cls *cls, struct egp_key *k)
{
       struct egp_key_sc *sc = k->data;
       u32 lvalue = cls->ops->read(cls, &sc->left);
       u32 rvalue = cls->ops->read(cls, &sc->right);

       switch (sc->op) {
#define SC(a, b) case EGP_OP_##a: return b
               SC(NONE, 0);
               SC(EQ, lvalue == rvalue);
               SC(NE, lvalue != rvalue);
               SC(LT, lvalue <  rvalue);
               SC(LE, lvalue <= rvalue);
               SC(GT, lvalue >  rvalue);
               SC(GE, lvalue >= rvalue);
#undef  SC
       }

       BUG();
       return 0;
}

static int
sc_validate(struct egp_config *conf, struct egp_ops *ops, void *d, size_t len)
{
       int err;
       struct egp_key_sc *sc = d;

       if (len != sizeof(*sc) || sc->op > EGP_OP_MAX)
               return -EINVAL;
       return 0;
}

static int
sc_replace(struct egp_cls *cls, struct egp_key *k, void *d, size_t len)
{
       k->data = kmalloc(len, GFP_KERNEL);
       if (NULL == k->data)
               return -ENOBUFS;
       memcpy(k->data, d, len);
       return 0;
}

static int
sc_dump(struct egp_cls *cls, struct sk_buff *skb, struct egp_key *k)
{
       struct egp_key_sc *sc = k->data;
       RTA_PUT(skb, TCA_EGP_KEY_DATA, sizeof(*sc), sc);
       return 0;

rtattr_failure:
       return -1;
}

static void
sc_free_data(struct egp_cls *cls, struct egp_key *k)
{
       if (k->data)
               kfree(k->data);
}

OTOH, on more complex ematches data might be nested TLVs with
optional parameters. etc.

> Stats are the other thing that adds complexity to the API. If you can
> make it optional then that would be best - I was thinking to not even
> have it in.

It's probably enough to allow optional generic hits/success stats
per match.

> I thought we already agreed on the layout:
> SEL2- which may nest E/MATCHEs TLVs. Sel2 not being very different from
> original selector. May be i didnt follow. 

You did follow but I made the existing u32 match a ematch as well.
Things like the program ID goes into the selector header T=1 and
classifier specific selector bits such as the hashing bits goes
into T=2. Thinking of it it's probably cleaner to put things like
hmark, hoff into its own TLV. So the selector TLV contains the
selector header at T=1 and nested ematch TLVs at T=2..T=N.

I think we're mostly in sync so I'll start working on it and
we can review again.
