From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
Date: Fri, 22 Aug 2008 12:48:44 -0700
Message-ID: <20080822124844.b05ee3e8.akpm@linux-foundation.org>
References: <200808221840.m7MIeuvB004442@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com, kxie@chelsio.com
To: Karen Xie <kxie@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33422 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756828AbYHVTtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 15:49:41 -0400
In-Reply-To: <200808221840.m7MIeuvB004442@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Aug 2008 11:40:56 -0700
Karen Xie <kxie@chelsio.com> wrote:

> [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
> 
> From: Karen Xie <kxie@chelsio.com>
> 
> cxgb3i iSCSI driver.
> 
> Signed-off-by: Karen Xie <kxie@chelsio.com>

I'm going to suggest that this not be merged in this form due to the
__GFP_NOFAIL issues identified below.

> 
>  drivers/scsi/Kconfig                 |    2 
>  drivers/scsi/Makefile                |    1 
>  drivers/scsi/cxgb3i/Kconfig          |    6 
>  drivers/scsi/cxgb3i/Makefile         |    5 
>  drivers/scsi/cxgb3i/cxgb3i.h         |  155 +++
>  drivers/scsi/cxgb3i/cxgb3i_init.c    |  109 ++
>  drivers/scsi/cxgb3i/cxgb3i_iscsi.c   |  824 ++++++++++++++
>  drivers/scsi/cxgb3i/cxgb3i_offload.c | 1985 ++++++++++++++++++++++++++++++++++
>  drivers/scsi/cxgb3i/cxgb3i_offload.h |  252 ++++
>  drivers/scsi/cxgb3i/cxgb3i_ulp2.c    |  692 ++++++++++++
>  drivers/scsi/cxgb3i/cxgb3i_ulp2.h    |  106 ++
>  11 files changed, 4137 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/scsi/cxgb3i/Kconfig
>  create mode 100644 drivers/scsi/cxgb3i/Makefile
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i.h
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_init.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_iscsi.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_offload.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_offload.h
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_ulp2.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_ulp2.h
> 

Please use scripts/checkpatch.pl. It finds things which should be fixed.

>
> ...
>
> +/**
> + * struct cxgb3i_tag_format - cxgb3i ulp tag for steering pdu payload
> + *
> + * @rsvd_bits:	# of bits used by h/w
> + * @rsvd_shift:	shift left
> + * @rsvd_mask:  bit mask
> + *
> + */
> +struct cxgb3i_tag_format {
> +	unsigned char idx_bits;
> +	unsigned char age_bits;
> +	unsigned char rsvd_bits;
> +	unsigned char rsvd_shift;
> +	u32 rsvd_mask;
> +};

Only three of the five fields were documented.

> +/**
> + * struct cxgb3i_ddp_info - cxgb3i direct data placement for pdu payload
> + *
> + * @llimit:	lower bound of the page pod memory
> + * @ulimit:	upper bound of the page pod memory
> + * @nppods:	# of page pod entries
> + * @idx_last:	page pod entry last used
> + * @map_lock:	lock to synchonize access to the page pod map
> + * @map:	page pod map
> + */
> +struct cxgb3i_ddp_info {
> +	unsigned int llimit;
> +	unsigned int ulimit;
> +	unsigned int nppods;
> +	unsigned int idx_last;
> +	spinlock_t map_lock;
> +	u8 *map;
> +};
> +
> +struct cxgb3i_hba {
> +	struct cxgb3i_adapter *snic;
> +	struct net_device *ndev;
> +	struct Scsi_Host *shost;
> +
> +	rwlock_t cconn_rwlock;
> +	struct list_head cconn_list;
> +};
> +
> +struct cxgb3i_adapter {
> +	struct list_head list_head;
> +	spinlock_t lock;
> +	struct t3cdev *tdev;
> +	struct pci_dev *pdev;
> +	unsigned char hba_cnt;
> +	struct cxgb3i_hba *hba[MAX_NPORTS];
> +
> +	unsigned int tx_max_size;
> +	unsigned int rx_max_size;
> +
> +	struct cxgb3i_tag_format tag_format;
> +	struct cxgb3i_ddp_info ddp;
> +};
> +
> +struct cxgb3i_conn {
> +	struct list_head list_head;
> +
> +	struct cxgb3i_endpoint *cep;
> +	struct iscsi_conn *conn;
> +	struct cxgb3i_hba *hba;
> +};
> +
> +struct cxgb3i_endpoint {
> +	struct s3_conn *c3cn;
> +	struct cxgb3i_hba *hba;
> +	struct cxgb3i_conn *cconn;
> +};

We got bored of documenting, I see ;)


