From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Thu, 29 Apr 2010 15:21:47 +0200
Message-ID: <1272547307.2222.83.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:56169 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933482Ab0D3Rw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:52:56 -0400
Received: by bwz19 with SMTP id 19so286405bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:52:54 -0700 (PDT)
In-Reply-To: <1272547061.4258.174.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 09:17 -0400, jamal a =C3=A9crit :

> Could we have some stat in there that shows IPIs being produced? I th=
ink
> it would help to at least observe any changes over variety of tests.
> I did try to patch my system during the first few tests to record IPI=
s
> but it seems to make more sense to have it as a perf stat.
>=20
> > Even with 200.000 IPI per second, 'perf top -C CPU_IPI_sender' show=
s
> > that sending IPI is very cheap (maybe ~1% of cpu cycles)
> >=20
> > # Samples: 32033467127
> > #
>=20
> One thing i observed is our profiles seem different. Could you send m=
e
> your .config for a single nehalem and i will try to go as close as
> possible to it? I have a sky2 instead of bnx - but i suspect everythi=
ng
> else will be very similar...
> I apologize i dont have much time to look into details - but what i c=
an
> do is test at least.

I'am going to redo some test on my 'old machine', with tg3 driver.

You could try following program :


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

struct softnet_stat_vals {
	int flip;
	unsigned int tab[2][10];
};

int read_file(struct softnet_stat_vals *v)
{
	char buffer[1024];
	FILE *F =3D fopen("/proc/net/softnet_stat", "r");

	v->flip ^=3D 1;
	if (!F)
		return -1;

	memset(v->tab[v->flip], 0, 10 * sizeof(unsigned int));
	while (fgets(buffer, sizeof(buffer), F)) {
		int i, pos =3D 0;
		unsigned int val;
=09
		for (i =3D 0; ;) {
			if (sscanf(buffer + pos, "%08x", &val) !=3D 1) break;
			v->tab[v->flip][i] +=3D val;
			pos +=3D 9;
			if (++i =3D=3D 10)
				break;
			}
		}
	fclose(F);

}


int main(int argc, char *argv[])
{
	struct softnet_stat_vals *v =3D calloc(sizeof(struct softnet_stat_vals=
), 1);
=09
	read_file(v);
	for (;;) {
		sleep(1);
		read_file(v);
		printf("%u rps\n", v->tab[v->flip][9] - v->tab[v->flip^1][9]);
	}
}


