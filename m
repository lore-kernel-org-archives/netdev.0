From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: state of rtcache removal...
Date: Thu, 17 Feb 2011 07:25:15 +0100
Message-ID: <1297923915.2645.24.camel@edumazet-laptop>
References: <20110216.160838.39164069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57320 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab1BQGZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 01:25:22 -0500
Received: by bwz15 with SMTP id 15so1381221bwz.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 22:25:20 -0800 (PST)
In-Reply-To: <20110216.160838.39164069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 16:08 -0800, David Miller a =C3=
=A9crit :
> So I've been testing out the routing cache removal patch to see
> what the impact is on performance.
>=20
> I'm using a UDP flood to a single IP address over a dummy interface
> with hard coded ARP entries, so that pretty much just the main IP
> output and routing paths are being exercised.
>=20
> The UDP flood tool I cooked up based upon a description sent to me by
> Eric Dumazet of a similar utility he uses for testing.  I've included
> the code to this tool at the end of this email, as well as the dummy
> interface setup script.   Basically, you go:
>=20
> bash# ./udpflood_setup.sh
> bash# time ./udpflood -l 10000 10.2.2.11
>=20
> The IP output path is about twice as slow with the routing cache
> removed entirely.  Here are the numbers I have:
>=20
> net-next-2.6, rt_cache on:
>=20
> davem@maramba:~$ time udpflood -l 10000000 10.2.2.11
> real		 1m47.012s
> user		 0m8.670s
> sys		 1m38.370s
>=20
> net-next-2.6, rt_cache turned off via sysctl:
>=20
> davem@maramba:~$ time udpflood -l 10000000 10.2.2.11
> real		 3m12.662s
> user		 0m9.490s
> sys		 3m3.220s
>=20
> net-next-2.6 + "BONUS" rt_cache deletion patch:
>=20
> maramba:/home/davem# time ./bin/udpflood -l 10000000 10.2.2.11
> real		     3m9.921s
> user		     0m9.520s
> sys		     3m0.440s
>=20
> I then worked on some simplifications of the code in net/ipv4/route.c
> that remains after the cache removal.  I'll post those patches after
> I've chewed on them some more, but they knock a couple seconds back o=
ff
> of the benchmark:
>=20
> The profile output is what you'd expect, with fib_table_lookup() topp=
ing
> the charts taking ~%10 of the time.
>=20
> What might not be initially apparent is that each output route lookup
> results in two calls to fib_table_lookup() and thus two trie lookups.
> Why?  Because we have two routing tables (3 with IP_MULTIPLE_TABLES
> enabled) that get searched, first the LOCAL then the MAIN table (then
> with mutliple-tables enabled, the DEFAULT).  And most external
> outgoing routes sit in the MAIN table.
>=20
> We do this so we can store all the interface address network,
> broadcast, loopback network, et al. routes in the LOCAL table, then a=
ll
> globally visible routes in the MAIN table.
>=20
> Anyways, the long and short of this is that route lookups take two
> trie lookups instead of just one.  On input there are even more, for
> source address validation done by fib_validate_source().  That can be
> up to 4 more fib_table_lookup() invocations.
>=20
> Add in another level of complexity if you have a series of FIB rules
> installed.
>=20
> So, to me, this means that spending time micro-optiming fib_trie is
> not going to help much.  Getting rid of that multiplier somehow, on
> the other hand, might.
>=20
> I plan to play with some ideas, such as sticking fib_alias entries in=
to
> the flow cache and consulting/populating the flow cache on fib_lookup=
()
> calls.
>=20
> -------------------- udpflood.c --------------------
> /* An adaptation of Eric Dumazet's udpflood tool.  */
>=20
> #include <stdio.h>
> #include <stddef.h>
> #include <malloc.h>
> #include <string.h>
> #include <errno.h>
>=20
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <arpa/inet.h>
>=20
> #define _GNU_SOURCE
> #include <getopt.h>
>=20
> static int usage(void)
> {
> 	printf("usage: udpflood [ -l count ] [ -m message_size ] IP_ADDRESS\=
n");
> 	return -1;
> }
>=20
> static int send_packets(in_addr_t addr, int port, int count, int msg_=
sz)
> {
> 	char *msg =3D malloc(msg_sz);
> 	struct sockaddr_in saddr;
> 	int fd, i, err;
>=20
> 	if (!msg)
> 		return -ENOMEM;
>=20
> 	memset(msg, 0, msg_sz);
>=20
> 	memset(&saddr, 0, sizeof(saddr));
> 	saddr.sin_family =3D AF_INET;
> 	saddr.sin_port =3D port;
> 	saddr.sin_addr.s_addr =3D addr;
>=20
> 	fd =3D socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
> 	if (fd < 0) {
> 		perror("socket");
> 		err =3D fd;
> 		goto out_nofd;
> 	}
> 	err =3D connect(fd, (struct sockaddr *) &saddr, sizeof(saddr));
> 	if (err < 0) {
> 		perror("connect");
> 		close(fd);
> 		goto out;
> 	}
> 	for (i =3D 0; i < count; i++) {
> 		err =3D sendto(fd, msg, msg_sz, 0,
> 			     (struct sockaddr *) &saddr, sizeof(saddr));
> 		if (err < 0) {
> 			perror("sendto");
> 			goto out;
> 		}
> 	}
>=20
> 	err =3D 0;
> out:
> 	close(fd);
> out_nofd:
> 	free(msg);
> 	return err;
> }
>=20
> int main(int argc, char **argv, char **envp)
> {
> 	int port, msg_sz, count, ret;
> 	in_addr_t addr;
>=20
> 	port =3D 6000;
> 	msg_sz =3D 32;
> 	count =3D 10000000;
>=20
> 	while ((ret =3D getopt(argc, argv, "l:s:p:")) >=3D 0) {
> 		switch (ret) {
> 		case 'l':
> 			sscanf(optarg, "%d", &count);
> 			break;
> 		case 's':
> 			sscanf(optarg, "%d", &msg_sz);
> 			break;
> 		case 'p':
> 			sscanf(optarg, "%d", &port);
> 			break;
> 		case '?':
> 			return usage();
> 		}
> 	}
>=20
> 	if (!argv[optind])
> 		return usage();
>=20
> 	addr =3D inet_addr(argv[optind]);
> 	if (addr =3D=3D INADDR_NONE)
> 		return usage();
>=20
> 	return send_packets(addr, port, count, msg_sz);
> }
>=20
> -------------------- udpflood_setup.sh --------------------
> #!/bin/sh
> modprobe dummy
> ifconfig dummy0 10.2.2.254 netmask 255.255.255.0 up
>=20
> for f in $(seq 11 26)
> do
>  arp -H ether -i dummy0 -s 10.2.2.$f 00:00:0c:07:ac:$f
> done
> --

Thanks David for this work in progress.

If I remember my works in last October/November, I also know fib_hash
was a bit faster than fib_trie (around 20%)...