It's a shame, because documenting the data structures is very useful. 
More important than documenting code flow, for example.

>
> ...
>
> +static inline void cxgb3i_parse_tag(struct cxgb3i_tag_format *format,
> +				    u32 tag, u32 *rsvd_bits, u32 *sw_bits)
> +{
> +	if (rsvd_bits)
> +		*rsvd_bits = (tag >> format->rsvd_shift) & format->rsvd_mask;
> +	if (sw_bits) {
> +		*sw_bits = (tag >> (format->rsvd_shift + format->rsvd_bits))
> +		    << format->rsvd_shift;
> +		*sw_bits |= tag & ((1 << format->rsvd_shift) - 1);
> +	}
> +}

Far too large to inline, has only one call site.  Can be made static
non-inline in cxgb3i_iscsi.c.

> +int cxgb3i_conn_ulp2_xmit(struct iscsi_conn *);
> +
> +void cxgb3i_display_byte_string(char *, unsigned char *, int, int);
> +
> +#endif
> diff --git a/drivers/scsi/cxgb3i/cxgb3i_init.c b/drivers/scsi/cxgb3i/cxgb3i_init.c
> new file mode 100644
> index 0000000..1c91bb0
> --- /dev/null
> +++ b/drivers/scsi/cxgb3i/cxgb3i_init.c
> @@ -0,0 +1,109 @@
> +/* cxgb3i_init.c: Chelsio S3xx iSCSI driver.
> + *
> + * Copyright (c) 2008 Chelsio Communications, Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation.
> + *
> + * Written by: Karen Xie (kxie@chelsio.com)
> + */
> +
> +#include "cxgb3i.h"
> +
> +#define DRV_MODULE_NAME         "cxgb3i"
> +#define DRV_MODULE_VERSION      "1.0.0"

I'd suggest that the version number just be removed.  It becomes
meaningless (and often misleading) once a driver is in the mainline
kernel.  People will update the driver without changing the version
number.  Code external to the driver but which affects it can change.

The kernel version identifier is really the only way in whcih you and
your support people can reproduce a user's code.

> +#define DRV_MODULE_RELDATE      "May 1, 2008"

Ditto.

> +static char version[] =
> +    "Chelsio S3xx iSCSI Driver " DRV_MODULE_NAME
> +    " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
> +
> +MODULE_AUTHOR("Karen Xie <kxie@chelsio.com>");
> +MODULE_DESCRIPTION("Chelsio S3xx iSCSI Driver");
> +MODULE_LICENSE("GPL");
> +MODULE_VERSION(DRV_MODULE_VERSION);
> +
> +static void open_s3_dev(struct t3cdev *);
> +static void close_s3_dev(struct t3cdev *);
> +cxgb3_cpl_handler_func cxgb3i_cpl_handlers[NUM_CPL_CMDS];
> +struct cxgb3_client t3c_client = {
> +	.name = "iscsi_cxgb3",
> +	.handlers = cxgb3i_cpl_handlers,
> +	.add = open_s3_dev,
> +	.remove = close_s3_dev,
> +};
> +
> +/**
> + * open_s3_dev - register with cxgb3 LLD
> + * @t3dev	cxgb3 adapter instance
> + */
> +static void open_s3_dev(struct t3cdev *t3dev)
> +{
> +	static int vers_printed;
> +
> +	if (!vers_printed) {
> +		printk(KERN_INFO "%s", version);

This is normally done at module_init() time.

> +		vers_printed = 1;
> +	}
> +
> +	cxgb3i_log_debug("open cxgb3 %s.\n", t3dev->name);
> +
> +	cxgb3i_sdev_add(t3dev, &t3c_client);
> +	cxgb3i_adapter_add(t3dev);
> +}
> +
> +/**
> + * close_s3_dev - de-register with cxgb3 LLD
> + * @t3dev	cxgb3 adapter instance
> + */
> +static void close_s3_dev(struct t3cdev *t3dev)
> +{
> +	struct cxgb3i_adapter *snic = cxgb3i_adapter_find_by_tdev(t3dev);
> +	cxgb3i_log_debug("close cxgb3 %s.\n", t3dev->name);
> +	if (snic)
> +		cxgb3i_adapter_remove(snic);
> +	cxgb3i_sdev_remove(t3dev);
> +}

