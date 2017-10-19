From: Florian Westphal <fw@strlen.de>
Subject: Re: Linux ECN Handling
Date: Thu, 19 Oct 2017 14:43:12 +0200
Message-ID: <20171019124312.GE16796@breakpoint.cc>
References: <CACJspmLFdy9i8K=TkzXHnofyFMNoJf9HkYE7On8uG+PREc2Dqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: ncardwell@google.com, daniel@iogearbox.net,
        Mohammad Alizadeh <alizadeh@csail.mit.edu>,
        Nick McKeown <nickm@stanford.edu>,
        Lavanya Jose <lavanyaj@cs.stanford.edu>, netdev@vger.kernel.org
To: Steve Ibanez <sibanez@stanford.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56910 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752702AbdJSMnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:43:32 -0400
Content-Disposition: inline
In-Reply-To: <CACJspmLFdy9i8K=TkzXHnofyFMNoJf9HkYE7On8uG+PREc2Dqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ full-quoting due to Cc fixups, adding netdev ]

Steve Ibanez <sibanez@stanford.edu> wrote:
> Hi Florian, Neal, and Daniel,
> 
> I hope this email finds you well. My name is Stephen Ibanez and I'm a PhD
> Student at Stanford currently working on a project with Mohammad Alizadeh,
> Nick McKeown, and Lavanya Jose. We have been doing some experiments using
> the linux DCTCP implementation and are trying to understand some strange
> behavior that we are encountering. I'm contacting you three because I have
> seen your names on some of the source files and recent commits in the linux
> source tree. Hopefully you can help us out or put us in contact with the
> right people?
> 
> Here are some details about our servers:
> 
>    - Distribution: Ubuntu 14.04 LTS
>    - Kernel release: 4.4.0-75-generic

Can you re-test with a more recent kernel such as 4.13.8?

> *The experiment:*
> 
> We use iperf3 to generate two DCTCP flows from different servers to a
> common server, as shown in the diagram below. We measure the sending rate
> of each flow, record the tcp_probe output, as well as run tcpdump on the
> source host interfaces.
> 
> [image: Inline image 6]
> 
> *The problem:*
> 
> Our rate measurements look like the one shown below; the flows often enter
> timeouts. In this case, both flows hit a timeout at t=0.3.
> [image: Inline image 2]
> 
> When looking at the sequence of packets seen at the source host interfaces
> around this timeout event this is what we see:
> 
> *10.0.0.1 timeout event:*
> [image: Inline image 3]
> 
> *10.0.0.3 timeout event:*
> [image: Inline image 4]
> 
> In both cases, the source:
> (1) receives an ACK for byte XYZ with the ECN flag set
> (2) stops sending anything for RTO_min=300ms
> (3) sends a retransmission for byte XYZ
> 
> I have verified that this behavior is consistent across multiple experiment
> runs. Here are the CWND samples for the 10.0.0.1 flow provided by tcp_probe
> at the time of the timeout event:
> 
> [image: Inline image 5]
> 
> From what I can tell, tcp_probe logs a sample whenever a packet is
> received. If this is true, then that means when the source receives the
> final ECN marked ACK just before the timeout the CWND=1 MSS.
> 
> *The conclusion:*
> 
> We believe that there may be an issue with how the linux kernel is handling
> the ECN echoes. For DCTCP, if the CWND is 1 MSS and the end host is still
> receiving ECN marks then the CWND should remain at 1 MSS and should *not*
> enter a timeout. This is because the switch can perform ECN marking very
> aggressively causing the source end host to receive many redundant ECN
> echoes over a short period of time.
> 
> Another potential issue is that from the CWND plot above it looks like the
> end host may be reacting to congestion signals more than once per window,
> which should not happen (section 5 of RF3168
> <https://tools.ietf.org/html/rfc3168>). tcp_probe reports SRTT measurements
> of about 400-500 us and in the plot above the CWND is reduced 6 times
> within this amount of time.
> 
> We have not yet tracked down the code path in the kernel code that is
> causing the behavior described above. Perhaps this is something that you
> can help us with? We would love to hear your thoughts on this matter and
> are happy to try other experiments that you suggest.
> 
> Here is a link
> <https://drive.google.com/file/d/0Bw-GEX7h5ufiYmpCV2VpOGEtQWs/view?usp=sharing>
> to
> download the packet traces if you would like to take a look.
> han-1_host.pcap is the trace from 10.0.0.1 and han-3_host.pcap is the trace
> from 10.0.0.3.
> 
> Looking forward to hearing from you!
> 
> Best,
> -Steve
