From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [RFC 5/9] snet: introduce snet_event.c and snet_event.h
Date: Sat, 2 Jan 2010 23:09:00 +0300
Message-ID: <20100102200900.GA27402@ioremap.net>
References: <1262437456-24476-1-git-send-email-sam@synack.fr> <1262437456-24476-6-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1262437456-24476-6-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Sat, Jan 02, 2010 at 02:04:12PM +0100, Samir Bellabes (sam@synack.fr) wrote:
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

> +
> +extern unsigned int event_hash_size;
> +

> +
> +static struct list_head *event_hash;
> +static rwlock_t event_hash_lock = __RW_LOCK_UNLOCKED();
> +

Those are way too generic names, please use snet_ prefix as you did in
other places.


I believe snet should be converted to RCU instead of rw locks.

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

You can have better distribution if not simply cut off the remainder.
Also it is a rather expensive operation.

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

Below comments looks a little bit weird, was it generated automatically
by editor?

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
> +	}

What about single error exiting point?

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

No need for double braces.

-- 
	Evgeniy Polyakov
