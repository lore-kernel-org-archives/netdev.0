From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v4 net-next 0/3] tcp: Make use of MSG_EOR in tcp_sendmsg
Date: Mon, 25 Apr 2016 20:50:02 -0400
Message-ID: <CACSApvaw=rMOw5HNBbytCVwJXapzyStEG_zry_7HHcWQT5e0gw@mail.gmail.com>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:34309 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbcDZAun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 20:50:43 -0400
Received: by mail-ob0-f169.google.com with SMTP id bg3so90074536obb.1
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 17:50:42 -0700 (PDT)
In-Reply-To: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 25, 2016 at 5:44 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> v4:
> ~ Do not set eor bit in do_tcp_sendpages() since there is
>   no way to pass MSG_EOR from the userland now.
> ~ Avoid rmw by testing MSG_EOR first in tcp_sendmsg().
> ~ Move TCP_SKB_CB(skb)->eor test to a new helper
>   tcp_skb_can_collapse_to() (suggested by Soheil).
> ~ Add some packetdrill tests.

Thanks for the nice patches and the tests!

> v3:
> ~ Separate EOR marking from the SKBTX_ANY_TSTAMP logic.
> ~ Move the eor bit test back to the loop in tcp_sendmsg and
>   tcp_sendpage because there could be >1 threads doing
>   sendmsg.
> ~ Thanks to Eric Dumazet's suggestions on v2.
> ~ The TCP timestamp bug fixes are separated into other threads.
>
> v2:
> ~ Rework based on the recent work
>   "add TX timestamping via cmsg" by
>   Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
> ~ This version takes the MSG_EOR bit as a signal of
>   end-of-response-message and leave the selective
>   timestamping job to the cmsg
> ~ Changes based on the v1 feedback (like avoid
>   unlikely check in a loop and adding tcp_sendpage
>   support)
> ~ The first 3 patches are bug fixes.  The fixes in this
>   series depend on the newly introduced txstamp_ack in
>   net-next.  I will make relevant patches against net after
>   getting some feedback.
> ~ The test results are based on the recently posted net fix:
>   "tcp: Fix SOF_TIMESTAMPING_TX_ACK when handling dup acks"
>
> One potential use case is to use MSG_EOR with
> SOF_TIMESTAMPING_TX_ACK to get a more accurate
> TCP ack timestamping on application protocol with
> multiple outgoing response messages (e.g. HTTP2).
>
> One of our use case is at the webserver.  The webserver tracks
> the HTTP2 response latency by measuring when the webserver sends
> the first byte to the socket till the TCP ACK of the last byte
> is received.  In the cases where we don't have client side
> measurement, measuring from the server side is the only option.
> In the cases we have the client side measurement, the server side
> data can also be used to justify/cross-check-with the client
> side data.
>
