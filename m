From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 12:38:53 +0200
Message-ID: <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com>
References: <7e0dd21a0809021127n35cd38d7m98be5ee5d7158788@mail.gmail.com>
	 <20080902194603.GA2825@2ka.mipt.ru>
	 <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:49485 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbYICKiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 06:38:54 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2704032rvb.1
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 03:38:53 -0700 (PDT)
In-Reply-To: <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

I'm not able to exceed 15Mo/s even with vmsplice/splice duo.

Due to some issues:
- I didn't manage to adjust size of packets sent over the network (it
seems to be aligned with page). And maximum packet size seems to be
the page size (4096).
- I need approximately two system calls (vmsplice and splice) for
~4096*8 bytes maximum which is maybe a limit of pipe.
- I'm still going through packet_sendmsg() (packet socket) which
allocates a sk_buff and copies all data inside.

As reference, with my "patch": I need to send more than 32 packets of
7200 bytes (pc network card limit) in one system call (send()) and
without sk_buff data copy. (To reach 85 Mbytes/s)

Please find below my test program for vmsplice/splice:

Best regards,
Johann

#include <stdio.h>
#define _GNU_SOURCE

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/uio.h>

#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <poll.h>


int main (void)
{
	struct tpacket_req s_packet_req;
	uint32_t size, opt_len;
	int fd, i, ec, i_sz_packet = 7150;
	struct pollfd s_pfd;
	struct sockaddr_ll my_addr, peer_addr;
	struct ifreq s_ifr; /* points to one interface returned from ioctl */
	int len;
	int fd_socket;
	int i_nb_buffer = 64;
	int i_buffer_size = 8192;
	int i_index;
	int i_updated_cnt;
	int i_ifindex;
	int i_header_size;
	struct tpacket_hdr * ps_header_start;
	struct tpacket_hdr * ps_header;
	char buffer[8000];

	/* reset indes */
	i_index = 0;

	fd_socket = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
	if(fd_socket == -1)
	{
		perror("socket");
		return EXIT_FAILURE;
	}

	/* start socket config: device and mtu */

	/* clear structure */
	memset(&my_addr, 0, sizeof(struct sockaddr_ll));
	my_addr.sll_family = PF_PACKET;
	my_addr.sll_protocol = htons(ETH_P_ALL);

	/* initialize interface struct */
	strncpy (s_ifr.ifr_name, "eth0", sizeof(s_ifr.ifr_name));

	/* Get the broad cast address */
	ec = ioctl(fd_socket, SIOCGIFINDEX, &s_ifr);
	if(ec == -1)
	{
		perror("iotcl");
		return EXIT_FAILURE;
	}
	/* update with interface index */
	i_ifindex = s_ifr.ifr_ifindex;

	/* new mtu value */
	s_ifr.ifr_mtu = 7200;

	/* update the mtu through ioctl */
	ec = ioctl(fd_socket, SIOCSIFMTU, &s_ifr);
	if(ec == -1)
	{
		perror("iotcl");
		return EXIT_FAILURE;
	}

	/* set sockaddr info */
	memset(&my_addr, 0, sizeof(struct sockaddr_ll));
	my_addr.sll_family = AF_PACKET;
	my_addr.sll_protocol = ETH_P_ALL;
	my_addr.sll_ifindex = i_ifindex;

	/* bind port */
	if (bind(fd_socket, (struct sockaddr *)&my_addr, sizeof(struct
sockaddr_ll)) == -1)
	{
		perror("bind");
		return EXIT_FAILURE;
	}
	/* prepare Tx ring request */
	s_packet_req.tp_block_size = i_buffer_size;
	s_packet_req.tp_frame_size = i_buffer_size;
	s_packet_req.tp_block_nr = i_nb_buffer;
	s_packet_req.tp_frame_nr = i_nb_buffer;


	/* calculate memory to mmap in the kernel */
	size = s_packet_req.tp_block_size * s_packet_req.tp_block_nr;


	{

		/* Splice flags (not laid down in stone yet). */
#ifndef SPLICE_F_MOVE
#define SPLICE_F_MOVE           0x01
#endif
#ifndef SPLICE_F_NONBLOCK
#define SPLICE_F_NONBLOCK       0x02
#endif
#ifndef SPLICE_F_MORE
#define SPLICE_F_MORE           0x04
#endif
#ifndef SPLICE_F_GIFT
#define SPLICE_F_GIFT           0x08
#endif
#ifndef __NR_splice
#define __NR_splice             313
#endif

		int filedes [2];
		int ret;
		int to_write;
		struct iovec iov;
		iov.iov_base = &buffer;
		iov.iov_len = 4096;


		ret = pipe (filedes);
		printf("fd = %d %d %d %p\n", fd, filedes[0], filedes[1], iov.iov_base);
		for(i=0; i< sizeof buffer; i++)
		{
			buffer[i] = (char) i;
		}
		for(i=0; i< 500000; i++)
		{
			to_write = 0;
			while (to_write < iov.iov_len*7) {
				ret = vmsplice (filedes [1],&iov, 1, SPLICE_F_MOVE | SPLICE_F_MORE);
				if (ret < 0)
				{
					perror("splice");
					return EXIT_FAILURE;
				}
				else
					to_write += ret;
			}

			while (to_write > 0) {
				ret = splice (filedes [0], NULL, fd_socket,
											NULL, to_write,
											SPLICE_F_MOVE | SPLICE_F_MORE);

				if (ret < 0)
				{
					perror("write splice");
					return EXIT_FAILURE;
				}
				else
					to_write -= ret;
			}
		}


	}

	return EXIT_SUCCESS;
}

On Wed, Sep 3, 2008 at 9:56 AM, Johann Baudy <johaahn@gmail.com> wrote:
> Hi Evgeniy,
>
>>> I've made lot of tests, playing with jumbo frames, raw sockets, ...
>>> I've never exceeded ~25Mbytes/s. So I've decided to analyze deeply the
>>> packet socket transmission process.
>>>
>>> The main blocking point was the memcpy_fromiovec() function that is
>>> located in the packet_sendmsg() of af_packet.c.
>>
>> Can you saturate the link with usual tcp/udp socket?
>
> No, only ~15-20Mo/s with standard tcp/udp socket.
>
>>
>>> But, I would like to get as much criticism as possible in order to
>>> start a discussion with experts about a conceivable way to mix
>>> zero-copy, sk_buff management and packet socket.
>>> Which is perhaps impossible with current network kernel flow ...
>>
>> Did you try vmsplice and splice?
>> It is the preferred way to do a zero-copy.
>
> Not yet, I will perform some tests using splice and let you know performances.
>
> Many thanks,
> Johann
>
>
>
> --
> Johann Baudy
> johaahn@gmail.com
>



-- 
Johann Baudy
johaahn@gmail.com
