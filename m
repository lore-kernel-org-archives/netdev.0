From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] net/core: Fix BUG to BUG_ON conditionals.
Date: Mon, 9 Oct 2017 16:23:57 -0700
Message-ID: <20171009232355.5mcd3fj7gjhenv25@ast-mbp>
References: <20171009153759.km3lqss7hb72wrze@debian>
 <20171009171540.lgmk2slq3bdrptxk@ast-mbp.dhcp.thefacebook.com>
 <20171009202633.ep5pbi2tlg7dqidz@sasha-lappy>
 <20171009230618.e5gla2iuqwmndkig@ast-mbp>
 <20171009231538.doypjzvxzkoxyoeo@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tim Hansen <devtimhansen@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "willemb@google.com" <willemb@google.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "soheil@google.com" <soheil@google.com>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "tom@quantonium.net" <tom@quantonium.net>,
        "Jason@zx2c4.com" <Jason@zx2c4.com>, "fw@strlen.de" <fw@strlen.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171009231538.doypjzvxzkoxyoeo@sasha-lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 11:15:40PM +0000, Levin, Alexander (Sasha Levin) wrote:
> On Mon, Oct 09, 2017 at 04:06:20PM -0700, Alexei Starovoitov wrote:
> >On Mon, Oct 09, 2017 at 08:26:34PM +0000, Levin, Alexander (Sasha Levin) wrote:
> >> On Mon, Oct 09, 2017 at 10:15:42AM -0700, Alexei Starovoitov wrote:
> >> >On Mon, Oct 09, 2017 at 11:37:59AM -0400, Tim Hansen wrote:
> >> >> Fix BUG() calls to use BUG_ON(conditional) macros.
> >> >>
> >> >> This was found using make coccicheck M=net/core on linux next
> >> >> tag next-2017092
> >> >>
> >> >> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
> >> >> ---
> >> >>  net/core/skbuff.c | 15 ++++++---------
> >> >>  1 file changed, 6 insertions(+), 9 deletions(-)
> >> >>
> >> >> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> >> >> index d98c2e3ce2bf..34ce4c1a0f3c 100644
> >> >> --- a/net/core/skbuff.c
> >> >> +++ b/net/core/skbuff.c
> >> >> @@ -1350,8 +1350,7 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
> >> >>  	/* Set the tail pointer and length */
> >> >>  	skb_put(n, skb->len);
> >> >>
> >> >> -	if (skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len))
> >> >> -		BUG();
> >> >> +	BUG_ON(skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len));
> >> >
> >> >I'm concerned with this change.
> >> >1. Calling non-trivial bit of code inside the macro is a poor coding style (imo)
> >> >2. BUG_ON != BUG. Some archs like mips and ppc have HAVE_ARCH_BUG_ON and implementation
> >> >of BUG and BUG_ON look quite different.
> >>
> >> For these archs, wouldn't it then be more efficient to use BUG_ON rather than BUG()?
> >
> >why more efficient? any data to prove that?
> 
> Just guessing.
> 
> Either way, is there a particular reason for not using BUG_ON() here
> besides that it's implementation is "quite different"?
> 
> >I'm pointing that the change is not equivalent and
> >this code has been around forever (pre-git days), so I see
> >no reason to risk changing it.
> 
> Do you know that BUG_ON() is broken on any archs?
> 
> If not, "this code has been around forever" is really not an excuse to
> not touch code.
> 
> If BUG_ON() behavior is broken somewhere, then it needs to get fixed.

no idea whether it's broken. My main objection is #1.
imo it's a very poor coding style to put functions with
side-effects into macros. Especially debug/bug/warn-like.
For example llvm has DEBUG() macro and everything inside
will disappear depending on compilation flags.
I wouldn't be surprised if somebody for the name
of security (to avoid crash on BUG_ON) will replace
BUG/BUG_ON with some other implementation or nop
and will have real bugs, since skb_copy_bits() is somehow
not called or called in different context.
