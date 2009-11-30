From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC PATCH v3  5/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 08:41:55 -0800
Message-ID: <4B13F5D3.6090009@oracle.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53377 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbZK3QmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:42:21 -0500
In-Reply-To: <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Sjur Braendeland <sjur.brandeland@stericsson.com>

what Patrick said:
patch description should be here and each email subject should be diffe=
rent
and describe what that patch does.
Please read Documentation/SubmittingPatches.

(more below)

> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
> ---
>  net/caif/Kconfig            |   51 ++
>  net/caif/Makefile           |   51 ++
>  net/caif/caif_chnlif.c      |  205 ++++++
>  net/caif/caif_config_util.c |  163 +++++
>  net/caif/caif_dev.c         |  520 ++++++++++++++
>  net/caif/caif_socket.c      | 1560 +++++++++++++++++++++++++++++++++=
++++++++++
>  net/caif/chnl_net.c         |  655 ++++++++++++++++++
>  7 files changed, 3205 insertions(+), 0 deletions(-)
>  create mode 100644 net/caif/Kconfig
>  create mode 100644 net/caif/Makefile
>  create mode 100644 net/caif/caif_chnlif.c
>  create mode 100644 net/caif/caif_config_util.c
>  create mode 100644 net/caif/caif_dev.c
>  create mode 100644 net/caif/caif_socket.c
>  create mode 100644 net/caif/chnl_net.c
>=20
> diff --git a/net/caif/Kconfig b/net/caif/Kconfig
> new file mode 100644
> index 0000000..9349123
> --- /dev/null
> +++ b/net/caif/Kconfig
> @@ -0,0 +1,51 @@
> +#
> +# CAIF net configurations
> +#
> +
> +#menu "CAIF Support"
> +comment "CAIF Support"
> +
> +menuconfig CAIF
> +	tristate "Enable CAIF support"
> +	default n
> +	---help---

Tell us what CAIF means, probably in the help text.

> +	Say Y here if you need to use a phone modem that uses CAIF as trans=
port.
> +	You will also need to say yes to any CAIF physical devices that you=
r platform
> +	supports.
> +	This can be either built-in or a loadable module; if you select to =
build it as module
> +	then the rest of CAIF also needs to built as modules.
> +	See Documentation/CAIF for a further explanation on how to use and =
configure.
> +
> +if CAIF
> +
> +config CAIF_NETDEV
> +	tristate "CAIF Network device"
> +	default CAIF
> +	---help---
> +	Say Y if you will be using the CAIF based network device.

	                           a (or any) CAIF-based

> +	This can be either built-in or a loadable module.
> +	If you select to build it as a built-in then the main CAIF device m=
ust also be a built-in.
> +	If unsure say Y.
> +
> +config CAIF_SOCK
> +	tristate "CAIF Sockets"
> +	default CAIF
> +	---help---
> +	Say Y if you will be using the CAIF Sockets.

	drop "the" ----------------^^^

> +	This can be either built-in or a loadable module.
> +	If you select to build it as a built-in then the main CAIF device m=
ist also be a built-in.

s/mist/must/

> +	If unsure say Y.
> +
> +config  CAIF_DEBUG
> +	bool "Enable Debug"
> +	default n
> +	--- help ---
> +	Enable the inclusion of debug code in the CAIF stack.
> +	Be aware that doing this will impact performance.
> +	If unsure say N.
> +
> +
> +# Include physical drivers
> +source "drivers/net/caif/Kconfig"
> +endif
> +#endmenu

