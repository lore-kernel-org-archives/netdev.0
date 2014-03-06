From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 2/2] 6lowpan: reassembly: fix kernel oops while
 unloading
Date: Thu, 6 Mar 2014 17:36:37 +0100
Message-ID: <20140306163635.GA21460@omega>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
 <1394052211-6976-3-git-send-email-alex.aring@gmail.com>
 <20140305223246.GA17526@breakpoint.cc>
 <20140306060943.GB13676@omega>
 <20140306133851.GC17526@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:49074 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbaCFQgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 11:36:44 -0500
Received: by mail-ea0-f178.google.com with SMTP id a15so1800057eae.23
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 08:36:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140306133851.GC17526@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2014 at 02:38:51PM +0100, Florian Westphal wrote:
> Alexander Aring <alex.aring@gmail.com> wrote:
> > On Wed, Mar 05, 2014 at 11:32:46PM +0100, Florian Westphal wrote:
> > > Alexander Aring <alex.aring@gmail.com> wrote:
> > > > It seems that the inet_frag_queue is deleted but the timer is running. This
> > > > patch adds a for loop to iterate over all frag_queue entries in the
> > > > frag_bucket and calling del_timer for each frag_queue entry while
> > > > unloading the 6lowpan module.
> > > > 
> > > > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > > > Reported-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> > > > ---
> > > > I am not sure about that I can do that in this simply way without hold
> > > > any lock of the inet_frag_queue or inet_frag_bucket. Please help there.
> > > > The kernel oops never occurs afterwards, but this isn't simple to test.
> > > > I can't test all cases.
> > > 
> > > I find it hard to believe that this is a 6lowpan specific problem,
> > > most likely this needs a fix in inet_fragment code.
> > > 
> > I thought that too, maybe it's a problem in the inet_fragment code.
> > 
> > 
> > There are two function which I call on exit:
> > 
> > inet_frags_fini(&lowpan_frags); - which deletes the secret_timer.
> > inet_frags_exit_net(&net->ieee802154_lowpan.frags, &lowpan_frags);
> >  - which runs a force inet_frag_evictor
> > 
> > maybe I forgot to call some other function to cleanup the fragmentation.
> 
> No, it looks correct.
> 
> > I don't saw any other exit function and I do a similar cleanup like ipv4/ipv6
> > and they don't have a module_exit function which is called for the
> > inet_fragment code. 
> 
> net/ipv6/netfilter/nf_defrag_ipv6_hooks.c has one (calls
> nf_ct_frag6_cleanup).
> 
ah, ok.

> I am currently testing this fix:
> 
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 322dceb..3b01959 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -208,7 +208,7 @@ int inet_frag_evictor(struct netns_frags *nf, struct
> 		inet_frags *f, bool force)
>         }
>  
>         work = frag_mem_limit(nf) - nf->low_thresh;
> -       while (work > 0) {
> +       while (work > 0 || force) {
> 
> 

I looked at this and try my little testscript and I don't get the kernel
oops also. What's the next step?

- Alex
