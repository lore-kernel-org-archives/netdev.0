From: Patrick McHardy <kaber@trash.net>
Subject: Re: nft 0.4, crash on list
Date: Sun, 22 Mar 2015 19:29:45 +0000
Message-ID: <20150322192944.GO7910@acer.localdomain>
References: <fded527361344541342afa2478b5ca9a@visp.net.lb>
 <74645ce188ee403b5ffcf2303046f694@visp.net.lb>
 <a457f2eac526c6fe6e6f80634358d587@visp.net.lb>
 <20150322053313.GA16931@acer.localdomain>
 <d029673de6d7994d231a4a37df763951@visp.net.lb>
 <20150322192900.GA14885@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
	Netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	stable@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150322192900.GA14885@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.03, Pablo Neira Ayuso wrote:
> On Sun, Mar 22, 2015 at 10:05:10AM +0200, Denys Fedoryshchenko wrote:
> > On 2015-03-22 07:33, Patrick McHardy wrote:
> > >On 22.03, Denys Fedoryshchenko wrote:
> > >>Sorry for noise, seems git version working fine!
> > >
> > >Still this shouldn't be happening. Just to confirm, you were using an
> > >unpatched kernel and by git you mean nftables git?
> >
> > Yes, correct. I tested on 3.18.8 and 3.19.2 vanilla kernels (x86_64).
> > On nftables 0.4 it does crash, on nftables git it doesn't.
> 
> I sent this fix to -stable by March 10th but this doesn't show up in
> 3.18.x and 3.19.x yet.
> 
> [ upstream commit 02263db00b6cb98701332aa257c07ca549c2324b ]

I think this is actually a different problem. We're using set->dtype
for uninit of the element's data, but unless it's NFT_DATA_VERDICT,
its holding the user encoding of the type.

Basically all the types except NFT_DATA_RESERVED_MASK map to
NFT_DATA_VALUE, and it seems we're not properly handling it in
that path.

> 
> We have several problems in this path:
> 
> 1) There is a use-after-free when removing individual elements from
>    the commit path.
> 
> 2) We have to uninit() the data part of the element from the abort
>    path to avoid a chain refcount leak.
> 
> 3) We have to check for set->flags to see if there's a mapping,
> instead
>    of the element flags.
> 
> 4) We have to check for !(flags & NFT_SET_ELEM_INTERVAL_END) to skip
>    elements that are part of the interval that have no data part, so
>    they don't need to be uninit().
> 
> Cc: <stable@vger.kernel.org> # 3.18.x
> Cc: <stable@vger.kernel.org> # 3.19.x
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> > >>On 2015-03-22 00:49, Denys Fedoryshchenko wrote:
> > >>>Additionally, if i will do "nft flush table mangle" , with this table
> > >>>added i will get this:
> > >>>[   42.800078] ------------[ cut here ]------------
> > >>>[   42.800092] WARNING: CPU: 3 PID: 2868 at
> > >>>net/netfilter/nf_tables_api.c:4122 nft_data_uninit+0x35/0x50
> > >>>[nf_tables]()
> 
