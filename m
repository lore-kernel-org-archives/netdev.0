From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC 5/9] snet: introduce snet_event.c and snet_event.h
Date: Mon, 4 Jan 2010 13:08:54 -0600
Message-ID: <20100104190854.GD6034@us.ibm.com>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
 <1262437456-24476-6-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:55561 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804Ab0ADTIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 14:08:54 -0500
Content-Disposition: inline
In-Reply-To: <1262437456-24476-6-git-send-email-sam@synack.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Samir Bellabes (sam@synack.fr):
> This patch adds the snet's subsystem responsive of managing events
> 
> snet is using the word 'event' for a couple of values [syscall, protocol]. For
> example, [listen, tcp] or [sendmsg, dccp] are events.
> This patch introduces a hastable 'event_hash' and operations (add/remove/search..)
> in order to manage which events have to be protected.
> With the help of the communication's subsystem, managing orders are coming from
> userspace.
> 
> Signed-off-by: Samir Bellabes <sam@synack.fr>
> ---
>  security/snet/include/snet_event.h |   20 +++
>  security/snet/snet_event.c         |  229 ++++++++++++++++++++++++++++++++++++
>  2 files changed, 249 insertions(+), 0 deletions(-)
>  create mode 100644 security/snet/include/snet_event.h
>  create mode 100644 security/snet/snet_event.c
> 
> diff --git a/security/snet/include/snet_event.h b/security/snet/include/snet_event.h
> new file mode 100644
> index 0000000..2c71ca7
> --- /dev/null
> +++ b/security/snet/include/snet_event.h
> @@ -0,0 +1,20 @@
> +#ifndef _SNET_EVENT_H
> +#define _SNET_EVENT_H
> +#include <linux/skbuff.h>
> +
> +extern unsigned int event_hash_size;
> +
> +/* manipulate the events hash table */
> +int snet_event_fill_info(struct sk_buff *skb, struct netlink_callback *cb);
> +int snet_event_is_registered(const enum snet_syscall syscall, const u8 protocol);
> +int snet_event_insert(const enum snet_syscall syscall, const u8 protocol);
> +int snet_event_remove(const enum snet_syscall syscall, const u8 protocol);
> +void snet_event_flush(void);
> +void snet_event_dumpall(void);
> +
> +/* init function */
> +int snet_event_init(void);
> +/* exit funtion */
> +int snet_event_exit(void);
> +
> +#endif /* _SNET_EVENT_H */
> diff --git a/security/snet/snet_event.c b/security/snet/snet_event.c
> new file mode 100644
> index 0000000..6ac5646
> --- /dev/null
> +++ b/security/snet/snet_event.c
> @@ -0,0 +1,229 @@
> +#include <linux/spinlock.h>
> +#include <linux/list.h>
> +#include <linux/jhash.h>
> +#include <linux/slab.h>
> +#include <linux/netlink.h>
> +
> +#include "snet.h"
> +#include "snet_event.h"
> +#include "snet_netlink.h"
> +
> +static struct list_head *event_hash;
> +static rwlock_t event_hash_lock = __RW_LOCK_UNLOCKED();
> +
> +struct snet_event_entry {
> +	struct list_head list;
> +	struct snet_event se;
> +};
> +
> +/* lookup for a event_hash - before using this function, lock event_hash_lock */
> +static struct snet_event_entry *__snet_event_lookup(const enum snet_syscall syscall,
> +						   const u8 protocol)
> +{
> +	unsigned int h = 0;
> +	struct list_head *l;
> +	struct snet_event_entry *s;
> +	struct snet_event t;
> +
> +	if (!event_hash)
> +		return NULL;
> +
> +	/* building the element to look for */
> +	t.syscall = syscall;
> +	t.protocol = protocol;
> +
> +	/* computing its hash value */
> +	h = jhash(&t, sizeof(struct snet_event), 0) % event_hash_size;
> +	l = &event_hash[h];
> +
> +	list_for_each_entry(s, l, list) {
> +		if ((s->se.protocol == protocol) &&
> +		    (s->se.syscall == syscall)) {
> +			return s;
> +		}
> +	}
> +	return NULL;
> +}
> +
> +int snet_event_fill_info(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	unsigned int i = 0, n = 0;
> +	int ret = -1;
> +	unsigned hashs_to_skip = cb->args[0];
> +	unsigned events_to_skip = cb->args[1];
> +	struct list_head *l;
> +	struct snet_event_entry *s;
> +
> +	read_lock_bh(&event_hash_lock);
> +
> +	if (!event_hash)
> +		goto errout;
> +
> +	for (i = 0; i < event_hash_size; i++) {
> +		if (i < hashs_to_skip)
> +			continue;

What is this?

> +		l = &event_hash[i];
> +		n = 0;
> +		list_for_each_entry(s, l, list) {
> +			if (++n < events_to_skip)
> +				continue;
> +			ret = snet_nl_list_fill_info(skb,
> +						     NETLINK_CB(cb->skb).pid,
> +						     cb->nlh->nlmsg_seq,
> +						     NLM_F_MULTI,
> +						     s->se.protocol,
> +						     s->se.syscall);
> +			if (ret < 0)
> +				goto errout;

So if it returns 0, presumably meaning successfully handled, you
want to go on processing any duplicates?

> +		}
> +	}
> +
> +errout:
> +	read_unlock_bh(&event_hash_lock);
> +
> +	cb->args[0] = i;
> +	cb->args[1] = n;
> +	return skb->len;
> +}
> +
> +/* void snet_event_dumpall() */
> +/* { */
> +/*	unsigned int i = 0; */
> +/*	struct list_head *l; */
> +/*	struct snet_event_entry *s; */
> +
> +/*	snet_dbg("entering\n"); */
> +/*	read_lock_bh(&event_hash_lock); */
> +/*	for (i = 0; i < (event_hash_size - 1); i++) { */
> +/*		l = &hash[i]; */
> +/*		list_for_each_entry(s, l, list) { */
> +/*			snet_dbg("[%d, %d, %d]\n", i, */
> +/*				 s->se.protocol, s->se.syscall); */
> +/*		} */
> +/*	} */
> +/*	read_unlock_bh(&event_hash_lock); */
> +/*	snet_dbg("exiting\n"); */
> +/*	return; */
> +/* } */
> +
> +/*
> + * check if a event is registered or not
> + * return 1 if event is registered, 0 if not
> + */
> +int snet_event_is_registered(const enum snet_syscall syscall, const u8 protocol)
> +{
> +	int ret = 0;
> +
> +	read_lock_bh(&event_hash_lock);
> +	if (__snet_event_lookup(syscall, protocol) != NULL)
> +		ret = 1;
> +	read_unlock_bh(&event_hash_lock);
> +	return ret;
> +}
> +
> +/* adding a event */
> +int snet_event_insert(const enum snet_syscall syscall, const u8 protocol)
> +{
> +	struct snet_event_entry *data = NULL;
> +	unsigned int h = 0;
> +
> +	data = kzalloc(sizeof(struct snet_event_entry), GFP_KERNEL);
> +	if (!data)
> +		return -ENOMEM;
> +
> +	write_lock_bh(&event_hash_lock);
> +	/* check if event is already registered */
> +	if (!event_hash || __snet_event_lookup(syscall, protocol) != NULL) {
> +		write_unlock_bh(&event_hash_lock);
> +		kfree(data);
> +		return -EINVAL;

-EBUSY to help debugging?

> +	}
> +
> +	data->se.syscall = syscall;
> +	data->se.protocol = protocol;
> +	INIT_LIST_HEAD(&(data->list));
> +	h = jhash(&(data->se), sizeof(struct snet_event), 0) % event_hash_size;
> +	list_add_tail(&data->list, &event_hash[h]);
> +	write_unlock_bh(&event_hash_lock);
> +
> +	return 0;
> +}
> +
> +/* removing a event */
> +int snet_event_remove(const enum snet_syscall syscall, const u8 protocol)
> +{
> +	struct snet_event_entry *data = NULL;
> +
> +	write_lock_bh(&event_hash_lock);
> +	data = __snet_event_lookup(syscall, protocol);
> +	if (data == NULL) {
> +		write_unlock_bh(&event_hash_lock);
> +		return -EINVAL;
> +	}
> +
> +	list_del(&data->list);
> +	write_unlock_bh(&event_hash_lock);
> +	kfree(data);
> +	return 0;
> +}
> +
> +/* flushing all events */
> +void __snet_event_flush(void)
> +{
> +	struct snet_event_entry *data = NULL;
> +	unsigned int i = 0;
> +
> +	for (i = 0; i < event_hash_size; i++) {
> +		while (!list_empty(&event_hash[i])) {
> +			data = list_entry(event_hash[i].next,
> +					  struct snet_event_entry, list);
> +			list_del(&data->list);
> +			kfree(data);
> +		}
> +	}
> +	return;
> +}
> +
> +void snet_event_flush(void)
> +{
> +	write_lock_bh(&event_hash_lock);
> +	if (event_hash)
> +		__snet_event_flush();
> +	write_unlock_bh(&event_hash_lock);
> +	return;
> +}
> +
> +/* init function */
> +int snet_event_init(void)
> +{
> +	int err = 0, i = 0;
> +
> +	event_hash = kzalloc(sizeof(struct list_head) * event_hash_size,
> +			     GFP_KERNEL);
> +	if (!event_hash) {
> +		printk(KERN_WARNING
> +		       "snet: can't alloc memory for event_hash\n");
> +		err = -ENOMEM;
> +		goto out;
> +	}
> +
> +	for (i = 0; i < event_hash_size; i++)
> +		INIT_LIST_HEAD(&(event_hash[i]));
> +
> +out:
> +	return err;
> +}
> +
> +/* exit function */
> +int snet_event_exit(void)
> +{
> +	write_lock_bh(&event_hash_lock);
> +	if (event_hash) {
> +		__snet_event_flush();
> +		kfree(event_hash);
> +		event_hash = NULL;
> +	}
> +	write_unlock_bh(&event_hash_lock);
> +
> +	return 0;
> +}
> -- 
> 1.6.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
