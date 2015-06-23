From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] netfilter: nf_queue: Don't recompute the hook_list head
Date: Tue, 23 Jun 2015 11:23:09 -0500
Message-ID: <87egl2z95e.fsf@x220.int.ebiederm.org>
References: <87381ne3rq.fsf@x220.int.ebiederm.org>
	<20150620105839.GB3439@salvia> <877fqya2wb.fsf@x220.int.ebiederm.org>
	<20150620185353.GA3567@salvia> <87fv5j7pwa.fsf@x220.int.ebiederm.org>
	<20150623161709.GA3752@salvia>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150623161709.GA3752@salvia> (Pablo Neira Ayuso's message of
	"Tue, 23 Jun 2015 18:17:10 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> On Mon, Jun 22, 2015 at 09:56:37AM -0500, Eric W. Biederman wrote:
>> Pablo Neira Ayuso <pablo@netfilter.org> writes:
> [...]
>> > There is no nfnetlink_queue support for the netdev family at this
>> > moment, so this can't be triggered unless you use an out of tree
>> > module.
>> >
>> > I have a patch here to add a static key to disable userspace queueing
>> > per family using a static key so that part would be basically
>> > inactive.
>> >
>> > But if you really want to see this in 4.1, no problem, please just let
>> > me know and I'll pass it to David, as I said it's basically not
>> > resolving any urgent problem so this is not harming.
>>
>> So I have read through the code and I simply do not see anywhere
>> that would prevent code in nft_queue to be called on a per netdevice
>> chain, or where in nfqnl_enqueue_packet we would decided not to queue
>> the packet.
>>
>> Could you please point me to what in the code makes this code path
>> impossible to use?
>
> int nf_queue(struct sk_buff *skb,
>              struct nf_hook_ops *elem,
>              struct nf_hook_state *state,
>              unsigned int queuenum)
> {
>         const struct nf_afinfo *afinfo;
>         ...
>
>         afinfo = nf_get_afinfo(state->pf);
>         if (!afinfo)
>                 goto err_unlock;
>
>         ...
> }
>
> There is no afinfo for NFPROTO_NETDEV, so the packet the packet will
> be dropped.
>
> Therefore, there is no way nf_reinject() can be called neither for
> bridge, arp, inet and netdev at this moment.
>
> I have a patch here to restrict this easily in nft_queue so the user
> knows this can't be used at configuration time.

Subtle but it I see it now.  Thank you.

With only nf_register_afinfo calls for ipv4 and ipv6 present in the
kernel it is clear that we can not run into trouble in the nedev ingress
path, and so my fix clearly does not need to be backported.

Eric

