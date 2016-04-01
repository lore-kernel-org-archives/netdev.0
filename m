From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 21:26:57 -0700
Message-ID: <20160401042655.GA16500@ast-mbp.thefacebook.com>
References: <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401014516.GA11017@ast-mbp.thefacebook.com>
 <1459479818.6473.265.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401040442.GA14661@ast-mbp.thefacebook.com>
 <56FDF541.6070106@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, mkubecek@suse.cz
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33709 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbcDAE1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 00:27:03 -0400
Received: by mail-pa0-f49.google.com with SMTP id zm5so81614099pac.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 21:27:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56FDF541.6070106@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2016 at 06:12:49AM +0200, Hannes Frederic Sowa wrote:
> On 01.04.2016 06:04, Alexei Starovoitov wrote:
> >On Thu, Mar 31, 2016 at 08:03:38PM -0700, Eric Dumazet wrote:
> >>On Thu, 2016-03-31 at 18:45 -0700, Alexei Starovoitov wrote:
> >>
> >>>Eric, what's your take on Hannes's patch 2 ?
> >>>Is it more accurate to ask lockdep to check for actual lock
> >>>or lockdep can rely on owned flag?
> >>>Potentially there could be races between setting the flag and
> >>>actual lock... but that code is contained, so unlikely.
> >>>Will we find the real issues with this 'stronger' check or
> >>>just spend a ton of time adapting to new model like your other
> >>>patch for release_sock and whatever may need to come next...
> >>
> >>More precise lockdep checks are certainly good, I only objected to 4/4
> >>trying to work around another bug.
> >>
> >>But why do we rush for 'net' tree ?
> >>
> >>This looks net-next material to me.
> >>
> >>Locking changes are often subtle, lets take the time to do them
> >>properly.
> >
> >completely agree. I think only first patch belongs in net.
> >Everything else is net-next material.
> 
> Problem with first patch is that it uses lock_sock_fast, thus the current
> sock_owned_by_user check doesn't get rid the lockdep warning. :/
> 
> Thus we would need to go with the two first patches. Do you think it is
> acceptable? I actually didn't see a problem and testing showed no problems
> so far.

I see. right. the patch 1 only makes sense when coupled with 2.
but now I'm not so sure that lockdep_is_held(&sk->sk_lock.slock)
is a valid check, since current sock_owned_by_user() is equivalent
to lockdep_is_held(&sk->sk_lock) only.
I would go with Daniel's approach. Much simpler to reason about.
