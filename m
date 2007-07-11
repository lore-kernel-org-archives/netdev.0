From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.23 PATCH 14/18] dm: netlink add to core
Date: Wed, 11 Jul 2007 14:34:23 -0700
Message-ID: <20070711143423.36722a41.akpm@linux-foundation.org>
References: <20070711210159.GF24114@agk.fab.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dm-devel@redhat.com, linux-kernel@vger.kernel.org,
	Mike Anderson <andmike@us.ibm.com>, netdev@vger.kernel.org
To: Alasdair G Kergon <agk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43800 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755206AbXGKVes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 17:34:48 -0400
In-Reply-To: <20070711210159.GF24114@agk.fab.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 22:01:59 +0100
Alasdair G Kergon <agk@redhat.com> wrote:

> From: Mike Anderson <andmike@us.ibm.com>
> 
> This patch adds support for the dm_path_event dm_send_event funtions which
> create and send netlink attribute events.
> 
> ...
>
> --- linux.orig/drivers/md/dm-netlink.c	2007-07-11 21:37:50.000000000 +0100
> +++ linux/drivers/md/dm-netlink.c	2007-07-11 21:37:51.000000000 +0100
> @@ -40,6 +40,17 @@ struct dm_event_cache {
>  
>  static struct dm_event_cache _dme_cache;
>  
> +struct dm_event {
> +        struct dm_event_cache *cdata;
> +        struct mapped_device *md;
> +        struct sk_buff *skb;
> +        struct list_head elist;
> +};
> +
> +static struct sock *_dm_netlink_sock;
> +static uint32_t _dm_netlink_daemon_pid;
> +static DEFINE_SPINLOCK(_dm_netlink_pid_lock);

The usage of this lock makes my head spin a bit.  It's a shame it wasn't
documented.

There's obviously something very significant happening with process IDs in
here.  A description of the design would be helpful.  Especially for the
containerisation guys who no doubt will need to tear their hair out over it
all ;)


