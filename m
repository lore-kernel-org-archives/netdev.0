From: Eric Lammerts <eric@lammerts.org>
Subject: [PATCH] wrong ENETDOWN in af_packet?
Date: Wed, 5 Mar 2003 15:11:23 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030305141123.GA16699@ally.lammerts.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


Hi,
I have a program that goes like this (source code at end of mail):

open PF_PACKET socket
look up index of interface x
bind to that interface
bring interface x down (~IFF_UP)
bring interface x up (IFF_UP|IFF_RUNNING)
for(;;) {
	recvfrom()
}

Problem: the first recvfrom() always results in ENETDOWN.

The reason is that (in af_packet.c) packet_notifier(NETDEV_DOWN) sets
sk->err to ENETDOWN, but packet_notifier(NETDEV_UP) doesn't clear it.
Is this behaviour deliberate?

If not, I suggest the following patch:

diff -u -r1.1.1.1 af_packet.c
--- linux-2.4.19/net/packet/af_packet.c	10 Jan 2003 16:20:09 -0000	1.1.1.1
+++ linux-2.4.19/net/packet/af_packet.c	5 Mar 2003 11:04:33 -0000
@@ -1407,6 +1407,7 @@
 				dev_add_pack(&po->prot_hook);
 				sock_hold(sk);
 				po->running = 1;
+				sk->err = 0;
 			}
 			spin_unlock(&po->bind_lock);
 #ifdef CONFIG_PACKET_MULTICAST


Currently I work around the problem by doing a getsockopt(x, SOL_SOCKET,
SO_ERROR,...) to clear the error variable.

Eric




#include <stdio.h>
#include <string.h>
#include <net/ethernet.h>
#include <net/if.h>
#include <net/if_packet.h>
#include <netinet/in.h>
#include <netpacket/packet.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>

void modify_iface_flags(int sock, char *device_name, short set, short reset)
{
	struct ifreq ifr;

	strncpy(ifr.ifr_name, device_name, IFNAMSIZ);
	if(ioctl(sock, SIOCGIFFLAGS, &ifr) < 0) {
		perror("SIOCGIFFLAGS");
		exit(1);
	}

	ifr.ifr_flags |= set;
	ifr.ifr_flags &= ~reset;

	strncpy(ifr.ifr_name, device_name, IFNAMSIZ);
	if(ioctl(sock, SIOCSIFFLAGS, &ifr) < 0) {
		perror("SIOCSIFFLAGS");
		exit(1);
	}
}

void bind_to_iface(int sock, char *ifacename)
{
	struct ifreq ifr;
	struct sockaddr_ll sa;

	strncpy(ifr.ifr_name, ifacename, IFNAMSIZ);
	if(ioctl(sock, SIOCGIFINDEX, &ifr) < 0) {
		perror("ioctl SIOCGIFINDEX");
		exit(1);
	}

	sa.sll_family = AF_PACKET;
	sa.sll_ifindex = ifr.ifr_ifindex;
	if(bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
		perror("bind");
		exit(1);
	}
}

int main()
{
	int fd, sz;
	char iface[] = "eth0";
	unsigned char data[1518];
	struct sockaddr_ll sa;
	socklen_t salen;
	
	fd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
	if(fd < 0) { perror("socket"); exit(1); }

	bind_to_iface(fd, iface);

	// bring it down
	modify_iface_flags(fd, iface, 0, IFF_UP);

	// bring it up
	modify_iface_flags(fd, iface, IFF_UP | IFF_RUNNING, 0);

	//receive packet	
	salen = sizeof(sa);
	sz = recvfrom(fd, data, sizeof(data), 0, (struct sockaddr *)&sa, &salen);
	if(sz == -1) {
		perror("recvfrom");
		exit(1);
	}
	return 0;
}
