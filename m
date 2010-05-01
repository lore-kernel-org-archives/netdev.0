From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 01 May 2010 07:57:04 +0200
Message-ID: <1272693424.2230.75.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
	 <1272660000.2230.4.camel@edumazet-laptop>  <1272672394.14499.1.camel@bigi>
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
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65318 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab0EAF5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 01:57:12 -0400
Received: by bwz19 with SMTP id 19so481102bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 22:57:10 -0700 (PDT)
In-Reply-To: <1272672394.14499.1.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 30 avril 2010 =C3=A0 20:06 -0400, jamal a =C3=A9crit :

> Yes, Nehalem.=20
> RPS off is better (~700Kpp) than RPS on(~650kpps). Are you seeing the
> same trend on the old hardware?
>=20

Of course not ! Or else RPS would be useless :(

I changed your program a bit to use EV_PERSIST, (to avoid epoll_ctl()
overhead for each packet...)

RPS off : 220.000 pps=20

RPS on (ee mask) : 700.000 pps  (with a slightly modified tg3 driver)
96% of delivered packets

This is on tg3 adapter, and tg3 has copybreak feature : small packets
are copied into skb of the right size.

define TG3_RX_COPY_THRESHOLD       256 -> 40 ...

We really should disable this feature for RPS workload,
unfortunatly ethtool cannot tweak this.

So profile of cpu 0 (RPS ON) looks like :

-----------------------------------------------------------------------=
-------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:99.7% [1000Hz cycles],  (all, cpu:=
 0)
-----------------------------------------------------------------------=
-------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ _______

              819.00 12.6% __alloc_skb            vmlinux
              592.00  9.1% eth_type_trans         vmlinux
              509.00  7.8% _raw_spin_lock         vmlinux
              475.00  7.3% __kmalloc_track_caller vmlinux
              358.00  5.5% tg3_read32             vmlinux
              345.00  5.3% __netdev_alloc_skb     vmlinux
              329.00  5.0% kmem_cache_alloc       vmlinux
              307.00  4.7% _raw_spin_lock_irqsave vmlinux
              284.00  4.4% bnx2_interrupt         vmlinux
              277.00  4.2% skb_pull               vmlinux
              248.00  3.8% tg3_poll_work          vmlinux
              202.00  3.1% __slab_alloc           vmlinux
              197.00  3.0% get_rps_cpu            vmlinux
              106.00  1.6% enqueue_to_backlog     vmlinux
               87.00  1.3% _raw_spin_lock_bh      vmlinux
               80.00  1.2% __copy_to_user_ll      vmlinux
               77.00  1.2% nommu_map_page         vmlinux
               77.00  1.2% __napi_gro_receive     vmlinux
               65.00  1.0% tg3_alloc_rx_skb       vmlinux
               60.00  0.9% skb_gro_reset_offset   vmlinux
               57.00  0.9% skb_put                vmlinux
               57.00  0.9% __slab_free            vmlinux


/*
 *  Usage: udpsnkfrk [ -p baseport] nbports
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
#include <event.h>

struct worker_data {
	struct event *snk_ev;
	struct event_base *base;
	struct timeval t;
	unsigned long pack_count;
	unsigned long bytes_count;
	unsigned long tout;
	int fd;			/* move to avoid hole on 64-bit */
	int pad1;=09
	unsigned long _padd[99]; /* avoid false sharing */
};

void usage(int code)
{
	fprintf(stderr, "Usage: udpsink [-p baseport] nbports\n");
	exit(code);
}

void process_recv(int fd, short ev, void *arg)
{
	char buffer[4096];
	struct sockaddr_in addr;
	socklen_t len =3D sizeof(addr);
	struct worker_data *wdata =3D (struct worker_data *)arg;
	int lu =3D 0;


	if (ev =3D=3D EV_TIMEOUT) {
		wdata->tout++;
		if ((event_add(wdata->snk_ev, &wdata->t)) < 0) {
			perror("cb event_add");
			return;
		}
	} else {
		do {
			lu =3D recvfrom(wdata->fd, buffer, sizeof(buffer), 0,
			      (struct sockaddr *)&addr, &len);
			if (lu > 0) {
				wdata->pack_count++;
				wdata->bytes_count +=3D lu;
			}
		} while (lu > 0);
	}
}

int prep_thread(struct worker_data *wdata)
{
	wdata->t.tv_sec =3D 1;
	wdata->t.tv_usec =3D random() % 50000L;

	wdata->base =3D event_init();
	event_set(wdata->snk_ev, wdata->fd, EV_READ|EV_PERSIST, process_recv, =
wdata);
	event_base_set(wdata->base, wdata->snk_ev);
	if ((event_add(wdata->snk_ev, &wdata->t)) < 0) {
		perror("event_add");
		return -1;
	}
	return 0;
}

void *worker_func(void *arg)
{
	struct worker_data *wdata =3D (struct worker_data *)arg;

	return (void *)event_base_loop(wdata->base, 0);
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
		else
			usage(1);
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
			wdata[i].fd =3D wdata[0].fd;
		} else {
			wdata[i].snk_ev =3D malloc(sizeof(struct event));
			if (!wdata[i].snk_ev)
				return 1;
			memset(wdata[i].snk_ev, 0, sizeof(struct event));

			wdata[i].fd =3D socket(PF_INET, SOCK_DGRAM, 0);
			if (wdata[i].fd =3D=3D -1) {
				free(wdata[i].snk_ev);
				perror("socket");
				return 1;
			}
			memset(&addr, 0, sizeof(addr));
			addr.sin_family =3D AF_INET;
//                      addr.sin_addr.s_addr =3D inet_addr(argv[optind]=
);
			addr.sin_port =3D htons(baseport + i);
			if (bind
			    (wdata[i].fd, (struct sockaddr *)&addr,
			     sizeof(addr)) < 0) {
				free(wdata[i].snk_ev);
				perror("bind");
				return 1;
			}
                      fcntl(wdata[i].fd, F_SETFL, O_NDELAY);
		}
		if (prep_thread(wdata + i)) {
			printf("failed to allocate thread %d, exit\n", i);
			exit(0);
		}
		pthread_create(&tid, NULL, worker_func, wdata + i);
	}

	for (;;) {
		unsigned long total;
		long delta;

		sleep(1);
		total =3D 0;
		for (i =3D 0; i < nbthreads; i++) {
			total +=3D wdata[i].pack_count;
		}
		delta =3D total - ototal;
		if (delta) {
			printf("%lu pps (%lu", delta, total);
			if (verbose) {
				for (i =3D 0; i < nbthreads; i++) {
					if (wdata[i].pack_count)
						printf(" %d:%lu", i,
						       wdata[i].pack_count);
				}
			}
			printf(")\n");
		}
		ototal =3D total;
	}
}



