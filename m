From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: Query regarding sk_filter
Date: Sat, 10 Jan 2015 18:40:21 +0600
Message-ID: <20150110124020.GB9428@kumar-pc.asicdesigners.com>
References: <20150109112302.GA9428@kumar-pc.asicdesigners.com>
 <CAADnVQKNF43g4RdMTRbPJ2m_XYwyekpmHb93UyarWJB-z8iGAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23277 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbbAJNKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 08:10:42 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQKNF43g4RdMTRbPJ2m_XYwyekpmHb93UyarWJB-z8iGAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 01/09/15, 2015 at 16:51:46 -0800, Alexei Starovoitov wrote:
> On Fri, Jan 9, 2015 at 3:23 AM, Kumar Sanghvi <kumaras@chelsio.com> wrote:
> > Hi netdev team,
> >
> > I have a query regarding sk_filter call in tcp receive path:
> >
> > In 'tcp_v4_rcv' function, if sk is found by __inet_lookup_skb then,
> > down the line, there is a call to sk_filter to ensure if the incoming packet
> > is allowed to be processed for that sk.
> >
> > However, in 'tcp_v4_hnd_req' function, if nsk is found by inet_lookup_established
> > then, later, there does not seem to be a sk_filter call for that nsk in the receive
> > path processing.
> >
> > I am wondering shouldn't there be a sk_filter call on nsk found in 'tcp_v4_hnd_req'
> > function ? Or, probably I am missing something.
> 
> hmm. I'm not sure what you're seeing.

This is more of a question out of curiosity :)

> tcp_v4_hnd_req() is called from tcp_v4_do_rcv() which is called
> after sk_filter() check is done in tcp_v4_rcv() (either directly
> or via prequeue/backlog)

Ok.
> 
> > I am running some high rate syn-flood tests and trying to understand
> > the sk_filter behaviour in this case.
> 
> are you saying not all of syn packets are reaching filter?

No, not saying that.

I was thinking more in terms of below:-
(BTW, I am unsure if case B described below is actually possible.
I am describing it hypothetically.
So, please correct me if I am smoking cracks and my understanding is wrong)

One more thing I forgot to clarify is: the syn-flood test that I am running uses the 
same 4-tuple of actual clients establishing connections with server.

Lets say there is iperf TCP server running on DUT.
There are some short-lived iperf clients establishing connections.
The syn-flood uses the same 4-tuple which the iperf clients use.

The two cases that I was thinking of are:

A) Connection is established on DUT.
-------------------------------------
Now, if a SYN comes with same 4-tuple then, in tcp_v4_rcv, a child socket would be
found from __inet_lookup_skb and the subsequent sk_filter would run for that child socket.


B) Connection is in process of establishing.
-------------------------------------------
Here, lets say a SYN comes (using the same 4-tuple as iperf client whose connection is in process 
of establishing)  and in tcp_v4_rcv, there is no existing established connection
found yet. So, listen socket would be returned via __inet_lookup_skb and subsequent sk_filter
would run on listen socket.

Further, as this SYN packet is processed, a child socket is found in tcp_v4_hnd_req.
And then, tcp_child_process would then get called from tcp_v4_do_rcv.

So, unlike case A), here the sk_filter ran on listen socket rather than the child socket.
Or does the sk_filter would run on child socket from some other part ?

May be, the question that I should have asked is : do child socket and parent listening socket have the 
same sk_filter applied i.e. do child socket inherit sk_filter from parent listening socket ?


Thank you for your response.
-Kumar.
