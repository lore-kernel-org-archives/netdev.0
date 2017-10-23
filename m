From: Steve Ibanez <sibanez@stanford.edu>
Subject: Re: Linux ECN Handling
Date: Mon, 23 Oct 2017 15:15:36 -0700
Message-ID: <CACJspmKjAr+q9cFVssXVxWQMCUWe3TNYO77m0nQwzQK4hTCOzA@mail.gmail.com>
References: <CACJspmLFdy9i8K=TkzXHnofyFMNoJf9HkYE7On8uG+PREc2Dqw@mail.gmail.com>
 <20171019124312.GE16796@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Westphal <fw@strlen.de>,
        Mohammad Alizadeh <alizadeh@csail.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00000d04.pphosted.com ([148.163.149.245]:43540 "EHLO
        mx0a-00000d04.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751116AbdJWXR1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:17:27 -0400
Received: from pps.filterd (m0102886.ppops.net [127.0.0.1])
        by mx0a-00000d04.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NMCuDT012995
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:43 -0700
Received: from mx0a-00000d03.pphosted.com (mx0a-00000d03.pphosted.com [148.163.149.244])
        by mx0a-00000d04.pphosted.com with ESMTP id 2dsqe2gpyh-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:43 -0700
Received: from pps.filterd (m0102881.ppops.net [127.0.0.1])
        by mx0a-00000d03.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NMFNRi028411
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:43 -0700
Received: from codegreen8.stanford.edu (codegreen8.stanford.edu [171.67.224.10])
        by mx0a-00000d03.pphosted.com with ESMTP id 2dr35xsj6r-1
        (version=TLSv1 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:43 -0700
Received: from codegreen8.stanford.edu (localhost.localdomain [127.0.0.1])
        by codegreen8.stanford.edu (Postfix) with ESMTP id BEFB247
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:42 -0700 (PDT)
Received: from smtp.stanford.edu (smtp2.stanford.edu [171.67.219.82])
        by codegreen8.stanford.edu (Postfix) with ESMTP id 8CCC44C
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:42 -0700 (PDT)
Received: from mail-pg0-f42.google.com (mail-pg0-f42.google.com [74.125.83.42])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        (Authenticated sender: sibanez)
        by smtp.stanford.edu (Postfix) with ESMTPSA id 7503C400CBE
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:37 -0700 (PDT)
Received: by mail-pg0-f42.google.com with SMTP id b192so12867234pga.2
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:15:37 -0700 (PDT)
In-Reply-To: <20171019124312.GE16796@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I upgraded the kernel on all of our machines to Linux
4.13.8-041308-lowlatency. However, I'm still observing the same
behavior where the source enters a timeout when the CWND=1MSS and it
receives ECN marks.

Here are the measured flow rates:
<https://drive.google.com/file/d/0B-bt9QS-C3ONT0VXMUt6WHhKREE/view?usp=sharing>

Here are snapshots of the packet traces at the sources when they both
enter a timeout at t=1.6sec:

10.0.0.1 timeout event:
<https://drive.google.com/file/d/0B-bt9QS-C3ONcl9WRnRPazg2ems/view?usp=sharing>

10.0.0.3 timeout event:
<https://drive.google.com/file/d/0B-bt9QS-C3ONeDlxRjNXa0VzWm8/view?usp=sharing>

Both still essentially follow the same sequence of events that I
mentioned earlier:
(1) receives an ACK for byte XYZ with the ECN flag set
(2) stops sending for RTO_min=300ms
(3) sends a retransmission for byte XYZ

The cwnd samples reported by tcp_probe still indicate that the sources
are reacting to the ECN marks more than once per window. Here are the
cwnd samples at the same timeout event mentioned above:
<https://drive.google.com/file/d/0B-bt9QS-C3ONdEZQdktpaW5JUm8/view?usp=sharing>

Let me know if there is anything else you think I should try.

Thanks,
-Steve

On Thu, Oct 19, 2017 at 5:43 AM, Florian Westphal <fw@strlen.de> wrote:
>
> [ full-quoting due to Cc fixups, adding netdev ]
>
> Steve Ibanez <sibanez@stanford.edu> wrote:
> > Hi Florian, Neal, and Daniel,
> >
> > I hope this email finds you well. My name is Stephen Ibanez and I'm a PhD
> > Student at Stanford currently working on a project with Mohammad Alizadeh,
> > Nick McKeown, and Lavanya Jose. We have been doing some experiments using
> > the linux DCTCP implementation and are trying to understand some strange
> > behavior that we are encountering. I'm contacting you three because I have
> > seen your names on some of the source files and recent commits in the linux
> > source tree. Hopefully you can help us out or put us in contact with the
> > right people?
> >
> > Here are some details about our servers:
> >
> >    - Distribution: Ubuntu 14.04 LTS
> >    - Kernel release: 4.4.0-75-generic
>
> Can you re-test with a more recent kernel such as 4.13.8?
>
> > *The experiment:*
> >
> > We use iperf3 to generate two DCTCP flows from different servers to a
> > common server, as shown in the diagram below. We measure the sending rate
> > of each flow, record the tcp_probe output, as well as run tcpdump on the
> > source host interfaces.
> >
> > [image: Inline image 6]
> >
> > *The problem:*
> >
> > Our rate measurements look like the one shown below; the flows often enter
> > timeouts. In this case, both flows hit a timeout at t=0.3.
> > [image: Inline image 2]
> >
> > When looking at the sequence of packets seen at the source host interfaces
> > around this timeout event this is what we see:
> >
> > *10.0.0.1 timeout event:*
> > [image: Inline image 3]
> >
> > *10.0.0.3 timeout event:*
> > [image: Inline image 4]
> >
> > In both cases, the source:
> > (1) receives an ACK for byte XYZ with the ECN flag set
> > (2) stops sending anything for RTO_min=300ms
> > (3) sends a retransmission for byte XYZ
> >
> > I have verified that this behavior is consistent across multiple experiment
> > runs. Here are the CWND samples for the 10.0.0.1 flow provided by tcp_probe
> > at the time of the timeout event:
> >
> > [image: Inline image 5]
> >
> > From what I can tell, tcp_probe logs a sample whenever a packet is
> > received. If this is true, then that means when the source receives the
> > final ECN marked ACK just before the timeout the CWND=1 MSS.
> >
> > *The conclusion:*
> >
> > We believe that there may be an issue with how the linux kernel is handling
> > the ECN echoes. For DCTCP, if the CWND is 1 MSS and the end host is still
> > receiving ECN marks then the CWND should remain at 1 MSS and should *not*
> > enter a timeout. This is because the switch can perform ECN marking very
> > aggressively causing the source end host to receive many redundant ECN
> > echoes over a short period of time.
> >
> > Another potential issue is that from the CWND plot above it looks like the
> > end host may be reacting to congestion signals more than once per window,
> > which should not happen (section 5 of RF3168
> > <https://tools.ietf.org/html/rfc3168>). tcp_probe reports SRTT measurements
> > of about 400-500 us and in the plot above the CWND is reduced 6 times
> > within this amount of time.
> >
> > We have not yet tracked down the code path in the kernel code that is
> > causing the behavior described above. Perhaps this is something that you
> > can help us with? We would love to hear your thoughts on this matter and
> > are happy to try other experiments that you suggest.
> >
> > Here is a link
> > <https://drive.google.com/file/d/0Bw-GEX7h5ufiYmpCV2VpOGEtQWs/view?usp=sharing>
> > to
> > download the packet traces if you would like to take a look.
> > han-1_host.pcap is the trace from 10.0.0.1 and han-3_host.pcap is the trace
> > from 10.0.0.3.
> >
> > Looking forward to hearing from you!
> >
> > Best,
> > -Steve
