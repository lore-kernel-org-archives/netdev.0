From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network namespaces
Date: Wed, 17 Jun 2015 15:55:25 -0500
Message-ID: <87wpz25a2q.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1506172216440.2649@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1506172216440.2649@ja.home.ssi.bg> (Julian
	Anastasov's message of "Wed, 17 Jun 2015 22:38:26 +0300 (EEST)")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Sun, 14 Jun 2015, Eric W. Biederman wrote:
>
>> This patshset roots out all of the very weird network namespace
>> computation logic (except for the code in ipvs) and fixes it.  I really
>> don't like how the code has been essentially guessing  which network
>> namespace to use.
>> 
>> Probably the worst guessing is in ipvs in the function skb_net. I have
>> some preliminary changes to fix ipvs but they are not quite ready yet.
>> Cleaning up ipvs enough that I can kill skb_net is on my short list.
>
> 	For IPVS skb_net is too complicated. One of
> the first things we do in hook handler is to check
> skb_dst, so even now dev_net(skb_dst(skb)->dev) should
> work.

A couple of things:
- You don't check skb_dst() first thing in all hooks.

- All hooks have state->net after my changes so it gets
  a lot easier.

- I am trying to avoid dev_net(skb_dst(skb)->dev) if I can
  because of my ulterior motive of allowing a destination
  network device in another network namespace.

>  sock_net is used for administration via netlink,
> skb_net is not used there (ip_vs_ctl.c).

Agreed.  sock_net is the right thing for the netlink sockets,
and while obscured by skb_sknet that works fine.

> 	As for removing/replacing skb_net, ip_vs_conn_net()
> is ok when cp is present,

Yes I have seen that.

> we have also svc->net,

And I have seen this.

>  otherwise
> we can store net into struct ip_vs_iphdr, it is filled by
> ip_vs_fill_iph_skb from small number of places when hook
> handler is entered.

Interesting I had not thought of changing ip_vs_iphdr.

I actually have a patch that passes state->net down to where it is
needed or uses ip_vs_conn_net() and it it looks ok, but the patch
is so busy with small tweaks that I need to break it up.

Further I am staring at things and trying to see if there is a way to
make the mass of parameters more readable/obvious.   Something like
the passing of struct nf_hook_state into the netfilter hooks.

Or in other words I want to make the change to ip_vs deadly boring,
obviously correct, and trivial to maintain, and I am not quite there
yet.

Eric

p.s.  I do have my patch that I can toss in your direction if you are
interested.
