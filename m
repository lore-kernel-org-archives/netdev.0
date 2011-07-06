From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] AF_PACKET fanout support
Date: Tue, 5 Jul 2011 17:46:36 -0700
Message-ID: <CA+mtBx_MtQGqNT6iungW7eyStpvLEGYsgXQ8=mYq_JR8jw3=DQ@mail.gmail.com>
References: <20110704.212002.1680758539791986198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: victor@inliniac.net, netdev@vger.kernel.org,
	Willem Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54484 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046Ab1GFAql convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 20:46:41 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p660keJG015089
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 17:46:40 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by hpaq7.eem.corp.google.com with ESMTP id p660kagh006313
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 17:46:38 -0700
Received: by pvg12 with SMTP id 12so5603826pvg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 17:46:36 -0700 (PDT)
In-Reply-To: <20110704.212002.1680758539791986198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Thanks for these patches!  Is it possible you could use an alternative
term than "fanout"?  I think this may be more often associated with a
transmit operation (e.g. multicast fanout).

Also, another useful mode of steering would be to steer packets to a
socket which was recently processed by a thread running on the same
CPU; somewhat analogous to RFS (cc'ed WIllem Bruijn who is already
working on this I believe).

Tom

On Mon, Jul 4, 2011 at 9:20 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> This is a fully functional version, I've tested both hash and
> load-balance modes successfully. =A0I plan to commit this to
> net-next-2.6 very soon.
>
> Below is a test program that other people can play with
> if they want. =A0It basically creates 4 threads, and creates
> an AF_PACKET fanout amongst them. =A0Each thread prints out
> it's pid in parentheses every time it receives 10 packets.
> After each thread processes 10,000 packets, it exits.
>
> Try things like "./test eth0 hash", "./test eth0 lb", etc.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> --------------------
> #include <stddef.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <string.h>
>
> #include <sys/types.h>
> #include <sys/wait.h>
> #include <sys/socket.h>
> #include <sys/ioctl.h>
>
> #include <unistd.h>
>
> #include <linux/if_ether.h>
> #include <linux/if_packet.h>
>
> #include <net/if.h>
>
> static const char *device_name;
> static int fanout_type;
> static int fanout_id;
>
> #ifndef PACKET_FANOUT
> #define PACKET_FANOUT =A0 =A0 =A0 =A0 =A0 18
> #define PACKET_FANOUT_HASH =A0 =A0 =A0 =A0 =A0 =A0 =A00
> #define PACKET_FANOUT_LB =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01
> #endif
>
> static int setup_socket(void)
> {
> =A0 =A0 =A0 =A0int err, fd =3D socket(AF_PACKET, SOCK_RAW, htons(ETH_=
P_IP));
> =A0 =A0 =A0 =A0struct sockaddr_ll ll;
> =A0 =A0 =A0 =A0struct ifreq ifr;
> =A0 =A0 =A0 =A0int fanout_arg;
>
> =A0 =A0 =A0 =A0if (fd < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("socket");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return EXIT_FAILURE;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0memset(&ifr, 0, sizeof(ifr));
> =A0 =A0 =A0 =A0strcpy(ifr.ifr_name, device_name);
> =A0 =A0 =A0 =A0err =3D ioctl(fd, SIOCGIFINDEX, &ifr);
> =A0 =A0 =A0 =A0if (err < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("SIOCGIFINDEX");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return EXIT_FAILURE;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0memset(&ll, 0, sizeof(ll));
> =A0 =A0 =A0 =A0ll.sll_family =3D AF_PACKET;
> =A0 =A0 =A0 =A0ll.sll_ifindex =3D ifr.ifr_ifindex;
> =A0 =A0 =A0 =A0err =3D bind(fd, (struct sockaddr *) &ll, sizeof(ll));
> =A0 =A0 =A0 =A0if (err < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("bind");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return EXIT_FAILURE;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0fanout_arg =3D (fanout_id | (fanout_type << 16));
> =A0 =A0 =A0 =A0err =3D setsockopt(fd, SOL_PACKET, PACKET_FANOUT,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &fanout_arg, sizeof(f=
anout_arg));
> =A0 =A0 =A0 =A0if (err) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("setsockopt");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return EXIT_FAILURE;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return fd;
> }
>
> static void fanout_thread(void)
> {
> =A0 =A0 =A0 =A0int fd =3D setup_socket();
> =A0 =A0 =A0 =A0int limit =3D 10000;
>
> =A0 =A0 =A0 =A0if (fd < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exit(fd);
>
> =A0 =A0 =A0 =A0while (limit-- > 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0char buf[1600];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int err;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D read(fd, buf, sizeof(buf));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("read");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exit(EXIT_FAILURE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((limit % 10) =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fprintf(stdout, "(%d) =
\n", getpid());
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0fprintf(stdout, "%d: Received 10000 packets\n", getpid=
());
>
> =A0 =A0 =A0 =A0close(fd);
> =A0 =A0 =A0 =A0exit(0);
> }
>
> int main(int argc, char **argp)
> {
> =A0 =A0 =A0 =A0int fd, err;
> =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0if (argc !=3D 3) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fprintf(stderr, "Usage: %s INTERFACE {=
hash|lb}\n", argp[0]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return EXIT_FAILURE;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (!strcmp(argp[2], "hash"))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fanout_type =3D PACKET_FANOUT_HASH;
> =A0 =A0 =A0 =A0else if (!strcmp(argp[2], "lb"))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fanout_type =3D PACKET_FANOUT_LB;
> =A0 =A0 =A0 =A0else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fprintf(stderr, "Unknown fanout type [=
%s]\n", argp[2]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exit(EXIT_FAILURE);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0device_name =3D argp[1];
> =A0 =A0 =A0 =A0fanout_id =3D getpid() & 0xffff;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < 4; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pid_t pid =3D fork();
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (pid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 0:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fanout_thread();
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case -1:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("fork");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exit(EXIT_FAILURE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < 4; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int status;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wait(&status);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return 0;
> }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