> diff --git a/net/caif/caif_chnlif.c b/net/caif/caif_chnlif.c
> new file mode 100644
> index 0000000..9c8a656
> --- /dev/null
> +++ b/net/caif/caif_chnlif.c
> @@ -0,0 +1,205 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2009
> + * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#include <linux/skbuff.h>
> +#include <net/caif/caif_kernel.h>
> +#include <net/caif/generic/caif_layer.h>
> +#include <net/caif/caif_config_util.h>
> +#include <net/caif/caif_log.h>
> +#include <net/caif/generic/cfpkt.h>
> +#include <net/caif/generic/cfcnfg.h>
> +#include <net/caif/generic/cfglue.h>
> +#include <net/caif/caif_chr.h>
> +struct caif_kernelif {
> +	struct layer layer;
> +	struct caif_device *dev;
> +	struct cfctrl_link_param param;
> +};
> +
> +
> +/**
> + * func caif_create_skb - Creates a CAIF SKB buffer

Use documented/expected kernel-doc notation, please.  I.e., drop "func"=
=2E

> + * @data:		data to add to buffer
> + * @data_length:	length of data
> + */
> +struct sk_buff *caif_create_skb(unsigned char *data, unsigned int da=
ta_length)
> +{
> +	/* NOTE: Make room for CAIF headers when using SKB inside CAIF. */
> +	struct sk_buff *skb =3D
> +	    alloc_skb(data_length + CAIF_SKB_HEAD_RESERVE +
> +		      CAIF_SKB_TAIL_RESERVE, GFP_ATOMIC);
> +	if (skb =3D=3D NULL)
> +		return NULL;
> +	skb_reserve(skb, CAIF_SKB_HEAD_RESERVE);
> +
> +	memcpy(skb_put(skb, data_length), data, data_length);
> +	return skb;
> +}
> +EXPORT_SYMBOL(caif_create_skb);
> +
=2E..

> +
> +module_init(caif_device_init);
> +module_exit(caif_device_exit);
> +
> +
> +
> +
> +
> +
> +
> +
> +

delete all of those trailing empty lines.

> diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
> new file mode 100644
> index 0000000..492fcfb
> --- /dev/null
> +++ b/net/caif/caif_socket.c
> @@ -0,0 +1,1560 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2009
> + * Author:	Sjur Br=C3=A6ndeland sjur.brandlenad@stericsson.com
> + *              Per Sigmond / Per.Sigmond@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#include <linux/fs.h>
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/sched.h>
> +#include <linux/spinlock.h>
> +#include <linux/mutex.h>
> +#include <linux/list.h>
> +#include <linux/wait.h>
> +#include <linux/poll.h>
> +#include <linux/tcp.h>
> +#include <asm/uaccess.h>
> +#include <asm/atomic.h>
> +
> +/* Caif header files. */
> +#include <linux/caif/caif_socket.h>
> +#include <net/caif/generic/caif_layer.h>
> +#include <linux/caif/caif_config.h>
> +#include <net/caif/caif_log.h>
> +#include <net/caif/caif_chr.h>
> +
> +MODULE_LICENSE("GPL");
> +
> +#define CHNL_SKT_READ_QUEUE_HIGH 2000
> +#define CHNL_SKT_READ_QUEUE_LOW 100
> +
> +#ifdef CAIF_USE_CACHE
> +int caif_max_links =3D 32;
> +#endif
> +
> +int caif_sockbuf_size =3D 40000; /* FIXME: Check this value! */
> +static struct kmem_cache *caif_sk_cachep;
> +static atomic_t caif_nr_socks =3D ATOMIC_INIT(0);
> +
> +#define CONN_STATE_OPEN_BIT           1
> +#define CONN_STATE_PENDING_BIT        2
> +#define CONN_STATE_PEND_DESTROY_BIT   3
> +#define CONN_REMOTE_SHUTDOWN_BIT      4
> +
> +#define TX_FLOW_ON_BIT                1
> +#define RX_FLOW_ON_BIT                2
> +
> +#define STATE_IS_OPEN(cf_sk) test_bit(CONN_STATE_OPEN_BIT,\
> +				    (void *) &(cf_sk)->conn_state)
> +#define STATE_IS_REMOTE_SHUTDOWN(cf_sk) test_bit(CONN_REMOTE_SHUTDOW=
N_BIT,\
> +				    (void *) &(cf_sk)->conn_state)
> +#define STATE_IS_PENDING(cf_sk) test_bit(CONN_STATE_PENDING_BIT,\
> +				       (void *) &(cf_sk)->conn_state)
> +#define STATE_IS_PENDING_DESTROY(cf_sk) test_bit(CONN_STATE_PEND_DES=
TROY_BIT,\
> +				       (void *) &(cf_sk)->conn_state)
> +
> +#define SET_STATE_PENDING_DESTROY(cf_sk) set_bit(CONN_STATE_PEND_DES=
TROY_BIT,\
> +				    (void *) &(cf_sk)->conn_state)
> +#define SET_STATE_OPEN(cf_sk) set_bit(CONN_STATE_OPEN_BIT,\
> +				    (void *) &(cf_sk)->conn_state)
> +#define SET_STATE_CLOSED(cf_sk) clear_bit(CONN_STATE_OPEN_BIT,\
> +					(void *) &(cf_sk)->conn_state)
> +#define SET_PENDING_ON(cf_sk) set_bit(CONN_STATE_PENDING_BIT,\
> +				    (void *) &(cf_sk)->conn_state)
> +#define SET_PENDING_OFF(cf_sk) clear_bit(CONN_STATE_PENDING_BIT,\
> +				       (void *) &(cf_sk)->conn_state)
> +#define SET_REMOTE_SHUTDOWN(cf_sk) set_bit(CONN_REMOTE_SHUTDOWN_BIT,=
\
> +				    (void *) &(cf_sk)->conn_state)
> +
> +#define RX_FLOW_IS_ON(cf_sk) test_bit(RX_FLOW_ON_BIT,\
> +				    (void *) &(cf_sk)->flow_state)
> +#define TX_FLOW_IS_ON(cf_sk) test_bit(TX_FLOW_ON_BIT,\
> +				    (void *) &(cf_sk)->flow_state)
> +
> +#define SET_RX_FLOW_OFF(cf_sk) clear_bit(RX_FLOW_ON_BIT,\
> +				       (void *) &(cf_sk)->flow_state)
> +#define SET_RX_FLOW_ON(cf_sk) set_bit(RX_FLOW_ON_BIT,\
> +				    (void *) &(cf_sk)->flow_state)
> +#define SET_TX_FLOW_OFF(cf_sk) clear_bit(TX_FLOW_ON_BIT,\
> +				       (void *) &(cf_sk)->flow_state)
> +#define SET_TX_FLOW_ON(cf_sk) set_bit(TX_FLOW_ON_BIT,\
> +				    (void *) &(cf_sk)->flow_state)
> +
> +#define SKT_READ_FLAG 0x01
> +#define SKT_WRITE_FLAG 0x02
> +
> +#define MAX_CAIF_SOCKETS	200
> +
> +#ifdef CONFIG_DEBUG_FS
> +struct dentry *debugfsdir;
> +#include <linux/debugfs.h>
> +
> +static int max_caif_sockets =3D MAX_CAIF_SOCKETS;
> +#endif
> +
> +/* The AF_CAIF socket */
> +struct caifsock {
> +	struct sock sk;		/* NOTE: sk has to be the first member */
> +	struct layer layer;
> +	char name[CAIF_LAYER_NAME_SZ];
> +	u32 conn_state;
> +	u32 flow_state;
> +	struct cfpktq *pktq;
> +	int file_mode;
> +	struct caif_channel_config config;
> +	int read_queue_len;
> +	spinlock_t read_queue_len_lock;
> +
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *debugfs_device_dir;
> +	atomic_t num_open;
> +	atomic_t num_close;
> +	atomic_t num_init;
> +	atomic_t num_init_resp;
> +	atomic_t num_init_fail_resp;
> +	atomic_t num_deinit;
> +	atomic_t num_deinit_resp;
> +	atomic_t num_remote_shutdown_ind;
> +	atomic_t num_tx_flow_off_ind;
> +	atomic_t num_tx_flow_on_ind;
> +	atomic_t num_rx_flow_off;
> +	atomic_t num_rx_flow_on;
> +#endif
> +};
> +
> +static void drain_queue(struct caifsock *cf_sk);
> +
> +/** Packet Receive Callback function called from CAIF Stack */

