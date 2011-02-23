From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [ISC-Bugs #22806] [PATCH] lfp: fix AF_INET checksum with csum
 offloading
Date: Wed, 23 Feb 2011 20:46:10 +0200
Message-ID: <20110223184610.GA28750@redhat.com>
References: <20101227171632.GA14920@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, herbert@gondor.hengli.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: dhcp-bugs@isc.org, dhcp-hackers@isc.org
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101227171632.GA14920@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No answer from isc so far.
I think it's a problem that the popular dhclient
has had this bug for so long.
Anyone knows what else can be done?


On Mon, Dec 27, 2010 at 07:16:32PM +0200, Michael S. Tsirkin wrote:
> When an AF_INET socket is used, linux would sometimes
> return a packet without the checksum.  This happens when a packet
> originates on the same machine, which is most common with virtual
> machines but might be possible even without with a software-based dhcp
> server such as dnsmasq.
> This appears to be a performance optimization to avoid calculating
> the checksum and there's no way to disable this. Users are required to
> detect such packets by passing a msg_control parameter to the recvmsg
> call. This was added in linux kernel 2.6.21.
> 
> dhclient from isc.org as of 4.2.0-P2 fails to do this and
> concequently discards such packets, so such setups fail to get an IP.
> This was reported in the past:
> https://lists.isc.org/mailman/htdig/dhcp-hackers/2010-April/001825.html
> 
> The attached patch fixes this by passing msg_control and looking
> at the tp_status field in the result. If the TP_STATUS_CSUMNOTREADY
> bit is set, the packet checksum is missing because the packet
> is local.
> 
> The patch below is currently successfully used at least on Fedora and
> some other Red Hat based distributions. Applying this to the ISC sources
> would help make the problem go away for everyone.
> ---
> 
> Notes:
> - The patch is to be applied with -p1.
> - The patch below applies to dhcp 4.2.0-P2 and 4.1.2 (the last with an offset).
> - Please Cc me on comments directly, I am not subscribed to the dhcp-hackers list.
> 
>  common/bpf.c     |    2 +-
>  common/dlpi.c    |    2 +-
>  common/lpf.c     |   81 ++++++++++++++++++++++++++++++++++++++++++------------
>  common/nit.c     |    2 +-
>  common/packet.c  |    4 +-
>  common/upf.c     |    2 +-
>  includes/dhcpd.h |    2 +-
>  7 files changed, 70 insertions(+), 25 deletions(-)
> 
> diff --git a/common/bpf.c b/common/bpf.c
> index b0ef657..8bd5727 100644
> --- a/common/bpf.c
> +++ b/common/bpf.c
> @@ -485,7 +485,7 @@ ssize_t receive_packet (interface, buf, len, from, hfrom)
>  		offset = decode_udp_ip_header (interface,
>  					       interface -> rbuf,
>  					       interface -> rbuf_offset,
> -  					       from, hdr.bh_caplen, &paylen);
> +  					       from, hdr.bh_caplen, &paylen, 0);
>  
>  		/* If the IP or UDP checksum was bad, skip the packet... */
>  		if (offset < 0) {
> diff --git a/common/dlpi.c b/common/dlpi.c
> index eb64342..d4a8bb9 100644
> --- a/common/dlpi.c
> +++ b/common/dlpi.c
> @@ -694,7 +694,7 @@ ssize_t receive_packet (interface, buf, len, from, hfrom)
>  	length -= offset;
>  #endif
>  	offset = decode_udp_ip_header (interface, dbuf, bufix,
> -				       from, length, &paylen);
> +				       from, length, &paylen, 0);
>  
>  	/*
>  	 * If the IP or UDP checksum was bad, skip the packet...
> diff --git a/common/lpf.c b/common/lpf.c
> index f727b7c..4bdb0f1 100644
> --- a/common/lpf.c
> +++ b/common/lpf.c
> @@ -29,18 +29,33 @@
>  #include "dhcpd.h"
>  #if defined (USE_LPF_SEND) || defined (USE_LPF_RECEIVE)
>  #include <sys/ioctl.h>
> +#include <sys/socket.h>
>  #include <sys/uio.h>
>  #include <errno.h>
>  
>  #include <asm/types.h>
>  #include <linux/filter.h>
>  #include <linux/if_ether.h>
> +#include <linux/if_packet.h>
>  #include <netinet/in_systm.h>
>  #include "includes/netinet/ip.h"
>  #include "includes/netinet/udp.h"
>  #include "includes/netinet/if_ether.h"
>  #include <net/if.h>
>  
> +#ifndef PACKET_AUXDATA
> +#define PACKET_AUXDATA 8
> +
> +struct tpacket_auxdata
> +{
> +	__u32		tp_status;
> +	__u32		tp_len;
> +	__u32		tp_snaplen;
> +	__u16		tp_mac;
> +	__u16		tp_net;
> +};
> +#endif
> +
>  /* Reinitializes the specified interface after an address change.   This
>     is not required for packet-filter APIs. */
>  
> @@ -66,10 +81,14 @@ int if_register_lpf (info)
>  	struct interface_info *info;
>  {
>  	int sock;
> -	struct sockaddr sa;
> +	union {
> +		struct sockaddr_ll ll;
> +		struct sockaddr common;
> +	} sa;
> +	struct ifreq ifr;
>  
>  	/* Make an LPF socket. */
> -	if ((sock = socket(PF_PACKET, SOCK_PACKET,
> +	if ((sock = socket(PF_PACKET, SOCK_RAW,
>  			   htons((short)ETH_P_ALL))) < 0) {
>  		if (errno == ENOPROTOOPT || errno == EPROTONOSUPPORT ||
>  		    errno == ESOCKTNOSUPPORT || errno == EPFNOSUPPORT ||
> @@ -84,11 +103,16 @@ int if_register_lpf (info)
>  		log_fatal ("Open a socket for LPF: %m");
>  	}
>  
> +	memset (&ifr, 0, sizeof ifr);
> +	strncpy (ifr.ifr_name, (const char *)info -> ifp, sizeof ifr.ifr_name);
> +	if (ioctl (sock, SIOCGIFINDEX, &ifr))
> +		log_fatal ("Failed to get interface index: %m");
> +
>  	/* Bind to the interface name */
>  	memset (&sa, 0, sizeof sa);
> -	sa.sa_family = AF_PACKET;
> -	strncpy (sa.sa_data, (const char *)info -> ifp, sizeof sa.sa_data);
> -	if (bind (sock, &sa, sizeof sa)) {
> +	sa.ll.sll_family = AF_PACKET;
> +	sa.ll.sll_ifindex = ifr.ifr_ifindex;
> +	if (bind (sock, &sa.common, sizeof sa)) {
>  		if (errno == ENOPROTOOPT || errno == EPROTONOSUPPORT ||
>  		    errno == ESOCKTNOSUPPORT || errno == EPFNOSUPPORT ||
>  		    errno == EAFNOSUPPORT || errno == EINVAL) {
> @@ -170,9 +194,18 @@ static void lpf_gen_filter_setup (struct interface_info *);
>  void if_register_receive (info)
>  	struct interface_info *info;
>  {
> +	int val;
> +
>  	/* Open a LPF device and hang it on this interface... */
>  	info -> rfdesc = if_register_lpf (info);
>  
> +	val = 1;
> +	if (setsockopt (info -> rfdesc, SOL_PACKET, PACKET_AUXDATA, &val,
> +			sizeof val) < 0) {
> +		if (errno != ENOPROTOOPT)
> +			log_fatal ("Failed to set auxiliary packet data: %m");
> +	}
> +
>  #if defined (HAVE_TR_SUPPORT)
>  	if (info -> hw_address.hbuf [0] == HTYPE_IEEE802)
>  		lpf_tr_filter_setup (info);
> @@ -294,7 +327,6 @@ ssize_t send_packet (interface, packet, raw, len, from, to, hto)
>  	double hh [16];
>  	double ih [1536 / sizeof (double)];
>  	unsigned char *buf = (unsigned char *)ih;
> -	struct sockaddr sa;
>  	int result;
>  	int fudge;
>  
> @@ -315,15 +347,7 @@ ssize_t send_packet (interface, packet, raw, len, from, to, hto)
>  				(unsigned char *)raw, len);
>  	memcpy (buf + ibufp, raw, len);
>  
> -	/* For some reason, SOCK_PACKET sockets can't be connected,
> -	   so we have to do a sentdo every time. */
> -	memset (&sa, 0, sizeof sa);
> -	sa.sa_family = AF_PACKET;
> -	strncpy (sa.sa_data,
> -		 (const char *)interface -> ifp, sizeof sa.sa_data);
> -
> -	result = sendto (interface -> wfdesc,
> -			 buf + fudge, ibufp + len - fudge, 0, &sa, sizeof sa);
> +	result = write (interface -> wfdesc, buf + fudge, ibufp + len - fudge);
>  	if (result < 0)
>  		log_error ("send_packet: %m");
>  	return result;
> @@ -340,14 +364,35 @@ ssize_t receive_packet (interface, buf, len, from, hfrom)
>  {
>  	int length = 0;
>  	int offset = 0;
> +	int nocsum = 0;
>  	unsigned char ibuf [1536];
>  	unsigned bufix = 0;
>  	unsigned paylen;
> -
> -	length = read (interface -> rfdesc, ibuf, sizeof ibuf);
> +	unsigned char cmsgbuf[CMSG_LEN(sizeof(struct tpacket_auxdata))];
> +	struct iovec iov = {
> +		.iov_base = ibuf,
> +		.iov_len = sizeof ibuf,
> +	};
> +	struct msghdr msg = {
> +		.msg_iov = &iov,
> +		.msg_iovlen = 1,
> +		.msg_control = cmsgbuf,
> +		.msg_controllen = sizeof(cmsgbuf),
> +	};
> +	struct cmsghdr *cmsg;
> +
> +	length = recvmsg (interface -> rfdesc, &msg, 0);
>  	if (length <= 0)
>  		return length;
>  
> +	for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
> +		if (cmsg->cmsg_level == SOL_PACKET &&
> +		    cmsg->cmsg_type == PACKET_AUXDATA) {
> +			struct tpacket_auxdata *aux = (void *)CMSG_DATA(cmsg);
> +			nocsum = aux->tp_status & TP_STATUS_CSUMNOTREADY;
> +		}
> +	}
> +
>  	bufix = 0;
>  	/* Decode the physical header... */
>  	offset = decode_hw_header (interface, ibuf, bufix, hfrom);
> @@ -364,7 +409,7 @@ ssize_t receive_packet (interface, buf, len, from, hfrom)
>  
>  	/* Decode the IP and UDP headers... */
>  	offset = decode_udp_ip_header (interface, ibuf, bufix, from,
> -				       (unsigned)length, &paylen);
> +				       (unsigned)length, &paylen, nocsum);
>  
>  	/* If the IP or UDP checksum was bad, skip the packet... */
>  	if (offset < 0)
> diff --git a/common/nit.c b/common/nit.c
> index 3822206..0da9c36 100644
> --- a/common/nit.c
> +++ b/common/nit.c
> @@ -369,7 +369,7 @@ ssize_t receive_packet (interface, buf, len, from, hfrom)
>  
>  	/* Decode the IP and UDP headers... */
>  	offset = decode_udp_ip_header (interface, ibuf, bufix,
> -				       from, length, &paylen);
> +				       from, length, &paylen, 0);
>  
>  	/* If the IP or UDP checksum was bad, skip the packet... */
>  	if (offset < 0)
> diff --git a/common/packet.c b/common/packet.c
> index 42bca69..fd2d975 100644
> --- a/common/packet.c
> +++ b/common/packet.c
> @@ -211,7 +211,7 @@ ssize_t
>  decode_udp_ip_header(struct interface_info *interface,
>  		     unsigned char *buf, unsigned bufix,
>  		     struct sockaddr_in *from, unsigned buflen,
> -		     unsigned *rbuflen)
> +		     unsigned *rbuflen, int nocsum)
>  {
>    unsigned char *data;
>    struct ip ip;
> @@ -322,7 +322,7 @@ decode_udp_ip_header(struct interface_info *interface,
>  					   8, IPPROTO_UDP + ulen))));
>  
>    udp_packets_seen++;
> -  if (usum && usum != sum) {
> +  if (!nocsum && usum && usum != sum) {
>  	  udp_packets_bad_checksum++;
>  	  if (udp_packets_seen > 4 &&
>  	      (udp_packets_seen / udp_packets_bad_checksum) < 2) {
> diff --git a/common/upf.c b/common/upf.c
> index feb82a2..fff3949 100644
> --- a/common/upf.c
> +++ b/common/upf.c
> @@ -320,7 +320,7 @@ ssize_t receive_packet (interface, buf, len, from, hfrom)
>  
>  	/* Decode the IP and UDP headers... */
>  	offset = decode_udp_ip_header (interface, ibuf, bufix,
> -				       from, length, &paylen);
> +				       from, length, &paylen, 0);
>  
>  	/* If the IP or UDP checksum was bad, skip the packet... */
>  	if (offset < 0)
> diff --git a/includes/dhcpd.h b/includes/dhcpd.h
> index cd7d962..0835d98 100644
> --- a/includes/dhcpd.h
> +++ b/includes/dhcpd.h
> @@ -2769,7 +2769,7 @@ ssize_t decode_hw_header PROTO ((struct interface_info *, unsigned char *,
>  				 unsigned, struct hardware *));
>  ssize_t decode_udp_ip_header PROTO ((struct interface_info *, unsigned char *,
>  				     unsigned, struct sockaddr_in *,
> -				     unsigned, unsigned *));
> +				     unsigned, unsigned *, int));
>  
>  /* ethernet.c */
>  void assemble_ethernet_header PROTO ((struct interface_info *, unsigned char *,
> -- 
> 1.7.3.2.91.g446ac
