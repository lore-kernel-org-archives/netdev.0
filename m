From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 31 Dec 2004 15:51:51 -0500
Message-ID: <1104526311.1047.379.camel@jzny.localdomain>
References: <20041229124842.GI32419@postel.suug.ch>
	 <1104330054.1089.329.camel@jzny.localdomain>
	 <20041229150140.GJ32419@postel.suug.ch>
	 <1104335620.1025.22.camel@jzny.localdomain>
	 <20041230174313.GB32419@postel.suug.ch>
	 <1104469111.1049.219.camel@jzny.localdomain>
	 <20041231110836.GD32419@postel.suug.ch>
	 <1104505142.1048.262.camel@jzny.localdomain>
	 <20041231153930.GN32419@postel.suug.ch>
	 <1104511494.1048.303.camel@jzny.localdomain>
	 <20041231181153.GP32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041231181153.GP32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-31 at 13:11, Thomas Graf wrote:
> * jamal <1104511494.1048.303.camel@jzny.localdomain> 2004-12-31 11:44

> Agreed I just don't get the reason for the PID. tc is usually called as
> a new process instance when dumping. 

Indeed. A new instance of tc should be able to delete or understand
what an old instance with different process ID installed.
The P in pid here stands for "program" not "process". Looking at it from
another angle it is the "owner" of that rule.
I gave an example of routes as a comparison:

Example:
[root@jzny root]# ip r ls
10.1.0.25 via 10.0.0.90 dev eth0  proto zebra 
10.0.0.0/24 dev eth0  proto kernel  scope link  src 10.0.0.9 
127.0.0.0/8 dev lo  scope link 
default via 10.0.0.1 dev eth0 
[root@jzny root]# 

See the "proto" field? Same logic - if tc installed those rules
that should read "tc". Same thinking for new u32 display with sel2.
More impaortantly though: 
If the u32 rule was installed by tc, then it can understand what the
code/opaqueid _in the match_ means. If i knew how tc used those opaque
values then i too in my program could intepret them when i dump even
though i didnt install the rule.
 
>  For me there are two possible
> options, we can either introduce a ID system where an ID is assigned
> to a match string in either a config file or a header file or we can
> have tc write id -> desc maps to a global file somewhere where id
> means match id + u32 handle + parent + dev. The first is probably
> the better way. We could extend the match header to 64bit:
> 
> u16 handle
> u16 matchID
> u16 kind
> u8 flags
> u8 pad


We need to know who installed the rule so we can intepret what the ID in
the match is.
Unless you see a desire that, in order to understand all this, we need
to also know on which device and which parent adds towards reaching that
goal then I am afraid this will overcomplicate things. Theres probably
other things you could gain from as well by having all those fields; you
dont need them for this simple case.

> > Its a non-trivial problem. Its ok to defer it for now but keep it in the
> > back of your mind. 
> 
> Agreed.

Lets review at a future date though.
 
> * jamal <1104514372.1047.326.camel@jzny.localdomain> 2004-12-31 12:32
> > One thing i just remembered: You need to know the length of the matches
> > and their data in order to store them. This is why i was earlier
> > preaching putting them in TLVs. Some things dont need the datalen
> > like u32 - however i suspect most will.
> 
> It might not have been obvious, but every match is indeed in its
> own TLV.

Ok, cool.  To recall:

>   TLV (TCA_U32_SEL2)
>   +-------------------+
>   | Selector header   |
>   +-------------------+
>   | Match 1 TLV       |
>   +-------------------+
>   | ...               |
>   +-------------------+
>   | Match N TLV       |
>   +-------------------+

You may actually need those Ts enumerated as if they are array
indices. Look at the way i transfer actions using "order"

> The part I don't want to use own TLVs is to separate the
> match header and match data. Match header is always the same size
> and match data can be aligned as well. We need len attributes for
> things like meta indev match, nbyte and kmp though. A Nbyte config
> TLV would look like:
> 
> TCA_EMATCH
> +-------------------------+
> | struct tcf_ematch_hdr   |
> | - - - - - - - - - - - --|
> | ematch data             |
> +-------------------------+

I was more worried about the matches not being TLVs.
So this looks good.

> where ematch data contains nested TLVs such as
> 
> TCA_EMATCH_NBYTE_HDR     header, contains length of pattern + possibily more
> TCA_EMATCH_NBYTE_START   lower limit of searching range (offset)
> TCA_EMATCH_NBYTE_END     upper limit of searching range (offset)
> TCA_EMATCH_NBYTE_PATTERN searching pattern, u8 []
> 
> The length in the header is required because we can't use
> L from TCA_EMATCH_NBYTE_PATTERN since it might be padded.
> 

My view was length is also a common field. Theres also another reason
why you want length viewable in a dumb way:
--> you dont really wanna force people to write dumpers for these
ematchers (goal: keep this interface as simple as it can be); i.e dont
need any pretty formater in the kernel.
If you have a length then you can reconstruct the TCA_EMATCH easily
without caring about the content. This is the path i started taking in 
eactions. Refer to my notes i sent earlier on the mythical one page
ematch/eaction.
If someone wants funky stuff - write a classifier.

> Same would go for meta:
> 
> TCA_EMATCH_META_HDR
> TCA_EMATCH_META_LVALUE
> TCA_EMATCH_MEtA_RVALUE
> 
> If needed we can put in match specific stats via a _STATS TLV.

Stats are the other thing that adds complexity to the API. If you can
make it optional then that would be best - I was thinking to not even
have it in.

> > So either need a length somewhere in the header or use TLVs for the
> > ematches in which you can make T=kind - still have 32 bit inside body
> > but reserve bits not used for flags for future use. Thoughts?.
> 
> I thought about the following ordering in the selctor TLV:
> 
>  T=1 generic selector header
>
>  T=2 classifier specific selector header (u32 hashsing stuff goes here)
>  T=3 ematch 1
>  T=N ematch N

I thought we already agreed on the layout:
SEL2- which may nest E/MATCHEs TLVs. Sel2 not being very different from
original selector. May be i didnt follow. 

cheers,
jamal
