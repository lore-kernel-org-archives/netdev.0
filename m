From: <kafai@fb.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Mon, 18 Apr 2016 16:43:25 -0700
Message-ID: <20160418234202.GA27948@kafai-mba.local>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-5-git-send-email-kafai@fb.com>
 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:10074 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751363AbcDRXnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 19:43:37 -0400
Content-Disposition: inline
In-Reply-To: <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 04:18:13PM -0700, Eric Dumazet wrote:
> On Mon, 2016-04-18 at 15:46 -0700, Martin KaFai Lau wrote:
> > This patch allows the user process to use MSG_EOR during
> > tcp_sendmsg to tell the kernel that it is the last byte
> > of an application response message.
> >
> > It is currently useful when the end-user has turned on any bit of the
> > SOF_TIMESTAMPING_TX_RECORD_MASK (either by setsockopt or cmsg).
> > The kernel will then mark the newly added tcb->eor_info bit so
> > that the shinfo->tskey will not be overwritten (i.e. lost) in
> > the later skb append/collapse operation.
> >
> > With selective SOF_TIMESTAMPING_TX_ACK (by cmsg) and MSG_EOR (this
> > patch), the user application can specially tell which outgoing byte
> > it wants to track its ACK and ask the kernel not to lose this
> > tracking info in the later skb append/collapse action.
> >
> > This patch handles the append case in tcp_sendmsg.  The later
> > patches will handle the collapse during retransmission and
> > skb slicing in tcp_fragment()/tso_fragment().
> >
> > One of our use case is at the webserver.  The webserver tracks
> > the HTTP2 response latency by measuring when the webserver sends
> > the first byte to the socket till the TCP ACK of the last byte
> > is received.  In the cases where we don't have client side
> > measurement, measuring from the server side is the only option.
> > In the cases we have the client side measurement, the server side
> > data can also be used to justify/cross-check-with the client
> > side data.
> >
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
> > Cc: Willem de Bruijn <willemb@google.com>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > ---
>
> MSG_EOR should not depend on SKBTX_ANY_TSTAMP
>
> Really, simply using send(fd, ..., len, MSG_EOR) should instruct TCP to
> mark the cooked skb as a non candidate for future coalescing.
It was one of my earlier local attempt.  There are cases that coalescing
will not lose the tskey, so I trashed it.

If we mark eor only based on MSG_EOR, we can still do checks on
prev_skb's tskey and next_skb's tskey before coalescing two skbs
or
you meant simply don't coalesce if the prev_skb has eor marked?

>
> netperf could then get an option to set this MSG_EOR ;)
Not sure how it is related.  Can you share how netperf can
benefit from MSG_EOR in TCP tests without any of the
SOF_TIMESTAMPING_TX_RECORD_MASK.
