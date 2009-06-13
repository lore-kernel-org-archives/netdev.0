From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [dm-devel] Updated cluster log patch (take 5)
Date: Sat, 13 Jun 2009 07:07:33 -0400
Message-ID: <20090613110733.GA7895@infradead.org>
References: <1244845317.19994.3.camel@hydrogen.msp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: device-mapper development <dm-devel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:35798 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbZFMLHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 07:07:31 -0400
Content-Disposition: inline
In-Reply-To: <1244845317.19994.3.camel@hydrogen.msp.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2009 at 05:21:57PM -0500, Jonathan Brassow wrote:
> The structure used for communication between kernel and userspace are
> located in include/linux/dm-log-cluster.h.  Due to the frequency,
> diversity, and 2-way communication nature of the exchanges between
> kernel and userspace, 'connector' is used as the interface for
> communication.

Maye I misremember it, but isn't the connector code strongly deprecated
in favour of genetlink?

> Index: linux-2.6/drivers/md/Kconfig
> ===================================================================
> --- linux-2.6.orig/drivers/md/Kconfig
> +++ linux-2.6/drivers/md/Kconfig
> @@ -231,6 +231,16 @@ config DM_MIRROR
>           Allow volume managers to mirror logical volumes, also
>           needed for live data migration tools such as 'pvmove'.
>  
> +config DM_LOG_CLUSTERED
> +	tristate "Mirror cluster logging (EXPERIMENTAL)"
> +	depends on DM_MIRROR && EXPERIMENTAL
> +	select CONNECTOR
> +	---help---
> +	  The cluster logging module provides a mechanism for
> +	  keeping log state coherent in a shared-storage cluster.
> +	  Device-mapper mirroring (RAID1) can leverage this log
> +	  type to make mirrors that are cluster-aware.
> +
>  config DM_ZERO
>  	tristate "Zero target"
>  	depends on BLK_DEV_DM
> Index: linux-2.6/drivers/md/Makefile
> ===================================================================
> --- linux-2.6.orig/drivers/md/Makefile
> +++ linux-2.6/drivers/md/Makefile
> @@ -8,6 +8,7 @@ dm-multipath-y	+= dm-path-selector.o dm-
>  dm-snapshot-y	+= dm-snap.o dm-exception.o dm-exception-store.o \
>  		   dm-snap-transient.o dm-snap-persistent.o
>  dm-mirror-y	+= dm-raid1.o
> +dm-log-clustered-y += dm-log-cluster.o dm-log-cluster-transfer.o
>  md-mod-y	+= md.o bitmap.o
>  raid456-y	+= raid5.o
>  raid6_pq-y	+= raid6algos.o raid6recov.o raid6tables.o \
> @@ -38,6 +39,7 @@ obj-$(CONFIG_DM_DELAY)		+= dm-delay.o
>  obj-$(CONFIG_DM_MULTIPATH)	+= dm-multipath.o dm-round-robin.o
>  obj-$(CONFIG_DM_SNAPSHOT)	+= dm-snapshot.o
>  obj-$(CONFIG_DM_MIRROR)		+= dm-mirror.o dm-log.o dm-region-hash.o
> +obj-$(CONFIG_DM_LOG_CLUSTERED)	+= dm-log-clustered.o
>  obj-$(CONFIG_DM_ZERO)		+= dm-zero.o
>  
>  quiet_cmd_unroll = UNROLL  $@
> Index: linux-2.6/include/linux/dm-log-cluster.h
> ===================================================================
> --- /dev/null
> +++ linux-2.6/include/linux/dm-log-cluster.h
> @@ -0,0 +1,305 @@
> +/*
> + * Copyright (C) 2006-2009 Red Hat, Inc.
> + *
> + * This file is released under the LGPL.
> + */
> +
> +#ifndef __DM_LOG_CLUSTER_H__
> +#define __DM_LOG_CLUSTER_H__
> +
> +#include <linux/dm-ioctl.h> /* For DM_UUID_LEN */
> +
> +/*
> + * The device-mapper cluster log module consists of a kernel component and
> + * a user-space component.  The kernel component implements the API defined
> + * in dm-dirty-log.h.  Its purpose is to simply to pass the parameters and
> + * return values of those API functions between kernel and user-space.
> + *
> + * Below are defined the 'request_types' - DM_CLOG_CTR, DM_CLOG_DTR, etc.
> + * These request types represent the different functions in the device-mapper
> + * dirty log API.  Each of these is described in more detail below.
> + *
> + * The user-space program must listen for requests from the kernel (representing
> + * the various API functions) and process them in a cluster-coherent mannor.
> + * User-space begins by setting up the communication link (error checking
> + * removed for clarity):
> + *	fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR);
> + *	addr.nl_family = AF_NETLINK;
> + *	addr.nl_groups = CN_IDX_DM;
> + *	addr.nl_pid = 0;
> + *	r = bind(fd, (struct sockaddr *) &addr, sizeof(addr));
> + *	opt = addr.nl_groups;
> + *	setsockopt(fd, SOL_NETLINK, NETLINK_ADD_MEMBERSHIP, &opt, sizeof(opt));
> + *
> + * User-space will then wait to receive requests form the kernel, which it
> + * will process as described below.  The requests are received in the form,
> + * ((struct dm_clog_request) + (additional data)).
> + */
> +
> +/*
> + * DM_CLOG_CTR corresponds to (found in dm-dirty-log.h):
> + * int (*ctr)(struct dm_dirty_log *log, struct dm_target *ti,
> + *	      unsigned argc, char **argv);
> + *
> + * The payload data trailing the dm_clog_request structure is a string
> + * containing the argv arguments.  The UUID contained in the dm_clog_request
> + * structure is all that is necessary to identify the log instance.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_CTR                    1
> +
> +/*
> + * DM_CLOG_DTR corresponds to (found in dm-dirty-log.h):
> + * void (*dtr)(struct dm_dirty_log *log);
> + *
> + * The UUID contained in the dm_clog_request structure is all that is
> + * necessary to identify the log instance being destroyed.  There is no
> + * payload data.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_DTR                    2
> +
> +/*
> + * DM_CLOG_PRESUSPEND corresponds to (found in dm-dirty-log.h):
> + * int (*presuspend)(struct dm_dirty_log *log);
> + *
> + * The UUID contained in the dm_clog_request structure is all that is
> + * necessary to identify the log instance being presuspended.  There is no
> + * payload data.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_PRESUSPEND             3
> +
> +/*
> + * DM_CLOG_POSTSUSPEND corresponds to (found in dm-dirty-log.h):
> + * int (*postsuspend)(struct dm_dirty_log *log);
> + *
> + * The UUID contained in the dm_clog_request structure is all that is
> + * necessary to identify the log instance being postsuspended.  There is no
> + * payload data.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_POSTSUSPEND            4
> +
> +/*
> + * DM_CLOG_RESUME corresponds to (found in dm-dirty-log.h):
> + * int (*resume)(struct dm_dirty_log *log);
> + *
> + * The UUID contained in the dm_clog_request structure is all that is
> + * necessary to identify the log instance being resumed.  There is no
> + * payload data.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_RESUME                 5
> +
> +/*
> + * DM_CLOG_GET_REGION_SIZE corresponds to (found in dm-dirty-log.h):
> + * uint32_t (*get_region_size)(struct dm_dirty_log *log);
> + *
> + * The region size is something that was determined at constructor time.
> + * It is returned in the payload area and 'data_size' is set to
> + * reflect this.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field appropriately.
> + */
> +#define DM_CLOG_GET_REGION_SIZE        6
> +
> +/*
> + * DM_CLOG_IS_CLEAN corresponds to (found in dm-dirty-log.h):
> + * int (*is_clean)(struct dm_dirty_log *log, region_t region);
> + *
> + * Payload is sizeof(uint64_t) and contains the region for which the clean
> + * status is being made.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - filling the payload with 0 (not clean) or
> + * 1 (clean), setting 'data_size' and 'error' appropriately.
> + */
> +#define DM_CLOG_IS_CLEAN               7
> +
> +/*
> + * DM_CLOG_IN_SYNC corresponds to (found in dm-dirty-log.h):
> + * int (*in_sync)(struct dm_dirty_log *log, region_t region,
> + *		  int can_block);
> + *
> + * Exactly the same as 'is_clean' above, except this time asking "has the
> + * region been recovered?" vs. "is the region not being modified?"
> + */
> +#define DM_CLOG_IN_SYNC                8
> +
> +/*
> + * DM_CLOG_FLUSH corresponds to (found in dm-dirty-log.h):
> + * int (*flush)(struct dm_dirty_log *log);
> + *
> + * No incoming or outgoing payload.  Simply flush log state to disk.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_FLUSH                  9
> +
> +/*
> + * DM_CLOG_MARK_REGION corresponds to (found in dm-dirty-log.h):
> + * void (*mark_region)(struct dm_dirty_log *log, region_t region);
> + *
> + * Incoming payload contains the one or more regions to mark dirty.
> + * The number of regions contained in the payload can be determined from
> + * 'data_size/sizeof(uint64_t)'.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_MARK_REGION           10
> +
> +/*
> + * DM_CLOG_CLEAR_REGION corresponds to (found in dm-dirty-log.h):
> + * void (*clear_region)(struct dm_dirty_log *log, region_t region);
> + *
> + * Incoming payload contains the one or more regions to mark clean.
> + * The number of regions contained in the payload can be determined from
> + * 'data_size/sizeof(uint64_t)'.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_CLEAR_REGION          11
> +
> +/*
> + * DM_CLOG_GET_RESYNC_WORK corresponds to (found in dm-dirty-log.h):
> + * int (*get_resync_work)(struct dm_dirty_log *log, region_t *region);
> + *
> + * No incoming payload.  Kernel bound payload should contain:
> + *	{
> + *		int64_t i; -- 1 if recovery necessary, 0 otherwise
> + *		uint64_t r; -- The region to recover if i=1
> + *	}
> + * 'data_size' should be set appropriately.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field appropriately.
> + */
> +#define DM_CLOG_GET_RESYNC_WORK       12
> +
> +/*
> + * DM_CLOG_SET_REGION_SYNC corresponds to (found in dm-dirty-log.h):
> + * void (*set_region_sync)(struct dm_dirty_log *log,
> + *			   region_t region, int in_sync);
> + *
> + * Incoming payload is:
> + *	{
> + *		uint64_t r; -- The region to set sync status on
> + *		int64_t i;  -- 0 if out-of-sync, 1 if in-sync
> + *	}
> + * No kernel bound payload.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_SET_REGION_SYNC       13
> +
> +/*
> + * DM_CLOG_GET_SYNC_COUNT corresponds to (found in dm-dirty-log.h):
> + * region_t (*get_sync_count)(struct dm_dirty_log *log);
> + *
> + * No incoming payload.  Kernel-bound payload contains the number of
> + * regions that are in-sync (in a size_t).
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_GET_SYNC_COUNT        14
> +
> +/*
> + * DM_CLOG_STATUS_INFO corresponds to (found in dm-dirty-log.h):
> + * int (*status)(struct dm_dirty_log *log, STATUSTYPE_INFO,
> + *		 char *result, unsigned maxlen);
> + *
> + * No incoming payload.  Kernel-bound payload contains a string with
> + * the STATUSTYPE_INFO information.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_STATUS_INFO           15
> +
> +/*
> + * DM_CLOG_STATUS_TABLE corresponds to (found in dm-dirty-log.h):
> + * int (*status)(struct dm_dirty_log *log, STATUSTYPE_TABLE,
> + *		 char *result, unsigned maxlen);
> + *
> + * No incoming payload.  Kernel-bound payload contains a string with
> + * the STATUSTYPE_TABLE information.
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and clearing
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_STATUS_TABLE          16
> +
> +/*
> + * DM_CLOG_IS_REMOTE_RECOVERING corresponds to (found in dm-dirty-log.h):
> + * int (*is_remote_recovering)(struct dm_dirty_log *log, region_t region);
> + *
> + * Incoming payload is a uint64_t containing the region number being inquired
> + * about.  Kernel bound payload should contain:
> + *	{
> + *		int64_t is_recovering;  -- 0 if no, 1 if yes
> + *		uint64_t in_sync_hint;  -- lowest region still needing resync
> + *	}
> + *
> + * When the request has been processed, user-space must return the
> + * dm_clog_request to the kernel - setting the 'error' field and
> + * 'data_size' appropriately.
> + */
> +#define DM_CLOG_IS_REMOTE_RECOVERING  17
> +
> +/*
> + * (DM_CLOG_REQUEST_MASK & request_type) to get the request type
> + *
> + * We are reserving 8 bits of the 32-bit 'request_type' field for the
> + * various request types above.  The remaining 24-bits are currently
> + * set to zero and are reserved for future use and compatibility concerns.
> + *
> + * User-space should always use DM_CLOG_REQUEST_TYPE to aquire the
> + * request type from the 'request_type' field to maintain forward compatibility.
> + */
> +#define DM_CLOG_REQUEST_MASK 0xFF
> +#define DM_CLOG_REQUEST_TYPE(request_type) \
> +	(DM_CLOG_REQUEST_MASK & (request_type))
> +
> +struct dm_clog_request {
> +	char uuid[DM_UUID_LEN]; /* Ties a request to a specific mirror log */
> +	char padding[7];        /* Padding because DM_UUID_LEN = 129 */
> +
> +	int32_t error;          /* Used to report back processing errors */
> +
> +	uint32_t seq;           /* Sequence number for request */
> +	uint32_t request_type;  /* DM_CLOG_* defined above */
> +	uint32_t data_size;     /* How much data (not including this struct) */
> +
> +	char data[0];
> +};
> +
> +#endif /* __DM_LOG_CLUSTER_H__ */
> Index: linux-2.6/drivers/md/dm-log-cluster-transfer.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6/drivers/md/dm-log-cluster-transfer.c
> @@ -0,0 +1,273 @@
> +/*
> + * Copyright (C) 2006-2009 Red Hat, Inc.
> + *
> + * This file is released under the LGPL.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <net/sock.h>
> +#include <linux/workqueue.h>
> +#include <linux/connector.h>
> +#include <linux/device-mapper.h>
> +
> +#include <linux/dm-log-cluster.h>
> +#include "dm-log-cluster-transfer.h"
> +
> +static uint32_t dm_clog_seq;
> +
> +/*
> + * Netlink/Connector is an unreliable protocol.  How long should
> + * we wait for a response before assuming it was lost and retrying?
> + * (If we do receive a response after this time, it will be discarded
> + * and the response to the resent request will be waited for.
> + */
> +#define DM_CLOG_RETRY_TIMEOUT (15 * HZ)
> +
> +/*
> + * Pre-allocated space for speed
> + */
> +#define DM_CLOG_PREALLOCED_SIZE 512
> +static struct cn_msg *prealloced_cn_msg;
> +static struct dm_clog_request *prealloced_clog_tfr;
> +
> +static struct cb_id clog_cn_id = { .idx = CN_IDX_DM, .val = CN_VAL_DM_CLUSTER_LOG };
> +static DEFINE_MUTEX(dm_clog_lock);
> +
> +struct receiving_pkg {
> +	struct list_head list;
> +	struct completion complete;
> +
> +	uint32_t seq;
> +
> +	int error;
> +	size_t *data_size;
> +	char *data;
> +};
> +
> +static DEFINE_SPINLOCK(receiving_list_lock);
> +static struct list_head receiving_list;
> +
> +static int dm_clog_sendto_server(struct dm_clog_request *tfr)
> +{
> +	int r;
> +	struct cn_msg *msg = prealloced_cn_msg;
> +
> +	memset(msg, 0, sizeof(struct cn_msg));
> +
> +	msg->id.idx = clog_cn_id.idx;
> +	msg->id.val = clog_cn_id.val;
> +	msg->ack = 0;
> +	msg->seq = tfr->seq;
> +	msg->len = sizeof(struct dm_clog_request) + tfr->data_size;
> +
> +	r = cn_netlink_send(msg, 0, gfp_any());
> +
> +	return r;
> +}
> +
> +/*
> + * Parameters for this function can be either msg or tfr, but not
> + * both.  This function fills in the reply for a waiting request.
> + * If just msg is given, then the reply is simply an ACK from userspace
> + * that the request was received.
> + *
> + * Returns: 0 on success, -ENOENT on failure
> + */
> +static int fill_pkg(struct cn_msg *msg, struct dm_clog_request *tfr)
> +{
> +	uint32_t rtn_seq = (msg) ? msg->seq : (tfr) ? tfr->seq : 0;
> +	struct receiving_pkg *pkg;
> +
> +	/*
> +	 * The 'receiving_pkg' entries in this list are statically
> +	 * allocated on the stack in 'dm_clog_consult_server'.
> +	 * Each process that is waiting for a reply from the user
> +	 * space server will have an entry in this list.
> +	 *
> +	 * We are safe to do it this way because the stack space
> +	 * is unique to each process, but still addressable by
> +	 * other processes.
> +	 */
> +	list_for_each_entry(pkg, &receiving_list, list) {
> +		if (rtn_seq != pkg->seq)
> +			continue;
> +
> +		if (msg) {
> +			pkg->error = -msg->ack;
> +			/*
> +			 * If we are trying again, we will need to know our
> +			 * storage capacity.  Otherwise, along with the
> +			 * error code, we make explicit that we have no data.
> +			 */
> +			if (pkg->error != -EAGAIN)
> +				*(pkg->data_size) = 0;
> +		} else if (tfr->data_size > *(pkg->data_size)) {
> +			DMERR("Insufficient space to receive package [%u] "
> +			      "(%u vs %lu)", tfr->request_type,
> +			      tfr->data_size, *(pkg->data_size));
> +
> +			*(pkg->data_size) = 0;
> +			pkg->error = -ENOSPC;
> +		} else {
> +			pkg->error = tfr->error;
> +			memcpy(pkg->data, tfr->data, tfr->data_size);
> +			*(pkg->data_size) = tfr->data_size;
> +		}
> +		complete(&pkg->complete);
> +		return 0;
> +	}
> +
> +	return -ENOENT;
> +}
> +
> +/*
> + * This is the connector callback that delivers data
> + * that was sent from userspace.
> + */
> +static void cn_clog_callback(void *data)
> +{
> +	struct cn_msg *msg = (struct cn_msg *)data;
> +	struct dm_clog_request *tfr = (struct dm_clog_request *)(msg + 1);
> +
> +	spin_lock(&receiving_list_lock);
> +	if (msg->len == 0)
> +		fill_pkg(msg, NULL);
> +	else if (msg->len < sizeof(*tfr))
> +		DMERR("Incomplete message received (expected %u, got %u): [%u]",
> +		      (unsigned)sizeof(*tfr), msg->len, msg->seq);
> +	else
> +		fill_pkg(NULL, tfr);
> +	spin_unlock(&receiving_list_lock);
> +}
> +
> +/**
> + * dm_clog_consult_server
> + * @uuid: log's uuid (must be DM_UUID_LEN in size)
> + * @request_type:  found in include/linux/dm-log-cluster.h
> + * @data: data to tx to the server
> + * @data_size: size of data in bytes
> + * @rdata: place to put return data from server
> + * @rdata_size: value-result (amount of space given/amount of space used)
> + *
> + * rdata_size is undefined on failure.
> + *
> + * Memory used to communicate with userspace is zero'ed
> + * before populating to ensure that no unwanted bits leak
> + * from kernel space to user-space.  All cluster log communications
> + * between kernel and user space go through this function.
> + *
> + * Returns: 0 on success, -EXXX on failure
> + **/
> +int dm_clog_consult_server(const char *uuid, int request_type,
> +			   char *data, size_t data_size,
> +			   char *rdata, size_t *rdata_size)
> +{
> +	int r = 0;
> +	size_t dummy = 0;
> +	int overhead_size =
> +		sizeof(struct dm_clog_request *) + sizeof(struct cn_msg);
> +	struct dm_clog_request *tfr = prealloced_clog_tfr;
> +	struct receiving_pkg pkg;
> +
> +	if (data_size > (DM_CLOG_PREALLOCED_SIZE - overhead_size)) {
> +		DMINFO("Size of tfr exceeds preallocated size");
> +		return -EINVAL;
> +	}
> +
> +	if (!rdata_size)
> +		rdata_size = &dummy;
> +resend:
> +	/*
> +	 * We serialize the sending of requests so we can
> +	 * use the preallocated space.
> +	 */
> +	mutex_lock(&dm_clog_lock);
> +
> +	memset(tfr, 0, DM_CLOG_PREALLOCED_SIZE - overhead_size);
> +	memcpy(tfr->uuid, uuid, DM_UUID_LEN);
> +	tfr->seq = dm_clog_seq++;
> +
> +	/*
> +	 * Must be valid request type (all other bits set to
> +	 * zero).  This reserves other bits for possible future
> +	 * use.
> +	 */
> +	tfr->request_type = request_type & DM_CLOG_REQUEST_MASK;
> +
> +	tfr->data_size = data_size;
> +	if (data && data_size)
> +		memcpy(tfr->data, data, data_size);
> +
> +	memset(&pkg, 0, sizeof(pkg));
> +	init_completion(&pkg.complete);
> +	pkg.seq = tfr->seq;
> +	pkg.data_size = rdata_size;
> +	pkg.data = rdata;
> +	spin_lock(&receiving_list_lock);
> +	list_add(&(pkg.list), &receiving_list);
> +	spin_unlock(&receiving_list_lock);
> +
> +	r = dm_clog_sendto_server(tfr);
> +
> +	mutex_unlock(&dm_clog_lock);
> +
> +	if (r) {
> +		DMERR("Unable to send cluster log request [%u] to server: %d",
> +		      request_type, r);
> +		spin_lock(&receiving_list_lock);
> +		list_del_init(&(pkg.list));
> +		spin_unlock(&receiving_list_lock);
> +
> +		goto out;
> +	}
> +
> +	r = wait_for_completion_timeout(&(pkg.complete), DM_CLOG_RETRY_TIMEOUT);
> +	spin_lock(&receiving_list_lock);
> +	list_del_init(&(pkg.list));
> +	spin_unlock(&receiving_list_lock);
> +	if (!r) {
> +		DMWARN("[%s] Request timed out: [%u/%u] - retrying",
> +		       (strlen(uuid) > 8) ?
> +		       (uuid + (strlen(uuid) - 8)) : (uuid),
> +		       request_type, pkg.seq);
> +		goto resend;
> +	}
> +
> +	r = pkg.error;
> +	if (r == -EAGAIN)
> +		goto resend;
> +
> +out:
> +
> +	return r;
> +}
> +
> +int dm_clog_tfr_init(void)
> +{
> +	int r;
> +	void *prealloced;
> +
> +	INIT_LIST_HEAD(&receiving_list);
> +
> +	prealloced = kmalloc(DM_CLOG_PREALLOCED_SIZE, GFP_KERNEL);
> +	if (!prealloced)
> +		return -ENOMEM;
> +
> +	prealloced_cn_msg = prealloced;
> +	prealloced_clog_tfr = prealloced + sizeof(struct cn_msg);
> +
> +	r = cn_add_callback(&clog_cn_id, "clulog", cn_clog_callback);
> +	if (r) {
> +		cn_del_callback(&clog_cn_id);
> +		return r;
> +	}
> +
> +	return 0;
> +}
> +
> +void dm_clog_tfr_exit(void)
> +{
> +	cn_del_callback(&clog_cn_id);
> +	kfree(prealloced_cn_msg);
> +}
> Index: linux-2.6/drivers/md/dm-log-cluster-transfer.h
> ===================================================================
> --- /dev/null
> +++ linux-2.6/drivers/md/dm-log-cluster-transfer.h
> @@ -0,0 +1,18 @@
> +/*
> + * Copyright (C) 2006-2009 Red Hat, Inc.
> + *
> + * This file is released under the LGPL.
> + */
> +
> +#ifndef __DM_LOG_CLUSTER_TRANSFER_H__
> +#define __DM_LOG_CLUSTER_TRANSFER_H__
> +
> +#define DM_MSG_PREFIX "dm-log-clustered"
> +
> +int dm_clog_tfr_init(void);
> +void dm_clog_tfr_exit(void);
> +int dm_clog_consult_server(const char *uuid, int request_type,
> +			   char *data, size_t data_size,
> +			   char *rdata, size_t *rdata_size);
> +
> +#endif /* __DM_LOG_CLUSTER_TRANSFER_H__ */
> Index: linux-2.6/drivers/md/dm-log-cluster.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6/drivers/md/dm-log-cluster.c
> @@ -0,0 +1,757 @@
> +/*
> + * Copyright (C) 2006-2009 Red Hat, Inc.
> + *
> + * This file is released under the LGPL.
> + */
> +
> +#include <linux/bio.h>
> +#include <linux/dm-dirty-log.h>
> +#include <linux/device-mapper.h>
> +
> +#include <linux/dm-log-cluster.h>
> +#include "dm-log-cluster-transfer.h"
> +
> +struct flush_entry {
> +	int type;
> +	region_t region;
> +	struct list_head list;
> +};
> +
> +struct log_c {
> +	struct dm_target *ti;
> +	uint32_t region_size;
> +	region_t region_count;
> +	char uuid[DM_UUID_LEN];
> +
> +	char *ctr_str;
> +	uint32_t ctr_size;
> +
> +	/*
> +	 * in_sync_hint gets set when doing is_remote_recovering.  It
> +	 * represents the first region that needs recovery.  IOW, the
> +	 * first zero bit of sync_bits.  This can be useful for to limit
> +	 * traffic for calls like is_remote_recovering and get_resync_work,
> +	 * but be take care in its use for anything else.
> +	 */
> +	uint64_t in_sync_hint;
> +
> +	spinlock_t flush_lock;
> +	struct list_head flush_list;  /* only for clear and mark requests */
> +
> +	struct dm_dev *disk_log;
> +};
> +
> +static mempool_t *flush_entry_pool;
> +
> +static void *flush_entry_alloc(gfp_t gfp_mask, void *pool_data)
> +{
> +	return kmalloc(sizeof(struct flush_entry), gfp_mask);
> +}
> +
> +static void flush_entry_free(void *element, void *pool_data)
> +{
> +	kfree(element);
> +}
> +
> +int cluster_do_request(struct log_c *lc, const char *uuid, int request_type,
> +		       char *data, size_t data_size,
> +		       char *rdata, size_t *rdata_size)
> +{
> +	int r;
> +
> +	/*
> +	 * If the server isn't there, -ESRCH is returned,
> +	 * and we must keep trying until the server is
> +	 * restored.
> +	 */
> +retry:
> +	r = dm_clog_consult_server(uuid, request_type, data,
> +				   data_size, rdata, rdata_size);
> +
> +	if (r != -ESRCH)
> +		return r;
> +
> +	DMERR(" Userspace cluster log server not found.");
> +	while (1) {
> +		set_current_state(TASK_INTERRUPTIBLE);
> +		schedule_timeout(2*HZ);
> +		DMWARN("Attempting to contact cluster log server...");
> +		r = dm_clog_consult_server(uuid, DM_CLOG_CTR, lc->ctr_str,
> +					   lc->ctr_size, NULL, NULL);
> +		if (!r)
> +			break;
> +	}
> +	DMINFO("Reconnected to cluster log server... CTR complete");
> +	r = dm_clog_consult_server(uuid, DM_CLOG_RESUME, NULL,
> +				   0, NULL, NULL);
> +	if (!r)
> +		goto retry;
> +
> +	DMERR("Error trying to resume cluster log: %d", r);
> +
> +	return -ESRCH;
> +}
> +
> +static int build_constructor_string(struct dm_target *ti,
> +				    unsigned int argc, char **argv,
> +				    char **ctr_str)
> +{
> +	int i, str_size;
> +	char *str = NULL;
> +
> +	*ctr_str = NULL;
> +
> +	for (i = 0, str_size = 0; i < argc; i++)
> +		str_size += strlen(argv[i]) + 1; /* +1 for space between args */
> +
> +	str_size += 20; /* Max number of chars in a printed u64 number */
> +
> +	str = kzalloc(str_size, GFP_KERNEL);
> +	if (!str) {
> +		DMWARN("Unable to allocate memory for constructor string");
> +		return -ENOMEM;
> +	}
> +
> +	for (i = 0, str_size = 0; i < argc; i++)
> +		str_size += sprintf(str + str_size, "%s ", argv[i]);
> +	str_size += sprintf(str + str_size, "%llu",
> +			    (unsigned long long)ti->len);
> +
> +	*ctr_str = str;
> +	return str_size;
> +}
> +
> +static int cluster_ctr(struct dm_dirty_log *log, struct dm_target *ti,
> +		       unsigned int argc, char **argv,
> +		       struct dm_dev *disk_log)
> +{
> +	int r = 0;
> +	int str_size;
> +	int offset = (disk_log) ? 1 : 0;
> +	char *ctr_str = NULL;
> +	struct log_c *lc = NULL;
> +	uint32_t region_size;
> +	region_t region_count;
> +
> +	/* Already checked argument count */
> +
> +	if (sscanf(argv[offset], "%u", &region_size) != 1) {
> +		DMWARN("Invalid region size string");
> +		return -EINVAL;
> +	}
> +
> +	region_count = dm_sector_div_up(ti->len, region_size);
> +
> +	lc = kmalloc(sizeof(*lc), GFP_KERNEL);
> +	if (!lc) {
> +		DMWARN("Unable to allocate cluster log context.");
> +		return -ENOMEM;
> +	}
> +
> +	lc->ti = ti;
> +	lc->region_size = region_size;
> +	lc->region_count = region_count;
> +	lc->disk_log = disk_log;
> +
> +	if (strlen(argv[1 + offset]) > (DM_UUID_LEN - 1)) {
> +		DMWARN("UUID argument too long.");
> +		kfree(lc);
> +		return -EINVAL;
> +	}
> +
> +	strncpy(lc->uuid, argv[1 + offset], DM_UUID_LEN);
> +	spin_lock_init(&lc->flush_lock);
> +	INIT_LIST_HEAD(&lc->flush_list);
> +
> +	str_size = build_constructor_string(ti, argc, argv, &ctr_str);
> +	if (str_size < 0) {
> +		kfree(lc);
> +		return str_size;
> +	}
> +
> +	/* Send table string */
> +	r = dm_clog_consult_server(lc->uuid, DM_CLOG_CTR,
> +				   ctr_str, str_size, NULL, NULL);
> +
> +	if (r == -ESRCH)
> +		DMERR(" Userspace cluster log server not found");
> +
> +	if (r) {
> +		kfree(lc);
> +		kfree(ctr_str);
> +	} else {
> +		lc->ctr_str = ctr_str;
> +		lc->ctr_size = str_size;
> +		log->context = lc;
> +	}
> +
> +	return r;
> +}
> +
> +/*
> + * cluster_core_ctr
> + *
> + * argv contains:
> + *   <region_size> <uuid> [[no]sync]
> + *
> + * Returns: 0 on success, -XXX on failure
> + */
> +static int cluster_core_ctr(struct dm_dirty_log *log, struct dm_target *ti,
> +			    unsigned int argc, char **argv)
> +{
> +	int r;
> +	if ((argc < 2) || (argc > 3)) {
> +		DMERR("Too %s arguments to clustered-core mirror log type.",
> +		      (argc < 2) ? "few" : "many");
> +		return -EINVAL;
> +	}
> +
> +	r = cluster_ctr(log, ti, argc, argv, NULL);
> +
> +	return r;
> +}
> +
> +
> +/*
> + * cluster_core_ctr
> + *
> + * argv contains:
> + *   <disk> <region_size> <uuid> [[no]sync]
> + *
> + * Returns: 0 on success, -XXX on failure
> + */
> +static int cluster_disk_ctr(struct dm_dirty_log *log, struct dm_target *ti,
> +			    unsigned int argc, char **argv)
> +{
> +	int r;
> +	struct dm_dev *dev;
> +
> +	if ((argc < 3) || (argc > 4)) {
> +		DMERR("Too %s arguments to clustered-disk mirror log type.",
> +		      (argc < 3) ? "few" : "many");
> +		return -EINVAL;
> +	}
> +
> +	r = dm_get_device(ti, argv[0], 0, 0, FMODE_READ | FMODE_WRITE, &dev);
> +	if (r)
> +		return r;
> +
> +	r = cluster_ctr(log, ti, argc, argv, dev);
> +	if (r)
> +		dm_put_device(ti, dev);
> +
> +	return r;
> +}
> +
> +static void cluster_dtr(struct dm_dirty_log *log)
> +{
> +	int r;
> +	struct log_c *lc = log->context;
> +
> +	r = dm_clog_consult_server(lc->uuid, DM_CLOG_DTR,
> +				   NULL, 0,
> +				   NULL, NULL);
> +
> +	if (lc->disk_log)
> +		dm_put_device(lc->ti, lc->disk_log);
> +	kfree(lc->ctr_str);
> +	kfree(lc);
> +
> +	return;
> +}
> +
> +static int cluster_presuspend(struct dm_dirty_log *log)
> +{
> +	int r;
> +	struct log_c *lc = log->context;
> +
> +	r = dm_clog_consult_server(lc->uuid, DM_CLOG_PRESUSPEND,
> +				   NULL, 0,
> +				   NULL, NULL);
> +
> +	return r;
> +}
> +
> +static int cluster_postsuspend(struct dm_dirty_log *log)
> +{
> +	int r;
> +	struct log_c *lc = log->context;
> +
> +	r = dm_clog_consult_server(lc->uuid, DM_CLOG_POSTSUSPEND,
> +				   NULL, 0,
> +				   NULL, NULL);
> +
> +	return r;
> +}
> +
> +static int cluster_resume(struct dm_dirty_log *log)
> +{
> +	int r;
> +	struct log_c *lc = log->context;
> +
> +	lc->in_sync_hint = 0;
> +	r = dm_clog_consult_server(lc->uuid, DM_CLOG_RESUME,
> +				   NULL, 0,
> +				   NULL, NULL);
> +
> +	return r;
> +}
> +
> +static uint32_t cluster_get_region_size(struct dm_dirty_log *log)
> +{
> +	struct log_c *lc = log->context;
> +
> +	return lc->region_size;
> +}
> +
> +/*
> + * cluster_is_clean
> + *
> + * Check whether a region is clean.  If there is any sort of
> + * failure when consulting the server, we return not clean.
> + *
> + * Returns: 1 if clean, 0 otherwise
> + */
> +static int cluster_is_clean(struct dm_dirty_log *log, region_t region)
> +{
> +	int r;
> +	int is_clean;
> +	size_t rdata_size;
> +	struct log_c *lc = log->context;
> +
> +	rdata_size = sizeof(is_clean);
> +	r = cluster_do_request(lc, lc->uuid, DM_CLOG_IS_CLEAN,
> +			       (char *)&region, sizeof(region),
> +			       (char *)&is_clean, &rdata_size);
> +
> +	return (r) ? 0 : is_clean;
> +}
> +
> +/*
> + * cluster_in_sync
> + *
> + * Check if the region is in-sync.  If there is any sort
> + * of failure when consulting the server, we assume that
> + * the region is not in sync.
> + *
> + * If 'can_block' is set, return immediately
> + *
> + * Returns: 1 if in-sync, 0 if not-in-sync, -EWOULDBLOCK
> + */
> +static int cluster_in_sync(struct dm_dirty_log *log, region_t region,
> +			   int can_block)
> +{
> +	int r;
> +	int in_sync;
> +	size_t rdata_size;
> +	struct log_c *lc = log->context;
> +
> +	/*
> +	 * We can never respond directly - even if in_sync_hint is
> +	 * set.  This is because another machine could see a device
> +	 * failure and mark the region out-of-sync.  If we don't go
> +	 * to userspace to ask, we might think the region is in-sync
> +	 * and allow a read to pick up data that is stale.  (This is
> +	 * very unlikely if a device actually fails; but it is very
> +	 * likely if a connection to one device from one machine fails.)
> +	 *
> +	 * There still might be a problem if the mirror caches the region
> +	 * state as in-sync... but then this call would not be made.  So,
> +	 * that is a mirror problem.
> +	 */
> +	if (!can_block)
> +		return -EWOULDBLOCK;
> +
> +	rdata_size = sizeof(in_sync);
> +	r = cluster_do_request(lc, lc->uuid, DM_CLOG_IN_SYNC,
> +			       (char *)&region, sizeof(region),
> +			       (char *)&in_sync, &rdata_size);
> +	return (r) ? 0 : in_sync;
> +}
> +
> +/*
> + * cluster_flush
> + *
> + * This function is ok to block.
> + * The flush happens in two stages.  First, it sends all
> + * clear/mark requests that are on the list.  Then it
> + * tells the server to commit them.  This gives the
> + * server a chance to optimise the commit to the cluster
> + * and/or disk, instead of doing it for every request.
> + *
> + * Additionally, we could implement another thread that
> + * sends the requests up to the server - reducing the
> + * load on flush.  Then the flush would have less in
> + * the list and be responsible for the finishing commit.
> + *
> + * Returns: 0 on success, < 0 on failure
> + */
> +static int cluster_flush(struct dm_dirty_log *log)
> +{
> +	int r = 0;
> +	unsigned long flags;
> +	struct log_c *lc = log->context;
> +	LIST_HEAD(flush_list);
> +	struct flush_entry *fe, *tmp_fe;
> +
> +	spin_lock_irqsave(&lc->flush_lock, flags);
> +	list_splice_init(&lc->flush_list, &flush_list);
> +	spin_unlock_irqrestore(&lc->flush_lock, flags);
> +
> +	if (list_empty(&flush_list))
> +		return 0;
> +
> +	/*
> +	 * FIXME: Count up requests, group request types,
> +	 * allocate memory to stick all requests in and
> +	 * send to server in one go.  Failing the allocation,
> +	 * do it one by one.
> +	 */
> +
> +	list_for_each_entry(fe, &flush_list, list) {
> +		r = cluster_do_request(lc, lc->uuid, fe->type,
> +				       (char *)&fe->region,
> +				       sizeof(fe->region),
> +				       NULL, NULL);
> +		if (r)
> +			goto fail;
> +	}
> +
> +	r = cluster_do_request(lc, lc->uuid, DM_CLOG_FLUSH,
> +			       NULL, 0, NULL, NULL);
> +
> +fail:
> +	/*
> +	 * We can safely remove these entries, even if failure.
> +	 * Calling code will receive an error and will know that
> +	 * the log facility has failed.
> +	 */
> +	list_for_each_entry_safe(fe, tmp_fe, &flush_list, list) {
> +		list_del(&fe->list);
> +		mempool_free(fe, flush_entry_pool);
> +	}
> +
> +	if (r)
> +		dm_table_event(lc->ti->table);
> +
> +	return r;
> +}
> +
> +/*
> + * cluster_mark_region
> + *
> + * This function should avoid blocking unless absolutely required.
> + * (Memory allocation is valid for blocking.)
> + */
> +static void cluster_mark_region(struct dm_dirty_log *log, region_t region)
> +{
> +	unsigned long flags;
> +	struct log_c *lc = log->context;
> +	struct flush_entry *fe;
> +
> +	/* Wait for an allocation, but _never_ fail */
> +	fe = mempool_alloc(flush_entry_pool, GFP_NOIO);
> +	BUG_ON(!fe);
> +
> +	spin_lock_irqsave(&lc->flush_lock, flags);
> +	fe->type = DM_CLOG_MARK_REGION;
> +	fe->region = region;
> +	list_add(&fe->list, &lc->flush_list);
> +	spin_unlock_irqrestore(&lc->flush_lock, flags);
> +
> +	return;
> +}
> +
> +/*
> + * cluster_clear_region
> + *
> + * This function must not block.
> + * So, the alloc can't block.  In the worst case, it is ok to
> + * fail.  It would simply mean we can't clear the region.
> + * Does nothing to current sync context, but does mean
> + * the region will be re-sync'ed on a reload of the mirror
> + * even though it is in-sync.
> + */
> +static void cluster_clear_region(struct dm_dirty_log *log, region_t region)
> +{
> +	unsigned long flags;
> +	struct log_c *lc = log->context;
> +	struct flush_entry *fe;
> +
> +	/*
> +	 * If we fail to allocate, we skip the clearing of
> +	 * the region.  This doesn't hurt us in any way, except
> +	 * to cause the region to be resync'ed when the
> +	 * device is activated next time.
> +	 */
> +	fe = mempool_alloc(flush_entry_pool, GFP_ATOMIC);
> +	if (!fe) {
> +		DMERR("Failed to allocate memory to clear region.");
> +		return;
> +	}
> +
> +	spin_lock_irqsave(&lc->flush_lock, flags);
> +	fe->type = DM_CLOG_CLEAR_REGION;
> +	fe->region = region;
> +	list_add(&fe->list, &lc->flush_list);
> +	spin_unlock_irqrestore(&lc->flush_lock, flags);
> +
> +	return;
> +}
> +
> +/*
> + * cluster_get_resync_work
> + *
> + * Get a region that needs recovery.  It is valid to return
> + * an error for this function.
> + *
> + * Returns: 1 if region filled, 0 if no work, <0 on error
> + */
> +static int cluster_get_resync_work(struct dm_dirty_log *log, region_t *region)
> +{
> +	int r;
> +	size_t rdata_size;
> +	struct log_c *lc = log->context;
> +	struct {
> +		int64_t i; /* 64-bit for mix arch compatibility */
> +		region_t r;
> +	} pkg;
> +
> +	if (lc->in_sync_hint >= lc->region_count)
> +		return 0;
> +
> +	rdata_size = sizeof(pkg);
> +	r = cluster_do_request(lc, lc->uuid, DM_CLOG_GET_RESYNC_WORK,
> +			       NULL, 0,
> +			       (char *)&pkg, &rdata_size);
> +
> +	*region = pkg.r;
> +	return (r) ? r : (int)pkg.i;
> +}
> +
> +/*
> + * cluster_set_region_sync
> + *
> + * Set the sync status of a given region.  This function
> + * must not fail.
> + */
> +static void cluster_set_region_sync(struct dm_dirty_log *log,
> +				    region_t region, int in_sync)
> +{
> +	int r;
> +	struct log_c *lc = log->context;
> +	struct {
> +		region_t r;
> +		int64_t i;
> +	} pkg;
> +
> +	pkg.r = region;
> +	pkg.i = (int64_t)in_sync;
> +
> +	r = cluster_do_request(lc, lc->uuid, DM_CLOG_SET_REGION_SYNC,
> +			       (char *)&pkg, sizeof(pkg),
> +			       NULL, NULL);
> +
> +	/*
> +	 * It would be nice to be able to report failures.
> +	 * However, it is easy emough to detect and resolve.
> +	 */
> +	return;
> +}
> +
> +/*
> + * cluster_get_sync_count
> + *
> + * If there is any sort of failure when consulting the server,
> + * we assume that the sync count is zero.
> + *
> + * Returns: sync count on success, 0 on failure
> + */
> +static region_t cluster_get_sync_count(struct dm_dirty_log *log)
> +{
> +	int r;
> +	size_t rdata_size;
> +	region_t sync_count;
> +	struct log_c *lc = (struct log_c *)log->context;
> +
> +	rdata_size = sizeof(sync_count);
> +	r = cluster_do_request(lc, lc->uuid, DM_CLOG_GET_SYNC_COUNT,
> +			       NULL, 0,
> +			       (char *)&sync_count, &rdata_size);
> +
> +	if (r)
> +		return 0;
> +
> +	if (sync_count >= lc->region_count)
> +		lc->in_sync_hint = lc->region_count;
> +
> +	return sync_count;
> +}
> +
> +/*
> + * cluster_status
> + *
> + * Returns: amount of space consumed
> + */
> +static int cluster_status(struct dm_dirty_log *log, status_type_t status_type,
> +			  char *result, unsigned int maxlen)
> +{
> +	int r = 0;
> +	size_t sz = (size_t)maxlen;
> +	struct log_c *lc = log->context;
> +
> +	switch (status_type) {
> +	case STATUSTYPE_INFO:
> +		r = cluster_do_request(lc, lc->uuid, DM_CLOG_STATUS_INFO,
> +				       NULL, 0,
> +				       result, &sz);
> +		break;
> +	case STATUSTYPE_TABLE:
> +		r = cluster_do_request(lc, lc->uuid, DM_CLOG_STATUS_TABLE,
> +				       NULL, 0,
> +				       result, &sz);
> +		break;
> +	}
> +	return (r) ? 0 : (int)sz;
> +}
> +
> +/*
> + * cluster_is_remote_recovering
> + *
> + * Returns: 1 if region recovering, 0 otherwise
> + */
> +static int cluster_is_remote_recovering(struct dm_dirty_log *log,
> +					region_t region)
> +{
> +	int r;
> +	struct log_c *lc = log->context;
> +	static unsigned long long limit;
> +	struct {
> +		int64_t is_recovering;
> +		uint64_t in_sync_hint;
> +	} pkg;
> +	size_t rdata_size = sizeof(pkg);
> +
> +	/*
> +	 * Once the mirror has been reported to be in-sync,
> +	 * it will never again ask for recovery work.  So,
> +	 * we can safely say there is not a remote machine
> +	 * recovering if the device is in-sync.  (in_sync_hint
> +	 * must be reset at resume time.)
> +	 */
> +	if (region < lc->in_sync_hint)
> +		return 0;
> +	else if (jiffies < limit)
> +		return 1;
> +
> +	limit = jiffies + (HZ / 4);
> +	r = cluster_do_request(lc, lc->uuid, DM_CLOG_IS_REMOTE_RECOVERING,
> +			       (char *)&region, sizeof(region),
> +			       (char *)&pkg, &rdata_size);
> +	if (r)
> +		return 1;
> +
> +	lc->in_sync_hint = pkg.in_sync_hint;
> +
> +	return (int)pkg.is_recovering;
> +}
> +
> +static struct dm_dirty_log_type _clustered_core_type = {
> +	.name = "clustered-core",
> +	.module = THIS_MODULE,
> +	.ctr = cluster_core_ctr,
> +	.dtr = cluster_dtr,
> +	.presuspend = cluster_presuspend,
> +	.postsuspend = cluster_postsuspend,
> +	.resume = cluster_resume,
> +	.get_region_size = cluster_get_region_size,
> +	.is_clean = cluster_is_clean,
> +	.in_sync = cluster_in_sync,
> +	.flush = cluster_flush,
> +	.mark_region = cluster_mark_region,
> +	.clear_region = cluster_clear_region,
> +	.get_resync_work = cluster_get_resync_work,
> +	.set_region_sync = cluster_set_region_sync,
> +	.get_sync_count = cluster_get_sync_count,
> +	.status = cluster_status,
> +	.is_remote_recovering = cluster_is_remote_recovering,
> +};
> +
> +static struct dm_dirty_log_type _clustered_disk_type = {
> +	.name = "clustered-disk",
> +	.module = THIS_MODULE,
> +	.ctr = cluster_disk_ctr,
> +	.dtr = cluster_dtr,
> +	.presuspend = cluster_presuspend,
> +	.postsuspend = cluster_postsuspend,
> +	.resume = cluster_resume,
> +	.get_region_size = cluster_get_region_size,
> +	.is_clean = cluster_is_clean,
> +	.in_sync = cluster_in_sync,
> +	.flush = cluster_flush,
> +	.mark_region = cluster_mark_region,
> +	.clear_region = cluster_clear_region,
> +	.get_resync_work = cluster_get_resync_work,
> +	.set_region_sync = cluster_set_region_sync,
> +	.get_sync_count = cluster_get_sync_count,
> +	.status = cluster_status,
> +	.is_remote_recovering = cluster_is_remote_recovering,
> +};
> +
> +static int __init cluster_dirty_log_init(void)
> +{
> +	int r = 0;
> +
> +	flush_entry_pool = mempool_create(100, flush_entry_alloc,
> +					  flush_entry_free, NULL);
> +
> +	if (!flush_entry_pool) {
> +		DMWARN("Unable to create flush_entry_pool:  No memory.");
> +		return -ENOMEM;
> +	}
> +
> +	r = dm_clog_tfr_init();
> +	if (r) {
> +		DMWARN("Unable to initialize cluster log communications");
> +		mempool_destroy(flush_entry_pool);
> +		return r;
> +	}
> +
> +	r = dm_dirty_log_type_register(&_clustered_core_type);
> +	if (r) {
> +		DMWARN("Couldn't register clustered-core dirty log type");
> +		dm_clog_tfr_exit();
> +		mempool_destroy(flush_entry_pool);
> +		return r;
> +	}
> +
> +	r = dm_dirty_log_type_register(&_clustered_disk_type);
> +	if (r) {
> +		DMWARN("Couldn't register clustered-disk dirty log type");
> +		dm_dirty_log_type_unregister(&_clustered_core_type);
> +		dm_clog_tfr_exit();
> +		mempool_destroy(flush_entry_pool);
> +		return r;
> +	}
> +
> +	DMINFO("version 1.0.0 loaded");
> +	return 0;
> +}
> +
> +static void __exit cluster_dirty_log_exit(void)
> +{
> +	dm_dirty_log_type_unregister(&_clustered_disk_type);
> +	dm_dirty_log_type_unregister(&_clustered_core_type);
> +	dm_clog_tfr_exit();
> +	mempool_destroy(flush_entry_pool);
> +
> +	DMINFO("version 1.0.0 unloaded");
> +	return;
> +}
> +
> +module_init(cluster_dirty_log_init);
> +module_exit(cluster_dirty_log_exit);
> +
> +MODULE_DESCRIPTION(DM_NAME " cluster-aware dirty log");
> +MODULE_AUTHOR("Jonathan Brassow <dm-devel@redhat.com>");
> +MODULE_LICENSE("GPL");
> Index: linux-2.6/Documentation/dm-log.txt
> ===================================================================
> --- /dev/null
> +++ linux-2.6/Documentation/dm-log.txt
> @@ -0,0 +1,63 @@
> +Device-Mapper Logging
> +=====================
> +The device-mapper logging code is used by some of the device-mapper
> +RAID targets to track regions of the disk that are not consistent.
> +A region (or portion of the address space) of the disk may be
> +inconsistent because a RAID stripe is currently being operated on or
> +a machine died while the region was being altered.  In the case of
> +mirrors, a region would be considered dirty/inconsistent while you
> +are writing to it because the writes need to be replicated for all
> +the legs of the mirror and may not reach the legs at the same time.
> +Once all writes are complete, the region is considered clean again.
> +
> +There is a generic logging interface that the device-mapper RAID
> +implementations use to perform logging operations (see
> +dm_dirty_log_type in include/linux/dm-dirty-log.h).  Various different
> +logging implementations are available and provide different
> +capabilities.  The list includes:
> +
> +Type	       Files
> +====	       =====
> +disk	       drivers/md/dm-log.c
> +core	       drivers/md/dm-log.c
> +cluster-disk   drivers/md/dm-log-cluster* include/linux/dm-log-cluster.h
> +cluster-core   drivers/md/dm-log-cluster* include/linux/dm-log-cluster.h
> +
> +The "disk" log type
> +-------------------
> +This log implementation commits the log state to disk.  This way, the
> +logging state survives reboots/crashes.
> +
> +The "core" log type
> +-------------------
> +This log implementation keeps the log state in memory.  The log state
> +will not survive a reboot or crash, but there may be a small boost in
> +performance.  This method can also be used if no storage device is
> +available for storing log state.
> +
> +The "cluster-*" log types
> +-------------------------
> +These types operate in the same way as their single machine counterparts,
> +but they are cluster-aware.  This is done by forwarding most logging
> +requests to userspace, where a daemon processes the request in an ordered
> +fashion with the rest of the nodes in the cluster.  This is necessary to
> +prevent log state corruption.  (Imagine if two machines are writing to the
> +same region of a mirror.  They would both mark the region dirty, but you
> +need a cluster-aware entity that can handle properly marking the region
> +clean when they are done.  Otherwise, you might clear the region when the
> +first machine is done, not the second.)
> +
> +The structure used for communication between kernel and userspace are
> +located in include/linux/dm-log-cluster.h.  Due to the frequency,
> +diversity, and 2-way communication nature of the exchanges between
> +kernel and userspace, 'connector' is used as the interface for
> +communication.  One existing userspace implementation of the daemon
> +uses openAIS/corosync in order to communicate with guaranteed ordering
> +and delivery.  This daemon, which is capable of coherently managing log
> +state from multiple cluster machines, can be found in the LVM2 code
> +repository.  Other implementations with no association to LVM or
> +openAIS/corosync are certainly possible.
> +
> +Providing a cluster-aware logging type gives device-mapper RAID1 (and
> +potentially other RAIDs) the ability to operate in a cluster-aware
> +fashion.
> Index: linux-2.6/include/linux/connector.h
> ===================================================================
> --- linux-2.6.orig/include/linux/connector.h
> +++ linux-2.6/include/linux/connector.h
> @@ -41,8 +41,10 @@
>  #define CN_IDX_BB			0x5	/* BlackBoard, from the TSP GPL sampling framework */
>  #define CN_DST_IDX			0x6
>  #define CN_DST_VAL			0x1
> +#define CN_IDX_DM			0x7	/* Device Mapper */
> +#define CN_VAL_DM_CLUSTER_LOG		0x1
>  
> -#define CN_NETLINK_USERS		7
> +#define CN_NETLINK_USERS		8
>  
>  /*
>   * Maximum connector's message size.
> Index: linux-2.6/include/linux/Kbuild
> ===================================================================
> --- linux-2.6.orig/include/linux/Kbuild
> +++ linux-2.6/include/linux/Kbuild
> @@ -57,6 +57,7 @@ header-y += dlmconstants.h
>  header-y += dlm_device.h
>  header-y += dlm_netlink.h
>  header-y += dm-ioctl.h
> +header-y += dm-log-cluster.h
>  header-y += dn.h
>  header-y += dqblk_xfs.h
>  header-y += efs_fs_sb.h
> 
> 
> --
> dm-devel mailing list
> dm-devel@redhat.com
> https://www.redhat.com/mailman/listinfo/dm-devel
---end quoted text---