Do not use /** to begin comments that are not kernel-doc notation.
(more found below, but deleted for now)

> +static int caif_sktrecv_cb(struct layer *layr, struct cfpkt *pkt)
> +{

> +/* Send a signal as a consequence of sendmsg, sendto or caif_sendmsg=
=2E */
> +static int caif_sendmsg(struct kiocb *kiocb, struct socket *sock,
> +			struct msghdr *msg, size_t len)
> +{
> +
> +	struct sock *sk =3D sock->sk;
> +	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
> +	void *payload;
> +	size_t payload_size =3D msg->msg_iov->iov_len;
> +	struct cfpkt *pkt =3D NULL;
> +	struct transmt_info info;
> +	unsigned char *txbuf;
> +	int err =3D 0;
> +	ssize_t ret =3D -EIO;
> +	int result;
> +	struct sk_buff *skb;
> +	CAIFLOG_TRACE("Enter %s\n", __func__);
> +	caif_assert(msg->msg_iovlen =3D=3D 1);
> +
> +	if (cf_sk =3D=3D NULL) {
> +		CAIFLOG_TRACE("[%s:%d] private_data not set!\n",
> +			      __func__, __LINE__);
> +		ret =3D -EBADFD;
> +		goto write_error_no_unlock;
> +	}
> +
> +	if (unlikely(msg->msg_iov->iov_base =3D=3D NULL)) {
> +		CAIFLOG_WARN("Buffer is NULL.\n");
> +		ret =3D -EINVAL;
> +		goto write_error_no_unlock;
> +	}
> +
> +	payload =3D msg->msg_iov->iov_base;
> +	if (payload_size > CAIF_MAX_PAYLOAD_SIZE) {
> +		CAIFLOG_TRACE("[%s:%d] buffer too long\n", __func__, __LINE__);
> +		ret =3D -EINVAL;
> +		goto write_error_no_unlock;
> +	}
> +	/* I want to be alone on cf_sk (except status and queue) */
> +	lock_sock(&(cf_sk->sk));
> +
> +	caif_assert(cf_sk->pktq);
> +
> +	if (!STATE_IS_OPEN(cf_sk)) {
> +		/* Socket is closed or closing */
> +		if (!STATE_IS_PENDING(cf_sk)) {
> +			CAIFLOG_TRACE("socket is closed (by remote end)\n");
> +			ret =3D -EPIPE;
> +		} else {
> +			CAIFLOG_TRACE("socket is closing...\n");
> +			ret =3D -EBADF;
> +		}
> +		goto write_error;
> +	}
> +
> +	/* Socket is open or opening */
> +	if (STATE_IS_PENDING(cf_sk)) {
> +		CAIFLOG_TRACE("socket is opening...\n");
> +
> +		if (msg->msg_flags & MSG_DONTWAIT) {
> +			/* We can't block */
> +			CAIFLOG_TRACE("state pending and MSG_DONTWAIT\n");
> +			ret =3D -EAGAIN;
> +			goto write_error;
> +		}
> +
> +		/* Let readers in */
> +		release_sock(&cf_sk->sk);
> +
> +		/* Blocking mode; state is pending and we need to wait
> +		   for its conclusion */
> +		result =3D
> +		    wait_event_interruptible(*cf_sk->sk.sk_sleep,
> +					     !STATE_IS_PENDING(cf_sk));
> +
> +		/* I want to be alone on cf_sk (except status and queue) */
> +		lock_sock(&(cf_sk->sk));
> +
> +		if (result =3D=3D -ERESTARTSYS) {
> +			CAIFLOG_TRACE
> +			    (" wait_event_interruptible woken by a signal (1)");
> +			ret =3D -ERESTARTSYS;
> +			goto write_error;
> +		}
> +	}
> +
> +	if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
> +		CAIFLOG_TRACE("received remote_shutdown indication\n");
> +		ret =3D -ESHUTDOWN;
> +		goto write_error;
> +	}
> +
> +	if (!TX_FLOW_IS_ON(cf_sk)) {
> +
> +		/* Flow is off. Check non-block flag */
> +		if (msg->msg_flags & MSG_DONTWAIT) {
> +			CAIFLOG_TRACE
> +			("caif_sendmsg: MSG_DONTWAIT and tx flow off");
> +			ret =3D -EAGAIN;
> +			goto write_error;
> +		}
> +
> +		/* release lock before waiting */
> +		release_sock(&cf_sk->sk);
> +
> +		/* Wait until flow is on or socket is closed */
> +		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
> +					TX_FLOW_IS_ON(cf_sk)
> +					|| !STATE_IS_OPEN(cf_sk)
> +					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
> +					) =3D=3D -ERESTARTSYS) {
> +			CAIFLOG_TRACE
> +				("caif_sendmsg:"
> +				" wait_event_interruptible woken by a signal");
> +			ret =3D -ERESTARTSYS;
> +			goto write_error_no_unlock;
> +		}
> +
> +		/* I want to be alone on cf_sk (except status and queue) */
> +		lock_sock(&(cf_sk->sk));
> +
> +		if (!STATE_IS_OPEN(cf_sk)) {
> +			/* someone closed the link, report error */
> +			CAIFLOG_TRACE("[%s:%d] remote end shutdown!\n",
> +				      __func__, __LINE__);
> +			ret =3D -EPIPE;
> +			goto write_error;
> +		}
> +
> +		if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
> +			CAIFLOG_TRACE("received remote_shutdown indication\n");
> +			ret =3D -ESHUTDOWN;
> +			goto write_error;
> +		}
> +	}
> +
> +	/* Create packet, buf=3DNULL means no copying */
> +	skb =3D caif_alloc_send_skb(sk,
> +				payload_size + CAIF_NEEDED_HEADROOM +
> +				CAIF_NEEDED_TAILROOM,
> +				&err);
> +	skb_reserve(skb, CAIF_NEEDED_HEADROOM);
> +	pkt =3D cfpkt_fromnative(CAIF_DIR_OUT, skb);
> +	caif_assert((void *)pkt =3D=3D (void *)skb);
> +
> +	if (pkt =3D=3D NULL) {
> +		CAIFLOG_TRACE
> +			("caif_sendmsg: cfpkt_create_pkt returned NULL\n");
> +		ret =3D -EIO;
> +		goto write_error;
> +	}
> +
> +	if (!cfpkt_raw_append(pkt, (void **) &txbuf, payload_size)) {
> +		CAIFLOG_TRACE("caif_sendmsg: cfpkt_raw_append failed\n");
> +		cfpkt_destroy(pkt);
> +		ret =3D -EINVAL;
> +		goto write_error;
> +	}
> +
> +	/* Copy data into buffer. */
> +	if (copy_from_user(txbuf, payload, payload_size)) {
> +		CAIFLOG_TRACE
> +			("caif_sendmsg: copy_from_user returned non zero.\n");
> +		cfpkt_destroy(pkt);
> +		ret =3D -EINVAL;
> +		goto write_error;
> +	}
> +	memset(&info, 0, sizeof(info));
> +
> +	/* Send the packet down the stack. */
> +	caif_assert(cf_sk->layer.dn);
> +	caif_assert(cf_sk->layer.dn->transmit);
> +
> +	do {
> +			ret =3D cf_sk->layer.dn->transmit(cf_sk->layer.dn,
> +							&info, pkt);

odd indentation?

> +		if (likely((ret >=3D 0) || (ret !=3D -EAGAIN)))
> +			break;
> +
> +		/* EAGAIN - retry */
> +		if (msg->msg_flags & MSG_DONTWAIT) {
> +			CAIFLOG_TRACE
> +			    ("NONBLOCK and transmit failed, error =3D %d\n",
> +			     ret);
> +			ret =3D -EAGAIN;
> +			goto write_error;
> +		}
> +
> +		/* Let readers in */
> +		release_sock(&cf_sk->sk);
> +
> +		/* Wait until flow is on or socket is closed */
> +		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
> +					TX_FLOW_IS_ON(cf_sk)
> +					|| !STATE_IS_OPEN(cf_sk)
> +					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
> +					) =3D=3D -ERESTARTSYS) {
> +			CAIFLOG_TRACE
> +			    ("wait_event_interruptible woken by a signal");
> +			ret =3D -ERESTARTSYS;
> +			goto write_error_no_unlock;
> +		}
> +
> +		/* I want to be alone on cf_sk (except status and queue) */
> +		lock_sock(&(cf_sk->sk));
> +
> +	} while (ret =3D=3D -EAGAIN);
> +
> +	if (ret < 0) {
> +		cfpkt_destroy(pkt);
> +		CAIFLOG_TRACE("transmit failed, error =3D %d\n",
> +			      ret);
> +
> +		goto write_error;
> +	}
> +
> +	release_sock(&cf_sk->sk);
> +	CAIFLOG_EXIT("");
> +	return payload_size;
> +
> +write_error:
> +	release_sock(&cf_sk->sk);
> +write_error_no_unlock:
> +	CAIFLOG_EXIT("");
> +	return ret;
> +}
> +

