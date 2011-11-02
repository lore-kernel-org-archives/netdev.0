From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 3.1-rc9
Date: Wed, 02 Nov 2011 18:58:21 +0100
Message-ID: <1320256701.2292.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318874090.4172.84.camel@twins>
	 <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com>
	 <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos>
	 <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins>
	 <20111018182046.GF1309@hostway.ca>
	 <alpine.LFD.2.02.1110182146440.3240@ionos>
	 <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca>
	 <20111031173246.GA10614@hostway.ca>
	 <alpine.LFD.2.02.1111021725550.2829@ionos>
	 <1320254854.2292.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320256157.2292.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Kirby <sim@hostway.ca>, David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320256157.2292.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 02 novembre 2011 =C3=A0 18:49 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mercredi 02 novembre 2011 =C3=A0 18:27 +0100, Eric Dumazet a =C3=A9=
crit :
>=20
> > I believe it might come from commit 0e734419
> > (ipv4: Use inet_csk_route_child_sock() in DCCP and TCP.)
> >=20
> > In case inet_csk_route_child_sock() returns NULL, we dont release s=
ocket
> > lock.
> >=20
> >=20
>=20
> Yes, thats the problem. I am testing following patch :
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 0ea10ee..683d97a 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1510,6 +1510,7 @@ exit:
>  	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
>  	return NULL;
>  put_and_exit:
> +	bh_unlock_sock(newsk);
>  	sock_put(newsk);
>  	goto exit;
>  }
>=20


This indeed solves the problem, but more closer inspection is needed to
close all bugs, not this only one.

# netstat -s
Ip:
    6961157 total packets received
    0 forwarded
    0 incoming packets discarded
    6961157 incoming packets delivered
    6961049 requests sent out
    2 dropped because of missing route    //// HERE, this is the origin
