From: jamal <hadi@cyberus.ca>
Subject: Re: Billing 3: WAS(Re: [PATCH 2/4] deferred drop,
	__parent	workaround, reshape_fail , netdev@oss.sgi.com ,
Date: 25 Aug 2004 07:34:33 -0400
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <1093433673.1040.147.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	<1092401484.1043.30.camel@jzny.localdomain>
	<20040816072032.GH15418@sunbeam2>
	<1092661235.2874.71.camel@jzny.localdomain>
	<4120D068.2040608@crocetta.org>
	<1092743526.1038.47.camel@jzny.localdomain>
	<41220AEA.20409@crocetta.org>
	<1093191124.1043.206.camel@jzny.localdomain>
	<4129BB3A.9000007@crocetta.org>
	<1093262296.1040.778.camel@jzny.localdomain>
	<4129E2A2.2050500@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz,
	netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <4129E2A2.2050500@crocetta.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


On Mon, 2004-08-23 at 08:27, sandr8 wrote:
> jamal wrote:
> 
> >Let me layout a few things:
> >
> >    ..-->classification --> tcaction
> >return code1 --> enqueue
> >return code2 ...(packet may be freed here)--> dev.c
> >
> >The rules are:

[..]
> >
> i don't know the code that does that, since afaik it
> was not yet there in 2.6.8... if it is, please tell me
> because i'm eager to have a full viewpoint of the
> forthcoming packet action framework :)

Look at the policer as an example - already in the kernel. It may decide
to shoot a packet.
The framework is already in since pre-2.6.8. My goal was to wait and
have it stabilize i.e no complaints and then start sending
patches for new actions. I can send you a few if you want to scrutinize
(although to understand the rules posted you dont need to see the
patches)

> >Again as  above shows, billing would work better at the qdisc level.
> >  
> >
> yes, sure...
> but for the moment i personally don't know which path
> STOLEN and QUEUED packets will follow... it's not
> a reproach :) it's just that i simply can't know for the
> moment, but i don't want to make you hurry, i perfectly
> understand that you've got plenty of things to do :)
> 

Let me know if you want me to send you an action or two ;->


> >
> >Linux is being efficient by sharing skbs. One of the most expensive
> >things in a stack is copying packets around (which is avoided).
> >If this was a simple system where allocating and freeing can be mapped
> >to exactly a flow then what you suggest can be done. In Linux you cant.
> >
> >  
> >
> in that patch i was not copying them... just passing them by reference 
> through a
> "struct sk_buff ** const skb" parameter.
> 
> what is the difference from before...?
> 
> calling:
> before) when calling we passed a pointer on the stack.
> now) when calling we pass a pointer on the stack
> 
> returning:
> before) when returning we didn't tell the caller which
> packet was dropped
> now) when returning we tell the sender which packet
> is not queued or is thrown away from our queue to
> make place for the packet enqueued.

The issue i had was two fold:
1) If you plan is to change things in the skb you have to
remember that you must copy or clone them (because you dont know who
else is holding references to the skb and for what purpose)
in which case the skb you manipulate is different from the one you
passed.
i.e no need to pass the reference to achieve that
2) You are making a lot of changes to pass **skb
in order to achieve your goal which doesnt seem strong to begin with.

> what happens on the stack now?
> 
> for the calling: more or less the same as before :)
> for the returning...
> 
> 1) the external pointer is const, cannot be changed. this
> is good to avoid stupid bugs.
> 2) being the external pointer const, the internal one always
> lays in the stack frame of the outmost caller of an enqueue
> operation. hust the external one is passed to callees. when
> a requeue operation is called, that pointer nevertheless stays
> in the stack frame of the outmost caller of an enqueue
> operation. that's to say: it never moves from the stack of the
> caller of dev->qdisc->enqueue()... [in that case it was dev.c,
> but maybe it would be nicer to have it in a sort of
> dev->enqueue() that would have to do with device level
> conntracking].
> 
> additional cost for the function calling? z-e-r-o !!! :)
> performance issues? maybe some improvement due
> to the elimination of many internal jumps and conditions.
> 
> furthermore, telling the caller the packet that we chose to
> drop allows it to reshape it without the need for every
> qdisc to recur too any callback function.

I didnt quiet parse what you said above - we may be saying the same
thing again. Did my last email (where we seem to sync) cover this?

cheers,
jamal
