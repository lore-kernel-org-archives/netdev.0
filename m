From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v4] tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In
Date: Thu, 10 Mar 2016 09:58:17 -0800
Message-ID: <20160310175817.GA85582@kafai-mba.local>
References: <1457630961-2809690-1-git-send-email-kafai@fb.com>
 <CANn89iJF2mw-2qFJ1r2xLo0FuH9JCNVPgTOAfnxL7nOX4qg2tg@mail.gmail.com>
 <CANn89iJFBqOkD8G1qQDY-p=Z3jSgtPbeSSoiuiAqWXYgXzi5-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33051 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752960AbcCJR6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 12:58:31 -0500
Content-Disposition: inline
In-Reply-To: <CANn89iJFBqOkD8G1qQDY-p=Z3jSgtPbeSSoiuiAqWXYgXzi5-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 09:43:18AM -0800, Eric Dumazet wrote:
> On Thu, Mar 10, 2016 at 9:39 AM, Eric Dumazet <edumazet@google.com> wrote:
> > On Thu, Mar 10, 2016 at 9:29 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> >> Per RFC4898, they count segments sent/received
> >> containing a positive length data segment (that includes
> >> retransmission segments carrying data).  Unlike
> >> tcpi_segs_out/in, tcpi_data_segs_out/in excludes segments
> >> carrying no data (e.g. pure ack).
> >>
> >> The patch also updates the segs_in in tcp_fastopen_add_skb()
> >> so that segs_in >= data_segs_in property is kept.  If
> >> tcp_segs_in() helper is used in this fastopen case, tp->segs_in
> >> has to be 0 reset first to avoid double counting.  Also, it has
> >> to be done before __skb_pull(skb, tcp_hdrlen(skb)) while
> >> there is no need to check skb->len since skb has already
> >> been confirmed carrying data.  I found it more confusing
> >> and chose to directly set segs_in and data_segs_in in
> >> this special case.
> >
> > Note that on my TODO list after commit e11ecddf5128011c936cc5360780190cbc901fdc
> > I had the project of pulling TCP headers much earlier in input path
> > so that we do not have all these special cases.
> >
> > Acked-by: Eric Dumazet <edumazet@google.com>
>
> Actually, tcp_fastopen_add_skb() can queue a packet with a FIN only,
> but no data.
Thanks for pointing it out.  Didn't know it is allowed and
the above end_seq check could also be +1 by the FIN.

>
> I believe you need to test skb->len before setting tp->data_segs_in
In that case, I will try to 0 reset segs_in with comment explanation and call
tcp_segs_in() before the skb_pull.  I will spin another version.
