From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v4 3/3] net: ipv6: Use ip6_datagram_send_common
 in ping.
Date: Fri, 25 Apr 2014 00:35:21 +0900
Message-ID: <CAKD1Yr0FWRmmC1BkrADnrSRvbD3_J7fO8SR8gqgEz8exfqD01w@mail.gmail.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398235078-27088-1-git-send-email-lorenzo@google.com> <1398235078-27088-3-git-send-email-lorenzo@google.com>
 <53579FD8.2090309@enst-bretagne.fr> <CAKD1Yr1bYu1Rtqi6cfSTsnq14dj+esOd=MsPaUs-CbqkFY5H8Q@mail.gmail.com>
 <20140424150657.GG1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Lorenzo Colitti <lorenzo@google.com>,
	Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:43270 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbaDXPfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:35:42 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so2444483iec.25
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 08:35:41 -0700 (PDT)
In-Reply-To: <20140424150657.GG1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 12:06 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> There are probably very few users of this code at the moment, since
>> the code was only released in 3.12, and support hasn't made it into
>> iputils yet. And even there, ping just probably prints the error
>> message and exits. So I don't think it's a big deal to change the
>> return code.
>
> Sure, but we don't know about other applications. Wouldn't it be just easier
> and leave this as is for now and finally let ipv6 ping sockets also handle
> ipv4? I looked at it some time ago and it didn't look complicated.

I tried this today, but it's trickier than it looks. If you just
naively call ping_v4_sendmsg, then things almost work, except the
protocol field in the IPv4 header is set to 58 (ICMPv6) instead of 1
(ICMP).

The reason is that we call ping_v4_push_pending_frames ->
ip_push_pending_frames -> ip_finish_skb -> __ip_make_skb , which ends
up doing:

      iph->protocol = sk->sk_protocol;

Passing down the protocol all through that call chain seems overkill,
because in basically every case except ICMP on a dual-stack socket,
the protocol you want is in fact sk->sk_protocol.

I suppose that since ping_v4_push_pending_frames gets called with the
socket locked, we might be able to get away with setting
sk->sk_protocol just before ping_v4_push_pending_frames and restoring
it afterwards. But that feels hacky and I don't know what else it
could break.
