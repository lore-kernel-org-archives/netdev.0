From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to
	kernel
Date: Mon, 23 Sep 2013 14:17:50 -0700
Message-ID: <CAEP_g=969qq6EAmo3mkaJP+tzqHQ9AUHje9j31CpzfD3RoRPaA@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
	<1378711207-29890-8-git-send-email-horms@verge.net.au>
	<CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
	<20130919155732.GC24919@verge.net.au>
	<CAEP_g=_Eds_XvPLUOhAAMZbxkzmBJEtSR9vVG2kkuRLehrfbDg@mail.gmail.com>
	<20130922053156.GA4849@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130922053156.GA4849-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 21, 2013 at 10:34 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> On Thu, Sep 19, 2013 at 12:21:33PM -0500, Jesse Gross wrote:
>> On Thu, Sep 19, 2013 at 10:57 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> > On Mon, Sep 16, 2013 at 03:38:21PM -0500, Jesse Gross wrote:
>> >> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> >> > @@ -616,6 +736,13 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
>> >> >                 goto out_loop;
>> >> >         }
>> >> >
>> >> > +       /* Needed to initialise inner protocol on kernels older
>> >> > +        * than v3.11 where skb->inner_protocol is not present
>> >> > +        * and compatibility code uses the OVS_CB(skb) to store
>> >> > +        * the inner protocol.
>> >> > +        */
>> >> > +       ovs_skb_set_inner_protocol(skb, skb->protocol);
>> >>
>> >> The comment makes it sound like this code should just be deleted when
>> >> upstreaming. However, I believe that we still need to initialize this
>> >> field, right? Is this the best place do it or should it be conditional
>> >> on adding a first MPLS header? (i.e. what happens if inner_protocol is
>> >> already set and the packet simply passes through OVS?)
>> >
>> > I believe there are several problems here.
>> >
>> > The first one, which my comment was written around is that I think that if
>> > inner_protocol is a field of struct sk_buff then we can rely on it already
>> > being initialised.  However, if we are using compatibility code, where
>> > inner_protcol is called in the callback field of struct sk_buff then I
>> > think that OVS needs to initialise it.
>>
>> I'm not sure that it's true that inner_protocol is already initialized
>> - I grepped the tree and the only assignment that I found is in
>> skbuff.c in __copy_skb_header().
>
> My assumption was that it would be initialised to zero,
> primarily due to the behaviour of __alloc_skb_head().
> Perhaps the core code should be fixed to make my assumption true?

I misunderstood then - I think you can assume that it is initialized
to zero, I though you meant that it was initialized to a protocol
value. However, I then still have my original question - don't we need
to set it here in both cases since we're not just 'initializing' it
but actually setting a protocol?

>> One other consideration in the OVS case - with recirculation we may
>> hit this code multiple times and the difference in behavior could be
>> surprising. However, on the other hand, we need to be careful because
>> skb->cb is not guaranteed to be initialized to zero.
>
> Thanks, that is also not something that I had considered.
>
> I'm not sure, but I think that we can rely on skb->cb
> not being clobbered between rounds of recirculation.
> Or at the very least I think we could save and restore it
> as necessary.

Yes, it should be safe to assume this.

> So I think if we could be careful to make sure that inner_protocol
> is in a sane state the first time we see the skb but not
> each time it is recirculated then I think things should work out.
>
> In my current implementation of recirculation the datapath
> side is driven ovs_dp_process_received_packet(). So by my reasoning
> above I think it would make sense to reset the inner_protocol there
> and in ovs_packet_cmd_execute() rather than in ovs_execute_actions()
> which each of those functions call.

I think that would work, however, I wonder if it's the right place in
general, independent of this compatibility issue. I guess it still
seems like the ideal thing to do is to move this as close to where it
is necessary as possible, specifically in mpls_push(). Is there a
reason to not put it there (again, other than the out-of-tree
compatibility issues)?