> +
> +static int setsockopt(struct socket *sock,
> +			int lvl, int opt, char __user *ov, int ol)
> +{
> +	struct sock *sk =3D sock->sk;
> +	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
> +	struct caif_channel_opt confopt;
> +	int res;
> +
> +	if (lvl !=3D SOL_CAIF) {
> +		CAIFLOG_TRACE("setsockopt bad level\n");
> +			return -ENOPROTOOPT;

odd indentation.

> +	}
> +
> +	switch (opt) {
> +	case CAIF_CHANNEL_OPT:
> +		if (ol < sizeof(struct caif_channel_opt)) {
> +			CAIFLOG_TRACE("setsockopt"
> +					" CAIF_CHANNEL_CONFIG bad size\n");
> +				return -EINVAL;

odd indentation.

> +		}
> +		res =3D copy_from_user(&confopt, ov, sizeof(confopt));
> +		if (res)
> +			return res;
> +		lock_sock(&(cf_sk->sk));
> +		cf_sk->config.priority =3D confopt.priority;
> +		cf_sk->config.phy_pref =3D confopt.link_selector;
> +		strncpy(cf_sk->config.phy_name, confopt.link_name,
> +			sizeof(cf_sk->config.phy_name));
> +		CAIFLOG_TRACE("Setting sockopt pri=3D%d pref=3D%d name=3D%s\n",
> +			      cf_sk->config.priority,
> +			      cf_sk->config.phy_pref,
> +			      cf_sk->config.phy_name);
> +		release_sock(&cf_sk->sk);
> +		return 0;
> +/* TODO: Implement the remaining options:
> + *	case CAIF_REQ_PARAM_OPT:
> + *	case CAIF_RSP_PARAM_OPT:
> + *	case CAIF_UTIL_FLOW_OPT:
> + *	case CAIF_CONN_INFO_OPT:
> + *	case CAIF_CONN_ID_OPT:
> + */
> +	default:
> +		CAIFLOG_TRACE("setsockopt: unhandled option %d\n",
> +			      opt);
> +		return -EINVAL;
> +	}
> +
> +
> +}

