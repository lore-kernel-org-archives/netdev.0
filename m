From: Thomas Lloyd <thomas.lloyd@actual-experience.com>
Subject: [PROBLEM]: IPv6 ICMP Ancillary Data IPV6_PKTINFO sendmsg() invalid argument
Date: Fri, 2 Dec 2016 18:19:50 -0000
Message-ID: <37a28e788c72094d16ec63f1474b90a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33785 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbcLBSRR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:17:17 -0500
Received: by mail-io0-f173.google.com with SMTP id j65so495820862iof.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:17:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

First post here; any pointers or improvements for bug reporting are
welcome.

[1.] One line summary of the problem:

sendmsg() with ancillary data of type IPV6_PKTINFO fails with invalid
argument and further possible memory corruption.

---------------------------------
[2.] Full description of the problem/report:

As part of my project I am attempting to perform IPv6 neighbour
solicitations to discover the MAC address of my local neighbours.
In the included test code link-local src and dst addresses are used to
send neighbour solicitations along with specifying the network interface
in IPV6_PKTINFO ancillary data.

In my test environment I have a Ubuntu 16.04 LTS Server/Router and a
Ubuntu 16.04 LTS Desktop.
These are both hosted on a Windows 10 Host as Virtual Guests.

Router/Server Interfaces:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group
default qlen 1
=C2=A0=C2=A0=C2=A0 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
=C2=A0=C2=A0=C2=A0 inet 127.0.0.1/8 scope host lo
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 valid_lft forever preferred_lft foreve=
r
=C2=A0=C2=A0=C2=A0 inet6 ::1/128 scope host
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft forever preferred_lft f=
orever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state
UP group default qlen 1000
=C2=A0=C2=A0=C2=A0 link/ether 08:00:27:c5:0e:76 brd ff:ff:ff:ff:ff:ff
=C2=A0=C2=A0=C2=A0 inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 valid_lft forever preferred_lft foreve=
r
=C2=A0=C2=A0=C2=A0 inet6 fe80::a00:27ff:fec5:e76/64 scope link
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft forever preferred_lft f=
orever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state
UP group default qlen 1000
=C2=A0=C2=A0=C2=A0 link/ether 08:00:27:0a:c1:80 brd ff:ff:ff:ff:ff:ff
=C2=A0=C2=A0=C2=A0 inet6 2001:db8:1000:baba::1/64 scope global
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft forever preferred_lft f=
orever
=C2=A0=C2=A0=C2=A0 inet6 fe80::a00:27ff:fe0a:c180/64 scope link
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft forever preferred_lft f=
orever

Eth0 is set up for NAT to a physical IPv4 network but is unused in this
test setup.
Eth1 is IPv6 and is the radvd interface attatched to an internal virtual
box network interface.

In my client environment I have three network interfaces:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group
default qlen 1
=C2=A0=C2=A0=C2=A0 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
=C2=A0=C2=A0=C2=A0 inet 127.0.0.1/8 scope host lo
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 valid_lft forever preferred_lft foreve=
r
=C2=A0=C2=A0=C2=A0 inet6 ::1/128 scope host
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft forever preferred_lft f=
orever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
=C2=A0=C2=A0=C2=A0 link/ether 08:00:27:b9:42:47 brd ff:ff:ff:ff:ff:ff
=C2=A0=C2=A0=C2=A0 inet 192.168.100.121/24 brd 192.168.100.255 scope global=
 dynamic
enp0s3
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 valid_lft 79320sec preferred_lft 79320=
sec
=C2=A0=C2=A0=C2=A0 inet6 fe80::5523:e7df:d12c:681/64 scope link
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft forever preferred_lft f=
orever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
=C2=A0=C2=A0=C2=A0 link/ether 08:00:27:1a:a7:22 brd ff:ff:ff:ff:ff:ff
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
=C2=A0=C2=A0=C2=A0 link/ether 08:00:27:35:13:22 brd ff:ff:ff:ff:ff:ff
=C2=A0=C2=A0=C2=A0 inet6 2001:db8:1000:baba:b30a:ed85:8568:cc66/64 scope gl=
obal
noprefixroute dynamic
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft 86389sec preferred_lft =
14389sec
=C2=A0=C2=A0=C2=A0 inet6 fe80::cffe:e7ef:a03a:34cb/64 scope link
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0valid_lft forever preferred_lft f=
orever

enp0s3 is a bridged physical wired connection on the host to an ipv4
network with router / gateway, ipv6 is active but not used.
enp0s8 is a bridged physical wifi connection on the host to another ipv4
subnet within the same network on the same router / gateway ipv6 is active
but not used .
enp0d9 is an internal virtual box network connected directly to another
Ubuntu guest as an IPv6 stateless router (the neighbour I am solicitating)
this interfaces is ipv4 enabled but not used.

The expected behaviour is to use the sendmsg() system call and specify the
outgoing interface for the neighbour sonication message using the
IPV6_PKTINFO ancillary data as detailed in the RFC3542 links below.

6.1.=C2=A0 Specifying/Receiving the Interface
https://tools.ietf.org/html/rfc3542.html#section-6.1

6.7 Summary of Outgoing Interface Selection
https://tools.ietf.org/html/rfc3542.html#section-6.7

The actual behaviour is for the sendmsg() system call to fail with errno
set to 22, Invalid Argument.

A note of interest is that if a perror() call is made to report this
problem a seg fault in mallo.c is encountered. I have not performed
further investigation.
You can see this has been commented after the sendmsg() system call in the
demo code.

Warning:
In my testing I have removed the IPV6_PKTINFO ancillary data and have
found that if the IPv6 router is not available at boot by default enp0s3
is used to send the packet.
I will send another e-mail further describing the behaviour with the
subject:

