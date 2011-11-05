From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942
 recommendation
Date: Sat, 05 Nov 2011 10:30:06 +0100
Message-ID: <1320485406.16908.4.camel@edumazet-laptop>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>
	 <1320423860.16609.4.camel@edumazet-laptop>
	 <1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Fran=E7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56155 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab1KEJaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2011 05:30:11 -0400
Received: by wyh15 with SMTP id 15so3023762wyh.19
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2011 02:30:10 -0700 (PDT)
In-Reply-To: <1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 05 novembre 2011 =C3=A0 01:39 -0700, Fran=C3=A7ois-Xavier Le =
Bail a
=C3=A9crit :

>=20
> I will study and test these options for my application server

Here is a sample of use of the IPv4 part, an udpecho service that use
IP_PKTINFO and IP_RECVTOS/IP_TOS to be able to use multihomed machine,
and reflect TOS field as well.

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <linux/udp.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 4040

int pktinfo_get(struct msghdr *my_hdr, struct in_pktinfo *pktinfo)
{
	int res =3D -1;

	if (my_hdr->msg_controllen > 0) {
		struct cmsghdr *get_cmsg;
		for (get_cmsg =3D CMSG_FIRSTHDR(my_hdr); get_cmsg;
			get_cmsg =3D CMSG_NXTHDR(my_hdr, get_cmsg)) {
			if (get_cmsg->cmsg_type =3D=3D IP_PKTINFO) {
				struct in_pktinfo *get_pktinfo =3D (struct in_pktinfo *)CMSG_DATA(g=
et_cmsg);
				memcpy(pktinfo, get_pktinfo, sizeof(*pktinfo));
				res =3D 0;
			}
		}
	}
	return res;
}

int tos_get(struct msghdr *my_hdr, unsigned char *tos)
{
	int res =3D -1;

	if (my_hdr->msg_controllen > 0) {
		struct cmsghdr *get_cmsg;
		for (get_cmsg =3D CMSG_FIRSTHDR(my_hdr); get_cmsg;
			get_cmsg =3D CMSG_NXTHDR(my_hdr, get_cmsg)) {
			if (get_cmsg->cmsg_type =3D=3D IP_TOS) {
				unsigned char *pkttos =3D (unsigned char *)CMSG_DATA(get_cmsg);
				*tos =3D *pkttos;
				res =3D 0;
			}
		}
	}
	return res;
}

int main(int argc, char *argv[])
{
	int fd =3D socket(AF_INET, SOCK_DGRAM, 0);
	struct sockaddr_in addr, rem_addr;
	int res, on =3D 1;
	struct msghdr msghdr;
	struct iovec vec[1];
	char cbuf[512];
	char frame[4096];
	struct in_pktinfo pktinfo;
	int c, count =3D 1000000;
	unsigned char last_tos =3D 0;

	while ((c =3D getopt(argc, argv, "c:")) !=3D -1) {
		if (c =3D=3D 'c') count =3D atoi(optarg);
		}
	memset(&addr, 0, sizeof(addr));
	addr.sin_family =3D AF_INET;
	addr.sin_port =3D htons(PORT);
	if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) =3D=3D -1) {
		perror("bind");
		return 1;
	}
	setsockopt(fd, SOL_IP, IP_PKTINFO, &on, sizeof(on));
	setsockopt(fd, SOL_IP, IP_RECVTOS, &on, sizeof(on));

	while (1) {
		unsigned char tos;

		memset(&msghdr, 0, sizeof(msghdr));
		msghdr.msg_control =3D cbuf;
		msghdr.msg_controllen =3D sizeof(cbuf);
		msghdr.msg_iov =3D vec;
		msghdr.msg_iovlen =3D 1;
		vec[0].iov_base =3D frame;
		vec[0].iov_len =3D sizeof(frame);
		msghdr.msg_name =3D &rem_addr;
		msghdr.msg_namelen =3D sizeof(rem_addr);
		res =3D recvmsg(fd, &msghdr, 0);
		if (res =3D=3D -1)
			break;
		if (pktinfo_get(&msghdr, &pktinfo) =3D=3D 0) {

//			printf("Got IP_PKTINFO dst addr=3D%s\n", inet_ntoa(pktinfo.ipi_spe=
c_dst));
			}
		if (tos_get(&msghdr, &tos) =3D=3D 0) {
			/* IP_TOS option wont be used in sendmsg(), we must use setsockopt()=
 instead */
			if (tos !=3D last_tos) {
				if (setsockopt(fd, SOL_IP, IP_TOS, &tos, sizeof(tos)) =3D=3D 0)
					last_tos =3D tos;
			}
		}
		/* ok, just echo reply this frame.
		 * Using sendmsg() will provide IP_PKTINFO back to kernel
		 * to let it use the 'right' source address
		 * (destination address of the incoming packet)
		 */
		vec[0].iov_len =3D res;
		sendmsg(fd, &msghdr, 0);
		if (--count =3D=3D 0)
			break;
	}
	return 0;
}
