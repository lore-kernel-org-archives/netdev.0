From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 11:00:29 +0100
Message-ID: <1293789629.2973.26.camel@edumazet-laptop>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 10:29 +0100, stefani@seibold.n=
et a
=C3=A9crit :
> From: Stefani Seibold <stefani@seibold.net>
>=20
> UDPCP is a communication protocol specified by the Open Base Station
> Architecture Initiative Special Interest Group (OBSAI SIG). The
> protocol is based on UDP and is designed to meet the needs of "Mobile
> Communcation Base Station" internal communications. It is widely used=
 by
> the major networks infrastructure supplier.
>=20
> The UDPCP communication service supports the following features:
>=20
> -Connectionless communication for serial mode data transfer
> -Acknowledged and unacknowledged transfer modes
> -Retransmissions Algorithm
> -Checksum Algorithm using Adler32
> -Fragmentation of long messages (disassembly/reassembly) to match to =
the MTU
>  during transport:
> -Broadcasting and multicasting messages to multiple peers in unacknow=
ledged
>  transfer mode
>=20
> UDPCP supports application level messages up to 64 KBytes (limited by=
 16-bit
> packet data length field). Messages that are longer than the MTU will=
 be
> fragmented to the MTU.
>=20
> UDPCP provides a reliable transport service that will perform message
> retransmissions in case transport failures occur.
>=20
> The code is also a nice example how to implement a UDP based protocol=
 as