[PROBLEM]: IPv6 Link-Local Routing through wrong interface

---------------------------------
[3.] Keywords (i.e., modules, networking, kernel):
=C2=A0networking, ipv6, link-local, ancillary

---------------------------------
[4.] Kernel version (from /proc/version):
Linux version 4.4.0-51-generic (buildd@lcy01-08) (gcc version 5.4.0
20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.4) ) #72-Ubuntu SMP Thu Nov 24
18:29:54 UTC 2016
Linux version 4.8.11-1-ARCH (builduser@tobias) (gcc version 6.2.1 20160830
(GCC) ) #1 SMP PREEMPT Sun Nov 27 09:26:14 CET 2016

---------------------------------
[5.] Output of Oops.. message (if applicable) with symbolic information
resolved (see Documentation/oops-tracing.txt)

---------------------------------
[6.] A small shell script or example program which triggers the problem
(if possible)

/*=C2=A0 Copyright (C) 2011-2015=C2=A0 P.D. Buchan (mailto:pdbuchan@yahoo.c=
om)

=C2=A0=C2=A0=C2=A0 This program is free software: you can redistribute it a=
nd/or modify
=C2=A0=C2=A0=C2=A0 it under the terms of the GNU General Public License as =
published by
=C2=A0=C2=A0=C2=A0 the Free Software Foundation, either version 3 of the Li=
cense, or
=C2=A0=C2=A0=C2=A0 (at your option) any later version.

=C2=A0=C2=A0=C2=A0 This program is distributed in the hope that it will be =
useful,
=C2=A0=C2=A0=C2=A0 but WITHOUT ANY WARRANTY; without even the implied warra=
nty of
=C2=A0=C2=A0=C2=A0 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.=C2=
=A0 See the
=C2=A0=C2=A0=C2=A0 GNU General Public License for more details.

=C2=A0=C2=A0=C2=A0 You should have received a copy of the GNU General Publi=
c License
=C2=A0=C2=A0=C2=A0 along with this program.=C2=A0 If not, see <http://www.g=
nu.org/licenses/>.
*/

// Send an IPv6 ICMP neighbor solicitation packet.
// Change hoplimit and specify interface using ancillary
// data method.

#define _GNU_SOURCE

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 // close()
#include <string.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 // strcpy, memset(), and memcpy()

#include <netinet/icmp6.h>=C2=A0=C2=A0=C2=A0 // struct nd_neighbor_solicit,=
 which
contains icmp6_hdr, ND_NEIGHBOR_SOLICIT
#include <netinet/in.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // IPPROTO_IPV6=
, IPPROTO_ICMPV6,
INET6_ADDRSTRLEN
#include <netinet/ip.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // IP_MAXPACKET=
 (65535)
#include <arpa/inet.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // inet_nt=
op()
#include <netdb.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 // struct addrinfo
#include <sys/ioctl.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // macro i=
octl is defined
#include <bits/ioctls.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // defines values fo=
r argument "request" of
ioctl. Here, we need SIOCGIFHWADDR
#include <bits/socket.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // structs msghdr an=
d cmsghdr
#include <net/if.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 // struct ifreq
#include <linux/ipv6.h>
#include <stdint.h>

#include <errno.h>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 // errno, perror()

// Definition of pktinfo6 created from definition of in6_pktinfo in
netinet/in.h.
// This should remove "redefinition of in6_pktinfo" errors in some linux
variants.
typedef struct _pktinfo6 pktinfo6;

struct _pktinfo6 {
=C2=A0 struct in6_addr ipi6_addr;
=C2=A0 int ipi6_ifindex;
};

// Function prototypes
uint16_t checksum (uint16_t *, int);
char *allocate_strmem (int);
uint8_t *allocate_ustrmem (int);

int
main (int argc, char **argv)
{
=C2=A0 int NS_HDRLEN =3D sizeof (struct nd_neighbor_solicit);=C2=A0 // Leng=
th of NS
message header
=C2=A0 int optlen =3D 8; // Option Type (1 byte) + Length (1 byte) + Length=
 of
MAC address (6 bytes)

=C2=A0 int i, sd, status, ifindex, cmsglen, psdhdrlen;
=C2=A0 struct addrinfo hints;
=C2=A0 struct addrinfo *res;
=C2=A0 struct sockaddr_in6 *ipv6, src, dst, dstsnmc;
=C2=A0 struct nd_neighbor_solicit *ns;
=C2=A0 socklen_t srclen;
=C2=A0 uint8_t *outpack, *options, *psdhdr, hoplimit;
=C2=A0 struct msghdr msghdr, msghdr2 ;
=C2=A0 struct ifreq ifr;
=C2=A0 struct cmsghdr *cmsghdr1, *cmsghdr2;
=C2=A0 pktinfo6 *pktinfo;
=C2=A0 struct iovec iov[2];
=C2=A0 char *target, *source, *interface;
=C2=A0 void *tmp;

=C2=A0 // Allocate memory for various arrays.
=C2=A0 interface =3D allocate_strmem (40);
=C2=A0 target =3D allocate_strmem (INET6_ADDRSTRLEN);
=C2=A0 source =3D allocate_strmem (INET6_ADDRSTRLEN);
=C2=A0 outpack =3D allocate_ustrmem (IP_MAXPACKET);
=C2=A0 options =3D allocate_ustrmem (optlen);
=C2=A0 psdhdr =3D allocate_ustrmem (IP_MAXPACKET);

=C2=A0 // Interface to send packet through.
=C2=A0 strcpy (interface, "enp0s9");

=C2=A0 // Source (node sending solicitation) IPv6 unicast address, or
=C2=A0 // the IPv6 unspecified address (::
=C2=A0 // You need to fill this out.
=C2=A0 //strcpy (source, "fe80::cffe:e7ef:a03a:34cb");
=C2=A0 strcpy (source, "::");

=C2=A0 // Target (which must be link-local) hostname or IPv6 address (node
we're requesting an advertisement from).
=C2=A0 // You need to fill this out.
=C2=A0 strcpy (target, "fe80::a00:27ff:fe0a:c180");

=C2=A0 // Fill out hints for getaddrinfo().
=C2=A0 memset (&hints, 0, sizeof (struct addrinfo));
=C2=A0 hints.ai_family =3D AF_INET6;
=C2=A0 hints.ai_socktype =3D SOCK_STREAM;
=C2=A0 hints.ai_flags =3D hints.ai_flags | AI_CANONNAME;

=C2=A0 // Resolve source using getaddrinfo().
=C2=A0 if ((status =3D getaddrinfo (source, NULL, &hints, &res)) !=3D 0) {
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "getaddrinfo() failed: %s\n", gai_strer=
ror (status));
=C2=A0=C2=A0=C2=A0 return (EXIT_FAILURE);
=C2=A0 }
=C2=A0 memset (&src, 0, sizeof (src));
=C2=A0 memcpy (&src, res->ai_addr, res->ai_addrlen);
=C2=A0 srclen =3D res->ai_addrlen;
=C2=A0 memcpy (psdhdr, src.sin6_addr.s6_addr, 16 * sizeof (uint8_t));=C2=A0=
 // Copy
