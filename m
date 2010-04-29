From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Thu, 29 Apr 2010 15:49:40 +0200
Message-ID: <1272548980.2222.87.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
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
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57327 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759093Ab0D3SYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:24:06 -0400
Received: by bwz19 with SMTP id 19so301694bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:24:04 -0700 (PDT)
In-Reply-To: <1272548258.4258.185.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 09:37 -0400, jamal a =C3=A9crit :
> On Thu, 2010-04-29 at 15:21 +0200, Eric Dumazet wrote:
>=20
>=20
> >=20
> > You could try following program :
> >=20
>=20
> Will do later today (test machine is not on the network and is about =
20
> minutes from here; so worst case i will get you results by end of day=
)
> I guess this program is good enough since it tells me the system wide
> ipi count - what my patch did was also to break it down by which cpu =
got
> how many IPIs (served to check if there was uneven distribution)
>=20
> >=20
> > Is your application mono threaded and receiving data to 8 sockets ?
> >=20
>=20
> I fork one instance per detected cpu and bind to different ports each
> time. Example bind to port 8200 on cpu0, 8201 on cpu1, etc.
>=20

I guess this is the problem ;)

With RPS, you should not bind your threads to cpu.
This is the rps hash who will decide for you.


I am using following program :

/*
 *  Usage: udpsink [ -p baseport] nbports
 *
 */
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>

struct worker_data {
	int fd;
	unsigned long pack_count;
	unsigned long bytes_count;
	unsigned long _padd[16 - 3]; /* alignment */=20
};

void usage(int code)
{
	fprintf(stderr, "Usage: udpsink [-p baseport] nbports\n");
	exit(code);
}

void *worker_func(void *arg)
{
	struct worker_data *wdata =3D (struct worker_data *)arg;
	char buffer[4096];
	struct sockaddr_in addr;
	int lu;

	while (1) {
		socklen_t len =3D sizeof(addr);
		lu =3D recvfrom(wdata->fd, buffer, sizeof(buffer), 0, (struct sockadd=
r *)&addr, &len);
		if (lu > 0) {
			wdata->pack_count++;
			wdata->bytes_count +=3D lu;
		}
	}
}

int main(int argc, char *argv[])
{
int c;
int baseport =3D 4000;
int nbthreads;
struct worker_data *wdata;
unsigned long ototal =3D 0;
int concurrent =3D 0;
int verbose =3D 0;
int i;
	while ((c =3D getopt(argc, argv, "cvp:")) !=3D -1) {
		if (c =3D=3D 'p')
			baseport =3D atoi(optarg);
		else if (c =3D=3D 'c')
			concurrent =3D 1;
		else if (c =3D=3D 'v')
			verbose++;
		else usage(1);
	}
	if (optind =3D=3D argc)
		usage(1);
	nbthreads =3D atoi(argv[optind]);
	wdata =3D calloc(sizeof(struct worker_data), nbthreads);
	if (!wdata) {
		perror("calloc");
		return 1;
	}
	for (i =3D 0; i < nbthreads; i++) {
		struct sockaddr_in addr;
		pthread_t tid;

		if (i && concurrent) {
			wdata[i].fd =3D wdata[0].fd ;
		} else {
			wdata[i].fd =3D socket(PF_INET, SOCK_DGRAM, 0);
			if (wdata[i].fd =3D=3D -1) {
				perror("socket");
				return 1;
			}
			memset(&addr, 0, sizeof(addr));
			addr.sin_family =3D AF_INET;
//			addr.sin_addr.s_addr =3D inet_addr(argv[optind]);
			addr.sin_port =3D htons(baseport + i);
			if (bind(wdata[i].fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) =
{
				perror("bind");
				return 1;
				}
//			fcntl(wdata[i].fd, F_SETFL, O_NDELAY);
			}
		pthread_create(&tid, NULL, worker_func, wdata + i);
	}
	for (;;) {
		unsigned long total;
		long delta;

		sleep(1);
		total =3D 0;
		for (i =3D 0; i < nbthreads;i++) {
			total +=3D wdata[i].pack_count;
		}
		delta =3D total - ototal;
		if (delta) {
			printf("%lu pps (%lu", delta, total);
			if (verbose) {
				for (i =3D 0; i < nbthreads;i++) {=20
					if (wdata[i].pack_count)
						printf(" %d:%lu", i, wdata[i].pack_count);
				}
			}
			printf(")\n");
		}
		ototal =3D total;
	}
}



