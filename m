From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Fri, 31 Dec 2004 19:11:53 +0100
Message-ID: <20041231181153.GP32419@postel.suug.ch>
References: <20041229124842.GI32419@postel.suug.ch> <1104330054.1089.329.camel@jzny.localdomain> <20041229150140.GJ32419@postel.suug.ch> <1104335620.1025.22.camel@jzny.localdomain> <20041230174313.GB32419@postel.suug.ch> <1104469111.1049.219.camel@jzny.localdomain> <20041231110836.GD32419@postel.suug.ch> <1104505142.1048.262.camel@jzny.localdomain> <20041231153930.GN32419@postel.suug.ch> <1104511494.1048.303.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104514372.1047.326.camel@jzny.localdomain> <1104511494.1048.303.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104511494.1048.303.camel@jzny.localdomain> 2004-12-31 11:44
> We may be talking about different things - please double check.
> The misunderstanding seems to be on scoping: PID is global and 
> the opaque ID is per match.
> IOW, theres a hierachy: 
> A program(such as tc) installs a filter rule - we need to be able to
> identify the program - this is the PID. Unique across all Linux.
> A filter rule constitutes one or more matches. Different programs may
> install different u32 rules. For most users its a single program - tc.
> Each program that installs a rule will need to be identified by the PID.
> Main purpose is so that it can decode what the second level number
> means. This second level number is what i said was opaque. Its meaning
> is per app. 
> So as an example PID 0x10 identifies application tc and opaque code
> 0x20 for tc translates to mean "thats an ip match, so no need to dump
> raw data - just dump it in english using ip_print()".
> 0x10 belongs to the selector; 0x20 is per match. 0x21 could mean "this
> is a TCP match with options" etc
> The ematches on the hand are purely decodable via user space without
> needing the opaque numbers - the kind/type serves these just fine.

Agreed I just don't get the reason for the PID. tc is usually called as
a new process instance when dumping. For me there are two possible
options, we can either introduce a ID system where an ID is assigned
to a match string in either a config file or a header file or we can
have tc write id -> desc maps to a global file somewhere where id
means match id + u32 handle + parent + dev. The first is probably
the better way. We could extend the match header to 64bit:

u16 handle
u16 matchID
u16 kind
u8 flags
u8 pad

> Its a non-trivial problem. Its ok to defer it for now but keep it in the
> back of your mind. 

Agreed.

* jamal <1104514372.1047.326.camel@jzny.localdomain> 2004-12-31 12:32
> One thing i just remembered: You need to know the length of the matches
> and their data in order to store them. This is why i was earlier
> preaching putting them in TLVs. Some things dont need the datalen
> like u32 - however i suspect most will.

It might not have been obvious, but every match is indeed in its
own TLV. The part I don't want to use own TLVs is to separate the
match header and match data. Match header is always the same size
and match data can be aligned as well. We need len attributes for
things like meta indev match, nbyte and kmp though. A Nbyte config
TLV would look like:

TCA_EMATCH
+-------------------------+
| struct tcf_ematch_hdr   |
| - - - - - - - - - - - --|
| ematch data             |
+-------------------------+

where ematch data contains nested TLVs such as

TCA_EMATCH_NBYTE_HDR     header, contains length of pattern + possibily more
TCA_EMATCH_NBYTE_START   lower limit of searching range (offset)
TCA_EMATCH_NBYTE_END     upper limit of searching range (offset)
TCA_EMATCH_NBYTE_PATTERN searching pattern, u8 []

The length in the header is required because we can't use
L from TCA_EMATCH_NBYTE_PATTERN since it might be padded.

Same would go for meta:

TCA_EMATCH_META_HDR
TCA_EMATCH_META_LVALUE
TCA_EMATCH_MEtA_RVALUE

If needed we can put in match specific stats via a _STATS TLV.

> So either need a length somewhere in the header or use TLVs for the
> ematches in which you can make T=kind - still have 32 bit inside body
> but reserve bits not used for flags for future use. Thoughts?.

I thought about the following ordering in the selctor TLV:

 T=1 generic selector header
 T=2 classifier specific selector header (u32 hashsing stuff goes here)
 T=3 ematch 1
 T=N ematch N

> BTW, for deleting - should not allow deleting one of N matches. Deletion
> should be at selector level. Replace can be used to pretend a single
> match was deleted.

Agreed.
