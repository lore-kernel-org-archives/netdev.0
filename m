From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 07/14] [rndis_host] Split up rndis_host.c
Date: Thu, 24 Jan 2008 16:58:19 -0800
Message-ID: <200801241658.20239.david-b@pacbell.net>
References: <20080120001421.25718.92634.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, bjd@jooz.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:36410 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754418AbYAYBUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 20:20:24 -0500
In-Reply-To: <20080120001421.25718.92634.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> Split up rndis_host.c into rndis_host.h and rndis_base.c. This is done so
> that rndis_wext can reuse common parts with rndis_host.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

> ---
> 
>  drivers/net/usb/rndis_host.c |  223 --------------------------------------
>  drivers/net/usb/rndis_host.h |  248 ++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 249 insertions(+), 222 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 12daf9c..29d7e3b 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -31,6 +31,7 @@
>  #include <linux/usb/cdc.h>
>  
>  #include "usbnet.h"
> +#include "rndis_host.h"
>  
>  
>  /*
> @@ -56,228 +57,6 @@
>   */
>  
>  /*
> - * CONTROL uses CDC "encapsulated commands" with funky notifications.
> - *  - control-out:  SEND_ENCAPSULATED
> - *  - interrupt-in:  RESPONSE_AVAILABLE
> - *  - control-in:  GET_ENCAPSULATED
> - *
> - * We'll try to ignore the RESPONSE_AVAILABLE notifications.
> - *
> - * REVISIT some RNDIS implementations seem to have curious issues still
> - * to be resolved.
> - */
> -struct rndis_msg_hdr {
> -	__le32	msg_type;			/* RNDIS_MSG_* */
> -	__le32	msg_len;
> -	// followed by data that varies between messages
> -	__le32	request_id;
> -	__le32	status;
> -	// ... and more
> -} __attribute__ ((packed));
> -
> -/* MS-Windows uses this strange size, but RNDIS spec says 1024 minimum */
> -#define	CONTROL_BUFFER_SIZE		1025
> -
> -/* RNDIS defines an (absurdly huge) 10 second control timeout,
> - * but ActiveSync seems to use a more usual 5 second timeout
> - * (which matches the USB 2.0 spec).
> - */
> -#define	RNDIS_CONTROL_TIMEOUT_MS	(5 * 1000)
> -
> -
> -#define ccpu2 __constant_cpu_to_le32
> -
> -#define RNDIS_MSG_COMPLETION	ccpu2(0x80000000)
> -
> -/* codes for "msg_type" field of rndis messages;
> - * only the data channel uses packet messages (maybe batched);
> - * everything else goes on the control channel.
> - */
> -#define RNDIS_MSG_PACKET	ccpu2(0x00000001)	/* 1-N packets */
> -#define RNDIS_MSG_INIT		ccpu2(0x00000002)
> -#define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_HALT		ccpu2(0x00000003)
> -#define RNDIS_MSG_QUERY		ccpu2(0x00000004)
> -#define RNDIS_MSG_QUERY_C	(RNDIS_MSG_QUERY|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_SET		ccpu2(0x00000005)
> -#define RNDIS_MSG_SET_C		(RNDIS_MSG_SET|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_RESET		ccpu2(0x00000006)
> -#define RNDIS_MSG_RESET_C	(RNDIS_MSG_RESET|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_INDICATE	ccpu2(0x00000007)
> -#define RNDIS_MSG_KEEPALIVE	ccpu2(0x00000008)
> -#define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
> -
> -/* codes for "status" field of completion messages */
> -#define	RNDIS_STATUS_SUCCESS		ccpu2(0x00000000)
> -#define	RNDIS_STATUS_FAILURE		ccpu2(0xc0000001)
> -#define	RNDIS_STATUS_INVALID_DATA	ccpu2(0xc0010015)
> -#define	RNDIS_STATUS_NOT_SUPPORTED	ccpu2(0xc00000bb)
> -#define	RNDIS_STATUS_MEDIA_CONNECT	ccpu2(0x4001000b)
> -#define	RNDIS_STATUS_MEDIA_DISCONNECT	ccpu2(0x4001000c)
> -
> -
> -struct rndis_data_hdr {
> -	__le32	msg_type;		/* RNDIS_MSG_PACKET */
> -	__le32	msg_len;		// rndis_data_hdr + data_len + pad
> -	__le32	data_offset;		// 36 -- right after header
> -	__le32	data_len;		// ... real packet size
> -
> -	__le32	oob_data_offset;	// zero
> -	__le32	oob_data_len;		// zero
> -	__le32	num_oob;		// zero
> -	__le32	packet_data_offset;	// zero
> -
> -	__le32	packet_data_len;	// zero
> -	__le32	vc_handle;		// zero
> -	__le32	reserved;		// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_init {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_INIT */
> -	__le32	msg_len;			// 24
> -	__le32	request_id;
> -	__le32	major_version;			// of rndis (1.0)
> -	__le32	minor_version;
> -	__le32	max_transfer_size;
> -} __attribute__ ((packed));
> -
> -struct rndis_init_c {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_INIT_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -	__le32	major_version;			// of rndis (1.0)
> -	__le32	minor_version;
> -	__le32	device_flags;
> -	__le32	medium;				// zero == 802.3
> -	__le32	max_packets_per_message;
> -	__le32	max_transfer_size;
> -	__le32	packet_alignment;		// max 7; (1<<n) bytes
> -	__le32	af_list_offset;			// zero
> -	__le32	af_list_size;			// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_halt {		/* OUT (no reply) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_HALT */
> -	__le32	msg_len;
> -	__le32	request_id;
> -} __attribute__ ((packed));
> -
> -struct rndis_query {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_QUERY */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	oid;
> -	__le32	len;
> -	__le32	offset;
> -/*?*/	__le32	handle;				// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_query_c {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_QUERY_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -	__le32	len;
> -	__le32	offset;
> -} __attribute__ ((packed));
> -
> -struct rndis_set {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_SET */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	oid;
> -	__le32	len;
> -	__le32	offset;
> -/*?*/	__le32	handle;				// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_set_c {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_SET_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -} __attribute__ ((packed));
> -
> -struct rndis_reset {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_RESET */
> -	__le32	msg_len;
> -	__le32	reserved;
> -} __attribute__ ((packed));
> -
> -struct rndis_reset_c {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_RESET_C */
> -	__le32	msg_len;
> -	__le32	status;
> -	__le32	addressing_lost;
> -} __attribute__ ((packed));
> -
> -struct rndis_indicate {		/* IN (unrequested) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_INDICATE */
> -	__le32	msg_len;
> -	__le32	status;
> -	__le32	length;
> -	__le32	offset;
> -/**/	__le32	diag_status;
> -	__le32	error_offset;
> -/**/	__le32	message;
> -} __attribute__ ((packed));
> -
> -struct rndis_keepalive {	/* OUT (optionally IN) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE */
> -	__le32	msg_len;
> -	__le32	request_id;
> -} __attribute__ ((packed));
> -
> -struct rndis_keepalive_c {	/* IN (optionally OUT) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -} __attribute__ ((packed));
> -
> -/* NOTE:  about 30 OIDs are "mandatory" for peripherals to support ... and
> - * there are gobs more that may optionally be supported.  We'll avoid as much
> - * of that mess as possible.
> - */
> -#define OID_802_3_PERMANENT_ADDRESS	ccpu2(0x01010101)
> -#define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
> -#define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
> -
> -/* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
> -#define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
> -#define RNDIS_PACKET_TYPE_MULTICAST		ccpu2(0x00000002)
> -#define RNDIS_PACKET_TYPE_ALL_MULTICAST		ccpu2(0x00000004)
> -#define RNDIS_PACKET_TYPE_BROADCAST		ccpu2(0x00000008)
> -#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	ccpu2(0x00000010)
> -#define RNDIS_PACKET_TYPE_PROMISCUOUS		ccpu2(0x00000020)
> -#define RNDIS_PACKET_TYPE_SMT			ccpu2(0x00000040)
> -#define RNDIS_PACKET_TYPE_ALL_LOCAL		ccpu2(0x00000080)
> -#define RNDIS_PACKET_TYPE_GROUP			ccpu2(0x00001000)
> -#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	ccpu2(0x00002000)
> -#define RNDIS_PACKET_TYPE_FUNCTIONAL		ccpu2(0x00004000)
> -#define RNDIS_PACKET_TYPE_MAC_FRAME		ccpu2(0x00008000)
> -
> -/* default filter used with RNDIS devices */
> -#define RNDIS_DEFAULT_FILTER ( \
> -	RNDIS_PACKET_TYPE_DIRECTED | \
> -	RNDIS_PACKET_TYPE_BROADCAST | \
> -	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
> -	RNDIS_PACKET_TYPE_PROMISCUOUS)
> -
> -/*
>   * RNDIS notifications from device: command completion; "reverse"
>   * keepalives; etc
>   */
> diff --git a/drivers/net/usb/rndis_host.h b/drivers/net/usb/rndis_host.h
> new file mode 100644
> index 0000000..1386a17
> --- /dev/null
> +++ b/drivers/net/usb/rndis_host.h
> @@ -0,0 +1,248 @@
> +/*
> + * Host Side support for RNDIS Networking Links
> + * Copyright (C) 2005 by David Brownell
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
> +
> +#ifndef	__RNDIS_HOST_H
> +#define	__RNDIS_HOST_H
> +
> +
> +/*
> + * CONTROL uses CDC "encapsulated commands" with funky notifications.
> + *  - control-out:  SEND_ENCAPSULATED
> + *  - interrupt-in:  RESPONSE_AVAILABLE
> + *  - control-in:  GET_ENCAPSULATED
> + *
> + * We'll try to ignore the RESPONSE_AVAILABLE notifications.
> + *
> + * REVISIT some RNDIS implementations seem to have curious issues still
> + * to be resolved.
> + */
> +struct rndis_msg_hdr {
> +	__le32	msg_type;			/* RNDIS_MSG_* */
> +	__le32	msg_len;
> +	// followed by data that varies between messages
> +	__le32	request_id;
> +	__le32	status;
> +	// ... and more
> +} __attribute__ ((packed));
> +
> +/* MS-Windows uses this strange size, but RNDIS spec says 1024 minimum */
> +#define	CONTROL_BUFFER_SIZE		1025
> +
> +/* RNDIS defines an (absurdly huge) 10 second control timeout,
> + * but ActiveSync seems to use a more usual 5 second timeout
> + * (which matches the USB 2.0 spec).
> + */
> +#define	RNDIS_CONTROL_TIMEOUT_MS	(5 * 1000)
> +
> +
> +#define ccpu2 __constant_cpu_to_le32
> +
> +#define RNDIS_MSG_COMPLETION	ccpu2(0x80000000)
> +
> +/* codes for "msg_type" field of rndis messages;
> + * only the data channel uses packet messages (maybe batched);
> + * everything else goes on the control channel.
> + */
> +#define RNDIS_MSG_PACKET	ccpu2(0x00000001)	/* 1-N packets */
> +#define RNDIS_MSG_INIT		ccpu2(0x00000002)
> +#define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_HALT		ccpu2(0x00000003)
> +#define RNDIS_MSG_QUERY		ccpu2(0x00000004)
> +#define RNDIS_MSG_QUERY_C	(RNDIS_MSG_QUERY|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_SET		ccpu2(0x00000005)
> +#define RNDIS_MSG_SET_C		(RNDIS_MSG_SET|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_RESET		ccpu2(0x00000006)
> +#define RNDIS_MSG_RESET_C	(RNDIS_MSG_RESET|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_INDICATE	ccpu2(0x00000007)
> +#define RNDIS_MSG_KEEPALIVE	ccpu2(0x00000008)
> +#define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
> +
> +/* codes for "status" field of completion messages */
> +#define	RNDIS_STATUS_SUCCESS		ccpu2(0x00000000)
> +#define	RNDIS_STATUS_FAILURE		ccpu2(0xc0000001)
> +#define	RNDIS_STATUS_INVALID_DATA	ccpu2(0xc0010015)
> +#define	RNDIS_STATUS_NOT_SUPPORTED	ccpu2(0xc00000bb)
> +#define	RNDIS_STATUS_MEDIA_CONNECT	ccpu2(0x4001000b)
> +#define	RNDIS_STATUS_MEDIA_DISCONNECT	ccpu2(0x4001000c)
> +
> +
> +struct rndis_data_hdr {
> +	__le32	msg_type;		/* RNDIS_MSG_PACKET */
> +	__le32	msg_len;		// rndis_data_hdr + data_len + pad
> +	__le32	data_offset;		// 36 -- right after header
> +	__le32	data_len;		// ... real packet size
> +
> +	__le32	oob_data_offset;	// zero
> +	__le32	oob_data_len;		// zero
> +	__le32	num_oob;		// zero
> +	__le32	packet_data_offset;	// zero
> +
> +	__le32	packet_data_len;	// zero
> +	__le32	vc_handle;		// zero
> +	__le32	reserved;		// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_init {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_INIT */
> +	__le32	msg_len;			// 24
> +	__le32	request_id;
> +	__le32	major_version;			// of rndis (1.0)
> +	__le32	minor_version;
> +	__le32	max_transfer_size;
> +} __attribute__ ((packed));
> +
> +struct rndis_init_c {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_INIT_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +	__le32	major_version;			// of rndis (1.0)
> +	__le32	minor_version;
> +	__le32	device_flags;
> +	__le32	medium;				// zero == 802.3
> +	__le32	max_packets_per_message;
> +	__le32	max_transfer_size;
> +	__le32	packet_alignment;		// max 7; (1<<n) bytes
> +	__le32	af_list_offset;			// zero
> +	__le32	af_list_size;			// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_halt {		/* OUT (no reply) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_HALT */
> +	__le32	msg_len;
> +	__le32	request_id;
> +} __attribute__ ((packed));
> +
> +struct rndis_query {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_QUERY */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	oid;
> +	__le32	len;
> +	__le32	offset;
> +/*?*/	__le32	handle;				// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_query_c {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_QUERY_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +	__le32	len;
> +	__le32	offset;
> +} __attribute__ ((packed));
> +
> +struct rndis_set {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_SET */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	oid;
> +	__le32	len;
> +	__le32	offset;
> +/*?*/	__le32	handle;				// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_set_c {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_SET_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +} __attribute__ ((packed));
> +
> +struct rndis_reset {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_RESET */
> +	__le32	msg_len;
> +	__le32	reserved;
> +} __attribute__ ((packed));
> +
> +struct rndis_reset_c {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_RESET_C */
> +	__le32	msg_len;
> +	__le32	status;
> +	__le32	addressing_lost;
> +} __attribute__ ((packed));
> +
> +struct rndis_indicate {		/* IN (unrequested) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_INDICATE */
> +	__le32	msg_len;
> +	__le32	status;
> +	__le32	length;
> +	__le32	offset;
> +/**/	__le32	diag_status;
> +	__le32	error_offset;
> +/**/	__le32	message;
> +} __attribute__ ((packed));
> +
> +struct rndis_keepalive {	/* OUT (optionally IN) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE */
> +	__le32	msg_len;
> +	__le32	request_id;
> +} __attribute__ ((packed));
> +
> +struct rndis_keepalive_c {	/* IN (optionally OUT) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +} __attribute__ ((packed));
> +
> +/* NOTE:  about 30 OIDs are "mandatory" for peripherals to support ... and
> + * there are gobs more that may optionally be supported.  We'll avoid as much
> + * of that mess as possible.
> + */
> +#define OID_802_3_PERMANENT_ADDRESS	ccpu2(0x01010101)
> +#define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
> +#define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
> +
> +/* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
> +#define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
> +#define RNDIS_PACKET_TYPE_MULTICAST		ccpu2(0x00000002)
> +#define RNDIS_PACKET_TYPE_ALL_MULTICAST		ccpu2(0x00000004)
> +#define RNDIS_PACKET_TYPE_BROADCAST		ccpu2(0x00000008)
> +#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	ccpu2(0x00000010)
> +#define RNDIS_PACKET_TYPE_PROMISCUOUS		ccpu2(0x00000020)
> +#define RNDIS_PACKET_TYPE_SMT			ccpu2(0x00000040)
> +#define RNDIS_PACKET_TYPE_ALL_LOCAL		ccpu2(0x00000080)
> +#define RNDIS_PACKET_TYPE_GROUP			ccpu2(0x00001000)
> +#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	ccpu2(0x00002000)
> +#define RNDIS_PACKET_TYPE_FUNCTIONAL		ccpu2(0x00004000)
> +#define RNDIS_PACKET_TYPE_MAC_FRAME		ccpu2(0x00008000)
> +
> +/* default filter used with RNDIS devices */
> +#define RNDIS_DEFAULT_FILTER ( \
> +	RNDIS_PACKET_TYPE_DIRECTED | \
> +	RNDIS_PACKET_TYPE_BROADCAST | \
> +	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
> +	RNDIS_PACKET_TYPE_PROMISCUOUS)
> +
> +#endif	/* __RNDIS_HOST_H */
> +
> 