It is conventional to put a single blank line between end-of-locals and
start-of-code.

> +/**
> + * cxgb3i_init_module - module init entry point
> + *
> + * initialize any driver wide global data structures and register itself
> + *	with the cxgb3 module
> + */
> +static int __init cxgb3i_init_module(void)
> +{
> +	int err;
> +
> +	err = cxgb3i_sdev_init(cxgb3i_cpl_handlers);

like that.

> +	if (err < 0)
> +		return err;
> +
> +	err = cxgb3i_iscsi_init();
> +	if (err < 0)
> +		return err;
> +
> +	err = cxgb3i_ulp2_init();
> +	if (err < 0)
> +		return err;
> +
> +	cxgb3_register_client(&t3c_client);
> +	return 0;
> +}
> +
>
> ...
>
> +struct cxgb3i_adapter *cxgb3i_adapter_find_by_tdev(struct t3cdev *t3dev)
> +{
> +	struct cxgb3i_adapter *snic;
> +
> +	read_lock(&cxgb3i_snic_rwlock);
> +	list_for_each_entry(snic, &cxgb3i_snic_list, list_head) {
> +		if (snic->tdev == t3dev) {
> +			read_unlock(&cxgb3i_snic_rwlock);
> +			return snic;
> +		}
> +	}
> +	read_unlock(&cxgb3i_snic_rwlock);
> +
> +	return NULL;
> +}

Is this racy?  We look up a device then return it after having unlocked
the lock.  The caller of this fucntion is handed a pointer to a think
which can now be freed by cxgb3i_adapter_remove().

