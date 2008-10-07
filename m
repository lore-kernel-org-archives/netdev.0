From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 07:24:45 +0200
Message-ID: <48EAF29D.8050203@cosmosbay.com>
References: <20081006185026.GA10383@minyard.local>	<48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: minyard@acm.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.101]:61892 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbYJGFZS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 01:25:18 -0400
In-Reply-To: <20081006.144002.56418911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 06 Oct 2008 23:22:31 +0200
>=20
>> Me wondering what impact this synchronize_rcu() can have on mono-thr=
eaded
>> VOIP applications using lot of UDP sockets. What is the maximum dela=
y of
>> this function ?
>=20
> The cost is enormous, we really can't use it here.
>=20
> I have a patch that did top-level socket destruction using RCU,
> and that didn't use synchronize_rcu(), and that killed connection
> rates by up to %20.
>=20
> I can only imagine what the cost would be if I had to add such a call
> in there.
>=20
> Really, I can't consider these changes seriously, as-is.

Yes, I suppose you are right about TCP sessions, that should stay as th=
ey are.

Then if we use call_rcu() RCU freeing only for UDP sockets, we should g=
et rid of
taking this rwlock each time we handle an incoming datagram, and introd=
uce
no extra cost for other sockets.

Most UDP sockets are setup for long periods (RTP trafic), or if an appl=
ication really
wants to {open/send or receive one UDP frame/close} many sockets, it al=
ready hits
RCU handling of its file structures and should not be slowed down that =
much.

By 'long period' I mean thousand of packets sent/received by each RTP s=
ession, being
voice (50 packets/second) or even worse video...