to checksum pseudo-header
=C2=A0 freeaddrinfo (res);

=C2=A0 // Resolve target using getaddrinfo().
=C2=A0 if ((status =3D getaddrinfo (target, NULL, &hints, &res)) !=3D 0) {
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "getaddrinfo() failed: %s\n", gai_strer=
ror (status));
=C2=A0=C2=A0=C2=A0 return (EXIT_FAILURE);
=C2=A0 }
=C2=A0 memset (&dst, 0, sizeof (dst));
=C2=A0 memset (&dstsnmc, 0, sizeof (dstsnmc));
=C2=A0 memcpy (&dst, res->ai_addr, res->ai_addrlen);
=C2=A0 memcpy (&dstsnmc, res->ai_addr, res->ai_addrlen);

=C2=A0 // Report target's unicast address.
=C2=A0 ipv6 =3D (struct sockaddr_in6 *) res->ai_addr;
=C2=A0 tmp =3D &(ipv6->sin6_addr);
=C2=A0 memset (target, 0, INET6_ADDRSTRLEN * sizeof (char));
=C2=A0 if (inet_ntop (AF_INET6, tmp, target, INET6_ADDRSTRLEN) =3D=3D NULL)=
 {
=C2=A0=C2=A0=C2=A0 status =3D errno;
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "inet_ntop() failed.\nError message: %s=
", strerror
(status));
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }
=C2=A0 printf ("Target unicast IPv6 address: %s\n", target);
=C2=A0 freeaddrinfo (res);

=C2=A0 // Convert target's IPv6 unicast address to solicited-node multicast
address.
=C2=A0 // Section 2.7.1 of RFC 4291.
=C2=A0 dstsnmc.sin6_addr.s6_addr[0]=3D 255;
=C2=A0 dstsnmc.sin6_addr.s6_addr[1]=3D2;
=C2=A0 for (i=3D2; i<11; i++) {
=C2=A0=C2=A0=C2=A0 dstsnmc.sin6_addr.s6_addr[i] =3D 0;
=C2=A0 }
=C2=A0 dstsnmc.sin6_addr.s6_addr[11]=3D1;
=C2=A0 dstsnmc.sin6_addr.s6_addr[12]=3D255;

=C2=A0 // Report target's solicited-node multicast address.
=C2=A0 ipv6 =3D (struct sockaddr_in6 *) &dstsnmc;
=C2=A0 tmp =3D &(ipv6->sin6_addr);
=C2=A0 memset (target, 0, INET6_ADDRSTRLEN * sizeof (char));
=C2=A0 if (inet_ntop (AF_INET6, tmp, target, INET6_ADDRSTRLEN) =3D=3D NULL)=
 {
=C2=A0=C2=A0=C2=A0 status =3D errno;
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "inet_ntop() failed.\nError message: %s=
", strerror
(status));
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }
=C2=A0 printf ("Target solicited-node multicast address: %s\n", target);
=C2=A0 memcpy (psdhdr + 16, dstsnmc.sin6_addr.s6_addr, 16 * sizeof (uint8_t=
));
// Solicited-node multicast address goes into pseudo-header

=C2=A0 // Request a socket descriptor sd.
=C2=A0 if ((sd =3D socket (AF_INET6, SOCK_RAW, IPPROTO_ICMPV6)) < 0) {
=C2=A0=C2=A0=C2=A0 perror ("Failed to get socket descriptor ");
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }

=C2=A0 // Use ioctl() to look up soliciting node's (i.e., source's) interfa=
ce
name and get its MAC address.
=C2=A0 memset (&ifr, 0, sizeof (ifr));
=C2=A0 snprintf (ifr.ifr_name, sizeof (ifr.ifr_name), "%s", interface);
=C2=A0 if (ioctl (sd, SIOCGIFHWADDR, &ifr) < 0) {
=C2=A0=C2=A0=C2=A0 perror ("ioctl() failed to get source MAC address ");
=C2=A0=C2=A0=C2=A0 return (EXIT_FAILURE);
=C2=A0 }