> a kernel socket modules.
>=20
> Due the nature of UDPCP which has no sliding windows support, the lat=
ency has a
> huge impact. The perfomance increase by implementing as a kernel modu=
le is
> about the factor 10, because there are no context switches and data p=
ackets or
> ACKs will be handled in the interrupt service.
>=20
> There are no side effects to the network subsystems so i ask for merg=
e it
> into linux-next. Hope you like it.
>=20
> Wish a happy new year. Keep on hacking.
>=20
> - Stefani
>=20
> Signed-off-by: Stefani Seibold <stefani@seibold.net>
> ---
>  include/linux/socket.h |    5 +-
>  include/net/udpcp.h    |   47 +
>  net/Kconfig            |    1 +
>  net/Makefile           |    1 +
>  net/ipv4/ip_output.c   |    2 +
>  net/ipv4/ip_sockglue.c |    2 +
>  net/ipv4/udp.c         |    2 +-
>  net/udpcp/Kconfig      |   34 +
>  net/udpcp/Makefile     |    5 +
>  net/udpcp/udpcp.c      | 2883 ++++++++++++++++++++++++++++++++++++++=
++++++++++
>  10 files changed, 2980 insertions(+), 2 deletions(-)
>  create mode 100644 include/net/udpcp.h
>  create mode 100644 net/udpcp/Kconfig
>  create mode 100644 net/udpcp/Makefile
>  create mode 100644 net/udpcp/udpcp.c
>=20
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 86b652f..624c5ed 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -193,7 +193,8 @@ struct ucred {
>  #define AF_PHONET	35	/* Phonet sockets		*/
>  #define AF_IEEE802154	36	/* IEEE802154 sockets		*/
>  #define AF_CAIF		37	/* CAIF sockets			*/
> -#define AF_MAX		38	/* For now.. */
> +#define	AF_UDPCP	38	/* UDPCP sockets		*/
> +#define AF_MAX		39	/* For now.. */
> =20
>  /* Protocol families, same as address families. */
>  #define PF_UNSPEC	AF_UNSPEC
> @@ -234,6 +235,7 @@ struct ucred {
>  #define PF_PHONET	AF_PHONET
>  #define PF_IEEE802154	AF_IEEE802154
>  #define PF_CAIF		AF_CAIF
> +#define	PF_UDPCP	AF_UDPCP
>  #define PF_MAX		AF_MAX
> =20
>  /* Maximum queue length specifiable by listen.  */
> @@ -307,6 +309,7 @@ struct ucred {
>  #define SOL_RDS		276
>  #define SOL_IUCV	277
>  #define SOL_CAIF	278
> +#define SOL_UDPCP	279
> =20
>  /* IPX options */
>  #define IPX_TYPE	1
> diff --git a/include/net/udpcp.h b/include/net/udpcp.h
> new file mode 100644
> index 0000000..ba199b9
> --- /dev/null
> +++ b/include/net/udpcp.h
> @@ -0,0 +1,47 @@
> +/* Definitions for UDPCP sockets. */
> +
> +#ifndef __LINUX_IF_UDPCP
> +#define __LINUX_IF_UDPCP
> +
> +#include "linux/ioctl.h"
> +
> +#define UDPCP_MAX_MSGSIZE	65487
> +
> +#define	UDPCP_MAX_WAIT_SEC	60
> +
> +#define UDPCP_OPT_TRANSFER_MODE		0
> +#define UDPCP_OPT_CHECKSUM_MODE		1
> +#define UDPCP_OPT_TX_TIMEOUT		2
> +#define UDPCP_OPT_RX_TIMEOUT		3
> +#define UDPCP_OPT_MAXTRY		4
> +#define	UDPCP_OPT_OUTSTANDING_ACKS	5
> +
> +#define	UDPCP_NOACK		0
> +#define	UDPCP_ACK		1
> +#define	UDPCP_SINGLE_ACK	2
> +#define	UDPCP_NOCHECKSUM	3
> +#define	UDPCP_CHECKSUM		4
> +
> +#define UDPCP_IOC_MAGIC  251
> +
> +#define UDPCP_IOCTL_GET_STATISTICS \
> +	_IOR(UDPCP_IOC_MAGIC, 0x01, struct udpcp_statistics *)
> +#define UDPCP_IOCTL_RESET_STATISTICS \
> +	_IO(UDPCP_IOC_MAGIC, 0x02)
> +#define UDPCP_IOCTL_SYNC \
> +	_IOR(UDPCP_IOC_MAGIC, 0x03, unsigned long)
> +
> +struct udpcp_statistics {
> +	unsigned int txMsgs;		/* Num of transmitted messages */
> +	unsigned int rxMsgs;		/* Num of received messages */
> +	unsigned int txNodes;		/* Num of receiver nodes */
> +	unsigned int rxNodes;		/* Num of transmitter nodes */
> +	unsigned int txTimeout;		/* Num of unsuccessful transmissions */
> +	unsigned int rxTimeout;		/* Num of partial message receptions */
> +	unsigned int txRetries;		/* Num of resends */
> +	unsigned int rxDiscardedFrags;	/* Num of discarded fragments */
> +	unsigned int crcErrors;		/* Num of crc errors detected */
> +};
> +
> +#endif
> +
> diff --git a/net/Kconfig b/net/Kconfig
> index 55fd82e..4a206fc 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -294,6 +294,7 @@ source "net/rfkill/Kconfig"
>  source "net/9p/Kconfig"
>  source "net/caif/Kconfig"
>  source "net/ceph/Kconfig"
> +source "net/udpcp/Kconfig"
> =20
>=20
>  endif   # if NET
> diff --git a/net/Makefile b/net/Makefile
> index 6b7bfd7..a17ae27 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -69,3 +69,4 @@ endif
>  obj-$(CONFIG_WIMAX)		+=3D wimax/
>  obj-$(CONFIG_DNS_RESOLVER)	+=3D dns_resolver/
>  obj-$(CONFIG_CEPH_LIB)		+=3D ceph/
> +obj-$(CONFIG_UDPCP)		+=3D udpcp/
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 439d2a3..55b2d0c 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1085,6 +1085,7 @@ error:
>  	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
>  	return err;
>  }
> +EXPORT_SYMBOL(ip_append_data);
> =20
>  ssize_t	ip_append_page(struct sock *sk, struct page *page,
>  		       int offset, size_t size, int flags)
> @@ -1341,6 +1342,7 @@ error:
>  	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
>  	goto out;
>  }
> +EXPORT_SYMBOL(ip_push_pending_frames);
> =20
>  /*
>   *	Throw away all pending data on the socket.
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 3948c86..310369c 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -226,6 +226,7 @@ int ip_cmsg_send(struct net *net, struct msghdr *=
msg, struct ipcm_cookie *ipc)
>  	}
>  	return 0;
>  }
> +EXPORT_SYMBOL(ip_cmsg_send);
> =20
>=20
>  /* Special input handler for packets caught by router alert option.
> @@ -369,6 +370,7 @@ void ip_local_error(struct sock *sk, int err, __b=
e32 daddr, __be16 port, u32 inf
>  	if (sock_queue_err_skb(sk, skb))
>  		kfree_skb(skb);
>  }
> +EXPORT_SYMBOL(ip_local_error);
> =20
>  /*
>   *	Handle MSG_ERRQUEUE
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 2d3ded4..f9890a2 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1310,7 +1310,7 @@ static int __udp_queue_rcv_skb(struct sock *sk,=
 struct sk_buff *skb)
>  	if (inet_sk(sk)->inet_daddr)
>  		sock_rps_save_rxhash(sk, skb->rxhash);
> =20
> -	rc =3D ip_queue_rcv_skb(sk, skb);
> +	rc =3D sock_queue_rcv_skb(sk, skb);

Ouch... Care to explain why you changed this part ???

You just destroyed commit f84af32cbca70a intent, without any word in
your changelog. Making UDP slower, while others try to speed it must be
explained and advertised.
=20
In general, we prefer a preliminary patch introducing all the changes i=
n
current stack, then another one with the new protocol.
