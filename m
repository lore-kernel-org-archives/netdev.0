From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFCv2 16/16] nfp: bpf: add offload of TC direct action mode
Date: Tue, 30 Aug 2016 12:52:52 +0200
Message-ID: <20160830125252.011f08d3@laptop>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
        <1472234775-29453-17-git-send-email-jakub.kicinski@netronome.com>
        <57C4A48F.6080403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:34498 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758159AbcH3Kw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 06:52:57 -0400
In-Reply-To: <57C4A48F.6080403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Aug 2016 23:09:35 +0200, Daniel Borkmann wrote:
> > +	 *   0,1   ok        NOT SUPPORTED[1]
> > +	 *   2   drop  0x22 -> drop,  count as stat1
> > +	 *   4,5 nuke  0x02 -> drop
> > +	 *   7  redir  0x44 -> redir, count as stat2
> > +	 *   * unspec  0x11 -> pass,  count as stat0
> > +	 *
> > +	 * [1] We can't support OK and RECLASSIFY because we can't tell TC
> > +	 *     the exact decision made.  We are forced to support UNSPEC
> > +	 *     to handle aborts so that's the only one we handle for passing
> > +	 *     packets up the stack.  
> 
> In da mode, RECLASSIFY is not supported, so this one could be scratched.
> For the OK and UNSPEC part, couldn't both be treated the same (as in: OK /
> pass to stack roughly equivalent as in sch_handle_ingress())? Or is the
> issue that you cannot populate skb->tc_index when passing to stack (maybe
> just fine to leave it at 0 for now)?

The comment is a bit confus(ed|ing).  The problem is:

tc filter add <filter1> skip_sw
tc filter add <filter2> skip_hw

If packet appears in the stack - was it because of OK or UNSPEC (or
RECLASSIFY) in filter1?  Do we need to run filter2 or not?  Passing
tc_index can be implemented the same way I do mark today.

> Just curious, does TC_ACT_REDIRECT work in this scenario?

I do the redirects in the card, all the problems stem from the
difficulty of passing full ret code in the skb from the driver
to tc_classify()/cls_bpf_classify().