> +struct cxgb3i_hba *cxgb3i_hba_find_by_netdev(struct net_device *ndev)
> +{
> +	struct cxgb3i_adapter *snic;
> +	int i;
> +
> +	read_lock(&cxgb3i_snic_rwlock);
> +	list_for_each_entry(snic, &cxgb3i_snic_list, list_head) {
> +		for (i = 0; i < snic->hba_cnt; i++) {
> +			if (snic->hba[i]->ndev == ndev) {
> +				read_unlock(&cxgb3i_snic_rwlock);
> +				return (snic->hba[i]);
> +			}
> +		}
> +	}
> +	read_unlock(&cxgb3i_snic_rwlock);
> +	return NULL;
> +}
> +
> +void cxgb3i_hba_conn_add(struct cxgb3i_conn *cconn, struct cxgb3i_hba *hba)
> +{
> +	cconn->hba = hba;
> +	write_lock(&hba->cconn_rwlock);
> +	list_add_tail(&cconn->list_head, &hba->cconn_list);
> +	write_unlock(&hba->cconn_rwlock);
> +}
> +
> +void cxgb3i_hba_conn_remove(struct cxgb3i_conn *cconn)
> +{
> +	struct cxgb3i_hba *hba = cconn->hba;
> +
> +	if (hba) {

Can `hba' really be NULL here?

> +		write_lock(&hba->cconn_rwlock);
> +		list_del(&cconn->list_head);
> +		write_unlock(&hba->cconn_rwlock);
> +	}
> +}
> +
>
> ...
>
> +void cxgb3i_hba_host_remove(struct cxgb3i_hba *hba)
> +{
> +	if (hba->shost) {

Can hba->shost really be NULL here?

> +		cxgb3i_log_debug("shost 0x%p, hba 0x%p, no %u.\n",
> +				 hba->shost, hba, hba->shost->host_no);
> +		iscsi_host_remove(hba->shost);
> +		pci_dev_put(hba->snic->pdev);
> +		/* cleanup connections ? */
> +		iscsi_host_free(hba->shost);
> +	}
> +}
> +
> +/**
> + * cxgb3i_ep_connect - establish TCP connection to target portal
> + * @dst_addr:		target IP address
> + * @non_blocking:	blocking or non-blocking call
> + *
> + * Initiates a TCP/IP connection to the dst_addr
> + */
> +static struct iscsi_endpoint *cxgb3i_ep_connect(struct sockaddr *dst_addr,
> +						int non_blocking)
> +{
> +	struct iscsi_endpoint *ep;
> +	struct cxgb3i_endpoint *cep;
> +	struct cxgb3i_hba *hba;
> +	struct s3_conn *c3cn = NULL;
> +	int err = 0;
> +
> +	c3cn = cxgb3i_c3cn_create();
> +	if (!c3cn) {
> +		cxgb3i_log_info("ep connect OOM.\n");
> +		err = -ENOMEM;
> +		goto release_conn;
> +	}
> +
> +	err = cxgb3i_c3cn_connect(c3cn, (struct sockaddr_in *)dst_addr);

hm, I'm surprised that networking doesn't provide a neater, typesafe
way of converting a sockaddr to a sockaddr_in.  union, anonymous union
or even a plain old inlined C function.  Casts are dangerous.

> +	if (err < 0) {
> +		cxgb3i_log_info("ep connect failed.\n");
> +		goto release_conn;
> +	}
> +	hba = cxgb3i_hba_find_by_netdev(c3cn->dst_cache->dev);
> +	if (!hba) {
> +		err = -ENOSPC;
> +		cxgb3i_log_info("NOT going through cxgbi device.\n");
> +		goto release_conn;
> +	}
> +	if (c3cn_in_state(c3cn, C3CN_STATE_CLOSE)) {
> +		err = -ENOSPC;
> +		cxgb3i_log_info("ep connect unable to connect.\n");
> +		goto release_conn;
> +	}
> +
> +	ep = iscsi_create_endpoint(sizeof(*cep));
> +	if (!ep) {
> +		err = -ENOMEM;
> +		cxgb3i_log_info("iscsi alloc ep, OOM.\n");
> +		goto release_conn;
> +	}
> +	cep = ep->dd_data;
> +	cep->c3cn = c3cn;
> +	cep->hba = hba;
> +
> +	cxgb3i_log_debug("ep 0x%p, 0x%p, c3cn 0x%p, hba 0x%p.\n",
> +			  ep, cep, c3cn, hba);
> +	return ep;
> +
> +release_conn:
> +	cxgb3i_log_debug("conn failed release.\n");
> +	if (c3cn)
> +		c3cn_release(c3cn);
> +	return ERR_PTR(err);
> +}
> +
> +/**
> + * cxgb3i_ep_poll - polls for TCP connection establishement
> + * @ep:		TCP connection (endpoint) handle
> + * @timeout_ms:	timeout value in milli secs
> + *
> + * polls for TCP connect request to complete
> + */
> +static int cxgb3i_ep_poll(struct iscsi_endpoint *ep, int timeout_ms)
> +{
> +	struct cxgb3i_endpoint *cep = (struct cxgb3i_endpoint *)ep->dd_data;

dd_data is void*, so no cast is needed.

The unneeded cast is actually a little bit dangerous because it
suppresses a compiler warning which we'd get if dd_data has any type
other than cxgb3i_endpoint* or void*.


> +	struct s3_conn *c3cn = cep->c3cn;
> +
> +	cxgb3i_log_debug("ep 0x%p, timeout %d, c3cn 0x%p, state 0x%x.\n",
> +			 ep, timeout_ms, c3cn, c3cn->state);
> +
> +	if (!c3cn_in_state(c3cn, C3CN_STATE_ESTABLISHED)) {
> +		cxgb3i_log_info("not in established state.\n");
> +		return 0;
> +	}
> +	return 1;
> +}
> +
> +/**
> + * cxgb3i_ep_disconnect - teardown TCP connection
> + * @ep:		TCP connection (endpoint) handle
> + *
> + * teardown TCP connection
> + */
> +static void cxgb3i_ep_disconnect(struct iscsi_endpoint *ep)
> +{
> +	struct cxgb3i_endpoint *cep = (struct cxgb3i_endpoint *)ep->dd_data;

Please check the whole patch for unneeded casts of void*.

> +	struct cxgb3i_conn *cconn = cep->cconn;
> +
> +	cxgb3i_log_debug("ep 0x%p, cep 0x%p.\n", ep, cep);
> +
> +	if (cconn && cconn->conn) {
> +		struct iscsi_conn *conn = cconn->conn;
> +		struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
> +		write_lock_bh(&cep->c3cn->callback_lock);
> +		cep->c3cn->user_data = NULL;
> +		set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
> +		cconn->cep = NULL;
> +		tcp_conn->sock = NULL;
> +		write_unlock_bh(&cep->c3cn->callback_lock);
> +	}

	if (cconn && cconn->conn) {
		struct iscsi_conn *conn = cconn->conn;
		struct iscsi_tcp_conn *tcp_conn = conn->dd_data;

		write_lock_bh(&cep->c3cn->callback_lock);
		cep->c3cn->user_data = NULL;
		set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
		cconn->cep = NULL;
		tcp_conn->sock = NULL;
		write_unlock_bh(&cep->c3cn->callback_lock);
	}

is easier to read, no?

> +
> +	cxgb3i_log_debug("ep 0x%p, cep 0x%p, release c3cn 0x%p.\n",
> +			 ep, cep, cep->c3cn);
> +	c3cn_release(cep->c3cn);
> +	iscsi_destroy_endpoint(ep);
> +}
> +
> +/**
> + * cxgb3i_session_create - create a new iscsi session
> + * @cmds_max:		max # of commands
> + * @qdepth:		scsi queue depth
> + * @initial_cmdsn:	initial iscsi CMDSN for this session
> + * @host_no:		pointer to return host no
> + *
> + * Creates a new iSCSI session
> + */
> +static struct iscsi_cls_session *cxgb3i_session_create(struct iscsi_endpoint
> +						       *ep, uint16_t cmds_max,
> +						       uint16_t qdepth,
> +						       uint32_t initial_cmdsn,
> +						       uint32_t *host_no)

Code uses a mixture of uint16_t and u16.

u16 is usually preferred for in-kernel work.

> +{
> +	struct cxgb3i_endpoint *cep;
> +	struct cxgb3i_hba *hba;
> +	struct Scsi_Host *shost;
> +	struct iscsi_cls_session *cls_session;
> +	struct iscsi_session *session;
> +	int i;
> +
> +	if (!ep) {
> +		cxgb3i_log_error("%s, missing endpoint.\n", __func__);
> +		return NULL;
> +	}
> +
> +	cep = (struct cxgb3i_endpoint *)ep->dd_data;

cast..

> +	hba = cep->hba;
> +	shost = hba->shost;
> +	cxgb3i_log_debug("ep 0x%p, cep 0x%p, hba 0x%p.\n", ep, cep, hba);
> +	BUG_ON(hba != iscsi_host_priv(shost));
> +
> +	*host_no = shost->host_no;
> +
> +	cls_session = iscsi_session_setup(&cxgb3i_iscsi_transport, shost,
> +					  cmds_max,
> +					  sizeof(struct iscsi_tcp_task),
> +					  initial_cmdsn, ISCSI_MAX_TARGET);
> +	if (!cls_session)
> +		return NULL;
> +
> +	session = cls_session->dd_data;

you forgot the typecast :)

> +	for (i = 0; i < session->cmds_max; i++) {
> +		struct iscsi_task *task = session->cmds[i];
> +		struct iscsi_tcp_task *tcp_task = task->dd_data;
> +
> +		task->hdr = &tcp_task->hdr.cmd_hdr;
> +		task->hdr_max = sizeof(tcp_task->hdr) - ISCSI_DIGEST_SIZE;
> +	}
> +
> +	if (iscsi_r2tpool_alloc(session))
> +		goto remove_session;
> +
> +	return cls_session;
> +
> +remove_session:
> +	iscsi_session_teardown(cls_session);
> +	return NULL;
> +}
> +
>
> ...
>
> +/**
> + * cxgb3i_conn_bind - binds iscsi sess, conn and endpoint together
> + * @cls_session:	pointer to iscsi cls session
> + * @cls_conn:		pointer to iscsi cls conn
> + * @transport_eph:	64-bit EP handle
> + * @is_leading:		leading connection on this session?
> + *
> + * Binds together an iSCSI session, an iSCSI connection and a
> + *	TCP connection. This routine returns error code if the TCP
> + *	connection does not belong on the device iSCSI sess/conn is bound
> + */
> +
> +static int cxgb3i_conn_bind(struct iscsi_cls_session *cls_session,
> +			    struct iscsi_cls_conn *cls_conn,
> +			    uint64_t transport_eph, int is_leading)
> +{
> +	struct iscsi_conn *conn = cls_conn->dd_data;
> +	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
> +	struct cxgb3i_conn *cconn = (struct cxgb3i_conn *)(tcp_conn + 1);

This looks a bit bizarre.  We somehow got a `struct iscsi_tcp_conn' and
a 'struct cxgb3i_conn' laid out contiguously in memory?  I don't think
I want to know how that happened, but it can all be done very nicely
using the C type system, rather than abusing it.

> +	struct iscsi_endpoint *ep;
> +	struct cxgb3i_endpoint *cep;
> +	struct s3_conn *c3cn;
> +	int err;
> +
> +	ep = iscsi_lookup_endpoint(transport_eph);
> +	if (!ep)
> +		return -EINVAL;
> +
> +	cxgb3i_log_debug("ep 0x%p, cls sess 0x%p, cls conn 0x%p.\n",
> +			 ep, cls_session, cls_conn);
> +
> +	err = iscsi_conn_bind(cls_session, cls_conn, is_leading);
> +	if (err)
> +		return -EINVAL;
> +
> +	cep = (struct cxgb3i_endpoint *)ep->dd_data;
> +	c3cn = cep->c3cn;
> +
> +	read_lock(&c3cn->callback_lock);
> +	tcp_conn->sock = (struct socket *)c3cn;
> +	c3cn->user_data = conn;
> +	read_unlock(&c3cn->callback_lock);
> +
> +	cconn->hba = cep->hba;
> +	cconn->cep = cep;
> +	cep->cconn = cconn;
> +
> +	conn->max_recv_dlength = cconn->hba->snic->rx_max_size - ISCSI_PDU_HEADER_MAX;
> +	conn->max_xmit_dlength = cconn->hba->snic->tx_max_size - ISCSI_PDU_HEADER_MAX;
> +
> +	spin_lock_bh(&conn->session->lock);
> +	sprintf(conn->portal_address, NIPQUAD_FMT,
> +		NIPQUAD(c3cn->daddr.sin_addr.s_addr));
> +	conn->portal_port = ntohs(c3cn->daddr.sin_port);
> +	spin_unlock_bh(&conn->session->lock);
> +
> +	iscsi_tcp_hdr_recv_prep(tcp_conn);
> +
> +	return 0;
> +}
> +
>
> ...
>
> +/*
> + * Deallocate a source port from the allocation map.  If the source port is
> + * outside our allocation range just return -- the caller is responsible for
> + * keeping track of their port usage outside of our allocation map.
> + */
> +static void c3cn_put_port(struct s3_conn *c3cn)
> +{
> +	int old = ntohs(c3cn->saddr.sin_port) - sport_base;
> +	c3cn->saddr.sin_port = 0;
> +
> +	if (old < 0 || old >= max_connect)
> +		return;

Is this covering up a bug?

> +	spin_lock(&sport_map_lock);
> +	__clear_bit(old, sport_map);
> +	spin_unlock(&sport_map_lock);
> +}
> +
>
> ...
>
> +/*
> + * large memory chunk allocation/release
> + */
> +void *cxgb3i_alloc_big_mem(unsigned int size)
> +{
> +	void *p = kmalloc(size, GFP_KERNEL);
> +	if (!p)
> +		p = vmalloc(size);

erk.

Yes, it happens.  We should provide this in core kernel.  We shouldn't
be open-coding it in a remote driver.

> +	if (p)
> +		memset(p, 0, size);
> +	return p;
> +}
> +
> +void cxgb3i_free_big_mem(void *addr)
> +{
> +	unsigned long p = (unsigned long)addr;
> +	if (p >= VMALLOC_START && p < VMALLOC_END)
> +		vfree(addr);
> +	else
> +		kfree(addr);
> +}

y:/usr/src/linux-2.6.27-rc4> grep -r VMALLOC_START drivers | wc -l
1

Now it's two.  That's a big hint that something is wrong here.

> +void cxgb3i_sdev_cleanup(cxgb3_cpl_handler_func *cpl_handlers)
> +{
> +	memset(cpl_handlers, 0, NUM_CPL_CMDS*(sizeof(*cpl_handlers)));
> +	if (sport_map)
> +		cxgb3i_free_big_mem(sport_map);
> +}

This function is odd.  cpl_handlers[] is already all-zeroes, so why are
we rezeroing it all?

The function has no callers so I'm at a loss.

> +int cxgb3i_sdev_init(cxgb3_cpl_handler_func *cpl_handlers)
> +{
> +	cpl_handlers[CPL_ACT_ESTABLISH] = do_act_establish;
> +	cpl_handlers[CPL_ACT_OPEN_RPL] = do_act_open_rpl;
> +	cpl_handlers[CPL_PEER_CLOSE] = do_peer_close;
> +	cpl_handlers[CPL_ABORT_REQ_RSS] = do_abort_req;
> +	cpl_handlers[CPL_ABORT_RPL_RSS] = do_abort_rpl;
> +	cpl_handlers[CPL_CLOSE_CON_RPL] = do_close_con_rpl;
> +	cpl_handlers[CPL_TX_DMA_ACK] = do_wr_ack;
> +	cpl_handlers[CPL_ISCSI_HDR] = do_iscsi_hdr;
> +
> +	sport_map = cxgb3i_alloc_big_mem((max_connect + 7)/8);

That's DIV_ROUND_UP().

> +	if (!sport_map)
> +		return -ENOMEM;
> +	return 0;
> +}
> +
>
> ...
>
> +/*
> + * Send an active open request.
> + */
> +static int act_open(struct s3_conn *c3cn, struct net_device *dev)
> +{
> +	struct cxgb3i_sdev_data *cdata = NDEV2CDATA(dev);
> +	struct t3cdev *cdev = cdata->cdev;
> +	struct dst_entry *dst = c3cn->dst_cache;
> +	struct sk_buff *skb;
> +
> +	c3cn_conn_debug("c3cn 0x%p.\n", c3cn);
> +	/*
> +	 * Initialize connection data.  Note that the flags and ULP mode are
> +	 * initialized higher up ...
> +	 */
> +	c3cn->dev = dev;
> +	c3cn->cdev = cdev;
> +	c3cn->tid = cxgb3_alloc_atid(cdev, cdata->client, c3cn);
> +	if (c3cn->tid < 0)
> +		goto out_err;
> +	c3cn->qset = 0;
> +	c3cn->l2t = t3_l2t_get(cdev, dst->neighbour, dev);
> +	if (!c3cn->l2t)
> +		goto free_tid;
> +
> +	skb = alloc_skb(sizeof(struct cpl_act_open_req),
> +			GFP_KERNEL | __GFP_NOFAIL);

__GFP_NOFAIL is unusual.  Should be commented, or removed.  Preferably
removed - __GFP_NOFAIL is a hack for callsites which haven't been fixed
yet.

> +	skb->sk = (struct sock *)c3cn;

This callsite should be fixed.  Allocations can fail.

> +	set_arp_failure_handler(skb, act_open_req_arp_failure);
> +
> +	c3cn_hold(c3cn);
> +
> +	init_offload_conn(c3cn, cdev, dst);
> +	c3cn->err = 0;
> +	c3cn_reset_flag(c3cn, C3CN_DONE);
> +
> +	mk_act_open_req(c3cn, skb, c3cn->tid, c3cn->l2t);
> +	l2t_send(cdev, skb, c3cn->l2t);
> +	return 0;
> +
> +free_tid:
> +	free_atid(cdev, c3cn->tid);
> +	c3cn->tid = 0;
> +out_err:
> +	return -1;
> +}
> +
> +/*
> + * Close a connection by sending a CPL_CLOSE_CON_REQ message.  Cannot fail
> + * under any circumstances.  We take the easy way out and always queue the
> + * message to the write_queue.  We can optimize the case where the queue is
> + * already empty though the optimization is probably not worth it.
> + */
> +static void mk_close_req(struct s3_conn *c3cn)
> +{
> +	struct sk_buff *skb;
> +	struct cpl_close_con_req *req;
> +	unsigned int tid = c3cn->tid;
> +
> +	c3cn_conn_debug("c3cn 0x%p.\n", c3cn);
> +
> +	skb = alloc_skb(sizeof(struct cpl_close_con_req),
> +			GFP_KERNEL | __GFP_NOFAIL);

dittoes

> +	req = (struct cpl_close_con_req *)__skb_put(skb, sizeof(*req));
> +	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_CLOSE_CON));
> +	req->wr.wr_lo = htonl(V_WR_TID(tid));
> +	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_CON_REQ, tid));
> +	req->rsvd = htonl(c3cn->write_seq);
> +
> +	skb_entail(c3cn, skb, C3CB_FLAG_NO_APPEND);
> +	if (c3cn->state != C3CN_STATE_SYN_SENT)
> +		s3_push_frames(c3cn, 1);
> +}
> +
> +static void skb_entail(struct s3_conn *c3cn, struct sk_buff *skb,
> +		       int flags)
> +{
> +	CXGB3_SKB_CB(skb)->seq = c3cn->write_seq;
> +	CXGB3_SKB_CB(skb)->flags = flags;
> +	__skb_queue_tail(&c3cn->write_queue, skb);
> +}
> +
> +/*
> + * Send RX credits through an RX_DATA_ACK CPL message.  If nofail is 0 we are
> + * permitted to return without sending the message in case we cannot allocate
> + * an sk_buff.  Returns the number of credits sent.
> + */
> +static u32 s3_send_rx_credits(struct s3_conn *c3cn, u32 credits, u32 dack,
> +			      int nofail)
> +{
> +	struct sk_buff *skb;
> +	struct cpl_rx_data_ack *req;
> +
> +	skb = (nofail ? alloc_ctrl_skb(c3cn, sizeof(*req))
> +	       : alloc_skb(sizeof(*req), GFP_ATOMIC));

ug.  All this nofail stuff seems to go pretty deep.  Sorry, but it all
should go away and the driver should be coded to handle allocation
failures.

> +	if (!skb)
> +		return 0;
> +
> +	req = (struct cpl_rx_data_ack *)__skb_put(skb, sizeof(*req));
> +	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
> +	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_RX_DATA_ACK, c3cn->tid));
> +	req->credit_dack = htonl(dack | V_RX_CREDITS(credits));
> +	skb->priority = CPL_PRIORITY_ACK;
> +	cxgb3_ofld_send(c3cn->cdev, skb);
> +	return credits;
> +}
> +
>
> ...
>

(attention span ran out, sorry)
