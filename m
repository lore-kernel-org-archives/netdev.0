From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Tue, 2 Oct 2007 11:38:55 -0300
Message-ID: <20071002143855.GG7881@ghostprotocols.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131108.31727.2@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50873 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbXJBOjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:39:06 -0400
Received: by ug-out-1314.google.com with SMTP id z38so2118966ugc
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 07:39:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071002131108.31727.2@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 02, 2007 at 03:10:08PM +0200, Urs Thuermann escreveu:
> This patch adds the CAN core functionality but no protocols or drivers.
> No protocol implementations are included here.  They come as separate
> patches.  Protocol numbers are already in include/linux/can.h.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
> 
> ---
>  include/linux/can.h       |  111 +++++
>  include/linux/can/core.h  |   77 +++
>  include/linux/can/error.h |   93 ++++
>  net/Kconfig               |    1 
>  net/Makefile              |    1 
>  net/can/Kconfig           |   25 +
>  net/can/Makefile          |    6 
>  net/can/af_can.c          |  970 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/can/af_can.h          |  120 +++++
>  net/can/proc.c            |  532 +++++++++++++++++++++++++
>  10 files changed, 1936 insertions(+)
> 
> Index: net-2.6.24/include/linux/can.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ net-2.6.24/include/linux/can.h	2007-10-02 12:10:18.000000000 +0200
> @@ -0,0 +1,111 @@
> +/*
> + * linux/can.h
> + *
> + * Definitions for CAN network layer (socket addr / CAN frame / CAN filter)
> + *
> + * Authors: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> + *          Urs Thuermann   <urs.thuermann@volkswagen.de>
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Send feedback to <socketcan-users@lists.berlios.de>
> + *
> + */
> +
> +#ifndef CAN_H
> +#define CAN_H
> +
> +#include <linux/types.h>
> +#include <linux/socket.h>
> +
> +/* controller area network (CAN) kernel definitions */
> +
> +/* special address description flags for the CAN_ID */
> +#define CAN_EFF_FLAG 0x80000000U /* EFF/SFF is set in the MSB */
> +#define CAN_RTR_FLAG 0x40000000U /* remote transmission request */
> +#define CAN_ERR_FLAG 0x20000000U /* error frame */
> +
> +/* valid bits in CAN ID for frame formats */
> +#define CAN_SFF_MASK 0x000007FFU /* standard frame format (SFF) */
> +#define CAN_EFF_MASK 0x1FFFFFFFU /* extended frame format (EFF) */
> +#define CAN_ERR_MASK 0x1FFFFFFFU /* omit EFF, RTR, ERR flags */
> +
> +/*
> + * Controller Area Network Identifier structure
> + *
> + * bit 0-28	: CAN identifier (11/29 bit)
> + * bit 29	: error frame flag (0 = data frame, 1 = error frame)
> + * bit 30	: remote transmission request flag (1 = rtr frame)
> + * bit 31	: frame format flag (0 = standard 11 bit, 1 = extended 29 bit)
> + */
> +typedef __u32 canid_t;
> +
> +/*
> + * Controller Area Network Error Frame Mask structure
> + *
> + * bit 0-28	: error class mask (see include/linux/can/error.h)
> + * bit 29-31	: set to zero
> + */
> +typedef __u32 can_err_mask_t;
> +
> +/**
> + * struct can_frame - basic CAN frame structure
> + * @can_id:  the CAN ID of the frame and CAN_*_FLAG flags, see above.
> + * @can_dlc: the data length field of the CAN frame
> + * @data:    the CAN frame payload.
> + */
> +struct can_frame {
> +	canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
> +	__u8    can_dlc; /* data length code: 0 .. 8 */
> +	__u8    data[8] __attribute__((aligned(8)));
> +};
> +
> +/* particular protocols of the protocol family PF_CAN */
> +#define CAN_RAW		1 /* RAW sockets */
> +#define CAN_BCM		2 /* Broadcast Manager */
> +#define CAN_TP16	3 /* VAG Transport Protocol v1.6 */
> +#define CAN_TP20	4 /* VAG Transport Protocol v2.0 */
> +#define CAN_MCNET	5 /* Bosch MCNet */
> +#define CAN_ISOTP	6 /* ISO 15765-2 Transport Protocol */
> +#define CAN_NPROTO	7
> +
> +#define SOL_CAN_BASE 100
> +
> +/**
> + * struct sockaddr_can - the sockaddr structure for CAN sockets
> + * @can_family:  address family number AF_CAN.
> + * @can_ifindex: CAN network interface index.
> + * @can_addr:    transport protocol specific address, mostly CAN IDs.
> + */
> +struct sockaddr_can {
> +	sa_family_t can_family;
> +	int         can_ifindex;
> +	union {
> +		struct { canid_t rx_id, tx_id; } tp16;
> +		struct { canid_t rx_id, tx_id; } tp20;
> +		struct { canid_t rx_id, tx_id; } mcnet;
> +		struct { canid_t rx_id, tx_id; } isotp;
> +	} can_addr;

Again being curious, what is the value of this union of all its members
have the same definition? Backward source code compatibility?

> +};
> +
> +/**
> + * struct can_filter - CAN ID based filter in can_register().
> + * @can_id:   relevant bits of CAN ID which are not masked out.
> + * @can_mask: CAN mask (see description)
> + *
> + * Description:
> + * A filter matches, when
> + *
> + *          <received_can_id> & mask == can_id & mask
> + *
> + * The filter can be inverted (CAN_INV_FILTER bit set in can_id) or it can
> + * filter for error frames (CAN_ERR_FLAG bit set in mask).
> + */
> +struct can_filter {
> +	canid_t can_id;
> +	canid_t can_mask;
> +};
> +
> +#define CAN_INV_FILTER 0x20000000U /* to be set in can_filter.can_id */
> +
> +#endif /* CAN_H */
> Index: net-2.6.24/include/linux/can/core.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ net-2.6.24/include/linux/can/core.h	2007-10-02 12:10:18.000000000 +0200
> @@ -0,0 +1,77 @@
> +/*
> + * linux/can/core.h
> + *
> + * Protoypes and definitions for CAN protocol modules using the PF_CAN core
> + *
> + * Authors: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> + *          Urs Thuermann   <urs.thuermann@volkswagen.de>
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Send feedback to <socketcan-users@lists.berlios.de>
> + *
> + */
> +
> +#ifndef CAN_CORE_H
> +#define CAN_CORE_H
> +
> +#include <linux/can.h>
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>
> +
> +#define CAN_VERSION "20071001"
> +
> +/* increment this number each time you change some user-space interface */
> +#define CAN_ABI_VERSION "8"
> +
> +#define CAN_VERSION_STRING "rev " CAN_VERSION " abi " CAN_ABI_VERSION
> +
> +#define DNAME(dev) ((dev) ? (dev)->name : "any")
> +
> +/**
> + * struct can_proto - CAN protocol structure
> + * @type:       type argument in socket() syscall, e.g. SOCK_DGRAM.
> + * @protocol:   protocol number in socket() syscall.
> + * @capability: capability needed to open the socket, or -1 for no restriction.
> + * @ops:        pointer to struct proto_ops for sock->ops.
> + * @prot:       pointer to struct proto structure.
> + */
> +struct can_proto {
> +	int              type;
> +	int              protocol;
> +	int              capability;
> +	struct proto_ops *ops;
> +	struct proto     *prot;
> +};
> +
> +/* function prototypes for the CAN networklayer core (af_can.c) */
> +
> +extern int  can_proto_register(struct can_proto *cp);
> +extern void can_proto_unregister(struct can_proto *cp);

We have proto registering infrastructure for bluetooth, inet and now
CAN, have you looked at:

struct inet_protosw;
proto_{register,unregister}, etc?

You have been thru many iterations already, sigh, I should have looked
at this before :-\


- Arnaldo
