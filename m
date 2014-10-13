From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [PATCH/RFC repost 7/8] ofproto: translate datapath
 select group action
Date: Mon, 13 Oct 2014 13:46:24 -0700
Message-ID: <20141013204624.GD6806@nicira.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-8-git-send-email-simon.horman@netronome.com>
 <20140926235725.GB20493@nicira.com>
 <20141009011434.GE9339@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:37220 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750745AbaJMUqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 16:46:32 -0400
Received: by mail-qa0-f47.google.com with SMTP id cm18so4940559qab.6
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 13:46:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141009011434.GE9339@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 10:14:36AM +0900, Simon Horman wrote:
> On Fri, Sep 26, 2014 at 04:57:25PM -0700, Ben Pfaff wrote:
> > On Thu, Sep 18, 2014 at 10:55:10AM +0900, Simon Horman wrote:
> > > This patch is a prototype and has several limitations:
> > > 
> > > * It assumes that no actions follow a select group action
> > >   because the resulting packet after a select group action may
> > >   differ depending on the bucket used. It may be possible
> > >   to address this problem using recirculation. Or to not use
> > >   the datapath select group in such situations. In any case
> > >   this patch does not solve this problem or even prevent it
> > >   from occurring.
> > 
> > It seems like this limitation in particular is a pretty big one.  Do
> > you have a good plan in mind for how to resolve it?
> 
> Hi Ben,
> 
> it seems to me that this would be somewhat difficult to resolve in the
> datapath so I propose not doing so. And I have two ideas on how to
> resolve this problem outside of the datapath.
> 
> 1. Recirculation
> 
>    It seems to me that it ought to be possible to handle this by
>    recirculating if actions occur after an ODP select group action.
> 
>    This could be made slightly more selective by only recirculating
>    if the execution different buckets may result in different packet
>    contents and the actions after the ODP select group action rely on
>    the packet contents (e.g. set actions do but output actions do not).
> 
>    My feeling is that this could be implemented by adding a small amount
>    of extra state to action translation in ovs-vswitchd.
> 
> 2. Fall back to selecting buckets in ovs-vswtichd
> 
>    The idea here is to detect cases where there would be a problem
>    executing actions after an ODP select group action and in that
>    case to select buckets in ovs-vswtichd: that is use the existing bucket
>    translation code in ovs-vswtichd.
> 
>    Though this seems conceptually simpler than recirculation it
>    seems to me that it would be somewhat more difficult to implement
>    as it implies a two stage translation process: e.g. one stage to
>    determine if an ODP select group may be used; and one to perform
>    the translation.
> 
>    I seem to recall trying various two stage translation processes
>    as part some earlier unrelated work. And my recollection is that
>    the result of my previous efforts were not pretty.
> 
> Both of the above more or less negate any benefits of ODP select group
> action. In particular lowering flow setup cost and potentially allowing
> complete offload of select groups from the datapath to hardware. However I
> think that this case is not a common one as it requires both of the
> following. And I think they are both not usual use cases.
> 
> * Different buckets modifying packets in different ways
>   - My expectation is that it is common for buckets to be homogeneous in
>     regards to packet modifications. But perhaps this is na??ve in the
>     context of VLANs, MPLS, and similar tags that can be pushed and popped.
> * Actions that rely on packet contents after
>   - My expectation is that it is common to use a select group to output
>     packets and that is the final action performed.

I am glad that you have thought about it.  Your ideas seem like a good
start to me.  Personally, approach #2, of falling back to selecting
buckets in ovs-vswitchd, seems like a clean solution to me, although
if it really takes multiple stages in translation then that is
undesirable, so I hope that some clean and simple approach works out.

I think that we probably need a solution before we can apply the patch
series, because otherwise we end up with half-working code.