> +int caif_connect(struct socket *sock, struct sockaddr *uservaddr,
> +	       int sockaddr_len, int flags)
> +{
> +	struct caifsock *cf_sk =3D NULL;
> +	int result =3D -1;
> +	int mode =3D 0;
> +	int ret =3D -EIO;
> +    struct sock *sk =3D sock->sk;

indent above line with tab, not spaces.

> +
> +	CAIFLOG_TRACE("Enter %s\n", __func__);
> +
> +	BUG_ON(sk =3D=3D NULL);
> +
> +	cf_sk =3D container_of(sk, struct caifsock, sk);
> +
> +	CAIFLOG_TRACE("cf_sk=3D%p OPEN=3D%d, TX_FLOW=3D%d, RX_FLOW=3D%d\n",=
 cf_sk,
> +		      STATE_IS_OPEN(cf_sk),
> +		      TX_FLOW_IS_ON(cf_sk), RX_FLOW_IS_ON(cf_sk));
> +
> +	sk->sk_state    =3D TCP_CLOSE;
> +	sock->state     =3D SS_UNCONNECTED;
> +
> +	/* FIXME: SOCK_DGRAM should be removed? */
> +	if (sock->type =3D=3D SOCK_DGRAM || sock->type =3D=3D SOCK_SEQPACKE=
T) {
> +		sock->state     =3D SS_CONNECTED;
> +		sk->sk_state    =3D TCP_ESTABLISHED;
> +	} else
> +		goto out;
> +
> +	/* I want to be alone on cf_sk (except status and queue) */
> +	lock_sock(&(cf_sk->sk));
> +
> +	ret =3D caif_channel_config(cf_sk, uservaddr, sockaddr_len,
> +				&cf_sk->config);
> +	if (ret) {
> +		CAIFLOG_TRACE
> +		    ("[%s:%d] Cannot set socket address\n",
> +		     __func__, __LINE__);
> +		goto open_error;
> +	}
> +
> +
> +#ifdef CONFIG_DEBUG_FS
> +	atomic_inc(&cf_sk->num_open);
> +#endif
> +	mode =3D SKT_READ_FLAG | SKT_WRITE_FLAG;
> +
> +	/* If socket is not open, make sure socket is in fully closed state=
 */
> +	if (!STATE_IS_OPEN(cf_sk)) {
> +		/* Has link close response been received
> +		   (if we ever sent it)? */
> +		if (STATE_IS_PENDING(cf_sk)) {
> +			/* Still waiting for close response from remote.
> +			   If opened non-blocking, report "would block" */
> +			if (flags & MSG_DONTWAIT) {
> +				CAIFLOG_TRACE("MSG_DONTWAIT"
> +					" && close pending\n");
> +				ret =3D -EAGAIN;
> +				goto open_error;
> +			}
> +
> +			CAIFLOG_TRACE
> +			    ("wait for close response from remote...\n");
> +
> +			release_sock(&cf_sk->sk);
> +
> +			/* Blocking mode; close is pending and we need to wait
> +			   for its conclusion */
> +			result =3D
> +			    wait_event_interruptible(*cf_sk->sk.sk_sleep,
> +						     !STATE_IS_PENDING(cf_sk));
> +
> +			lock_sock(&(cf_sk->sk));
> +			if (result =3D=3D -ERESTARTSYS) {
> +				CAIFLOG_TRACE
> +				    ("wait_event_interruptible woken"
> +				     "by a signal (1)");
> +				ret =3D -ERESTARTSYS;
> +				goto open_error;
> +			}
> +		}
> +	}
=2E..
> +}