> +static int dm_netlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> +{
> +	int r = 0;
> +
> +	if (security_netlink_recv(skb, CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	spin_lock(&_dm_netlink_pid_lock);
> +	if (_dm_netlink_daemon_pid) {
> +		if (_dm_netlink_daemon_pid != nlh->nlmsg_pid)
> +			r = -EBUSY;
> +	} else
> +		_dm_netlink_daemon_pid = nlh->nlmsg_pid;
> +	spin_unlock(&_dm_netlink_pid_lock);
> +
> +	return r;
> +}

This really does need some comments.  nfi what it's all trying to do here.

> +static void dm_netlink_rcv(struct sock *sk, int len)
> +{
> +	unsigned qlen = 0;

stupid gcc.

> +
> +	do
> +		netlink_run_queue(sk, &qlen, &dm_netlink_rcv_msg);
> +	while (qlen);
> +
> +}

stray blank line there.

> +static int dm_netlink_rcv_event(struct notifier_block *this,
> +				unsigned long event, void *ptr)
> +{
> +	struct netlink_notify *n = ptr;
> +
> +	spin_lock(&_dm_netlink_pid_lock);
> +
> +	if (event == NETLINK_URELEASE &&
> +	    n->protocol == NETLINK_DM && n->pid &&
> +	    n->pid == _dm_netlink_daemon_pid)
> +		_dm_netlink_daemon_pid = 0;
> +
> +	spin_unlock(&_dm_netlink_pid_lock);
> +
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block dm_netlink_notifier = {
> +	.notifier_call  = dm_netlink_rcv_event,
> +};
> +
>  int __init dm_netlink_init(void)
>  {
>  	int r;
>  
> +	r = netlink_register_notifier(&dm_netlink_notifier);
> +	if (r)
> +		return r;
> +
> +	_dm_netlink_sock = netlink_kernel_create(NETLINK_DM, 0,
> +						 dm_netlink_rcv, NULL,
> +						 THIS_MODULE);

I think we're supposed to use the genetlink APIs here.  One for the net
guys to check, please.

> +	if (!_dm_netlink_sock) {
> +		r = -ENOBUFS;
> +		goto notifier_out;
> +	}
>  	r = dme_cache_init(&_dme_cache, DM_EVENT_SKB_SIZE);
> -	if (!r)
> -		DMINFO("version 1.0.0 loaded");
> +	if (r)
> +		goto socket_out;
> +
> +	DMINFO("version 1.0.0 loaded");
> +
> +	return 0;
> +
> +socket_out:
> +	sock_release(_dm_netlink_sock->sk_socket);
> +notifier_out:
> +	netlink_unregister_notifier(&dm_netlink_notifier);
> +	DMERR("%s: dme_cache_init failed: %d", __FUNCTION__, r);
>  
>  	return r;
>  }
> @@ -100,4 +292,6 @@ int __init dm_netlink_init(void)
>  void dm_netlink_exit(void)
>  {
>  	dme_cache_destroy(&_dme_cache);
> +	sock_release(_dm_netlink_sock->sk_socket);
> +	netlink_unregister_notifier(&dm_netlink_notifier);
>  }
> Index: linux/drivers/md/dm-netlink.h
> ===================================================================
> --- linux.orig/drivers/md/dm-netlink.h	2007-07-11 21:37:50.000000000 +0100
> +++ linux/drivers/md/dm-netlink.h	2007-07-11 21:37:51.000000000 +0100
> @@ -21,19 +21,22 @@
>  #ifndef DM_NETLINK_H
>  #define DM_NETLINK_H
>  
> -struct dm_event_cache;
> +#include <linux/dm-netlink-if.h>
> +
> +struct dm_table;
>  struct mapped_device;
> -struct dm_event {
> -	struct dm_event_cache *cdata;
> -	struct mapped_device *md;
> -	struct sk_buff *skb;
> -	struct list_head elist;
> -};
> +struct dm_event;
> +
> +void dm_event_add(struct mapped_device *md, struct list_head *elist);
>  
>  #ifdef CONFIG_DM_NETLINK
>  
>  int dm_netlink_init(void);
>  void dm_netlink_exit(void);
> +void dm_netlink_send_events(struct list_head *events);
> +
> +void dm_path_event(enum dm_netlink_event_type evt_type, struct dm_table *t,
> +                   const char *path, int nr_valid_paths);
>  
>  #else	/* CONFIG_DM_NETLINK */
>  
> @@ -44,6 +47,14 @@ static inline int __init dm_netlink_init
>  static inline void dm_netlink_exit(void)
>  {
>  }
> +static void inline dm_netlink_send_events(struct list_head *events)
> +{
> +}
> +static void inline dm_path_event(enum dm_netlink_event_type evt_type,
> +			  struct dm_table *t, const char *path,
> +			  int nr_valid_paths)
> +{
> +}

Please use `static inline void', not `static void inline'.  Just a
consistency thing.

>  #endif	/* CONFIG_DM_NETLINK */
>  
> Index: linux/drivers/md/dm.c
> ===================================================================
> --- linux.orig/drivers/md/dm.c	2007-07-11 21:37:50.000000000 +0100
> +++ linux/drivers/md/dm.c	2007-07-11 21:37:51.000000000 +0100
> @@ -111,8 +111,11 @@ struct mapped_device {
>  	/*
>  	 * Event handling.
>  	 */
> +	atomic_t event_seq;	/* Used for netlink events */
>  	atomic_t event_nr;
>  	wait_queue_head_t eventq;
> +	struct list_head event_list;
> +	spinlock_t event_lock;
>  
>  	/*
>  	 * freeze/thaw support require holding onto a super block
> @@ -1001,6 +1004,9 @@ static struct mapped_device *alloc_dev(i
>  	atomic_set(&md->holders, 1);
>  	atomic_set(&md->open_count, 0);
>  	atomic_set(&md->event_nr, 0);
> +	atomic_set(&md->event_seq, 0);
> +	INIT_LIST_HEAD(&md->event_list);
> +	spin_lock_init(&md->event_lock);
>  
>  	md->queue = blk_alloc_queue(GFP_KERNEL);
>  	if (!md->queue)
> @@ -1099,6 +1105,14 @@ static void free_dev(struct mapped_devic
>  static void event_callback(void *context)
>  {
>  	struct mapped_device *md = (struct mapped_device *) context;
> +	unsigned long flags;
> +	LIST_HEAD(events);
> +
> +	spin_lock_irqsave(&md->event_lock, flags);
> +	list_splice_init(&md->event_list, &events);
> +	spin_unlock_irqrestore(&md->event_lock, flags);
> +
> +	dm_netlink_send_events(&events);
>  
>  	atomic_inc(&md->event_nr);
>  	wake_up(&md->eventq);
> @@ -1516,6 +1530,11 @@ out:
>  /*-----------------------------------------------------------------
>   * Event notification.
>   *---------------------------------------------------------------*/
> +uint32_t dm_next_event_seq(struct mapped_device *md)
> +{
> +	return atomic_add_return(1, &md->event_seq);
> +}
> +
>  uint32_t dm_get_event_nr(struct mapped_device *md)
>  {
>  	return atomic_read(&md->event_nr);
> @@ -1527,6 +1546,15 @@ int dm_wait_event(struct mapped_device *
>  			(event_nr != atomic_read(&md->event_nr)));
>  }
>  
> +void dm_event_add(struct mapped_device *md, struct list_head *elist)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&md->event_lock, flags);
> +	list_add(elist, &md->event_list);
> +	spin_unlock_irqrestore(&md->event_lock, flags);
> +}
> +
>
> ...
>
> +/*
> + * Device Mapper Netlink Interface
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
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
> + *
> + * Copyright IBM Corporation, 2005, 2006
> + * 	Author: Mike Anderson <andmike@us.ibm.com>
> + */
> +#ifndef _LINUX_DM_NETLINK_IF_H
> +#define _LINUX_DM_NETLINK_IF_H
> +
> +#include <linux/netlink.h>
> +
> +/*
> + * Single netlink message type used for all DM events
> + */
> +#define DM_EVENT_MSG NLMSG_MIN_TYPE + 1
> +
> +enum dm_netlink_event_type {
> +	DM_EVENT_PATH_FAILED = 1,
> +	DM_EVENT_PATH_REINSTATED = 2,
> +	DM_EVENT_MAX,
> +};
> +
> +enum dm_netlink_event_attr {
> +	DM_EVENT_ATTR_SEQNUM		= 1,	/* Sequence number */
> +	DM_EVENT_ATTR_TSSEC		= 2,	/* Time Stamp seconds */
> +	DM_EVENT_ATTR_TSUSEC		= 3,	/* Time Stamp micro seconds */
> +	DM_EVENT_ATTR_NAME		= 4,	/* Major:Minor */
> +						/* 5 is deprecated */
> +	DM_EVENT_ATTR_NUM_VALID_PATHS	= 6,	/* (Multipath) */
> +	DM_EVENT_ATTR_PATH		= 7,	/* (Multipath) Pathname */
> +	DM_EVENT_ATTR_MAX,
> +};
> +
> +#define DM_EVENT_IF_VERSION 0x10
> +
> +struct dm_netlink_msghdr {
> +	uint16_t type;
> +	uint16_t version;
> +	uint16_t reserved1;
> +	uint16_t reserved2;
> +} __attribute__((aligned(sizeof(uint64_t))));
> +
> +#endif	/* _LINUX_DM_NETLINK_IF_H */
