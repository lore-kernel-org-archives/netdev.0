From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have
 a TCP_TIMEWAIT sk
Date: Wed, 1 Jul 2015 17:05:21 -0700
Message-ID: <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
 <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
 <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com> <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35268 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbbGBAFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 20:05:41 -0400
Received: by qkbp125 with SMTP id p125so41451732qkb.2
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 17:05:40 -0700 (PDT)
In-Reply-To: <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 1, 2015 at 4:26 PM, Eric Dumazet <edumazet@google.com> wrote:
> I think you are mistaken Alex.

Indeed, I was!  Should be unsurpising.

>
> socket early demux cannot possibly set skb->destructor to sock_rfree()

Yeah I will admit adding the code to sock_rfree reflexively out of paranoia.

> If skb->destructor is set by early demux, it correctly points to sock_edemux()
>
> And this one correctly handles all socket variants.

Yes, the problem appears to be in ip_vs_prepare_tunneled_skb
(ip_vs_xmit.c:859 in 4.0)

        if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
                new_skb = skb_realloc_headroom(skb, max_headroom);
                if (!new_skb)
                        goto error;
                if (skb->sk)
                        skb_set_owner_w(new_skb, skb->sk);
                consume_skb(skb);
                skb = new_skb;
        }

skb_set_owner_w sets sock_wfree.

I'll figure out how to ensure that we're using an appropriate destructor here.

Appreciate the patience!

-- 
Alex Gartrell <agartrell@fb.com>
