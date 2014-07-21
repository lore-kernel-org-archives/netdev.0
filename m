From: Mihail Dakov <mihail.dakov@ng4t.com>
Subject: AF_PACKET: tx_ring mirrored in rx_ring?
Date: Mon, 21 Jul 2014 15:38:49 +0200
Message-ID: <53CD17E9.6000102@ng4t.com>
References: <53CD1326.5090006@ng4t.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040008000800060401050102"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud15.udmedia.de ([194.117.254.55]:42032 "EHLO
	mail.ud15.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129AbaGUNjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 09:39:54 -0400
In-Reply-To: <53CD1326.5090006@ng4t.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040008000800060401050102
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit


Hello guys,

I am having a trouble using the RX/TX ring buffer for AF_PACKET sockets. 
I create two sockets (one for rx, one for tx). I bind those sockets to 
the same interface. According the docs you can create a socket per 
direction or single socket for both directions (allocating double the 
memory needed for a ring buffer, and then mapping first rx and then tx 
buffer). In this case I opted for creating two sockets, one per 
direction. The problem is that when I use the tx_ring to send over the 
pf_socket I see those message "mirrored" in the rx_ring buffer which is 
not an expected behavior for my application. In other to reproduce the 
issue I simplified my application into a smaller one. Then I send a 
manually created ping message with adjusted mac and ip address so that a 
remote machine in my local network answers it. I successfully see the 
ping request double (once in the tx_ring and once in the rx_ring). Which 
I think is not expected behavior. This application was tested on kernel 
3.14.12-1 and was compiled with gcc (Debian 4.8.3-5) and on kernel 
3.2.0-52-lowlatency with compiler gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3.


So some questions have arised:
  1. Is this normal behavior? If it is, why? I mean, if I use a socket 
per direction I expect to see only packets for that direction on the 
correspondent socket, right?
  2. Could you provide some more insights about why this "problem" is 
happening? Am I doing it wrong? Did I get it wrong (the whole ring 
buffer in af_packets)? Am I using wrong settings?

I have attached the simple program which should reproduce the issue.


--
Mihail Dakov
mihail.dakov@ng4t.com


--------------040008000800060401050102
Content-Type: text/x-c++src;
 name="pftest.cpp"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pftest.cpp"

#include <cstdio>
#include <cstdint>
#include <cstring>
#include <cstdlib>

#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/poll.h>

#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <netinet/ip_icmp.h>
#include <net/if.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/sockios.h>
#include <errno.h>
#include <signal.h>

#define BLOCK_SZ (4096 << 8)
#define FRAME_SZ 2048

#define IP_HLEN 20

struct ring3_t
{
	uint8_t *rx_buf;
	uint32_t brx;//current block idx
	struct tpacket_req3 req;
	ring3_t()
	{
		rx_buf = NULL;
		brx = 0;
	}
};

struct ring_t
{
	uint8_t *rx_buf;
	uint8_t *tx_buf;
	uint32_t ftx;//current frame idx for tx
	uint32_t frx;//current frame idx for rx
	struct tpacket_req req;
	ring_t()
	{
		rx_buf = tx_buf = NULL;
		ftx = frx = 0;
	}
};

static int rx_kernel_ready(struct tpacket_hdr_v1 *hdr)
{
	return (hdr->block_status & TP_STATUS_USER);
}

static void rx_user_ready(struct tpacket_hdr_v1 *hdr)
{
	hdr->block_status = TP_STATUS_KERNEL;
}

static int tx_kernel_ready(struct tpacket2_hdr *hdr)
{
	return !(hdr->tp_status & (TP_STATUS_SEND_REQUEST | TP_STATUS_SENDING));
}

static void tx_user_ready(struct tpacket2_hdr *hdr)
{
	hdr->tp_status = TP_STATUS_SEND_REQUEST;
}
void filltxring(int sock, uint32_t *frame, ring_t *ring, uint8_t *data, uint32_t len);

uint32_t seq = 0, frametx = 0, flushneed = 0;
int sockrx,socktx, rbuf = 16777216, sbuf = 16777216;
ring_t txring;

