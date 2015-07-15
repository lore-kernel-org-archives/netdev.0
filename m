From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -next 0/6] Per network namespace netfilter chains
Date: Wed, 15 Jul 2015 19:20:38 +0200
Message-ID: <20150715172038.GA4319@salvia>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
 <87r3pae5hn.fsf@x220.int.ebiederm.org>
 <878uansj4d.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <878uansj4d.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 10, 2015 at 06:11:46PM -0500, Eric W. Biederman wrote:
> 
> By maintining a set of functions to register and unregister netfilter
> hooks both globally and per network namespace I have managed to write a
> compact patchset that maintain per network netfilter chains, and
> registers the nftables netfilter hooks per network namespace.

Nice, thank you.

It would be great to convert this to the for_each_net_rcu variant once
we're sure this is safe.

> There are lots of other possible and desirable cleanups but this one is
> a core change needed to make the other changes independent small
> changes.

The state->net field will kill that dev_net(...) ? x : y; all over the
code, that would be nice.

Some comments on your patchset:

* 1/6 netfilter: nf_queue: Don't recompute the hook_list head

I already passed this to current nf as you insisted on getting this,
and for the sake of correctness, so it's basically already in David's
net tree.

* From 2 to 6, I have applied these series with small coding style
  cleanups.

- Add line break between variable declaration and body:

 +      struct list_head *nf_hook_list = &nf_hooks[pf][hook];
-+
 +      if (nf_hook_list_active(nf_hook_list, pf, hook)) {

and here:

 int nft_register_basechain(struct nft_base_chain *basechain,
                           unsigned int hook_nops)
  {
 +      struct net *net = read_pnet(&basechain->pnet);
++

- Get rid of unnecessary parens:

-+      if ((reg->pf == NFPROTO_NETDEV) && (reg->hooknum == NF_NETDEV_INGRESS))
++      if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)

- Get rid of unnecesary brackets:

-+      for_each_net(net) {
++      for_each_net(net)
 +              nf_unregister_net_hook(net, reg);
-+      }

and here:

-+      list_for_each_entry_continue_reverse(elem, &nf_hook_list, list) {
++      list_for_each_entry_continue_reverse(elem, &nf_hook_list, list)
 +              nf_unregister_net_hook(net, elem);
-+      }

I have pushed this to:

http://git.kernel.org/cgit/linux/kernel/git/pablo/nf-next.git/log/?h=pending

in case you want to have a closer look. Thank you.
