From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] net: add wireless TX status socket option
Date: Fri, 07 Oct 2011 20:06:25 +0200
Message-ID: <1318010785.3988.39.camel@jlt3.sipsolutions.net>
References: <1318007970.3988.27.camel@jlt3.sipsolutions.net>
	 (sfid-20111007_191939_635174_0248A79F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1318007970.3988.27.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org> (sfid-20111007_191939_635174_0248A79F)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-10-07 at 19:19 +0200, Johannes Berg wrote:

> This works similar to the existing TX timestamping
> in that it reflects the SKB back to the socket's
> error queue with a SCM_WIFI_STATUS cmsg that has
> an int indicating ACK status (0/1).

I should give you a test application. This is based on the code in
Documentation/networking/timestamping/timestamping.c and sends the same
frames, but to UDP port 1 to a peer you give on the command line.

E.g. if you save this file as ack.c, you can do

$ ./ack 192.168.100.2
SO_WIFI_STATUS 1
1318010597.494035: sent 124 bytes
1318010597.494084: select 2505916us
1318010597.513457: select returned: 1, success
ready for reading
1318010597.513668: received error data, 194 bytes from 69.0.0.152, 72 bytes control messages
   cmsg len 20: SOL_SOCKET acked: 1
   cmsg len 48: IPPROTO_IP IP_RECVERR ee_errno 'No message of desired type' ee_origin 4 => bounced packet => GOT OUR DATA BACK (HURRAY!)
1318010597.513860: select 2486140us

(not sure what's with the bogus RX IP, probably just not a valid field here)

johannes


/*
 * This program demonstrates how the wifi ack status feature in
 * the Linux kernel works. It sends some random packets and prints
 * out whether it was acked.
 *
 * Copyright (C) 2009, 2011 Intel Corporation.
 * Author: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 * Author: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include <sys/time.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/ioctl.h>
#include <arpa/inet.h>
#include <net/if.h>

#include <asm/types.h>
#include <linux/net_tstamp.h>
#include <linux/errqueue.h>

#ifndef SO_WIFI_STATUS
# define SO_WIFI_STATUS		41
# define SCM_WIFI_STATUS	SO_WIFI_STATUS
#endif

#ifndef SO_EE_ORIGIN_TXSTATUS
#define SO_EE_ORIGIN_TXSTATUS	4
#endif

static void bail(const char *error)
{
	printf("%s: %s\n", error, strerror(errno));
	exit(1);
}

static const unsigned char sync[] = {
	0x00, 0x01, 0x00, 0x01,
	0x5f, 0x44, 0x46, 0x4c,
	0x54, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x01, 0x01,

	/* fake uuid */
	0x00, 0x01,
	0x02, 0x03, 0x04, 0x05,

	0x00, 0x01, 0x00, 0x37,
	0x00, 0x00, 0x00, 0x08,
	0x00, 0x00, 0x00, 0x00,
	0x49, 0x05, 0xcd, 0x01,
	0x29, 0xb1, 0x8d, 0xb0,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x01,

	/* fake uuid */
	0x00, 0x01,
	0x02, 0x03, 0x04, 0x05,

	0x00, 0x00, 0x00, 0x37,
	0x00, 0x00, 0x00, 0x04,
	0x44, 0x46, 0x4c, 0x54,
	0x00, 0x00, 0xf0, 0x60,
	0x00, 0x01, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x01,
	0x00, 0x00, 0xf0, 0x60,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x04,
	0x44, 0x46, 0x4c, 0x54,
	0x00, 0x01,

	/* fake uuid */
	0x00, 0x01,
	0x02, 0x03, 0x04, 0x05,

	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00
};

static void sendpacket(int sock, struct sockaddr *addr, socklen_t addr_len)
{
	struct timeval now;
	int res;

	res = sendto(sock, sync, sizeof(sync), 0,
		addr, addr_len);
	gettimeofday(&now, 0);
	if (res < 0)
		printf("%s: %s\n", "send", strerror(errno));
	else
		printf("%ld.%06ld: sent %d bytes\n",
		       (long)now.tv_sec, (long)now.tv_usec,
		       res);
}

static void printpacket(struct msghdr *msg, int res,
			char *data, int sock)
{
	struct sockaddr_in *from_addr = (struct sockaddr_in *)msg->msg_name;
	struct cmsghdr *cmsg;
	struct timeval tv;
	struct timespec ts;
	struct timeval now;

	gettimeofday(&now, 0);

	printf("%ld.%06ld: received %s data, %d bytes from %s, %zu bytes control messages\n",
	       (long)now.tv_sec, (long)now.tv_usec, "error",
	       res,
	       inet_ntoa(from_addr->sin_addr),
	       msg->msg_controllen);
	for (cmsg = CMSG_FIRSTHDR(msg);
	     cmsg;
	     cmsg = CMSG_NXTHDR(msg, cmsg)) {
		printf("   cmsg len %zu: ", cmsg->cmsg_len);
		switch (cmsg->cmsg_level) {
		case SOL_SOCKET:
			printf("SOL_SOCKET ");
			switch (cmsg->cmsg_type) {
			case SCM_WIFI_STATUS: {
				int *ack = (void *)CMSG_DATA(cmsg);
				printf("acked: %d", *ack);
				break;
			}
			default:
				printf("type %d", cmsg->cmsg_type);
				break;
			}
			break;
		case IPPROTO_IP:
			printf("IPPROTO_IP ");
			switch (cmsg->cmsg_type) {
			case IP_RECVERR: {
				struct sock_extended_err *err =
					(struct sock_extended_err *)CMSG_DATA(cmsg);
				printf("IP_RECVERR ee_errno '%s' ee_origin %d => %s",
					strerror(err->ee_errno),
					err->ee_origin,
					err->ee_origin == SO_EE_ORIGIN_TXSTATUS ?
					"bounced packet" : "unexpected origin"
					);
				if (res < sizeof(sync))
					printf(" => truncated data?!");
				else if (!memcmp(sync, data + res - sizeof(sync),
						 sizeof(sync)))
					printf(" => GOT OUR DATA BACK (HURRAY!)");
				break;
			}
			case IP_PKTINFO: {
				struct in_pktinfo *pktinfo =
					(struct in_pktinfo *)CMSG_DATA(cmsg);
				printf("IP_PKTINFO interface index %u",
					pktinfo->ipi_ifindex);
				break;
			}
			default:
				printf("type %d", cmsg->cmsg_type);
				break;
			}
			break;
		default:
			printf("level %d type %d",
				cmsg->cmsg_level,
				cmsg->cmsg_type);
			break;
		}
		printf("\n");
	}
}

static void recvpacket(int sock)
{
	char data[256];
	struct msghdr msg;
	struct iovec entry;
	struct sockaddr_in from_addr;
	struct {
		struct cmsghdr cm;
		char control[512];
	} control;
	int res;

	memset(&msg, 0, sizeof(msg));
	msg.msg_iov = &entry;
	msg.msg_iovlen = 1;
	entry.iov_base = data;
	entry.iov_len = sizeof(data);
	msg.msg_name = (caddr_t)&from_addr;
	msg.msg_namelen = sizeof(from_addr);
	msg.msg_control = &control;
	msg.msg_controllen = sizeof(control);

	res = recvmsg(sock, &msg, MSG_ERRQUEUE|MSG_DONTWAIT);
	if (res < 0) {
		printf("%s %s: %s\n",
		       "recvmsg", "error",
		       strerror(errno));
	} else {
		printpacket(&msg, res, data, sock);
	}
}

int main(int argc, char **argv)
{
	int i;
	int enabled = 1;
	int sock;
	struct ifreq device;
	struct ifreq hwtstamp;
	struct sockaddr_in addr;
	struct ip_mreq imr;
	int val;
	socklen_t len;
	struct timeval next;

	addr.sin_family = AF_INET;
	addr.sin_port = htons(1);

	if (argc != 2 || inet_aton(argv[1], &addr.sin_addr) == 0) {
		printf("%s <ip addr>\n", argv[0]);
		exit(1);
	}

	sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (sock < 0)
		bail("socket");


	/* set socket option for wifi status */
	if (setsockopt(sock, SOL_SOCKET, SO_WIFI_STATUS,
		       &enabled, sizeof(enabled)) < 0) {
		bail("enable ack status");
	}

	/* request IP_PKTINFO for debugging purposes */
	if (setsockopt(sock, SOL_IP, IP_PKTINFO,
		       &enabled, sizeof(enabled)) < 0)
		printf("%s: %s\n", "setsockopt IP_PKTINFO", strerror(errno));

	/* verify socket options */
	len = sizeof(val);
	if (getsockopt(sock, SOL_SOCKET, SO_WIFI_STATUS, &val, &len) < 0)
		printf("%s: %s\n", "getsockopt SO_TIMESTAMP", strerror(errno));
	else
		printf("SO_WIFI_STATUS %d\n", val);

	/* send packets forever every five seconds */
	gettimeofday(&next, 0);
	next.tv_sec = (next.tv_sec + 1) / 5 * 5;
	next.tv_usec = 0;
	while (1) {
		struct timeval now;
		struct timeval delta;
		long delta_us;
		int res;
		fd_set readfs, errorfs;

		gettimeofday(&now, 0);
		delta_us = (long)(next.tv_sec - now.tv_sec) * 1000000 +
			(long)(next.tv_usec - now.tv_usec);
		if (delta_us > 0) {
			/* continue waiting for timeout or data */
			delta.tv_sec = delta_us / 1000000;
			delta.tv_usec = delta_us % 1000000;

			FD_ZERO(&readfs);
			FD_ZERO(&errorfs);
			FD_SET(sock, &readfs);
			FD_SET(sock, &errorfs);
			printf("%ld.%06ld: select %ldus\n",
			       (long)now.tv_sec, (long)now.tv_usec,
			       delta_us);
			res = select(sock + 1, &readfs, 0, &errorfs, &delta);
			gettimeofday(&now, 0);
			printf("%ld.%06ld: select returned: %d, %s\n",
			       (long)now.tv_sec, (long)now.tv_usec,
			       res,
			       res < 0 ? strerror(errno) : "success");
			if (res > 0) {
				if (FD_ISSET(sock, &readfs))
					printf("ready for reading\n");
				if (FD_ISSET(sock, &errorfs))
					printf("has error\n");
				recvpacket(sock);
			}
		} else {
			/* write one packet */
			sendpacket(sock,
				   (struct sockaddr *)&addr,
				   sizeof(addr));
			next.tv_sec += 5;
			continue;
		}
	}

	return 0;
}


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