=C2=A0 // Copy source MAC address into options buffer.
=C2=A0 options[0] =3D 1;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 // Option Type - "source link layer address"
(Section 4.6 of RFC 4861)
=C2=A0 options[1] =3D optlen / 8;=C2=A0 // Option Length - units of 8 octet=
s (RFC
4861)
=C2=A0 for (i=3D0; i<6; i++) {
=C2=A0=C2=A0=C2=A0 options[i+2] =3D (uint8_t) ifr.ifr_addr.sa_data[i];
=C2=A0 }

=C2=A0 // Report soliciting node MAC address to stdout.
=C2=A0 printf ("MAC address for interface %s is ", interface);
=C2=A0 for (i=3D0; i<5; i++) {
=C2=A0=C2=A0=C2=A0 printf ("%02x:", options[i+2]);
=C2=A0 }
=C2=A0 printf ("%02x\n", options[5+2]);

=C2=A0 // Always bind otherwise the packet will be sent out on the first ac=
tive
site-local or link-local interface.
=C2=A0 // Bind the socket descriptor to the source address if not site-loca=
l or
link-local.
=C2=A0 if (!(psdhdr[0] =3D=3D 0xfe)) {
=C2=A0=C2=A0=C2=A0 if (bind (sd, (struct sockaddr *) &src, srclen) < 0) {
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 perror ("Failed to bind the socket descripto=
r to the source address
");
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0=C2=A0=C2=A0 }
=C2=A0 }

=C2=A0 // Find interface index from interface name.
=C2=A0 // This will be put in cmsghdr data in order to specify the interfac=
e we
want to use.
=C2=A0 if ((ifindex =3D if_nametoindex (interface)) =3D=3D 0) {
=C2=A0=C2=A0=C2=A0 perror ("if_nametoindex() failed to obtain interface ind=
ex ");
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }
=C2=A0 printf ("Soliciting node's index for interface %s is %i\n", interfac=
e,
ifindex);

=C2=A0 // Define first part of buffer outpack to be a neighbor solicit stru=
ct.
=C2=A0 ns =3D (struct nd_neighbor_solicit *) outpack;
=C2=A0 memset (ns, 0, sizeof (*ns));

=C2=A0 // Populate icmp6_hdr portion of neighbor solicit struct.
=C2=A0 ns->nd_ns_hdr.icmp6_type =3D ND_NEIGHBOR_SOLICIT;=C2=A0 // 135 (RFC =
4861)
=C2=A0 ns->nd_ns_hdr.icmp6_code =3D 0;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // zero for neighbor
solicitation (RFC 4861)
=C2=A0 ns->nd_ns_hdr.icmp6_cksum =3D htons(0);=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 // zero when calculating
checksum
=C2=A0 ns->nd_ns_reserved =3D htonl(0);=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // Reserved - must be set to
zero (RFC 4861)
=C2=A0 ns->nd_ns_target =3D dst.sin6_addr;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 // Target address (NOT
MULTICAST) (as type in6_addr)

=C2=A0 // Append options to end of neighbor solicit struct.
=C2=A0 memcpy (outpack + NS_HDRLEN, options, optlen * sizeof (uint8_t));

=C2=A0 // Need a pseudo-header for checksum calculation. Define length. (RF=
C
2460)
=C2=A0 // Length =3D source IP (16 bytes) + destination IP (16 bytes)
=C2=A0 //=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 + upper layer packet le=
ngth (4 bytes) + zero (3 bytes)
=C2=A0 //=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 + next header (1 byte)
=C2=A0 psdhdrlen =3D 16 + 16 + 4 + 3 + 1 + NS_HDRLEN + optlen;

=C2=A0 // Prepare msghdr for sendmsg().
=C2=A0 memset (&msghdr, 0, sizeof (msghdr));
=C2=A0 msghdr.msg_name =3D &dstsnmc;=C2=A0 // Destination IPv6 address (sol=
icited node
multicast) (as struct sockaddr_in6)
=C2=A0 msghdr.msg_namelen =3D sizeof (dstsnmc);
=C2=A0 memset (&iov, 0, sizeof (iov));
=C2=A0 iov[0].iov_base =3D (uint8_t *) outpack;=C2=A0 // Point msghdr to bu=
ffer
outpack
=C2=A0 iov[0].iov_len =3D NS_HDRLEN + optlen;
=C2=A0 msghdr.msg_iov =3D iov;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // scatter/gather array
=C2=A0 msghdr.msg_iovlen =3D 1;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 // number of elements in
scatter/gather array

=C2=A0 // Tell msghdr we're adding cmsghdr data to change hop limit and spe=
cify
interface.
=C2=A0 // Allocate some memory for our cmsghdr data.
=C2=A0 cmsglen =3D CMSG_SPACE (sizeof (int)) + CMSG_SPACE (sizeof (pktinfo)=
);
=C2=A0 msghdr.msg_control =3D allocate_ustrmem (cmsglen);
=C2=A0 msghdr.msg_controllen =3D cmsglen;

=C2=A0 // Change hop limit to 255 as required for neighbor solicitation (RF=
C
4861).
=C2=A0 hoplimit =3D 255u;
=C2=A0 cmsghdr1 =3D CMSG_FIRSTHDR (&msghdr);
=C2=A0 if(NULL =3D=3D cmsghdr1)
=C2=A0 {
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 =C2=A0 fprintf (stderr, "NULL Returned out of Memory");
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 =C2=A0 exit (EXIT_FAILURE);
=C2=A0 }

=C2=A0 cmsghdr1->cmsg_level =3D IPPROTO_IPV6;
=C2=A0 cmsghdr1->cmsg_type =3D IPV6_HOPLIMIT;=C2=A0 // We want to change ho=
p limit
=C2=A0 cmsghdr1->cmsg_len =3D CMSG_LEN (sizeof (int));
=C2=A0 *(CMSG_DATA (cmsghdr1)) =3D hoplimit;

