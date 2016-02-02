From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 1/7] tcp: apply Kern's check on RTTs used for
 congestion control
Date: Tue, 2 Feb 2016 15:28:54 -0800
Message-ID: <CAK6E8=fxGFuc=OkTWRjC+2FCDC0=hGm6GbQ4SRfj6M0OWy9GkA@mail.gmail.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
 <1445057867-32257-2-git-send-email-ycheng@google.com> <CA++eYdtOmvKi8h=GZ3TGC_gQXHfK6r4YgsvYWhY5geM5XY3fzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34848 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbcBBX3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 18:29:36 -0500
Received: by mail-wm0-f51.google.com with SMTP id r129so140977460wmr.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 15:29:35 -0800 (PST)
In-Reply-To: <CA++eYdtOmvKi8h=GZ3TGC_gQXHfK6r4YgsvYWhY5geM5XY3fzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2016 at 11:30 AM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
>
> On Sat, Oct 17, 2015 at 6:57 AM, Yuchung Cheng <ycheng@google.com> wrote:
> > Currently ca_seq_rtt_us does not use Kern's check. Fix that by
> > checking if any packet acked is a retransmit, for both RTT used
> > for RTT estimation and congestion control.
> >
> *snip*
>
> This patch (commit 9e45a3e) puzzles me, because Karn's check was
> already in effect:
> http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c?v=4.3#L3117
>
> Since first_ackt/last_ackt is only set when non-retransmitted packets
> are ACKed (sequentially), we know them to be unambiguous samples for
> RTTM. Even if a (sequential) ACK covers retransmitted packets, we can
> still make a valid RTTM if that ACK also covers non-retransmitted
> packets. But this patch seems to prevent that?
Perhaps the commit message is not clear. Here is an example: an ACK
acks 2 packets where the 1st packet was retransmitted but the 2nd
packet is not.

Since we don't know if the ACk was caused by the retransmission (plugs
a hole) or by the original, we should not take an RTT sample. In other
words, we should refrain from taking RTT sample as long as the ACK
covers any retransmitted sequence.
