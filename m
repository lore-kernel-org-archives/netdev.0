From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: PKTINFO doesnt need dst reference
Date: Wed, 09 Nov 2011 23:03:03 +0100
Message-ID: <1320876183.3272.8.camel@edumazet-laptop>
References: <1320673364.3020.21.camel@bwh-desktop>
	 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111109.163708.2156133928191684256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37013 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab1KIWDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 17:03:08 -0500
Received: by eye27 with SMTP id 27so1911046eye.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 14:03:07 -0800 (PST)
In-Reply-To: <20111109.163708.2156133928191684256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 novembre 2011 =C3=A0 16:37 -0500, David Miller a =C3=A9c=
rit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 09 Nov 2011 18:24:35 +0100
>=20
> > [PATCH net-next] ipv4: IP_PKTINFO doesnt need dst reference
> >=20
> > When a socket uses IP_PKTINFO notifications, we currently force a d=
st
> > reference for each received skb. Reader has to access dst to get ne=
eded
> > information (rt_iif & rt_spec_dst) and must release dst reference.
> >=20
> > We also forced a dst reference if skb was put in socket backlog, ev=
en
> > without IP_PKTINFO handling. This happens under stress/load.
> >=20
> > We can instead store the needed information in skb->cb[], so that o=
nly
> > softirq handler really access dst, improving cache hit ratios.
> >=20
> > This removes two atomic operations per packet, and false sharing as
> > well.
> >=20
> > On a benchmark using a mono threaded receiver (doing only recvmsg()
> > calls), I can reach 720.000 pps instead of 570.000 pps.
> >=20
> > IP_PKTINFO is typically used by DNS servers, and any multihomed awa=
re
> > UDP application.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Looks good, if it compiles I'll push it out to net-next :-)

Arg :(  I cross my fingers :)

BTW, on my bnx2x adapter, even small UDP frames use more than PAGE_SIZE
bytes :

skb->truesize=3D4352 len=3D26 (payload only)

Truesize being now more precise, we hit badly the shared
udp_memory_allocated, even with single frames.

I wonder if we shouldnt increase SK_MEM_QUANTUM a bit to avoid
ping/pong...

-#define SK_MEM_QUANTUM ((int)PAGE_SIZE)
+#define SK_MEM_QUANTUM ((int)PAGE_SIZE * 2)
