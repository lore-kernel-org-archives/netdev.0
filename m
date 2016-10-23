From: Xin Long <lucien.xin@gmail.com>
Subject: Re: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not
 return ENOMEM err back in sctp_packet_transmit
Date: Mon, 24 Oct 2016 02:20:51 +0800
Message-ID: <CADvbK_ci-aaX6-mgXTgR0mJm9ww7+48DmXH+m5R+-0PyMDH16g@mail.gmail.com>
References: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com> <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevic@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Michael Tuexen <Michael.Tuexen@lurchi.franken.de>,
        Eric Dumazet <edumazet@google.com>,
        Brenda Butler <bjb@mojatatu.com>, gabor@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34911 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756494AbcJWSUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 14:20:53 -0400
In-Reply-To: <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think the specific use case this patch addresses
> seems to have bitten us in an older kernel sctp (3.11?).
> A send() on a loaded network box caused the skb to
> alloc in what appears to be this code path and fail (problem
> is intermittent, so not 100% sure). errno seen was ENOMEM.
> Unfortunately the manpage for sendxxx sucks.
> It says "no memory available".
> [We'll fix the manpage if there is an appropriate answer].
>
> Two questions:
> a) Seems like we can safely ignore ENOMEM in user space
> at least for this use case. i.e the kernel will retry and
> eventually send this message. Is there any other scenario
> where we have to worry about ENOMEM showing up in user space?
>
> b) What is the general view of what sendXXX reaction oughta
> be from user space in presence of ENOMEM?
>
This patch doesn't ignore all the ENOMEN cases, only after msg is
enqueued in out queue/send queue, in the lower layer, when alloc
new skb and copy data from old skb, if it fails to alloc new skb, sctp
will ignore this ENOMEM, as this msg will be taken care by retransmit
mechanism, it's reasonable and also safe, user can't feel that.

But for the cases before enqueue, like in sctp_sendmsg,
sctp_datamsg_from_user may return ENOMEM, this err will return
back to user, and can't be ignored.

So I don't really think we should change something in manpage, what
do you think ? maybe a little explanation there is also nice, :)
