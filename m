From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v4 3/3] net: ipv6: Use ip6_datagram_send_common
 in ping.
Date: Wed, 23 Apr 2014 21:22:23 +0900
Message-ID: <CAKD1Yr1bYu1Rtqi6cfSTsnq14dj+esOd=MsPaUs-CbqkFY5H8Q@mail.gmail.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398235078-27088-1-git-send-email-lorenzo@google.com> <1398235078-27088-3-git-send-email-lorenzo@google.com>
 <53579FD8.2090309@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:49844 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbaDWMWo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 08:22:44 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so4225956igc.1
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 05:22:43 -0700 (PDT)
In-Reply-To: <53579FD8.2090309@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 8:11 PM, Florent Fourcot
<florent.fourcot@enst-bretagne.fr> wrote:
> Le 22/04/2014 17:14, Lorenzo Colitti a =C3=A9crit :> +
>> +             if (sin6->sin6_family !=3D AF_INET6)
>> +                     return -EAFNOSUPPORT;
>> +
>
> It has before returned -EINVAL, it changes the return to the user spa=
ce.
> You made it consistent with other protocols, but perhaps should you a=
dd
> a notice in the commit changelog?

Actually I'm not sure what the correct value is. When you setsockopt
IPV6_V6ONLY and then send to a mapped address, the error you get
depends on what you're trying to do - ip6_datagram_connect returns
EAFNOSUPPORT, but udpv6_sendmsg, dccp_v6_connect and tcp_v6_connect
return ENETUNREACH. I think EINVAL is wrong. EAFNOSUPPORT is probably
best because the code doesn't support dual-stack ping sockets, but it
could.

There are probably very few users of this code at the moment, since
the code was only released in 3.12, and support hasn't made it into
iputils yet. And even there, ping just probably prints the error
message and exits. So I don't think it's a big deal to change the
return code.

>> -             if (sk->sk_bound_dev_if &&
>> -                 sk->sk_bound_dev_if !=3D u->sin6_scope_id) {
>> -                     return -EINVAL;
>> -             }
>
> What about this check now ?

I think that was incorrect. It would return EINVAL even if you did
something as simple as:

- Open an IPv6 ping socket.
- Bind it to eth0 with SO_BINDTODEVICE
- Send a ping to 2001:: without specifying a scope id.
