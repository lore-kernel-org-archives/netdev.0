From: Daniel Risacher <magnus@alum.mit.edu>
Subject: source address for UDP broadcasts with aliased interfaces?
Date: Fri, 19 Nov 2004 12:13:38 -0500
Message-ID: <E1CVCKI-0006S1-00@m5.risacher.org>
Reply-To: magnus@alum.mit.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(previously posted on LKML; resent here per suggestion from Alan Cox)

I'm not sure if this is a bug or a feature.

There seems to be no way to get the kernel to send a UDP broadcast
packet to INADDR_BROADCAST from a specific address, short of using
iptables.

I would think that bind()ing a socket to a local address would
determine the source address, but the kernel seems to ignore the bound
address.

I'm trying to write a program that communicates with multiple hosts on
a local net, several of which have firewall rules that drop packets
from external addresses. The source computer has multiple aliased
addresses on the eth0 interface. I therefore want to broadcast from a
specific non-routable internal address. I've experimented with bind()
and setsockopt(,SO_BINDTODEVICE,) to determine the source address
and/or interface but the kernel seems to pick whatever it wants.

Is there a correct way to specify the sender address/interface?

Dan Risacher

(reference code follows; testing was done on Linux 2.6.9)

struct sockaddr_in to_addr;
struct sockaddr_in my_addr;
my_addr.sin_family = AF_INET;
my_addr.sin_port = htons(0);

/***** find_if_addr() will return 10.0.0.7 (the address of eth0)  ******/
my_addr.sin_addr.s_addr = find_if_addr(interface);
to_addr.sin_family = AF_INET;
to_addr.sin_port = htons(11415);
to_addr.sin_addr.s_addr = INADDR_BROADCAST;

fd = socket(PF_INET, SOCK_DGRAM, 0);

res = setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &one, sizeof(one));
if (res) perror ("setsockopt (SO_BROADCAST)");

/***** this should bind the source to 10.0.0.7, I think *****/
res = bind(fd, (struct sockaddr*) &my_addr, sizeof(struct sockaddr_in));
if (res) perror ("bind");

res = setsockopt(fd, SOL_SOCKET, SO_BINDTODEVICE, interface,
                 1+strlen(interface));
if (res) perror ("setsockopt (SO_BINDTODEVICE)");

/***** when sent, the packet is actually coming from 66.92.162.116 (eth0:wan) *****/
res = sendto(fd, mesg, strlen(mesg), MSG_DONTROUTE,
             (struct sockaddr *)&to_addr,
             sizeof(struct sockaddr_in));
if (res == -1) perror ("sendto");