> +
> +/* This function is called as part of close. */
> +static int caif_release(struct socket *sock)
> +{
> +	struct sock *sk =3D sock->sk;
> +	struct caifsock *cf_sk =3D NULL;
> +	CAIFLOG_TRACE("Enter %s\n", __func__);
> +
> +	caif_assert(sk !=3D NULL);
> +	cf_sk =3D container_of(sk, struct caifsock, sk);
> +
> +	caif_shutdown(sock, SHUT_RDWR);
> +	lock_sock(&(cf_sk->sk));
> +	/* NOTE: This is how the sock->sk structure is used all over the li=
nux
> +	 *       socket implementation. Since there is no locking protectin=
g
> +	 *       the sock->sk pointer, the linux socket implementation do n=
ot
> +	 *       support multiple threads using the same socket descriptor,
> +	 *       since if one of the threads close the socket, the other
> +	 *       threads may end up accessing a pointer to NULL. See for
> +	 *       instance sock_setsockopt in net/socket.c, it uses sock->sk
> +	 *       without checking if its value is NULL. */

	/*
	 * Note: This is the Linux long comment
	 * style.  Please use it.
	 */

> +	sock->sk =3D NULL;
> +
> +	/* Unlink the socket from the hunt name table. */
> +
> +
> +	/* Trigger the pending attachs from and to the socket.  This needs =
to
> +	 * be done before the socket starts to be released. */
> +
> +
> +	/* Remove pending new link requests. */
> +
> +	/* Detach the socket from its process context by making it orphan. =
*/
> +	sock_orphan(sk);
> +
> +	/* Setting SHUTDOWN_MASK means that both send and receive are shutd=
own
> +	 * for the socket. */
> +	sk->sk_shutdown =3D SHUTDOWN_MASK;
> +
> +	/* Set the socket state to closed, the TCP_CLOSE macro is used when
> +	 * closing any socket. */
> +	sk->sk_state =3D TCP_CLOSE;
> +
> +	/* Flush out this sockets receive queue. */
> +	drain_queue(cf_sk);
> +
> +	/* Finally release the socket. */
> +	STATE_IS_PENDING_DESTROY(cf_sk);
> +	release_sock(&cf_sk->sk);
> +	sock_put(sk);
> +
> +	return 0;
> +
> +	/* The rest of the cleanup will be handled from the
> +	 * caif_sock_destructor */
> +}

> +/* This function is called when a socket is finally destructed. */

                                                       destroyed. */

