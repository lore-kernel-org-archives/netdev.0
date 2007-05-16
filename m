From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [patch 2/7] CAN: Add PF_CAN core module
Date: Wed, 16 May 2007 13:35:45 -0300
Message-ID: <39e6f6c70705160935q66109a3ci414374544d99c78f@mail.gmail.com>
References: <20070516145100.29877.0@janus.isnogud.escape.de>
	 <20070516145121.29877.2@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Thomas Gleixner" <tglx@linutronix.de>,
	"Oliver Hartkopp" <oliver.hartkopp@volkswagen.de>,
	"Urs Thuermann" <urs.thuermann@volkswagen.de>
To: "Urs Thuermann" <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:37455 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761768AbXEPQfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 12:35:47 -0400
Received: by wr-out-0506.google.com with SMTP id 76so279417wra
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 09:35:47 -0700 (PDT)
In-Reply-To: <20070516145121.29877.2@janus.isnogud.escape.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/16/07, Urs Thuermann <urs@isnogud.escape.de> wrote:
> This patch adds the CAN core functionality but no protocols or drivers.
> No protocol implementations are included here.  They come as separate
> patches.  Protocol numbers are already in include/linux/can.h.
>
> Signed-Off-By: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-Off-By: Urs Thuermann <urs.thuermann@volkswagen.de>

<SNIP>

> +
> +/**
> + * struct sockaddr_can - the sockaddr structure for CAN sockets
> + * @can_family:  address family number AF_CAN.
> + * @can_ifindex: CAN network interface index.
> + * @can_addr:    transport protocol specific address, mostly CAN IDs.
> + */
> +struct sockaddr_can {
> +       sa_family_t can_family;
> +       int         can_ifindex;
> +       union {
> +               struct { canid_t rx_id, tx_id; } tp16;
> +               struct { canid_t rx_id, tx_id; } tp20;
> +               struct { canid_t rx_id, tx_id; } mcnet;
> +               struct { canid_t rx_id, tx_id; } isotp;
> +               struct { int     lcu,   type;  } bap;
> +       } can_addr;
> +};

Can can_ifindex be turned into a unsigned short? That way we would
have it nicely packed, avoiding this hole:

[acme@filo examples]$ pahole can
/* <1c2> /home/acme/git/pahole/examples/can.c:5 */
struct sockaddr_can {
	sa_family_t                can_family;    /*     0     2 */

	/* XXX 2 bytes hole, try to pack */

	int                        can_ifindex;   /*  4  4 */
	union {
		struct {
			canid_t    rx_id;         /*  8  4 */
			canid_t    tx_id;         /* 12  4 */
		} tp16;                           /*     8 */
		struct {
			canid_t    rx_id;         /*  8  4 */
			canid_t    tx_id;         /* 12  4 */
		} tp20;                           /*     8 */
		struct {
			canid_t    rx_id;         /*  8  4 */
			canid_t    tx_id;         /* 12  4 */
		} mcnet;                          /*     8 */
		struct {
			canid_t    rx_id;         /*  8  4 */
			canid_t    tx_id;         /* 12  4 */
		} isotp;                          /*     8 */
		struct {
			int        lcu;           /*  8  4 */
			int        type;          /* 12  4 */
		} bap;                            /*     8 */
	} can_addr;                               /*  8  8 */
}; /* size: 16, cachelines: 1 */
   /* sum members: 14, holes: 1, sum holes: 2 */
   /* last cacheline: 16 bytes */
   /* definitions: 1 */

- Arnaldo
