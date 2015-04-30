From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 02:48:39 +0200
Message-ID: <20150430004839.GG7025@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <55417545.30103@iogearbox.net>
 <20150430003019.GE7025@acer.localdomain>
 <55417A3A.50405@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55417A3A.50405@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.04, Daniel Borkmann wrote:
> On 04/30/2015 02:30 AM, Patrick McHardy wrote:
> >On 30.04, Daniel Borkmann wrote:
> >>>
> >>>I can also see there were also intentions to support userspace
> >>>queueing at some point since TC_ACT_QUEUED has been there since the
> >>>beginning.  That should be possible at some point using this
> >>>infrastructure (once there are no further concerns on the
> >>>netif_receive_core_finish() patch as soon as gcc 4.9 and follow up
> >>>versions keep inlining this new function).
> >>
> >>Wrt the other mail, just thinking out loud ... do you see a longer-term
> >>possibility of further generalizing the gen hooks infrastructure, so that
> >>actually classifier from tc could attach (disregarding the nf_* naming
> >>scheme for now) ...
> >>
> >>     `-> nf_hook_slow()
> >>      `-> [for each entry in hook list]   <-- here as an entry
> >>       `-> nf_iterate()
> >>        `-> (*elemp)->hook()
> >>
> >>... as well?
> >
> >Jumping in there since I'm probably the one thinking the TC ingress
> >abstraction is wrong the strongest - yes, it's an interesting idea.
> >Unlike egress qdiscs, ingress only has a single classifier chain
> >anyways, so there is no qdisc internal classification structure to
> 
> Yes, exactly.
> 
> >be observed. It should be possible to skip the ingress invocation
> >for classification purposes completely and only use it to expose
> >it to userspace for management purposes, while invoking the chain
> >directly.
> 
> That would also meet our goals to only have a single classifier
> chain, eventually. ;)

For TC, yes. What Pablo is trying to achieve (and I agree that it's
worthwhile) is multiple things:

* have people use TC ingress as before, obviously
* have people use netfilter, if they prefer
* have them combine both if for some unfortunate reason they require it

Netfilter is based on hook chains. The cost when only using a single hook
is minimal (as Pablo showed in his numbers), but even if only using
TC and a single netfilter classifier chain, there has to be some relative
ordering and the hooks provide this in a generic way.

So I'm all in favour of reduing costs for single or for multi-hook
cases, but it wouldn't be usable for us anymore when doing away with
multiple hooks completely.

One more point to consider is - this is generic infrastructure - the
next person requiring a hook will not have to touch the ingress path
at all. He can register with the hooks, having zero additional costs
for people not using it.
