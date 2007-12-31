From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] [UDP]: add udp_mem, udp_rmem_min and udp_wmem_min
Date: Mon, 31 Dec 2007 15:42:42 +0100
Message-ID: <4778FFE2.9090008@cosmosbay.com>
References: <47775E7A.60708@redhat.com>	<20071231.001925.151533664.davem@davemloft.net>	<4778AE48.1040701@cosmosbay.com> <20071231.041342.101160102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: haoki@redhat.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:45285 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757732AbXLaOoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 09:44:11 -0500
In-Reply-To: <20071231.041342.101160102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 31 Dec 2007 09:54:32 +0100
>=20
>> Maybe I read the patch incorrectly, or we could add some new sysctl =
so that
>> we not try to uncharge memory if a socket 'forward_alloc' is beyond =
a given=20
>> limit (say 2 pages), so that number of atomic_inc/dec on udp_memory_=
allocated=20
>> (or tcp_memory_allocated) is reduced.
>=20
> This is what we should be striving for, using forward_alloc
> as much as possible as a "cache" to avoid the atomics on
> the global var as much as possible.

Thank you for this confirmation David, I understand now that tcp doesnt=
=20
currently satisfy the contract.

=46or example, tcp_delack_timer() calls sk_mem_reclaim().

So on a machine with a lot of mostly idle sockets (but all sockets are =
doing=20
some trafic, say one message per minute / socket), we can see :

$ grep TCP /proc/net/sockstat
TCP: inuse 1083667 orphan 8840 tw 6646 alloc 1083809 mem 262305
$ cat /proc/sys/net/ipv4/tcp_mem
2000000 3000000 4000000

so an average of 1/4 page are 'allocated' per socket :(

On this machine, we constantly change tcp_memory_allocated, even if we =
always=20
are under tcp_mem[0] limit.

Maybe we need to introduce some mechanism to let sk_forward between 0 a=
nd=20
SK_MEM_QUANTUM (inclusive).

static inline void sk_mem_reclaim_overpage(struct sock *sk)
{
         if (sk->sk_forward_alloc > SK_MEM_QUANTUM) {
                 __sk_mem_reclaim(sk);
		}
}

and use sk_mem_reclaim_overpage() instead of sk_mem_reclaim() in=20
tcp_delack_timer() ?

Thank you

Small program output :

$ gcc -o prog prog.c ; ./prog
TCP: inuse 1035 orphan 0 tw 271 alloc 1203 mem 16
TCP: inuse 1035 orphan 0 tw 271 alloc 1203 mem 4016
TCP: inuse 1034 orphan 0 tw 272 alloc 1202 mem 3015
TCP: inuse 1034 orphan 0 tw 272 alloc 1202 mem 3016
TCP: inuse 1034 orphan 0 tw 272 alloc 1202 mem 3516
TCP: inuse 1034 orphan 0 tw 272 alloc 1202 mem 14 <OOPS>

$ cat prog.c
#include <sys/socket.h>
#include <string.h>
#include <stdlib.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>
#include <asm/ioctls.h>
#include <stdio.h>

int SOCK_COUNT =3D 1000;
int *sockets_fd_tab;
unsigned int count;

static void open_sockets(int domain, int type)
{
         int fdlisten=3D-1, on =3D 1;
         socklen_t addrlen;
         struct sockaddr_in host, peer;

         if (domain =3D=3D AF_INET && type =3D=3D SOCK_STREAM) {
                 fdlisten =3D socket(AF_INET, type, 0);
                 setsockopt(fdlisten, SOL_SOCKET, SO_REUSEADDR, &on, si=
zeof(int));
                 memset(&host, 0, sizeof(host));
                 host.sin_family =3D AF_INET;
                 bind(fdlisten, (struct sockaddr *)&host, sizeof(host))=
;
                 addrlen =3D sizeof(host);
                 getsockname(fdlisten, (struct sockaddr *)&host, &addrl=
en);
                 listen(fdlisten, 5);
         }
         while (1) {
                 int res, vec[2];
                 if (domain =3D=3D AF_UNIX) {
                         res =3D socketpair(AF_UNIX, type, 0, vec);
                         if (res =3D=3D -1)
                                 break;
                 } else {
                         vec[0] =3D socket(AF_INET, type, 0);
                         if (vec[0] =3D=3D -1)
                                 break;
                         ioctl(vec[0], FIONBIO, &on);
                         if (type =3D=3D SOCK_STREAM) {
                                 connect(vec[0], (struct sockaddr *)&ho=
st,=20
sizeof(host));
                                 addrlen =3D sizeof(peer);
                                 vec[1] =3D accept(fdlisten, (struct so=
ckaddr=20
*)&peer, &addrlen);
                                 if (vec[1] =3D=3D -1) {
                                         close(vec[0]);
                                         break;
                                 }
                         } else {
                         }
                 }
                 sockets_fd_tab[count++] =3D vec[0];
                 sockets_fd_tab[count++] =3D vec[1];
                 if (count =3D=3D SOCK_COUNT)
                         break;
         }
}

const char some_msg[1024] =3D "One dummy message";

static void fill_sockets()
{
         unsigned int ui;
         for (ui =3D 0; ui < count; ui++)
                 send(sockets_fd_tab[ui], some_msg, 100, 0);
         for (ui =3D 0; ui < count; ui++)
                 send(sockets_fd_tab[ui], some_msg, 100, 0);
}

static void empty_sockets()
{
         unsigned int ui;
         char buffer[4096];

         for (ui =3D 0; ui < count; ui++)
                 recv(sockets_fd_tab[ui], buffer, sizeof(buffer), 0);
}

static void dump_infos()
{
         system("grep TCP /proc/net/sockstat");
}

int main(int argc, char *argv[])
{
         int c;
         while ((c =3D getopt(argc, argv, "n:")) !=3D EOF) {
                 if (c =3D=3D 'n')
                         SOCK_COUNT =3D atoi(optarg);
         }
         sockets_fd_tab =3D malloc(SOCK_COUNT * sizeof(int));
         open_sockets(AF_INET, SOCK_STREAM);
         dump_infos();

         fill_sockets();
         dump_infos();
         sleep(1); /* to see effect of delayed acks */
         dump_infos();
         empty_sockets();
         dump_infos();

         fill_sockets();
         dump_infos();
         empty_sockets();
         sleep(1); /* to see effect of delayed acks */
         dump_infos();

         return 0;
}

