From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Wed, 1 Feb 2012 02:48:21 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5B932C9@EUSAACMS0702.eamcs.ericsson.se>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have
 listener>	 <1328053998-2498-1-git-send-email-shawn.lu@ericsson.com>
 <1328072958.2617.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:53373 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab2BAHsb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 02:48:31 -0500
In-Reply-To: <1328072958.2617.34.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric:

How about change the title and log to following:

  tcp: md5: RST: getting md5 key from listener

    TCP RST mechanism is broken in TCP md5(RFC2385). When
    connection is gone, md5 key is lost, sending RST
    without md5 hash is deem to ignored by peer. This can
    be a problem since RST help protocal like bgp to fast
    recove from peer crash.

    In most case, users of tcp md5, such as bgp and ldp,
    have listener on both side to accept connection from peer.
    md5 keys for peers are saved in listening socket.

    There are two cases in finding md5 key when connection is
    lost:
    1.Passive receive RST: The message is send to well known port,
    tcp will associate packet with listener. md5 key can be gotten
    from listener.

    2.Active receive RST (no sock): The message is send to ative
    side, there is no socket associated with message. In this case,
    finding listener from source port, then find md5 key from
    listener.

    we are not loosing sercuriy here:
    packet is checked with md5 hash. No RST is generated
    if md5 hash doesn't match or no md5 key can be found.

Note:
Will send out a new version that is on top of your new patch
-- "tcp: md5: protects md5sig_info with RCU"


-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Tuesday, January 31, 2012 9:09 PM
To: Shawn Lu
Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
Subject: Re: [PATCH] tcp: md5: fix md5 RST when both sides have listene=
r

Le mardi 31 janvier 2012 =E0 15:53 -0800, Shawn Lu a =E9crit :
> TCP RST mechanism is broken in TCP md5(RFC2385). When connection is=20
> gone, md5 key is lost, sending RST without md5 hash is deem to ignore=
d=20
> by peer. This can be a problem since RST help protocal like bgp to=20
> fast recove from peer crash.
>=20
> In most case, users of tcp md5, such as bgp and ldp, have listeners o=
n=20
> both sides. md5 keys for peers are saved in listening socket. When=20
> passive side connection is gone, we can still get md5 key from=20
> listening socket.
> When active side of connection is gone, we can try to find listening=20
> socket through source port, and then md5 key.
> we are not loosing sercuriy here:
> packet is valified checked with md5 hash. No RST is generated if md5=20
> hash doesn't match or no md5 key can be found.
>=20
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---

Small notes :=20

1) Always add [PATCH Vx] on your submission if it was a new version of =
a previous patch. (V2, V3, V4, ...)

If possible, add after the "---" separator an explanation of what chang=
ed in your new submission :

V3: added some rcu_read_lock()/rcu_read_unlock() sections

2) Also patch title and changelog are a bit confusing.

Only the machine receiving the TCP message and answering by RST message=
 needs a listener, in case tcp frame cannot be associated to an existin=
g tcp socket (ESTABLISHED or TIMEWAIT).

The other side doesnt need a listener, only a client using TCP MD5 opti=
on in its socket.

Other than that, your patch seems fine to me.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
