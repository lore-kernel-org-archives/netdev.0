From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next] dctcp: update cwnd on congestion event
Date: Fri, 2 Dec 2016 22:49:35 +0100
Message-ID: <20161202214935.GB31010@breakpoint.cc>
References: <1479138121-32294-1-git-send-email-fw@strlen.de>
 <CADVnQymNZ+FQ5xJ92HuSkheAJfOTUyh-PsA11bxRWERZkD5zdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Netdev <netdev@vger.kernel.org>,
        Lawrence Brakmo <brakmo@fb.com>,
        Andrew Shewmaker <agshew@gmail.com>,
        Glenn Judd <glenn.judd@morganstanley.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:59302 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750750AbcLBVwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 16:52:45 -0500
Content-Disposition: inline
In-Reply-To: <CADVnQymNZ+FQ5xJ92HuSkheAJfOTUyh-PsA11bxRWERZkD5zdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neal Cardwell <ncardwell@google.com> wrote:
> On Mon, Nov 14, 2016 at 10:42 AM, Florian Westphal <fw@strlen.de> wrote:
> >
> > draft-ietf-tcpm-dctcp-02 says:
> >
> > ... when the sender receives an indication of congestion
> > (ECE), the sender SHOULD update cwnd as follows:
> >
> >          cwnd = cwnd * (1 - DCTCP.Alpha / 2)
> >
> > So, lets do this and reduce cwnd more smoothly (and faster), as per
> > current congestion estimate.
> 
> AFAICT this is doing a multiplicative decrease of cwnd on every ACK
> that has an ECE bit.
> 
> If I am reading the code correctly, then I would have two concerns:
> 
> 1) Has that been tested? That seems like an extremely dramatic
> decrease in cwnd. For example, if the cwnd is 80, and there are 40
> ACKs, and half the ACKs are ECE marked, then my back-of-the-envelope
> calculations seem to suggest that after just 11 ACKs the cwnd would be
> down to a minimal value of 2:
> 
> ack 1 cwnd=60
> ack 2 cwnd=45
> ack 3 cwnd=33
[..]

You are assuming alpha = 0.5?
Then, yes, looks correct.  Since some of these acks will most likely
also end an observation window acks might also cause change to alpha.

> 2) That seems to contradict another passage in the draft (v 02 or 03). Consider
>      https://tools.ietf.org/html/draft-ietf-tcpm-dctcp-03
> where it says
> 
>    Just as specified in [RFC3168], DCTCP does not react to congestion
>    indications more than once for every window of data.
> 
> So the draft seems to advocate not reacting to congestion indications
> more than once per window. Yet this patch reacts on every ECE-marked
> ACK within a window.
> 
> Am I reading something incorrectly?

No, I will raise this on tcpm next monday (if you want you
can of course do this yourself).

Would be easy to make it so this cwnd update only happens once in each
observation cycle, but it would be even better if this would get input
from draft authors.

Thanks Neal!
