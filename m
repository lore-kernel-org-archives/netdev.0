From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] iputils: Add capability dropping
Date: Tue, 21 Feb 2012 20:59:39 +0900
Message-ID: <4F43872B.1030700@linux-ipv6.org>
References: <4F2EBC40.2080500@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: =?ISO-8859-1?Q?=C1ngel_Gonz=E1lez?= <ingenit@zoho.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51715 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754847Ab2BUL7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 06:59:42 -0500
In-Reply-To: <4F2EBC40.2080500@zoho.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied. Thank you.

=C1ngel Gonz=E1lez wrote:
> This patch adds support for dropping capabilities to the iputils prog=
rams
> which need root privileges (ping, ping6, clockdiff, traceroute6), so =
that
> users installing them suid can instead install them setcap cap_net_ra=
w+ep
>
> The feature adds libcap as a requisite. In order to disable the featu=
re
>   sed -i "s/-DCAPABILITIES//;s/ -lcap//" Makefile
>
>
> Signed-off-by: =C1ngel Gonz=E1lez<ingenit@zoho.com>
> ---
>
> diff -ur iputils/Makefile iputils-capabilities/Makefile
> --- iputils/Makefile	2012-01-10 02:42:52.000000000 +0100
> +++ iputils-capabilities/Makefile	2012-02-05 17:40:18.000000000 +0100
> @@ -14,7 +14,7 @@
>   # What a pity, all new gccs are buggy and -Werror does not work. Si=
gh.
>   #CCOPT=3D-D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -g -Werror
>   CCOPT=3D-D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -g
> -CFLAGS=3D$(CCOPT) $(GLIBCFIX) $(DEFINES)
> +CFLAGS=3D$(CCOPT) $(GLIBCFIX) $(DEFINES) -DCAPABILITIES
>
>   IPV4_TARGETS=3Dtracepath ping clockdiff rdisc arping tftpd rarpd
>   IPV6_TARGETS=3Dtracepath6 traceroute6 ping6
> @@ -25,11 +25,12 @@
>
>   all: $(TARGETS)
>
> -
> +clockdiff: -lcap
> +traceroute6: -lcap
>   tftpd: tftpd.o tftpsubs.o
> -arping: arping.o -lsysfs
> -ping: ping.o ping_common.o
> -ping6: ping6.o ping_common.o -lresolv -lcrypto
> +arping: arping.o -lsysfs -lcap
> +ping: ping.o ping_common.o -lcap
> +ping6: ping6.o ping_common.o -lresolv -lcrypto -lcap
>   ping.o ping6.o ping_common.o: ping_common.h
>   tftpd.o tftpsubs.o: tftp.h
>
> diff -ur iputils/arping.c iputils-capabilities/arping.c
> --- iputils/arping.c	2012-01-10 02:42:52.000000000 +0100
> +++ iputils-capabilities/arping.c	2012-02-05 17:23:53.000000000 +0100
> @@ -22,6 +22,9 @@
>   #include<linux/if_ether.h>
>   #include<net/if_arp.h>
>   #include<sys/uio.h>
> +#ifdef CAPABILITIES
> +#include<sys/capability.h>
> +#endif
>
>   #include<netdb.h>
>   #include<unistd.h>
> @@ -356,6 +359,17 @@
>   		exit(-1);
>   	}
>
> +#ifdef CAPABILITIES
> +	{
> +		cap_t caps =3D cap_init();
> +		if (cap_set_proc(caps)) {
> +			perror("arping: cap_set_proc");
> +			exit(-1);
> +		}
> +		cap_free(caps);
> +	}
> +#endif
> +
>   	while ((ch =3D getopt(argc, argv, "h?bfDUAqc:w:s:I:V")) !=3D EOF) =
{
>   		switch(ch) {
>   		case 'b':
> diff -ur iputils/clockdiff.c iputils-capabilities/clockdiff.c
> --- iputils/clockdiff.c	2012-01-10 02:42:52.000000000 +0100
> +++ iputils-capabilities/clockdiff.c	2012-02-05 17:33:14.000000000 +0=
100
> @@ -20,6 +20,9 @@
>   #include<arpa/inet.h>
>   #include<errno.h>
>   #include<linux/types.h>
> +#ifdef CAPABILITIES
> +#include<sys/capability.h>
> +#endif
>
>   void usage(void) __attribute__((noreturn));
>
> @@ -530,6 +533,20 @@
>     exit(1);
>   }
>
> +void drop_rights(void) {
> +#ifdef CAPABILITIES
> +	cap_t caps =3D cap_init();
> +	if (cap_set_proc(caps)) {
> +		perror("clockdiff: cap_set_proc");
> +		exit(-1);
> +	}
> +	cap_free(caps);
> +#endif
> +	if (setuid(getuid())) {
> +		perror("clockdiff: setuid");
> +		exit(-1);
> +	}
> +}
>
>   int
>   main(int argc, char *argv[])
> @@ -541,10 +558,7 @@
>   	int n_errno =3D 0;
>
>   	if (argc<  2) {
> -		if (setuid(getuid())) {
> -			perror("clockdiff: setuid");
> -			exit(-1);
> -		}
> +		drop_rights();
>   		usage();
>   	}
>
> @@ -554,11 +568,7 @@
>   	errno =3D 0;
>   	if (nice(-16) =3D=3D -1)
>   		n_errno =3D errno;
> -
> -	if (setuid(getuid())) {
> -		perror("clockdiff: setuid");
> -		exit(-1);
> -	}
> +	drop_rights();
>
>   	if (argc =3D=3D 3) {
>   		if (strcmp(argv[1], "-o") =3D=3D 0) {
> diff -ur iputils/ping.c iputils-capabilities/ping.c
> --- iputils/ping.c	2012-01-10 02:42:52.000000000 +0100
> +++ iputils-capabilities/ping.c	2012-02-05 17:33:51.000000000 +0100
> @@ -62,6 +62,9 @@
>
>   #include<netinet/ip.h>
>   #include<netinet/ip_icmp.h>
> +#ifdef CAPABILITIES
> +#include<sys/capability.h>
> +#endif
>
>   #ifndef ICMP_FILTER
>   #define ICMP_FILTER	1
> @@ -131,6 +134,16 @@
>   		perror("ping: setuid");
>   		exit(-1);
>   	}
> +#ifdef CAPABILITIES
> +	{
> +		cap_t caps =3D cap_init();
> +		if (cap_set_proc(caps)) {
> +			perror("ping: cap_set_proc");
> +			exit(-1);
> +		}
> +		cap_free(caps);
> +	}
> +#endif
>
>   	source.sin_family =3D AF_INET;
>
> diff -ur iputils/ping6.c iputils-capabilities/ping6.c
> --- iputils/ping6.c	2012-01-10 02:42:52.000000000 +0100
> +++ iputils-capabilities/ping6.c	2012-02-05 17:33:44.000000000 +0100
> @@ -72,6 +72,9 @@
>   #include<netinet/ip6.h>
>   #include<netinet/icmp6.h>
>   #include<resolv.h>
> +#ifdef CAPABILITIES
> +#include<sys/capability.h>
> +#endif
>
>   #include "ping6_niquery.h"
>
> @@ -551,9 +554,19 @@
>
>   	uid =3D getuid();
>   	if (setuid(uid)) {
> -		perror("ping: setuid");
> +		perror("ping6: setuid");
>   		exit(-1);
>   	}
> +#ifdef CAPABILITIES
> +	{
> +		cap_t caps =3D cap_init();
> +		if (cap_set_proc(caps)) {
> +			perror("ping6: cap_set_proc");
> +			exit(-1);
> +		}
> +		cap_free(caps);
> +	}
> +#endif
>
>   	source.sin6_family =3D AF_INET6;
>   	memset(&firsthop, 0, sizeof(firsthop));
> diff -ur iputils/traceroute6.c iputils-capabilities/traceroute6.c
> --- iputils/traceroute6.c	2012-01-10 02:42:52.000000000 +0100
> +++ iputils-capabilities/traceroute6.c	2012-02-05 17:33:59.000000000 =
+0100
> @@ -249,6 +249,9 @@
>   #include<netinet/ip6.h>
>   #include<netinet/icmp6.h>
>   #include<linux/types.h>
> +#ifdef CAPABILITIES
> +#include<sys/capability.h>
> +#endif
>
>   #include<arpa/inet.h>
>
> @@ -342,6 +345,16 @@
>   		perror("traceroute6: setuid");
>   		exit(-1);
>   	}
> +#ifdef CAPABILITIES
> +	{
> +		cap_t caps =3D cap_init();
> +		if (cap_set_proc(caps)) {
> +			perror("traceroute6: cap_set_proc");
> +			exit(-1);
> +		}
> +		cap_free(caps);
> +	}
> +#endif
>
>   	on =3D 1;
>   	seq =3D tos =3D 0;
>
>