void signal_handler(int signum)
{
	switch(signum)
	{
		case SIGHUP:
		{
			uint8_t data[128];

			uint8_t const ping[] = {
				0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xBB,0xBB,0xBB,0xBB,0xBB,0xBB,0x08,0x00,0x45,0x00,
				0x00,0x54,0xb3,0x31,0x40,0x00,0x40,0x01,0x9f,0x18,0xCC,0xCC,0xCC,0xCC,0xDD,0xDD,
				0xDD,0xDD,0x08,0x00,0x71,0xae,0x02,0x35,0x00,0x01,0xed,0xda,0xcc,0x53,0x00,0x00,
				0x00,0x00,0x00,0x1a,0x0b,0x00,0x00,0x00,0x00,0x00,0x10,0x11,0x12,0x13,0x14,0x15,
				0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,0x20,0x21,0x22,0x23,0x24,0x25,
				0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f,0x30,0x31,0x32,0x33,0x34,0x35,
				0x36,0x37
			};
			std::memmove(data,ping,98);
			filltxring(socktx, &frametx, &txring, data, 98);
			break;
		}
		default:
			break;
	}
}

void flushtx(int sock)
{
	if (flushneed)
	{
		if (sendto(sock, NULL, 0, MSG_DONTWAIT, NULL, 0) < 0)
			fprintf(stderr, "flushtx: sendto() error %s\n",strerror(errno));
		flushneed = 0;
	}
}

void filltxring(int sock, uint32_t *frame, ring_t *ring, uint8_t *data, uint32_t len)
{
	struct tpacket2_hdr *hdr = NULL;
	uint8_t *buf = NULL,
			*base = (uint8_t*)(ring->tx_buf+(*frame)*FRAME_SZ);
	hdr = (struct tpacket2_hdr *)base;
	if (tx_kernel_ready(hdr))
	{
		buf = base+(TPACKET2_HDRLEN-sizeof(struct sockaddr_ll));
		std::memmove(buf,data,len);
		struct ethhdr *ethh = (struct ethhdr*)buf;
		uint8_t *smac = (uint8_t*)ethh->h_source;
		uint8_t *dmac = (uint8_t*)ethh->h_dest;
		struct iphdr *iph = (struct iphdr*)&buf[ETH_HLEN];
		fprintf(stderr,"ftx:%d,len:%d################"
			"smac=%02x:%02x:%02x:%02x:%02x:%02x,"
			"dmac=%02x:%02x:%02x:%02x:%02x:%02x,"
			"sa:%08x,da:%08x\n",
			*frame,len,
			smac[0],smac[1],smac[2],smac[3],smac[4],smac[5],
			dmac[0],dmac[1],dmac[2],dmac[3],dmac[4],dmac[5],
			iph->saddr,iph->daddr);
		hdr->tp_len = len;
		hdr->tp_snaplen = len;
		tx_user_ready(hdr);
		flushneed = 1;
		//next frame
		*frame = ((*frame) + 1) % ring->req.tp_frame_nr;
	}
}

void walkrxring(int sock, int *block, ring3_t *ring)
{
	while (1)
	{
		struct tpacket_block_desc *bd = NULL;
		struct tpacket3_hdr *hdr = NULL;
		uint8_t *data = NULL;

		bd = (struct tpacket_block_desc*)(ring->rx_buf+ (*block)*BLOCK_SZ);
		if (rx_kernel_ready(&bd->hdr.bh1))
		{
			hdr = (struct tpacket3_hdr*)((uint8_t*)bd+bd->hdr.bh1.offset_to_first_pkt);
			for (uint32_t p=0;p<bd->hdr.bh1.num_pkts;p++)
			{
				data = (uint8_t*)hdr+hdr->tp_mac;
				if (hdr->tp_snaplen < FRAME_SZ)//only packet < 
				{
					struct ethhdr *ethh = (struct ethhdr*)data;
					uint8_t *smac = (uint8_t*)ethh->h_source;
					uint8_t *dmac = (uint8_t*)ethh->h_dest;
					struct iphdr *iph = (struct iphdr*)&data[ETH_HLEN];
					struct udphdr *udph = (struct udphdr*)&data[ETH_HLEN+IP_HLEN];
					fprintf(stderr,"p:%d,len:%d,nump:%d,blk:%d###"
						"smac=%02x:%02x:%02x:%02x:%02x:%02x,"
						"dmac=%02x:%02x:%02x:%02x:%02x:%02x,"
						"sa:%08x,da:%08x,sp:%u,dp:%u\n",
						p,hdr->tp_snaplen,bd->hdr.bh1.num_pkts,*block,
						smac[0],smac[1],smac[2],smac[3],smac[4],smac[5],
						dmac[0],dmac[1],dmac[2],dmac[3],dmac[4],dmac[5],
						iph->saddr,iph->daddr,
						ntohs(udph->source),ntohs(udph->dest));
				}
				hdr = (struct tpacket3_hdr*)((uint8_t*)hdr+hdr->tp_next_offset);
			}
			rx_user_ready(&bd->hdr.bh1);
			//next block
			*block = ((*block) + 1) % ring->req.tp_block_nr;
		} else {
			return;//
		}
	}
}

