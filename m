From: Alejandro Riveira =?UTF-8?B?RmVybsOhbmRleg==?=
	<ariveira@gmail.com>
Subject: Re: IPv6 multicast forwarding
Date: Fri, 24 Oct 2008 11:10:44 +0200
Message-ID: <20081024111044.74c15155@varda>
References: <50a66e370810231511m10a10ca2oa870e9fbd55f4b0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Todd Hayton" <todd.hayton@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755395AbYJXJLQ@vger.kernel.org>
In-Reply-To: <50a66e370810231511m10a10ca2oa870e9fbd55f4b0e@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Thu, 23 Oct 2008 18:11:50 -0400
"Todd Hayton" <todd.hayton@gmail.com> escribi=C3=B3:


  [ CCing netdev@vger.kernel.org ]


> Let me apologize in advance for the length of this message - it is lo=
ng!
>=20
> I'm trying to test out IPv6 multicast forwarding on a 2.6.26 kernel
> and I'm getting some strange values for the upcall messages from the
> kernel. My code is below, but to give an overview, my setup is as
> follows:
>=20
>     sender ------ ff15::1 -----> [eth1] linux 2.6.26 [eth0] ------> .=
=2E.
>=20
> So my incoming interface is eth1 and my outgoing interface is eth0 an=
d
> I am sending traffic to IPv6 multicast group ff15::1
>=20
> I am seeing that mifs are being created successfully:
>=20
> [root@localhost mcast-tools]# cat /proc/net/ip6_mr_vif
> Interface      BytesIn  PktsIn  BytesOut PktsOut Flags
>  1 eth1              0       0         0       0 00000
>  2 eth0              0       0         0       0 00000
>=20
> And after I start sending traffic I can see that the kernel is
> queueing the packets (as it does not yet have a route installed for
> this traffic):
>=20
> [root@localhost mcast-tools]# cat /proc/net/ip6_mr_cache
> Group                            Origin                           Iif
>     Pkts  Bytes     Wrong  Oifs
> ff15:0000:0000:0000:0000:0000:0000:0001
> fec0:0000:0000:0000:0000:0000:0000:0001 65535     1028        4
> 0
>=20
> Which is where my code comes in, I am monitoring a raw ICMPV6 socket
> so as to receive the kernel upcalls for this traffic. Now, I am
> expecting to get a message from the kernel that "appears" to be an ML=
D
> header but is in reality an mrt6msg, the flag being that the icmp6
> type is set to 0 so as to indicate to the userland process that this
> is an upcall.
>=20
> However, in my code after I've detected that the raw socket is
> readable and I read from it, I never really seem to get data that
> looks like an mld_hdr:
>=20
> ...
>       n =3D read(raw_icmpv6_sock, raw_recv_buf, sizeof(raw_recv_buf))=
;
>       if (n < 0) {
>         perror("read: ");
>         exit(1);
>       }
>      mh =3D (struct mld_hdr *)raw_recv_buf;
>     if (mh->mld_icmp6_hdr.icmp6_type =3D=3D 0) { /* kernel upcall */
> ...
>=20
> Except the icmp6_type is *never* 0 - instead it's an assortment of
> strange values.
>=20
> I fired up gdb, examined the contents of raw_recv_buf, right after
> read() occurs and mh is set to point to raw_recv_buf:
>=20
> (gdb) p/x raw_recv_buf[0]@n
> $13 =3D {0x20, 0x0, 0x80, 0x1, 0x20, 0x0, ....
> (gdb) p/d mh->mld_icmp6_hdr.icmp6_type
> $14 =3D 32
>=20
> and then the next packet comes in with different values..
>=20
> (gdb) p/x raw_recv_buf[0]@n
> $15 =3D {0x86, 0x15, 0x60, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x=
0,
> 0xc2, 0x3, 0x18, 0x0, 0x95, 0x1a, 0x7, 0x0, 0x3, 0x15, 0x60, 0x1,
> 0x86, 0x15, 0x60, 0x1, 0xec, 0x\
> ec, 0xe9, 0xe9, 0xe9, 0xe9, 0xff, 0xff, 0x0, 0x0, 0x0, 0x0}
> (gdb) p/d mh->mld_icmp6_hdr.icmp6_type
> $16 =3D 134
>=20
> Now I am examining the traffic sent in another window:
>=20
> [root@localhost linux]# tcpdump -xnnevi eth1
> tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size=
 96 bytes
> 17:59:50.713520 08:00:27:9c:aa:88 > 33:33:00:00:00:01, ethertype IPv6
> (0x86dd), length 66: (hlim 3, next-header UDP (17) payload length: 12=
)
> fec0::1.40825 > ff15::1.31337: [udp sum ok] UDP, length 4
> 	0x0000:  6000 0000 000c 1103 fec0 0000 0000 0000
> 	0x0010:  0000 0000 0000 0001 ff15 0000 0000 0000
> 	0x0020:  0000 0000 0000 0001 9f79 7a69 000c 2354
> 	0x0030:  6162 6364
> 17:59:51.725815 08:00:27:9c:aa:88 > 33:33:00:00:00:01, ethertype IPv6
> (0x86dd), length 66: (hlim 3, next-header UDP (17) payload length: 12=
)
> fec0::1.40825 > ff15::1.31337: [udp sum ok] UDP, length 4
> 	0x0000:  6000 0000 000c 1103 fec0 0000 0000 0000
> 	0x0010:  0000 0000 0000 0001 ff15 0000 0000 0000
> 	0x0020:  0000 0000 0000 0001 9f79 7a69 000c 2354
> 	0x0030:  6162 6364
>=20
> So either I'm misunderstanding the upcall mechanism here (most likely=
)
> or there's a bug... If there's any other information I can include le=
t
> me know. Below is the code I am using to monitor the raw socket - it'=
s
> not pretty code :-) just what I am using for testing right now!
>=20
> Todd H
>=20
> #include <stdio.h>
> #include <stdlib.h>
> #include <strings.h>
> #include <errno.h>
>=20
> #include <sys/types.h>
> #include <sys/uio.h>
> #include <sys/socket.h>
> #include <sys/select.h>
> #include <sys/param.h>
>=20
> #include <net/route.h>
>=20
> #include <netinet/in.h>
> #include <netinet/ip6.h>
> #include <netinet/icmp6.h>
> #include <linux/mroute6.h>
>=20
> #include <arpa/inet.h>
>=20
> #include <unistd.h>
>=20
> #define IVIF 1
> #define OVIF 2
>=20
> static int raw_icmpv6_sock =3D -1;
> static char raw_recv_buf[8192];
>=20
> int raw_sock_init()
> {
>   struct icmp6_filter filt;
>=20
>   raw_icmpv6_sock =3D socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
>   if (raw_icmpv6_sock < 0) {
>     perror("socket: ");
>     return -1;
>   }
>=20
>   ICMP6_FILTER_SETBLOCKALL(&filt);
>   if (setsockopt(raw_icmpv6_sock, IPPROTO_ICMPV6, ICMP6_FILTER, &filt=
,
> sizeof(filt)) < 0) {
>     perror("setsockopt ICMP6_FILTER");
>     return -1;
>   }
>=20
>   return 0;
> }
>=20
> int mrt6_init()
> {
>   int v;
>=20
>   if (raw_sock_init() < 0)
>     return -1;
>=20
>   v =3D 1;
>   if (setsockopt(raw_icmpv6_sock, IPPROTO_IPV6, MRT6_INIT,
> 		 (void *)&v, sizeof(int)) < 0) {
>     perror("setsockopt: ");
>     return -1;
>   }
>   return 0;
> }
>=20
> int mrt6_done()
> {
>   int v;
>   v =3D 1;
>   if (setsockopt(raw_icmpv6_sock, IPPROTO_IP, MRT6_DONE,
> 		 (void *)&v, sizeof(int)) < 0) {
>     perror("setsockopt: ");
>     return -1;
>   }
>   return 0;
> }
>=20
> int mrt6_add_mfc(struct sockaddr_in6 src, struct sockaddr_in6 grp)
> {
>   struct mf6cctl mc;
>=20
>   bzero(&mc, sizeof(mc));
>   mc.mf6cc_origin     =3D src;
>   mc.mf6cc_mcastgrp   =3D grp;
>   mc.mf6cc_parent     =3D IVIF;
>=20
>   IF_ZERO(&mc.mf6cc_ifset);
>   IF_SET(OVIF, &mc.mf6cc_ifset);
>=20
>   if (setsockopt(raw_icmpv6_sock, IPPROTO_IPV6, MRT6_ADD_MFC,
> 		 (void *)&mc, sizeof(mc))) {
>     perror("setsockopt: ");
>     return -1;
>   }
>=20
>   return 0;
> }
>=20
> int mrt6_add_mif()
> {
>   struct mif6ctl mc;
>=20
>   bzero(&mc, sizeof(mc));
>=20
>   mc.mif6c_mifi =3D IVIF;
>   mc.mif6c_pifi =3D 3;
>=20
>   if (setsockopt(raw_icmpv6_sock, IPPROTO_IPV6, MRT6_ADD_MIF,
> 		 (void *)&mc, sizeof(mc))) {
>     perror("setsockopt: ");
>     return -1;
>   }
>=20
>   bzero(&mc, sizeof(mc));
>=20
>   mc.mif6c_mifi =3D OVIF;
>   mc.mif6c_pifi =3D 2;
>=20
>   if (setsockopt(raw_icmpv6_sock, IPPROTO_IPV6, MRT6_ADD_MIF,
> 		 (void *)&mc, sizeof(mc))) {
>     perror("setsockopt: ");
>     return -1;
>   }
>   return 0;
> }
>=20
> int main()
> {
>   if (mrt6_init() < 0)
>     exit(1);
>=20
>   if (mrt6_add_mif() < 0)
>     exit(1);
>=20
>   /* wait for upcall */
>   while (1) {
>     int              n      =3D 0;
>     fd_set           rset;
>     struct mld_hdr * mh     =3D NULL;
>     struct mrt6msg * upcall =3D NULL;
>=20
>     FD_ZERO(&rset);
>     FD_SET(raw_icmpv6_sock, &rset);
>=20
>     n =3D select(raw_icmpv6_sock + 1, &rset, NULL, NULL, NULL);
>     if (n < 0) {
>       perror("select: ");
>       exit(1);
>     }
>=20
>     n =3D read(raw_icmpv6_sock, raw_recv_buf, sizeof(raw_recv_buf));
>     if (n < 0) {
>       perror("read: ");
>       exit(1);
>     }
>     mh =3D (struct mld_hdr *)raw_recv_buf;
>     if (mh->mld_icmp6_hdr.icmp6_type =3D=3D 0) { /* kernel upcall */
>       upcall =3D (struct mrt6msg *)raw_recv_buf;
>       if (upcall->im6_msgtype =3D=3D MRT6MSG_NOCACHE) {
> 	char sbuf[64], dbuf[64];
> 	struct sockaddr_in6 src, grp;
> 	fprintf(stderr, "(%s,%s)\n",
> 		inet_ntop(AF_INET6, &upcall->im6_src, sbuf, sizeof(sbuf)),
> 		inet_ntop(AF_INET6, &upcall->im6_dst, dbuf, sizeof(dbuf)));=09
>=20
> 	bzero(&src, sizeof(src));
> 	bzero(&grp, sizeof(grp));
>=20
> 	src.sin6_addr =3D upcall->im6_src;
> 	grp.sin6_addr =3D upcall->im6_dst;
>=20
> 	mrt6_add_mfc(src, grp);
>       }
>     }
>=20
>   }
>   if (mrt6_done() < 0)
>     exit(1);
>=20
>   exit(0);
> }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
