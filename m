From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942 recommendation
Date: Thu, 10 Nov 2011 02:58:45 -0800 (PST)
Message-ID: <1320922725.65072.YahooMailNeo@web126002.mail.ne1.yahoo.com>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>  <1320423860.16609.4.camel@edumazet-laptop>  <1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com> <1320485406.16908.4.camel@edumazet-laptop>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm13-vm3.bullet.mail.ne1.yahoo.com ([98.138.91.143]:20032 "HELO
	nm13-vm3.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756931Ab1KJK6r convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 05:58:47 -0500
In-Reply-To: <1320485406.16908.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----

> From: Eric Dumazet <eric.dumazet@gmail.com>
> To: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> Sent: Saturday, November 5, 2011 10:30 AM
> Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4=
942 recommendation
>=20
> Le samedi 05 novembre 2011 =E0 01:39 -0700, Fran=E7ois-Xavier Le Bail=
 a
> =E9crit :
>=20
>>=20
>>  I will study and test these options for my application server
>=20
> Here is a sample of use of the IPv4 part, an udpecho service that use
> IP_PKTINFO and IP_RECVTOS/IP_TOS to be able to use multihomed machine=
,
> and reflect TOS field as well.
> [. . .]

Hi,

I have updated the code for IPv6.

When a UDP client send to an unicast address on a multihomed Linux 3.0.=
0 host, from another host, it's OK.
=46or example :
setup 2001::1 on eth0, 2a01::1 on eth1.
send to 2001::1, recv from 2001::1.
send to 2a01::1, recv from 2a01::1.

When the UDP client send to an Subnet-Router anycast address on a multi=
homed Linux 3.0.0 host, from another host, it's KO.
send to 2001:: or 2a01::, the udpecho server display "sendmsg: Invalid =
argument".

Any idea ?

Thanks,
=46rancois-Xavier

Here is the server code:
----------------------------------------------------------------------
// Here is a sample of use of the IPv6 part, an udpecho service that us=
e
// IPV6_RECVPKTINFO to be able to use multihomed machine.

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <linux/udp.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 4040

struct in6_pktinfo {
=A0=A0=A0=A0=A0=A0=A0 struct in6_addr ipi6_addr;=A0 /* src/dst IPv6 add=
ress */
=A0=A0=A0 unsigned int ipi6_ifindex;=A0 /* send/recv interface index */
};

int pktinfo_get(struct msghdr *my_hdr, struct in6_pktinfo *pktinfo)
{
=A0=A0=A0 int res =3D -1;

=A0=A0=A0 fprintf(stderr, "pktinfo_get()\n");
=A0=A0=A0 if (my_hdr->msg_controllen > 0) {
=A0=A0=A0=A0=A0=A0=A0 struct cmsghdr *get_cmsg;
=A0=A0=A0=A0=A0=A0=A0 for (get_cmsg =3D CMSG_FIRSTHDR(my_hdr); get_cmsg=
;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 get_cmsg =3D CMSG_NXTHDR(my_hdr, get_=
cmsg)) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (get_cmsg->cmsg_type =3D=3D IPV6_P=
KTINFO) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 struct in6_pktinfo *get_p=
ktinfo =3D (struct in6_pktinfo *)CMSG_DATA(get_cmsg);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 memcpy(pktinfo, get_pktin=
fo, sizeof(*pktinfo));
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 res =3D 0;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0 }
=A0=A0=A0 return res;
}

int main(int argc, char *argv[])
{
=A0=A0=A0 int fd =3D socket(AF_INET6, SOCK_DGRAM, 0);
=A0=A0=A0 struct sockaddr_in6 addr, rem_addr;
=A0=A0=A0 int res, on =3D 1;
=A0=A0=A0 struct msghdr msghdr;
=A0=A0=A0 struct iovec vec[1];
=A0=A0=A0 char cbuf[512];
=A0=A0=A0 char frame[4096];
=A0=A0=A0 struct in6_pktinfo pktinfo;
=A0=A0=A0 int c, count =3D 1000000;

=A0=A0=A0 while ((c =3D getopt(argc, argv, "c:")) !=3D -1) {
=A0=A0=A0=A0=A0=A0=A0 if (c =3D=3D 'c') count =3D atoi(optarg);
=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0 memset(&addr, 0, sizeof(addr));
=A0=A0=A0 addr.sin6_family =3D AF_INET6;
=A0=A0=A0 addr.sin6_port =3D htons(PORT);
=A0=A0=A0 if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) =3D=3D -=
1) {
=A0=A0=A0=A0=A0=A0=A0 perror("bind");
=A0=A0=A0=A0=A0=A0=A0 return 1;
=A0=A0=A0 }
=A0=A0=A0 //setsockopt(fd, IPPROTO_IPV6, IPV6_PKTINFO, &on, sizeof(on))=
;
=A0=A0=A0 setsockopt(fd, IPPROTO_IPV6, IPV6_RECVPKTINFO, &on, sizeof(on=
));

=A0=A0=A0 while (1) {

=A0=A0=A0=A0=A0=A0=A0 memset(&msghdr, 0, sizeof(msghdr));
=A0=A0=A0=A0=A0=A0=A0 msghdr.msg_control =3D cbuf;
=A0=A0=A0=A0=A0=A0=A0 msghdr.msg_controllen =3D sizeof(cbuf);
=A0=A0=A0=A0=A0=A0=A0 msghdr.msg_iov =3D vec;
=A0=A0=A0=A0=A0=A0=A0 msghdr.msg_iovlen =3D 1;
=A0=A0=A0=A0=A0=A0=A0 vec[0].iov_base =3D frame;
=A0=A0=A0=A0=A0=A0=A0 vec[0].iov_len =3D sizeof(frame);
=A0=A0=A0=A0=A0=A0=A0 msghdr.msg_name =3D &rem_addr;
=A0=A0=A0=A0=A0=A0=A0 msghdr.msg_namelen =3D sizeof(rem_addr);
=A0=A0=A0=A0=A0=A0=A0 res =3D recvmsg(fd, &msghdr, 0);
=A0=A0=A0=A0=A0=A0=A0 if (res =3D=3D -1)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;
=A0=A0=A0=A0=A0=A0=A0 if (pktinfo_get(&msghdr, &pktinfo) =3D=3D 0) {

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 //printf("Got IPV6_PKTINFO dst addr=3D=
%s\n", inet_ntoa(pktinfo.ipi6_addr));
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0=A0=A0=A0=A0 /* ok, just echo reply this frame.
=A0=A0=A0=A0=A0=A0=A0 * Using sendmsg() will provide IPV6_PKTINFO back =
to kernel
=A0=A0=A0=A0=A0=A0=A0 * to let it use the 'right' source address
=A0=A0=A0=A0=A0=A0=A0 * (destination address of the incoming packet)
=A0=A0=A0=A0=A0=A0=A0 */
=A0=A0=A0=A0=A0=A0=A0 vec[0].iov_len =3D res;
=A0=A0=A0=A0=A0=A0=A0 res =3D sendmsg(fd, &msghdr, 0);
=A0=A0=A0=A0=A0=A0=A0 if (res =3D=3D -1) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 perror ("sendmsg");
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;
=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0=A0=A0=A0=A0 if (--count =3D=3D 0)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;
=A0=A0=A0 }
=A0=A0=A0 return 0;
}

----------------------------------------------------------------------