=C2=A0 // Specify source interface index for this packet via cmsghdr data.
=C2=A0 cmsghdr2 =3D CMSG_NXTHDR (&msghdr, cmsghdr1);
=C2=A0 if(NULL =3D=3D cmsghdr2)
=C2=A0 {
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 =C2=A0 fprintf (stderr, "NULL Returned out of Memory");
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 =C2=A0 exit (EXIT_FAILURE);
=C2=A0 }
=C2=A0 cmsghdr2->cmsg_level =3D IPPROTO_IPV6;
=C2=A0 cmsghdr2->cmsg_type =3D IPV6_PKTINFO;=C2=A0 // We want to specify in=
terface
here
=C2=A0 cmsghdr2->cmsg_len =3D CMSG_LEN (sizeof (pktinfo));
=C2=A0 pktinfo =3D (pktinfo6 *) CMSG_DATA (cmsghdr2);
=C2=A0 pktinfo->ipi6_ifindex =3D ifindex;
=C2=A0 pktinfo->ipi6_ifindex =3D 0;

=C2=A0 // Compute ICMPv6 checksum (RFC 2460).
=C2=A0 // psdhdr[0 to 15] =3D source IPv6 address, set earlier.
=C2=A0 // psdhdr[16 to 31] =3D destination IPv6 address, set earlier.
=C2=A0 psdhdr[32] =3D 0;=C2=A0 // Length should not be greater than 65535 (=
i.e., 2
bytes)
=C2=A0 psdhdr[33] =3D 0;=C2=A0 // Length should not be greater than 65535 (=
i.e., 2
bytes)
=C2=A0 psdhdr[34] =3D (NS_HDRLEN + optlen)=C2=A0 / 256;=C2=A0 // Upper laye=
r packet length
=C2=A0 psdhdr[35] =3D (NS_HDRLEN + optlen)=C2=A0 % 256;=C2=A0 // Upper laye=
r packet length
=C2=A0 psdhdr[36] =3D 0;=C2=A0 // Must be zero
=C2=A0 psdhdr[37] =3D 0;=C2=A0 // Must be zero
=C2=A0 psdhdr[38] =3D 0;=C2=A0 // Must be zero
=C2=A0 psdhdr[39] =3D IPPROTO_ICMPV6;
=C2=A0 memcpy (psdhdr + 40, outpack, (NS_HDRLEN + optlen) * sizeof (uint8_t=
));
=C2=A0 ns->nd_ns_hdr.icmp6_cksum =3D checksum ((uint16_t *) psdhdr, psdhdrl=
en);

=C2=A0 printf ("Checksum: %x\n", ntohs (ns->nd_ns_hdr.icmp6_cksum));

=C2=A0 if (sendmsg (sd, &msghdr, 0) < 0) {
=C2=A0=C2=A0 // perror ("sendmsg() failed ");
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 =C2=A0 fprintf (stderr,"[%d] %s\n", errno, strerror(errno));
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }
=C2=A0 close (sd);

=C2=A0 // Free allocated memory.
=C2=A0 free (interface);
=C2=A0 free (target);
=C2=A0 free (source);
=C2=A0 free (outpack);
=C2=A0 free (options);
=C2=A0 free (psdhdr);
=C2=A0 free (msghdr.msg_control);

=C2=A0 return (EXIT_SUCCESS);
}

// Computing the internet checksum (RFC 1071).
// Note that the internet checksum does not preclude collisions.
uint16_t
checksum (uint16_t *addr, int len)
{
=C2=A0 int count =3D len;
=C2=A0 register uint32_t sum =3D 0;
=C2=A0 uint16_t answer =3D 0;

=C2=A0 // Sum up 2-byte values until none or only one byte left.
=C2=A0 while (count > 1) {
=C2=A0=C2=A0=C2=A0 sum +=3D *(addr++);
=C2=A0=C2=A0=C2=A0 count -=3D 2;
=C2=A0 }

=C2=A0 // Add left-over byte, if any.
=C2=A0 if (count > 0) {
=C2=A0=C2=A0=C2=A0 sum +=3D *(uint8_t *) addr;
=C2=A0 }

=C2=A0 // Fold 32-bit sum into 16 bits; we lose information by doing this,
=C2=A0 // increasing the chances of a collision.
=C2=A0 // sum =3D (lower 16 bits) + (upper 16 bits shifted right 16 bits)
=C2=A0 while (sum >> 16) {
=C2=A0=C2=A0=C2=A0 sum =3D (sum & 0xffff) + (sum >> 16);
=C2=A0 }

=C2=A0 // Checksum is one's compliment of sum.
=C2=A0 answer =3D ~sum;

=C2=A0 return (answer);
}

// Allocate memory for an array of chars.
char *
allocate_strmem (int len)
{
=C2=A0 void *tmp;

=C2=A0 if (len <=3D 0) {
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "ERROR: Cannot allocate memory because =
len =3D %i in
allocate_strmem().\n", len);
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }

=C2=A0 tmp =3D (char *) malloc (len * sizeof (char));
=C2=A0 if (tmp !=3D NULL) {
=C2=A0=C2=A0=C2=A0 memset (tmp, 0, len * sizeof (char));
=C2=A0=C2=A0=C2=A0 return (tmp);
=C2=A0 } else {
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "ERROR: Cannot allocate memory for arra=
y
allocate_strmem().\n");
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }
}

