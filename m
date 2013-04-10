From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH 1/4] Add packet recirculation
Date: Wed, 10 Apr 2013 18:16:57 +0900
Message-ID: <20130410091657.GA27777@verge.net.au>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
	<1365403431-18102-2-git-send-email-horms@verge.net.au>
	<CAEP_g=9nj24hZcA-czzuz3xaweATxRxmibuFaqODTSoPmRmHsw@mail.gmail.com>
	<20130409075024.GG11444@verge.net.au>
	<CAEP_g=-baZGttBowXKGdgKafxp9fkUrQ=44y562ZzfnOL-XaQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEP_g=-baZGttBowXKGdgKafxp9fkUrQ=44y562ZzfnOL-XaQg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Tue, Apr 09, 2013 at 08:44:02AM -0700, Jesse Gross wrote:
> On Tue, Apr 9, 2013 at 12:50 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> > On Mon, Apr 08, 2013 at 06:46:29PM -0700, Jesse Gross wrote:
> >> On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> > diff --git a/datapath/actions.c b/datapath/actions.c
> >> > index e9634fe..7b0f022 100644
> >> > --- a/datapath/actions.c
> >> > +++ b/datapath/actions.c
> >> > @@ -617,6 +617,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> >> >                 case OVS_ACTION_ATTR_SAMPLE:
> >> >                         err = sample(dp, skb, a);
> >> >                         break;
> >> > +
> >> > +               case OVS_ACTION_ATTR_RECIRCULATE:
> >> > +                       return 1;
> >>
> >> I think that if we've had a previous output action with the port
> >> stored in prev_port then this will cause the packet to not actually be
> >> output.
> >
> > I'm not so sure.
> >
> > I see something like this occurring:
> >
> > 1. Iteration of for loop for output action
> >
> >    switch (nla_type(a)) {
> >    case OVS_ACTION_ATTR_OUTPUT:
> >         prev_port = nla_get_u32(a);
> >         break;
> >         ...
> >    }
> >
> > 2. Iteration of of for loop for next action, lets say its is recirculate
> >
> >    i. Output packet
> >
> >    if (prev_port != -1) {
> >         do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
> >         prev_port = -1;
> >    }
> >
> >    ii. Return due to recirculate
> >    switch (nla_type(a)) {
> >    ...
> >    case OVS_ACTION_ATTR_RECIRCULATE:
> >            return 1;
> >    }
> >
> >
> > Am I missing something?
> 
> Sorry, you're right.
> 
> >> > @@ -901,6 +913,9 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
> >> >                         skip_copy = true;
> >> >                         break;
> >> >
> >> > +               case OVS_ACTION_ATTR_RECIRCULATE:
> >> > +                       break;
> >>
> >> I think we might want to jump out the loop here to better model how
> >> the actions are actually executed.
> >
> > Sure, perhaps something like this?
> >
> > diff --git a/datapath/datapath.c b/datapath/datapath.c
> > index ab39dd7..721a52c 100644
> > --- a/datapath/datapath.c
> > +++ b/datapath/datapath.c
> > @@ -914,7 +914,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
> >                         break;
> >
> >                 case OVS_ACTION_ATTR_RECIRCULATE:
> > -                       break;
> > +                       goto out;
> >
> >                 default:
> >                         return -EINVAL;
> > @@ -926,6 +926,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
> >                 }
> >         }
> >
> > +out:
> >         if (rem > 0)
> >                 return -EINVAL;
> 
> Since this function is now both validating and copying I think this
> will result in the recirculate action not being copied.

Thanks, I'll look into that.

> >> > diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
> >> > index 47830c1..5129da1 100644
> >> > --- a/ofproto/ofproto-dpif.c
> >> > +++ b/ofproto/ofproto-dpif.c
> >>
> >> I'm still working on more detailed comments for this.  However, I'm
> >> concerned about whether the behavior for revalidation and stats is
> >> correct.
> >
> > I am a little concerned about that too.
> > Perhaps Ben could look over it?
> 
> To rephrase, there are problems in both of those areas. Validation in
> particular I don't think handles resubmitted facets and I believe that
> stats on rules will be the sum of all resubmitted passes.

Some questions:
By resubmitted do you mean recirculated?
What is the stats behaviour that you would like?

With regards to validation, I assume the area of concern
is around facet_revalidate(). I will look into that.

> Both of these will likely significantly affect the data structures, so
> please look into this before we go further.

Sure. I was not planning to push (much) further until this series
is reviewed properly.

> In general, I'd also like
> to see patches that are standalone without needing follow on patches
> to fix known problems (for example, the recirculation ID patches or
> MPLS GSO) unless there is a good reason.

Thanks, I understand. I'll try and structure my patches accordingly.