> +static void caif_sock_destructor(struct sock *sk)
> +{
> +	struct caifsock *cf_sk =3D NULL;
> +	CAIFLOG_TRACE("Enter %s\n", __func__);
> +	cf_sk =3D container_of(sk, struct caifsock, sk);
> +
> +	/* Error checks. */
> +	caif_assert(!atomic_read(&sk->sk_wmem_alloc));
> +	caif_assert(sk_unhashed(sk));
> +	caif_assert(!sk->sk_socket);
> +
> +	if (!sock_flag(sk, SOCK_DEAD)) {
> +		CAIFLOG_TRACE("Attempt to release alive caif socket: 0x%p", sk);
> +		return;
> +	}
> +
> +	lock_sock(&(cf_sk->sk));
> +
> +	if (STATE_IS_OPEN(cf_sk)) {
> +		CAIFLOG_TRACE
> +			("[%s:%d] socket is opened (cf_sk=3D%p)"
> +				" file_mode =3D 0x%x\n", __func__, __LINE__,
> +				cf_sk, cf_sk->file_mode);
> +		release_sock(&cf_sk->sk);
> +		return;
> +	}
> +
> +	CAIFLOG_TRACE("pktq =3D %p \n", cf_sk->pktq);
> +	drain_queue(cf_sk);
> +	CAIFLOG_TRACE("pktq =3D %p \n", cf_sk->pktq);
> +
> +	cfglu_free(cf_sk->pktq);
> +
> +#ifdef CONFIG_DEBUG_FS
> +	if (cf_sk->debugfs_device_dir !=3D NULL)
> +		debugfs_remove_recursive(cf_sk->debugfs_device_dir);
> +#endif
> +
> +	release_sock(&cf_sk->sk);
> +	CAIFLOG_WARN("caif_sock_destructor: Removing socket %s\n",
> +		cf_sk->name);
> +	/* Decrease the global caif socket counter. */
> +	atomic_dec(&caif_nr_socks);
> +	return;
> +}
> +


> diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
> new file mode 100644
> index 0000000..fbc8a64
> --- /dev/null
> +++ b/net/caif/chnl_net.c
> @@ -0,0 +1,655 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2009
> + * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#include <linux/version.h>
> +#include <linux/fs.h>
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_ether.h>
> +#include <linux/moduleparam.h>
> +#include <linux/ip.h>
> +#include <linux/sched.h>
> +#include <linux/sockios.h>
> +
> +/* CAIF header files. */
> +#include <net/caif/generic/caif_layer.h>
> +#include <net/caif/generic/cfcnfg.h>
> +#include <net/caif/generic/cfpkt.h>
> +#include <net/caif/caif_chr.h>
> +#include <net/caif/caif_log.h>
> +
> +/*NetLink Header files*/
> +#include <net/rtnetlink.h>
> +#include <linux/caif/if_caif.h>
> +
> +#define CAIF_CONNECT_TIMEOUT 30
> +#define SIZE_MTU 1500
> +#define SIZE_MTU_MAX 4080
> +#define SIZE_MTU_MIN 68
> +
> +static LIST_HEAD(chnl_net_list);
> +static spinlock_t list_lock;
> +
> +MODULE_LICENSE("GPL");
> +
> +struct chnl_net {
> +	struct layer chnl;
> +	struct net_device_stats stats;
> +	spinlock_t lock;
> +	struct caif_channel_config config;
> +	struct list_head list_field;
> +	struct net_device *netdev;
> +	char name[256];
> +	wait_queue_head_t netmgmt_wq;
> +	/* Flow status to remember and control the transmission. */
> +	bool flowenabled;
> +};
> +
> +
> +static struct chnl_net *find_device(char *name, bool remove_from_lis=
t)
> +{
> +	struct list_head *list_node;
> +	struct list_head *n;
> +	struct chnl_net *dev =3D NULL;
> +	struct chnl_net *tmp;
> +	CAIFLOG_ENTER("");
> +	spin_lock(&list_lock);
> +	CAIFLOG_TRACE("[%s:%d] start looping \n", __func__,
> +		__LINE__);
> +	list_for_each_safe(list_node, n, &chnl_net_list) {
> +		tmp =3D
> +			list_entry(list_node, struct chnl_net, list_field);

Above doesn't need to be on 2 lines.

> +		/* Find from name. */
> +		if (name) {
> +			if (!strncmp(tmp->name, name, sizeof(tmp->name)))
> +				dev =3D tmp;
> +		} else
> +			/* Get the first element if name is not specified. */
> +			dev =3D tmp;
> +		if (dev) {
> +			CAIFLOG_TRACE("[%s:%d] match %s \n",
> +				__func__, __LINE__,  name);
> +			if (remove_from_list)
> +				list_del(list_node);
> +			break;
> +		}
> +	}
> +	spin_unlock(&list_lock);
> +	return dev;
> +}



--=20
~Randy
