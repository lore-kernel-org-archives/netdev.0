From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2] sctp: start t5 timer only when peer.rwnd is 0
 and local.state is SHUTDOWN_PENDING
Date: Thu, 27 Aug 2015 09:30:14 -0400
Message-ID: <55DF10E6.3010007@redhat.com>
References: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>	<55DB5ED2.1050702@redhat.com>	<20150824183146.GB1873@localhost.localdomain>	<55DB644B.1090305@redhat.com> <CADvbK_cZhT3crJhP-5HQVpm=iAYTCDkiBNnDNCibvfOvEyzN7w@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	network dev <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@infradead.org>, davem <davem@davemloft.net>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49554 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbbH0NaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 09:30:16 -0400
In-Reply-To: <CADvbK_cZhT3crJhP-5HQVpm=iAYTCDkiBNnDNCibvfOvEyzN7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2015 09:19 AM, lucien xin wrote:
>>
>> No, these are 2 distinct instances.  In one instance, the peer is reachable and
>> is able to communication 0 rwnd state to us.  Thus we are being nice and granting
>> the peer more time to exit the 0 window state.
>>
>> In the other state, the peer is unreachable and we just happen to hit the 0-window
>> condition based on some estimations of the peer window.  In this case, we should
>> be subject to the Max.RTX and terminate the association sooner.
>>
>> -vlad
>>
> okay, I got you,
> 
> we can see that local update their peer.rwnd in sctp_packet_append_data() and
> sctp_retransmit_mark(), it do that according to a_rwnd and outstanding, so the
> root reason is that it's hard to know that peer really closed it's window, maybe
> just so many outstanding lead to that.
> 
> what we can do is to trust peer.rwnd is the real window in peer.
> from another angle,  even though it's not real, at least we can reduce the
> * the other state* you mentioned by doing this. especially, if there is only one
> small packet keep retransmitting in SHUTDOWN_PENDING state, the
> peer.rwnd is more believable to be the real peer window.
> 
> I saw bsd code didnot care about Max.Retrans in SHUTDOWN_PENDING,
> instead it just start T5 timer. but now that we choose Max.Retrans + T5, it's
> better to process more unreachable by using Max.Retrans. I also hope we can
> do it better there as Marcelo said, but by now I cannot see it. :)
> 

So one potential way is to have peer.rwnd and peer.a_rwnd, where peer.a_rwnd is
the window advertised by peer and peer.rwnd and our estimation based on peer.a_rwnd.
This way we will always know where we stand.

Although I am not sure yet if we want to grow the peer structure any more.

Another way is to have an estimate or 0-window probe bit/flags one the send side
and set it when we do 0-window probe.  This way we'd know that when 0-window probe
bit is set, peer returned 0 window.

Just some thoughts.
-vlad
