From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.8)
Date: Fri, 14 Jan 2011 12:32:51 +0100
Message-ID: <1295004771.3937.8.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop>  <20110113153436.70d3c0a3@s6510>
	 <1294975793.3403.117.camel@edumazet-laptop>
	 <1294976067.3403.118.camel@edumazet-laptop>
	 <1294977498.3403.127.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41849 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab1ANLc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 06:32:56 -0500
Received: by wyb28 with SMTP id 28so2721105wyb.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 03:32:54 -0800 (PST)
In-Reply-To: <1294977498.3403.127.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 04:58 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le vendredi 14 janvier 2011 =C3=A0 04:34 +0100, Eric Dumazet a =C3=A9=
crit :
>=20
> > Hmm, please wait a bit, I had another crash when I stopped my
> > bench/stress
>=20
> I am not sure p->qavg is correctly computed.
>=20
> Crash happened because choke_peek_random() was called while no packet
> was in queue.
>=20
> With my params (min=3D10833 max=3D32500 burst=3D18055 limit=3D130000)=
 this
> implies qavg was very big while qlen=3D=3D0 !
>=20
> qdisc choke 11: dev ifb0 parent 1:11 limit 130000b min 10833b max 325=
00b ewma 13 Plog 21 Scell_log 30
>  Sent 200857857 bytes 365183 pkt (dropped 1010937, overlimits 557577 =
requeues 0)=20
>  rate 32253Kbit 7330pps backlog 17875996b 32505p requeues 0=20
>   marked 0 early 557577 pdrop 0 other 0 matched 226680

Moving the qdisc_bstats_update(sch, skb); out of choke_enqueue() to
choke_dequeue(), I get nicer rate values (because packets that are
enqueued but CHOKed dont artificialy raise the packet/byte rates)

Now, rate properly matches my 10Mbit CBQ bandwidth :

qdisc choke 11: parent 1:11 limit 130000b min 10833b max 32500b ewma 13=
 Plog 21 Scell_log 30
 Sent 86470970 bytes 157418 pkt (dropped 127451, overlimits 48275 reque=
ues 0)=20
 rate 9947Kbit 2264pps backlog 17759368b 32288p requeues 0=20
  marked 0 early 48275 pdrop 0 other 0 matched 39588


=46or other qdiscs, it is less easy because qdisc_bstats_update() call =
is
integrated in __qdisc_enqueue_tail() / qdisc_enqueue_tail(), so all
users shall be updated at once.





