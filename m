From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC 1/7] netfilter: add socket to struct nft_pktinfo
Date: Tue, 29 Sep 2015 13:25:14 -0500
Message-ID: <87io6tytf9.fsf@x220.int.ebiederm.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
	<1443525140-13493-2-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pablo@netfilter.org, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443525140-13493-2-git-send-email-daniel@zonque.org> (Daniel
	Mack's message of "Tue, 29 Sep 2015 13:12:14 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Mack <daniel@zonque.org> writes:

> The high-level netfilter hook API already enables users to pass a socket,
> but that information is lost when the chains are walked.
>
> In order to let internal eval callbacks use the passed filter rather than
> skb->sk, add a pointer of type 'struct sock' to 'struct nft_pktinfo' and
> set that field via nft_set_pktinfo().
>
> This allows us to run filter chains from situations where skb->sk is unset.
> Fall back to skb->sk in case state->sk is NULL, so filter callbacks can be
> written in a generic way.

A word of caution here, and something I expect needs to be thought
about.  The reason sk is passed through netfilter and some of the other
paths is that there are tunnel cases where there are two sk's in play
and the passed in socket makes it possible to have both sk's available.

I really don't understand all of the details, but they exist in the git
history of the change.

Reading your change description it does not feel as though you are aware
of the subtleties and as such I suspect your code gets something wrong.


The placing of sk as the first word in struct nft_pktinfo is also a
little concerning, as I don't expect it will be as highly used as
the later fields, and everything that is highly used we want to keep
in one cache line if we can.

Eric

> Signed-off-by: Daniel Mack <daniel@zonque.org>
> ---
>  include/net/netfilter/nf_tables.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
> index aa8bee7..05e97ed 100644
> --- a/include/net/netfilter/nf_tables.h
> +++ b/include/net/netfilter/nf_tables.h
> @@ -13,6 +13,7 @@
>  #define NFT_JUMP_STACK_SIZE	16
>  
>  struct nft_pktinfo {
> +	struct sock			*sk;
>  	struct sk_buff			*skb;
>  	const struct net_device		*in;
>  	const struct net_device		*out;
> @@ -29,6 +30,7 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
>  				   struct sk_buff *skb,
>  				   const struct nf_hook_state *state)
>  {
> +	pkt->sk = state->sk ?: skb->sk;
>  	pkt->skb = skb;
>  	pkt->in = pkt->xt.in = state->in;
>  	pkt->out = pkt->xt.out = state->out;
