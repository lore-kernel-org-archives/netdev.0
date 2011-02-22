From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: why all packets have same queue no when rps enabled?
Date: Tue, 22 Feb 2011 06:41:10 +0100
Message-ID: <1298353270.3360.1.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6D0C@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:65228 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab1BVFsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 00:48:08 -0500
Received: by bwz10 with SMTP id 10so2868532bwz.10
        for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 21:48:06 -0800 (PST)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6D0C@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 f=C3=A9vrier 2011 =C3=A0 20:07 -0800, Jon Zhou a =C3=A9crit=
 :
> Hi
>=20
> I expect each incoming packet will have a different queue no. when I =
enabled RPS on kernel 2.6.36.4
>=20
> cat /sys/class/net/eth4/queues/rx-0/rps_cpus
> 00000000,000000ff
>=20
> CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU=
6       CPU7       CPU8       CPU9       CPU10      CPU11      CPU12   =
   CPU13      CPU14      CPU15      CPU16
>       CPU17      CPU18      CPU19      CPU20      CPU21      CPU22   =
   CPU23      CPU24      CPU25      CPU26      CPU27      CPU28      CP=
U29      CPU30      CPU31
>      HI:          0          0          0          0          0      =
    0          0          0          0          0          0          0=
          0          0          0          0          0
>          0          0          0          0          0          0    =
      0          0          0          0          0          0         =
 0          0          0
>    TIMER:    6027512     710165    2623243     542768     427807     =
217424     192940     217043          0          0          0          =
0          0          0          0          0          0
>          0          0          0          0          0          0    =
      0          0          0          0          0          0         =
 0          0          0
>   NET_TX:    1365741         59     750957          0        171     =
     0          3          0          0          0          0          =
0          0          0          0          0          0
>          0          0          0          0          0          0    =
      0          0          0          0          0          0         =
 0          0          0
>   NET_RX:   40465750   11140803    8545859   14417762    8913471   12=
298691   14216845    3348431   < ---- indeed spread across cpus
>=20
>=20
> I manually disable RSS on the intel X520 multiqueue supported NIC.
> Cat /proc/interrupts
>=20
>   87:   21348294          0          0          0          0         =
 0          0          0   PCI-MSI-edge      eth4-rx-0
>   88:      38394          0          0          0          0         =
 0          0          0   PCI-MSI-edge      eth4-tx-0
>=20
>=20
>=20
> When I tried the below program to filter packet by queue no.I got the=
se results:
>=20
> struct sock_filter BPF_code[]=3D {    =20
>     { 0x28,0,0,SKF_AD_OFF+SKF_AD_QUEUE},
>     { 0x15, 0, 1, 0x00000001 },
>     { 0x6, 0, 0, 0x0000ffff },
>     { 0x6, 0, 0, 0x00000000 }
>   };
>=20
>   struct sock_fprog Filter;=20
>    =20
>   Filter.len =3D 4;//15;
>   Filter.filter =3D BPF_code;
>  =20
>   if ( (sock=3Dsocket(PF_PACKET, SOCK_RAW, htons(ETH_P_IP)))<0) {
>     perror("socket");
>     exit(1);
>   }
>=20
>   /* Set the network card in promiscuos mode */
>   strncpy(ethreq.ifr_name,"eth4",IFNAMSIZ);
>   if (ioctl(sock,SIOCGIFFLAGS,&ethreq)=3D=3D-1) {
>     perror("ioctl");
>     close(sock);
>     exit(1);
>   }
>   ethreq.ifr_flags|=3DIFF_PROMISC;
>   if (ioctl(sock,SIOCSIFFLAGS,&ethreq)=3D=3D-1) {
>     perror("ioctl");
>     close(sock);
>     exit(1);
>   }
>=20
>   /* Attach the filter to the socket */
>   if(setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER,&Filter, sizeof(Fi=
lter))<0){
>     perror("setsockopt");
>     close(sock);
>     exit(1);
>   }
>   static int count =3D 0;
>   while (1) {
>     printf("#%d----------\n",count++);
>     n =3D recvfrom(sock,buffer,2048,0,NULL,NULL);
>     printf("%d bytes read\n",n);
> ...
> }
>=20
>=20
> Looks almost all packets fall at same queue?
> Will RPS allocate queue no for each packet? and what hash algorithm r=
ps used? (is it Toeplitz hash algorithm?)
>=20

I believe you are mistaken.

RPS is not there to spread load on _all_ cpus, but to use a hash
function so that all packets of a given flow are directed to a given
cpu.

If you receive 1.000.000 packets of the same flow, they all are
delivered to one CPU.