int pfsocket(int protocol,
			int version,
			bool trans,
			struct ifreq *req,
			struct sockaddr_ll *addr,
			char *devname,
			int rsize,
			int ssize)
{
	int sock, discardoff = 1;
	if (trans)
		sock = socket(AF_PACKET, SOCK_RAW, 0);//Only TX
	else
		sock = socket(AF_PACKET, SOCK_RAW, htons(protocol));
	if (sock < 0)
		return -1;
	std::strncpy(req->ifr_ifrn.ifrn_name, devname, IFNAMSIZ);
	if (ioctl(sock, SIOGIFINDEX, req) < 0)
		return -2;
	addr->sll_family = AF_PACKET;
	addr->sll_ifindex = req->ifr_ifru.ifru_ivalue;
	if (trans)
		addr->sll_protocol = 0;//tx only
	else
		addr->sll_protocol = htons(protocol);
	addr->sll_pkttype 	= 0;
	addr->sll_halen		= 0;
	addr->sll_hatype	= 0;
	if (ioctl(sock, SIOCGIFHWADDR, req) < 0)
		return -3;
	if (setsockopt(sock,SOL_SOCKET, SO_RCVBUFFORCE,&rsize,sizeof(rsize)) < 0)
		return -4;
	if (setsockopt(sock,SOL_SOCKET, SO_SNDBUFFORCE,&ssize,sizeof(ssize)) < 0)
		return -5;
	if (setsockopt(sock, SOL_PACKET, PACKET_VERSION, &version, sizeof(version)) < 0)
		return -6;
	if (setsockopt(sock, SOL_PACKET, PACKET_LOSS, &discardoff, sizeof(discardoff)) < 0)
		return -7;
	return sock;
}

void *slayout(void *ring, bool v3, size_t mmsize)
{
	if (v3)
	{
		struct ring3_t *r = (struct ring3_t*)ring;
		std::memset(&r->req,0,sizeof(r->req));
		r->req.tp_block_nr = mmsize/BLOCK_SZ;
		r->req.tp_block_size = BLOCK_SZ;
		r->req.tp_frame_size = FRAME_SZ;
		r->req.tp_frame_nr = (BLOCK_SZ/FRAME_SZ)*r->req.tp_block_nr;
		r->req.tp_retire_blk_tov = 1;//1ms scanning interval
		// r->req.tp_feature_req_word = TP_FT_REQ_FILL_RXHASH;
		r->req.tp_feature_req_word = 0;
		ring = (void*)r;
	} else {
		struct ring_t *r = (struct ring_t *)ring;
		std::memset(&r->req,0,sizeof(r->req));
		r->req.tp_block_nr = mmsize/BLOCK_SZ;
		r->req.tp_block_size = BLOCK_SZ;
		r->req.tp_frame_size = FRAME_SZ;
		r->req.tp_frame_nr = (BLOCK_SZ/FRAME_SZ)*r->req.tp_block_nr;
		ring = (void*)r;
	}
	return ring;
}