// Allocate memory for an array of unsigned chars.
uint8_t *
allocate_ustrmem (int len)
{
=C2=A0 void *tmp;

=C2=A0 if (len <=3D 0) {
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "ERROR: Cannot allocate memory because =
len =3D %i in
allocate_ustrmem().\n", len);
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }

=C2=A0 tmp =3D (uint8_t *) malloc (len * sizeof (uint8_t));
=C2=A0 if (tmp !=3D NULL) {
=C2=A0=C2=A0=C2=A0 memset (tmp, 0, len * sizeof (uint8_t));
=C2=A0=C2=A0=C2=A0 return (tmp);
=C2=A0 } else {
=C2=A0=C2=A0=C2=A0 fprintf (stderr, "ERROR: Cannot allocate memory for arra=
y
allocate_ustrmem().\n");
=C2=A0=C2=A0=C2=A0 exit (EXIT_FAILURE);
=C2=A0 }
}

---------------------------------
[7.] Environment
Host -> Windows 10 - VirtualBox Version 5.1.10 r112026 (Qt5.6.2)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 Guest -> Ubuntu 16.04 (Up to date)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 Guest -> Arch Linux (Latest)

-------------
[7.1] Software
Linux tom-VirtualBox 4.4.0-51-generic #72-Ubuntu SMP Thu Nov 24 18:29:54
UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

GNU C=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 5.4.0
GNU Make=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 4.1
Binutils
2.26.1
Util-linux
2.27.1
Mount=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 2.27.1
Module-init-tools=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 22
E2fsprogs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1.42.13
Pcmciautils=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 018
PPP
2.4.7
Linux C Library=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2.23
Dynamic linker (ldd)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 2.23
Linux C++ Library=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 6.0.21
Procps
3.3.10
Net-tools=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1.60
Kbd
1.15.5
Console-tools=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 1.15.5
Sh-utils=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 8.=
25
Udev=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 229
Wireless-tools=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 30
Modules Loaded=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 8250_fintek
ablk_helper aesni_intel aes_x86_64 ahci autofs4 binfmt_misc crc32_pclmul
crct10dif_pclmul cryptd drm drm_kms_helper e1000 fb_sys_fops fjes gf128mul
ghash_clmulni_intel glue_helper hid hid_generic i2c_piix4 input_leds
joydev libahci lp lrw mac_hid parport parport_pc pata_acpi ppdev psmouse
serio_raw syscopyarea sysfillrect sysimgblt ttm usbhid vboxguest vboxsf
vboxvideo video


Linux archbox 4.8.11-1-ARCH #1 SMP PREEMPT Sun Nov 27 09:26:14 CET 2016
x86_64 GNU/Linux

GNU C=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 6.2.1
GNU Make=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 4.2.1
Binutils=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2.27
Util-linux=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 2.28.2
Mount=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2.28.2
Module-init-tools=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=
=A0 23
E2fsprogs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 1.43.3
Jfsutils=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1.1.15
Reiserfsprogs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 3.6.25
Xfsprogs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 4.8.0
Pcmciautils=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 018
Linux C Library=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2.24
Dynamic linker (ldd)=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0 2.24
Linux C++ Library=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 6.0.22
Kbd=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2.0.3
Console-tools=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2.0.3
Sh-utils=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 8.25
Udev=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 232
Modules Loaded=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ablk_h=
elper ac ac97_bus acpi_cpufreq aesni_intel
aes_x86_64 ata_generic ata_piix atkbd battery button cdrom cfg80211 crc16
crc32c_intel crc32_pclmul crct10dif_pclmul cryptd e1000 ehci_hcd ehci_pci
evdev ext4 fjes fscrypto gf128mul ghash_clmulni_intel glue_helper hid
hid_generic i2c_piix4 i8042 input_leds intel_agp intel_gtt intel_rapl_perf
ip_tables jbd2 joydev led_class libata libps2 lrw mac_hid mbcache mousedev
ohci_hcd ohci_pci parport parport_pc pata_acpi pcspkr ppdev psmouse rfkill
sch_fq_codel scsi_mod sd_mod serio serio_raw snd snd_ac97_codec
snd_intel8x0 snd_pcm snd_timer soundcore sr_mod tpm tpm_tis tpm_tis_core
usb_common usbcore usbhid video x_tables

-------------
[7.2.] Processor information
(Ubuntu)
processor=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 : 0
vendor_id=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 : GenuineIntel
cpu family=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 6
model=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 94
model name=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : Intel(R) Core(TM) i7-6700H=
Q CPU @ 2.60GHz
stepping=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 : 3
cpu MHz=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 : 2591.818
cache size=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 : 6144 KB
physical id=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0
siblings=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 : 1
core id=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0
cpu cores=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 : 1
apicid=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0
initial apicid=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0
fpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : yes
fpu_exception=C2=A0=C2=A0=C2=A0 : yes
cpuid level=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 22
wp=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : =
yes
flags=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : fpu vme de pse tsc ms=
r pae mce cx8 apic sep
mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx rdtscp lm
constant_tsc rep_good nopl xtopology nonstop_tsc pni pclmulqdq monitor
ssse3 cx16 sse4_1 sse4_2 movbe popcnt aes xsave avx rdrand lahf_lm abm
3dnowprefetch rdseed clflushopt
bugs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 :
bogomips=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
: 5183.63
clflush size=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 64
cache_alignment=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 : 64
address sizes=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 39 bits physical, 48 bits vir=
tual
power management:

(Arch)
processor=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0
vendor_id=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : GenuineIntel
cpu family=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 6
model=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 94
model name=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : Intel(R) Core(TM) i7-6700HQ CPU =
@ 2.60GHz
stepping=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 3
cpu MHz=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 2591.998
cache size=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 6144 KB
physical id=C2=A0=C2=A0=C2=A0=C2=A0 : 0
siblings=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 2
core id=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0: 0
cpu cores=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 2
apicid=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0
initial apicid=C2=A0 : 0
fpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 : yes
fpu_exception=C2=A0=C2=A0 : yes
cpuid level=C2=A0=C2=A0=C2=A0=C2=A0 : 22
wp=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 : yes
flags=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : fpu vme=
 de pse tsc msr pae mce cx8 apic sep mtrr pge mca
cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm
constant_tsc rep_good nopl xtopology nonstop_tsc eagerfpu pni pclmulqdq
ssse3 cx16 sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand
hypervisor lahf_lm abm 3dnowprefetch rdseed clflushopt
bugs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 :
bogomips=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 5186.99
clflush size=C2=A0=C2=A0=C2=A0 : 64
cache_alignment : 64
address sizes=C2=A0=C2=A0 : 39 bits physical, 48 bits virtual
power management:

processor=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 1
vendor_id=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : GenuineIntel
cpu family=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 6
model=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 94
model name=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : Intel(R) Core(TM) i7-6700HQ CPU =
@ 2.60GHz
stepping=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 3
cpu MHz=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 2591.998
cache size=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 6144 KB
physical id=C2=A0=C2=A0=C2=A0=C2=A0 : 0
siblings=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 2
core id=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 1
cpu cores=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 2
apicid=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 1
initial apicid=C2=A0 : 1
fpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 : yes
fpu_exception=C2=A0=C2=A0 : yes
cpuid level=C2=A0=C2=A0=C2=A0=C2=A0 : 22
wp=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 : yes
flags=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : fpu vme=
 de pse tsc msr pae mce cx8 apic sep mtrr pge mca
cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm
constant_tsc rep_good nopl xtopology nonstop_tsc eagerfpu pni pclmulqdq
ssse3 cx16 sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand
hypervisor lahf_lm abm 3dnowprefetch rdseed clflushopt
bugs=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 :
bogomips=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 5186.99
clflush size=C2=A0=C2=A0=C2=A0 : 64
cache_alignment : 64
address sizes=C2=A0=C2=A0 : 39 bits physical, 48 bits virtual
power management:

-------------
[7.3.] Module information
(Ubuntu)
vboxsf 45056 0 - Live 0x0000000000000000 (OE)
binfmt_misc 20480 1 - Live 0x0000000000000000
crct10dif_pclmul 16384 0 - Live 0x0000000000000000
crc32_pclmul 16384 0 - Live 0x0000000000000000
ghash_clmulni_intel 16384 0 - Live 0x0000000000000000
vboxvideo 49152 2 - Live 0x0000000000000000 (OE)
ttm 94208 1 vboxvideo, Live 0x0000000000000000
aesni_intel 167936 0 - Live 0x0000000000000000
aes_x86_64 20480 1 aesni_intel, Live 0x0000000000000000
lrw 16384 1 aesni_intel, Live 0x0000000000000000
drm_kms_helper 155648 1 vboxvideo, Live 0x0000000000000000
gf128mul 16384 1 lrw, Live 0x0000000000000000
glue_helper 16384 1 aesni_intel, Live 0x0000000000000000
ablk_helper 16384 1 aesni_intel, Live 0x0000000000000000
cryptd 20480 3 ghash_clmulni_intel,aesni_intel,ablk_helper, Live
0x0000000000000000
drm 364544 5 vboxvideo,ttm,drm_kms_helper, Live 0x0000000000000000
joydev 20480 0 - Live 0x0000000000000000
fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
input_leds 16384 0 - Live 0x0000000000000000
serio_raw 16384 0 - Live 0x0000000000000000
syscopyarea 16384 2 vboxvideo,drm_kms_helper, Live 0x0000000000000000
sysfillrect 16384 2 vboxvideo,drm_kms_helper, Live 0x0000000000000000
sysimgblt 16384 2 vboxvideo,drm_kms_helper, Live 0x0000000000000000
vboxguest 282624 6 vboxsf,vboxvideo, Live 0x0000000000000000 (OE)
i2c_piix4 24576 0 - Live 0x0000000000000000
8250_fintek 16384 0 - Live 0x0000000000000000
mac_hid 16384 0 - Live 0x0000000000000000
parport_pc 32768 0 - Live 0x0000000000000000
ppdev 20480 0 - Live 0x0000000000000000
lp 20480 0 - Live 0x0000000000000000
parport 49152 3 parport_pc,ppdev,lp, Live 0x0000000000000000
autofs4 40960 2 - Live 0x0000000000000000
hid_generic 16384 0 - Live 0x0000000000000000
usbhid 49152 0 - Live 0x0000000000000000
hid 118784 2 hid_generic,usbhid, Live 0x0000000000000000
psmouse 131072 0 - Live 0x0000000000000000
ahci 36864 3 - Live 0x0000000000000000
libahci 32768 1 ahci, Live 0x0000000000000000
fjes 28672 0 - Live 0x0000000000000000
video 40960 0 - Live 0x0000000000000000
e1000 135168 0 - Live 0x0000000000000000
pata_acpi 16384 0 - Live 0x0000000000000000

(Arch)
cfg80211 495616 0 - Live 0xffffffffa0416000
rfkill 20480 2 cfg80211, Live 0xffffffffa0394000
ppdev 20480 0 - Live 0xffffffffa0410000
crct10dif_pclmul 16384 0 - Live 0xffffffffa040b000
crc32_pclmul 16384 0 - Live 0xffffffffa0406000
crc32c_intel 24576 0 - Live 0xffffffffa03fb000
ghash_clmulni_intel 16384 0 - Live 0xffffffffa03f6000
aesni_intel 167936 0 - Live 0xffffffffa03c3000
aes_x86_64 20480 1 aesni_intel, Live 0xffffffffa03bd000
lrw 16384 1 aesni_intel, Live 0xffffffffa03b8000
gf128mul 16384 1 lrw, Live 0xffffffffa03b3000
glue_helper 16384 1 aesni_intel, Live 0xffffffffa03a3000
ablk_helper 16384 1 aesni_intel, Live 0xffffffffa039e000
cryptd 20480 3 ghash_clmulni_intel,aesni_intel,ablk_helper, Live
0xffffffffa03a8000
intel_rapl_perf 16384 0 - Live 0xffffffffa0387000
input_leds 16384 0 - Live 0xffffffffa0382000
pcspkr 16384 0 - Live 0xffffffffa031f000
evdev 24576 3 - Live 0xffffffffa038d000
psmouse 126976 0 - Live 0xffffffffa0362000
led_class 16384 1 input_leds, Live 0xffffffffa0359000
joydev 20480 0 - Live 0xffffffffa0335000
mousedev 20480 0 - Live 0xffffffffa02f8000
mac_hid 16384 0 - Live 0xffffffffa02dd000
parport_pc 28672 0 - Live 0xffffffffa02e8000
parport 40960 2 ppdev,parport_pc, Live 0xffffffffa032a000
acpi_cpufreq 20480 0 - Live 0xffffffffa0324000
fjes 28672 0 - Live 0xffffffffa028a000
battery 20480 0 - Live 0xffffffffa0306000
tpm_tis 16384 0 - Live 0xffffffffa02e3000
intel_agp 20480 0 - Live 0xffffffffa0315000
tpm_tis_core 20480 1 tpm_tis, Live 0xffffffffa030f000
ac 16384 0 - Live 0xffffffffa0301000
button 16384 0 - Live 0xffffffffa02f3000
tpm 36864 2 tpm_tis,tpm_tis_core, Live 0xffffffffa02d3000
video 36864 0 - Live 0xffffffffa02c9000
e1000 131072 0 - Live 0xffffffffa02a8000
i2c_piix4 24576 0 - Live 0xffffffffa0232000
intel_gtt 20480 1 intel_agp, Live 0xffffffffa02a2000
snd_intel8x0 36864 0 - Live 0xffffffffa0293000
snd_ac97_codec 118784 1 snd_intel8x0, Live 0xffffffffa026c000
ac97_bus 16384 1 snd_ac97_codec, Live 0xffffffffa0098000
snd_pcm 90112 2 snd_intel8x0,snd_ac97_codec, Live 0xffffffffa0249000
snd_timer 28672 1 snd_pcm, Live 0xffffffffa023c000
snd 69632 4 snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer, Live
0xffffffffa0220000
soundcore 16384 1 snd, Live 0xffffffffa0080000
sch_fq_codel 20480 2 - Live 0xffffffffa021a000
ip_tables 28672 0 - Live 0xffffffffa0145000
x_tables 28672 1 ip_tables, Live 0xffffffffa0150000
ext4 524288 1 - Live 0xffffffffa0199000
crc16 16384 1 ext4, Live 0xffffffffa00a9000
jbd2 90112 1 ext4, Live 0xffffffffa00f9000
fscrypto 24576 1 ext4, Live 0xffffffffa00f2000
mbcache 16384 2 ext4, Live 0xffffffffa0068000
hid_generic 16384 0 - Live 0xffffffffa006e000
usbhid 49152 0 - Live 0xffffffffa018c000
hid 114688 2 hid_generic,usbhid, Live 0xffffffffa016f000
sr_mod 24576 0 - Live 0xffffffffa00b4000
cdrom 53248 1 sr_mod, Live 0xffffffffa00e4000
sd_mod 36864 3 - Live 0xffffffffa005e000
ata_generic 16384 0 - Live 0xffffffffa001c000
pata_acpi 16384 0 - Live 0xffffffffa0017000
ohci_pci 16384 0 - Live 0xffffffffa0012000
serio_raw 16384 0 - Live 0xffffffffa00af000
atkbd 24576 0 - Live 0xffffffffa00a2000
libps2 16384 2 psmouse,atkbd, Live 0xffffffffa009d000
ata_piix 36864 2 - Live 0xffffffffa008e000
ehci_pci 16384 0 - Live 0xffffffffa0085000
ohci_hcd 49152 1 ohci_pci, Live 0xffffffffa0073000
ehci_hcd 73728 1 ehci_pci, Live 0xffffffffa015c000
libata 208896 3 ata_generic,pata_acpi,ata_piix, Live 0xffffffffa0111000
scsi_mod 159744 3 sr_mod,sd_mod,libata, Live 0xffffffffa00bc000
usbcore 208896 5 usbhid,ohci_pci,ohci_hcd,ehci_pci,ehci_hcd, Live
0xffffffffa002a000
usb_common 16384 1 usbcore, Live 0xffffffffa0022000
i8042 28672 0 - Live 0xffffffffa000a000
serio 20480 6 psmouse,serio_raw,atkbd,i8042, Live 0xffffffffa0000000

--=20
Registered Office: Actual Experience plc
Quay House, The Ambury, Bath BA1 1UA,
Registered No. 06838738, VAT No. 971 9696 56

The information transmitted is intended only for the person or entity to=20
which it is addressed and may contain confidential and/or privileged=20
material. Any review, retransmission, dissemination or other use of, or=20
taking of any action in reliance upon, this information by persons or=20
entities other than the intended recipient is prohibited. If you received=
=20
this in error, please contact the sender and delete the material from any=
=20
computer. Although we routinely screen for viruses, addressees should check=
=20
this e-mail and any attachment for viruses. We make no warranty as to=20
absence of viruses in this e-mail or any attachments.
