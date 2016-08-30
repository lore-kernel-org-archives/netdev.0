From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFCv2 16/16] nfp: bpf: add offload of TC direct action mode
Date: Tue, 30 Aug 2016 22:50:54 +0200
Message-ID: <20160830225054.453e207b@laptop>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
        <1472234775-29453-17-git-send-email-jakub.kicinski@netronome.com>
        <57C4A48F.6080403@iogearbox.net>
        <20160830125252.011f08d3@laptop>
        <57C5E642.2070600@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:14495 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750846AbcH3Uu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 16:50:59 -0400
In-Reply-To: <57C5E642.2070600@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Aug 2016 22:02:10 +0200, Daniel Borkmann wrote:
> On 08/30/2016 12:52 PM, Jakub Kicinski wrote:
> > On Mon, 29 Aug 2016 23:09:35 +0200, Daniel Borkmann wrote:  
>  [...]  
> >>
> >> In da mode, RECLASSIFY is not supported, so this one could be scratched.
> >> For the OK and UNSPEC part, couldn't both be treated the same (as in: OK /
> >> pass to stack roughly equivalent as in sch_handle_ingress())? Or is the
> >> issue that you cannot populate skb->tc_index when passing to stack (maybe
> >> just fine to leave it at 0 for now)?  
> >
> > The comment is a bit confus(ed|ing).  The problem is:
> >
> > tc filter add <filter1> skip_sw
> > tc filter add <filter2> skip_hw
> >
> > If packet appears in the stack - was it because of OK or UNSPEC (or
> > RECLASSIFY) in filter1?  Do we need to run filter2 or not?  Passing
> > tc_index can be implemented the same way I do mark today.  
> 
> Okay, I see, thanks for explaining. So, if passing tc_index (or any other
> meta data) can be implemented the same way as we do with mark already,
> could we store such verdict, say, in some unused skb->tc_verd bits (the
> skb->tc_index could be filled by the program already) and pass that up the
> stack to differentiate between them? There should be no prior user before
> ingress, so that patch 4 could become something like:
> 
>    if (tc_skip_sw(prog->gen_flags)) {
>       filter_res = tc_map_hw_verd_to_act(skb);
>    } else if (at_ingress) {
>       ...
>    } ...

This looks promising!

> And I assume it wouldn't make any sense anyway to have a skip_sw filter
> being chained /after/ some skip_hw and the like, right?

Right.  I think it should be enforced by TC core or at least some shared
code similar to tc_flags_valid() to reject offload attempts of filters
which are not first in line from the wire.  Right now AFAICT enabling
transparent offload with ethtool may result in things going down to HW
completely out of order and user doesn't even have to specify the
skip_* flags...