void *setuprxring(int sock, struct ring3_t *ring, size_t mmsize)
{
	if (slayout((void*)ring,true,mmsize) == NULL)
		return NULL;
	if (setsockopt(sock, SOL_PACKET,PACKET_RX_RING,(void*)&ring->req,sizeof(ring->req)) < 0)
		return NULL;

	ring->rx_buf = (uint8_t*)mmap(NULL,mmsize,PROT_READ|PROT_WRITE,
								MAP_SHARED|MAP_LOCKED,sock,0);
	if (ring->rx_buf == MAP_FAILED)
		return NULL;
	return (void*)ring;
}

void *setuptxring(int sock, struct ring_t *ring, size_t mmsize)
{
	if (slayout((void*)ring,false,mmsize)==NULL)
		return NULL;
	if (setsockopt(sock, SOL_PACKET, PACKET_TX_RING,(void*)&ring->req,sizeof(ring->req)) < 0)
		return NULL;
	ring->tx_buf = (uint8_t*)mmap(NULL,mmsize,PROT_READ|PROT_WRITE,
								MAP_SHARED|MAP_LOCKED,
								sock,
								0);
	if (ring->tx_buf == MAP_FAILED)
		return NULL;
	return (void*)ring;
}

int main(int argc, char **argv)
{

	if (argc != 2)
	{
		fprintf(stderr, "Usage: %s <dev_name>\n", argv[0]);
		exit(EXIT_SUCCESS);
	}

	struct sockaddr_ll ifa;
	struct ifreq ifr;
	char *device = new char[IFNAMSIZ];
	ring3_t rxring;

	std::memset(&ifa,0,sizeof(ifa));
	std::memset(&ifr,0,sizeof(ifr));
	std::memset(&txring,0,sizeof(txring));
	std::memset(&rxring,0,sizeof(rxring));
	std::memset(device,0,IFNAMSIZ);

	std::strcpy(device, argv[1]);

	sockrx = pfsocket(ETH_P_ALL,TPACKET_V3,false,&ifr,&ifa,device,rbuf,sbuf);

	if (sockrx < 0)
		return sockrx;
	
	fprintf(stderr, "Socket rx(%d) created\n",sockrx);
	
	if (setuprxring(sockrx,&rxring,rbuf) == NULL)
		return -8;

	fprintf(stderr, "Ring rx setup done.\n");
	
	if (bind(sockrx,(struct sockaddr*)&ifa,sizeof(ifa)) < 0)
		return -9;
	
	fprintf(stderr, "Socket rx(%d) bound to %s\n", sockrx, device);
	
	socktx = pfsocket(ETH_P_ALL,TPACKET_V2,true,&ifr,&ifa,device,rbuf,sbuf);

	if (socktx < 0)
		return socktx;
	
	fprintf(stderr, "Socket tx(%d) created\n", socktx);

	if (setuptxring(socktx,&txring,sbuf) == NULL)
		return -10;

	fprintf(stderr, "Ring tx setup done.\n");

	if (bind(socktx,(struct sockaddr*)&ifa,sizeof(ifa)) < 0)
		return -11;

	fprintf(stderr, "Socket tx(%d) bound to %s\n", socktx, device);
	
	uint32_t nfds = 1;
	int ret = 0, block = 0;
	struct pollfd fds[nfds];

	fds[0].fd = sockrx;
	fds[0].events = POLLIN|POLLRDNORM|POLLERR;
	fds[0].revents = 0;

	sigset_t newmask, zeromask;
	struct timespec tv;

	std::memset(&tv,0,sizeof(tv));
	sigemptyset(&zeromask);
	sigemptyset(&newmask);
	sigaddset(&newmask,SIGINT);

	signal(SIGHUP, signal_handler);

	while (1)
	{
		tv.tv_nsec = 1000000;//1ms
		ret = ppoll(fds,nfds,&tv,&zeromask);

		if (ret < 0 && errno == EINTR)
			continue;
		if (ret < 0)
		{
			fprintf(stderr, "ppoll() error:%s\n", strerror(errno));
			exit(EXIT_FAILURE);
		}

		//read rxring every 1ms
		walkrxring(sockrx,&block,&rxring);
		//try to flush every 1ms
		flushtx(socktx);
	}
	return 0;
}



--------------040008000800060401050102--
