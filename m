From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net v2] sctp: start t5 timer only when peer.rwnd is 0 and
 local.state is SHUTDOWN_PENDING
Date: Thu, 27 Aug 2015 21:19:32 +0800
Message-ID: <CADvbK_cZhT3crJhP-5HQVpm=iAYTCDkiBNnDNCibvfOvEyzN7w@mail.gmail.com>
References: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>
	<55DB5ED2.1050702@redhat.com>
	<20150824183146.GB1873@localhost.localdomain>
	<55DB644B.1090305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	network dev <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@infradead.org>, davem <davem@davemloft.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36352 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbbH0NTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 09:19:33 -0400
Received: by oibi18 with SMTP id i18so5607097oib.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 06:19:33 -0700 (PDT)
In-Reply-To: <55DB644B.1090305@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> No, these are 2 distinct instances.  In one instance, the peer is reachable and
> is able to communication 0 rwnd state to us.  Thus we are being nice and granting
> the peer more time to exit the 0 window state.
>
> In the other state, the peer is unreachable and we just happen to hit the 0-window
> condition based on some estimations of the peer window.  In this case, we should
> be subject to the Max.RTX and terminate the association sooner.
>
> -vlad
>
okay, I got you,

we can see that local update their peer.rwnd in sctp_packet_append_data() and
sctp_retransmit_mark(), it do that according to a_rwnd and outstanding, so the
root reason is that it's hard to know that peer really closed it's window, maybe
just so many outstanding lead to that.

what we can do is to trust peer.rwnd is the real window in peer.
from another angle,  even though it's not real, at least we can reduce the
* the other state* you mentioned by doing this. especially, if there is only one
small packet keep retransmitting in SHUTDOWN_PENDING state, the
peer.rwnd is more believable to be the real peer window.

I saw bsd code didnot care about Max.Retrans in SHUTDOWN_PENDING,
instead it just start T5 timer. but now that we choose Max.Retrans + T5, it's
better to process more unreachable by using Max.Retrans. I also hope we can
do it better there as Marcelo said, but by now I cannot see it. :)
