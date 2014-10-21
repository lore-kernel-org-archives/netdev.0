From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH] netfilter: Fix wastful cleanup check for unconfirmed conn
 in get_next_corpse
Date: Tue, 21 Oct 2014 21:48:24 +0800
Message-ID: <CA+6hz4pyRzK9fpPjzYWTDHs0whxy6MfT=y-3sg9zTRC07DX1UA@mail.gmail.com>
References: <CA+6hz4ouOLgFwHOM6xeXEaUQpm2xOasDowKLPfZWuG3sAssUvA@mail.gmail.com>
	<CA+6hz4oodWXXyWhcR=Zt4Esf1Riwatvy0xYMhFnQ8CkTaqV=Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+6hz4oodWXXyWhcR=Zt4Esf1Riwatvy0xYMhFnQ8CkTaqV=Pg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry. I get it is not an issue after read the codes again.
The unconfirmed conn list check is only checked once in the current codes.
Because it will be checked only when no matched conntracks found in
function get_next_corpse.

Then I think current codes may confuse the reader. I am an example.
So could my changes be as the enhancement ?

Best Regards
Feng

On Tue, Oct 21, 2014 at 10:47 AM, Feng Gao <gfree.wind@gmail.com> wrote:
> Paste my changes directly instead of the attachment.
>
> Subject: [PATCH 1/1] netfilter: Fix wastful cleanup check for unconfirmed
> conn in get_next_corpse
>
> The function get_next_corpse is used to iterate the conntracks.
> It will check the per cpu unconfirmed list of every cpu too.
> Now it is only invoked by nf_ct_iterate_cleanup in one while loop.
> Actually the unconfirmed list could be accessed completely by one call, then
> the others are wastful.
>
> So move the unconfirmed list check outside the function get_next_corpse and
> create one new function
> Let the nf_ct_iterate_cleanup invokes the new function
> clean_up_unconfirmed_conntracks once after the loops.
>
> Signed-off-by: fgao <gfree.wind@gmail.com>
> ---
>  net/netfilter/nf_conntrack_core.c | 36 ++++++++++++++++++++++++------------
>  1 file changed, 24 insertions(+), 12 deletions(-)
>
> diff --git a/net/netfilter/nf_conntrack_core.c
> b/net/netfilter/nf_conntrack_core.c
> index 5016a69..ace7c2c2 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1348,6 +1348,28 @@ static void nf_conntrack_attach(struct sk_buff *nskb,
> const struct sk_buff *skb)
>   nf_conntrack_get(nskb->nfct);
>  }
>
> +static void clean_up_unconfirmed_conntracks(struct net *net,
> + int (*iter)(struct nf_conn *i, void *data),
> + void *data)
> +{
> + struct nf_conntrack_tuple_hash *h;
> + struct nf_conn *ct;
> + struct hlist_nulls_node *n;
> + int cpu;
> +
> + for_each_possible_cpu(cpu) {
> + struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
> +
> + spin_lock_bh(&pcpu->lock);
> + hlist_nulls_for_each_entry(h, n, &pcpu->unconfirmed, hnnode) {
> + ct = nf_ct_tuplehash_to_ctrack(h);
> + if (iter(ct, data))
> + set_bit(IPS_DYING_BIT, &ct->status);
> + }
> + spin_unlock_bh(&pcpu->lock);
> + }
> +}
> +
>  /* Bring out ya dead! */
>  static struct nf_conn *
>  get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void
> *data),
> @@ -1356,7 +1378,6 @@ get_next_corpse(struct net *net, int (*iter)(struct
> nf_conn *i, void *data),
>   struct nf_conntrack_tuple_hash *h;
>   struct nf_conn *ct;
>   struct hlist_nulls_node *n;
> - int cpu;
>   spinlock_t *lockp;
>
>   for (; *bucket < net->ct.htable_size; (*bucket)++) {
> @@ -1376,17 +1397,6 @@ get_next_corpse(struct net *net, int (*iter)(struct
> nf_conn *i, void *data),
>   local_bh_enable();
>   }
>
> - for_each_possible_cpu(cpu) {
> - struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
> -
> - spin_lock_bh(&pcpu->lock);
> - hlist_nulls_for_each_entry(h, n, &pcpu->unconfirmed, hnnode) {
> - ct = nf_ct_tuplehash_to_ctrack(h);
> - if (iter(ct, data))
> - set_bit(IPS_DYING_BIT, &ct->status);
> - }
> - spin_unlock_bh(&pcpu->lock);
> - }
>   return NULL;
>  found:
>   atomic_inc(&ct->ct_general.use);
> @@ -1411,6 +1421,8 @@ void nf_ct_iterate_cleanup(struct net *net,
>
>   nf_ct_put(ct);
>   }
> +
> + clean_up_unconfirmed_conntracks(net, iter, data);
>  }
>  EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup);
>
> --
> 1.9.1
>
>
> On Tue, Oct 21, 2014 at 8:31 AM, Feng Gao <gfree.wind@gmail.com> wrote:
>>
>> Hi all,
>>
>> I am sorry to send the patch commit again because the last email is
>> not plain text and is rejected by some servers.
>>
>> This is the patch to branch master of kernel.
>>
>> The function get_next_corpse is only invoked by nf_ct_iterate_cleanup
>> in one while loop, and it will check the per cpu unconfirmed conntrack
>> list every time.
>>
>> I think the whole list of unconfirmed conntracks could be accessed by
>> one call, so the others are not necessary.
>>
>> So I move the checks outside the get_next_corpse, and create one new
>> function clean_up_unconfirmed_conntracks.
>> Let the nf_ct_iterate_cleanup invokes the
>> clean_up_unconfirmed_conntracks after the while loop.
>>
>> These codes have already exist for a long time. Firstly I think maybe
>> there is some reason, but I fail to get it.
>>
>>
>> Best Regards
>> Feng
>
>
