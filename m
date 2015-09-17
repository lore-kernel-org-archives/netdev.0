From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH RFC 0/3] Allow postponed netfilter handling for socket
 matches
Date: Thu, 17 Sep 2015 12:04:31 +0200
Message-ID: <55FA902F.50006@zonque.org>
References: <1442418180-14322-1-git-send-email-daniel@zonque.org>
 <20150916212100.GT24810@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: pablo@netfilter.org, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	balazs.scheidler@balabit.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150916212100.GT24810@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On 09/16/2015 11:21 PM, Florian Westphal wrote:
> Daniel Mack <daniel@zonque.org> wrote:
>> I'm re-addressing the issue of matching socket meta information for
>> non-established sockets that has been discussed a while ago:
>>
>>   http://article.gmane.org/gmane.comp.security.firewalls.netfilter.devel/56877
>>
>> Being able to reliably match on net_cls cgroup ids is crucial in
>> order to build a per-application or per-container firewall rules
>> which don't leak ingress packets. Such a feature would be very
>> useful to have.
> 
> Could you clarify what 'which don't leak ingress packets' means?

Well, currently, the existing cgroups matches only filter packets that
are sent to an established socket. All other packets are ignored. So
when users install such matches as advertised by the documented
examples, and the chain policy is permissive, the firewall 'leaks'
packets, which is unexpected.

>> The patch set is obviously not yet finished, because a lot more
>> protocol handlers need to be patched. Right now, I only addressed
>> tcp_ipv4. Before I do that, I want to get some feedback on the
>> approach, so please let me know what you think.
> 
> I think there are several issues.
> 
> implementation problems:
> - i'm not sure its legal to call the hook input with skb->sk locked,
>   some matches might want to aquire it.

In the code as it stands after my patch set, I don't see where skb->sk
is locked? After all, skb->sk is NULL, even on the 2nd iteration, which
is why I patched the newly looked up socket to be available in the nf hook.

> - what makes NFT_META_CGROUP special? (or was that just an example?)

It's what I want to get working, but other 'meta' hooks can be made
working in a similar fashion.

> design issues:
> The assumption seems to be that a given skb can always be mapped to a
> particular socket, and hence a cgroup.
>
> Thats not necessarily the case, e.g. with broad-/multicasting or when
> the socket is e.g. in timewait state.

Yes, that's true. The idea for multicast would be to just drop the
cloned skb instead of delivering it to the final socket.

> Some skbs will now travel INPUT hooks twice.
>
> And once you'd extend this so that we re-invoke nf hooks for mcast
> packets, for each socket they've been received on, you change netfilter
> behaviour again (one skb, one traversal -> n traversals of ruleset, one
> for each sk).
> 
> I think that this makes it a non-starter, sorry.

Hmm, I see your point.

> I would much rather see nft_demux_{udp,tcp,sctp,dccp,...}.c which moves
> early-demux-esque code into the nft ruleset.
> 
> Then you could do something like
> 
> nft add rule ip filter input meta l4proto tcp demux meta cgroup 42

Ok, but how would that be different from the unconditional demuxing
patches we've kicked around earlier, especially when it comes to
multicast sockets? Could you explain what you have in mind here?

> The caveat being that even in this case we cannot guarantee
> that skb->sk is set afterwards, or that a cgroup can be derived from it.
> 
> Iff you absolutely need this, I'd seriously entertain the idea of adding
> NFPROTO_L4_TCP, etc, ... or, maybe better, allow to attach nft ruleset
> as a socket filter.

That would be a new netfilter hook then, something that is called after
LOCAL_IN, for ingress only? In a sense, it would be called from the
protocol handlers, just as my patches do right now, but instead of
conditionally re-iterating the same rules again, we would walk a
different chain?

> But really, at that point, a much better question would be wheter net
> cgroups are the answer to whatever the question was, or what problem we
> are attempting to address here...

The idea is simply to have a packet filter which is based on information
derived from the task that sends or will eventually handle the packet.
IOW: We want to be able to install netfilter rules that apply to all
packets received or sent by tasks that match a certain criteria, without
modifying the sources of those tasks.

As we already have net_cls hooked up in netfilter rules, it seems
easiest to just get this working. But with the multiple approaches we
already had, it appears the real fix needs more thinking.


Thanks,
Daniel
