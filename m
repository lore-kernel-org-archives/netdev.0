From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH next] dctcp: update cwnd on congestion event
Date: Fri, 2 Dec 2016 16:01:37 -0500
Message-ID: <CADVnQymNZ+FQ5xJ92HuSkheAJfOTUyh-PsA11bxRWERZkD5zdQ@mail.gmail.com>
References: <1479138121-32294-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Lawrence Brakmo <brakmo@fb.com>,
        Andrew Shewmaker <agshew@gmail.com>,
        Glenn Judd <glenn.judd@morganstanley.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35598 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbcLBVCJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 16:02:09 -0500
Received: by mail-oi0-f41.google.com with SMTP id b126so279701612oia.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 13:02:08 -0800 (PST)
In-Reply-To: <1479138121-32294-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 10:42 AM, Florian Westphal <fw@strlen.de> wrote:
>
> draft-ietf-tcpm-dctcp-02 says:
>
> ... when the sender receives an indication of congestion
> (ECE), the sender SHOULD update cwnd as follows:
>
>          cwnd = cwnd * (1 - DCTCP.Alpha / 2)
>
> So, lets do this and reduce cwnd more smoothly (and faster), as per
> current congestion estimate.

AFAICT this is doing a multiplicative decrease of cwnd on every ACK
that has an ECE bit.

If I am reading the code correctly, then I would have two concerns:

1) Has that been tested? That seems like an extremely dramatic
decrease in cwnd. For example, if the cwnd is 80, and there are 40
ACKs, and half the ACKs are ECE marked, then my back-of-the-envelope
calculations seem to suggest that after just 11 ACKs the cwnd would be
down to a minimal value of 2:

ack 1 cwnd=60
ack 2 cwnd=45
ack 3 cwnd=33
ack 4 cwnd=24
ack 5 cwnd=18
ack 6 cwnd=13
ack 7 cwnd=9
ack 8 cwnd=6
ack 9 cwnd=4
ack 10 cwnd=3
ack 11 cwnd=2

2) That seems to contradict another passage in the draft (v 02 or 03). Consider
     https://tools.ietf.org/html/draft-ietf-tcpm-dctcp-03
where it says

   Just as specified in [RFC3168], DCTCP does not react to congestion
   indications more than once for every window of data.

So the draft seems to advocate not reacting to congestion indications
more than once per window. Yet this patch reacts on every ECE-marked
ACK within a window.

Am I reading something incorrectly?

cheers,
neal
