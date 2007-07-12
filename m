From: Mike Anderson <andmike@us.ibm.com>
Subject: Re: [2.6.23 PATCH 14/18] dm: netlink add to core
Date: Wed, 11 Jul 2007 17:40:38 -0700
Message-ID: <20070712004038.GB29241@us.ibm.com>
References: <20070711210159.GF24114@agk.fab.redhat.com>
	<20070711143423.36722a41.akpm@linux-foundation.org>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dm-devel@redhat.com,
	linux-kernel@vger.kernel.org, Alasdair G Kergon <agk@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20070711143423.36722a41.akpm@linux-foundation.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 11 Jul 2007 22:01:59 +0100
> Alasdair G Kergon <agk@redhat.com> wrote:
> 
> > From: Mike Anderson <andmike@us.ibm.com>
> > 
> > This patch adds support for the dm_path_event dm_send_event funtions which
> > create and send netlink attribute events.
> > 
> > ...
> >
> > --- linux.orig/drivers/md/dm-netlink.c	2007-07-11 21:37:50.000000000 +0100
> > +++ linux/drivers/md/dm-netlink.c	2007-07-11 21:37:51.000000000 +0100
> > @@ -40,6 +40,17 @@ struct dm_event_cache {
> >  
> >  static struct dm_event_cache _dme_cache;
> >  
> > +struct dm_event {
> > +        struct dm_event_cache *cdata;
> > +        struct mapped_device *md;
> > +        struct sk_buff *skb;
> > +        struct list_head elist;
> > +};
> > +
> > +static struct sock *_dm_netlink_sock;
> > +static uint32_t _dm_netlink_daemon_pid;
> > +static DEFINE_SPINLOCK(_dm_netlink_pid_lock);
> 
> The usage of this lock makes my head spin a bit.  It's a shame it wasn't
> documented.
> 
> There's obviously something very significant happening with process IDs in
> here.  A description of the design would be helpful.  Especially for the
> containerisation guys who no doubt will need to tear their hair out over it
> all ;)
> 

ok, answered below.

> 
> > +static int dm_netlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> > +{
> > +	int r = 0;
> > +
> > +	if (security_netlink_recv(skb, CAP_SYS_ADMIN))
> > +		return -EPERM;
> > +
> > +	spin_lock(&_dm_netlink_pid_lock);
> > +	if (_dm_netlink_daemon_pid) {
> > +		if (_dm_netlink_daemon_pid != nlh->nlmsg_pid)
> > +			r = -EBUSY;
> > +	} else
> > +		_dm_netlink_daemon_pid = nlh->nlmsg_pid;
> > +	spin_unlock(&_dm_netlink_pid_lock);
> > +
> > +	return r;
> > +}
> 
> This really does need some comments.  nfi what it's all trying to do here.
> 

The code is restricting the connection to only one daemon.

I added the lock above as in some testing of connect / disconnect cycles
with a lot of events I receiving errors.

The pid is a hold over from older code. If this will cause issue for other
users I can switch to using nlmsg_multicast (genlmsg_multicast depending
on the comment if I need to switch to the genl interface) and remove this
code all together.

> > +static void dm_netlink_rcv(struct sock *sk, int len)
> > +{
> > +	unsigned qlen = 0;
> 
> stupid gcc.
> 
> > +
> > +	do
> > +		netlink_run_queue(sk, &qlen, &dm_netlink_rcv_msg);
> > +	while (qlen);
> > +
> > +}
> 
> stray blank line there.
> 

ok, removed.

> > +static int dm_netlink_rcv_event(struct notifier_block *this,
> > +				unsigned long event, void *ptr)
> > +{
> > +	struct netlink_notify *n = ptr;
> > +
> > +	spin_lock(&_dm_netlink_pid_lock);
> > +
> > +	if (event == NETLINK_URELEASE &&
> > +	    n->protocol == NETLINK_DM && n->pid &&
> > +	    n->pid == _dm_netlink_daemon_pid)
> > +		_dm_netlink_daemon_pid = 0;
> > +
> > +	spin_unlock(&_dm_netlink_pid_lock);
> > +
> > +	return NOTIFY_DONE;
> > +}
> > +
> > +static struct notifier_block dm_netlink_notifier = {
> > +	.notifier_call  = dm_netlink_rcv_event,
> > +};
> > +
> >  int __init dm_netlink_init(void)
> >  {
> >  	int r;
> >  
> > +	r = netlink_register_notifier(&dm_netlink_notifier);
> > +	if (r)
> > +		return r;
> > +
> > +	_dm_netlink_sock = netlink_kernel_create(NETLINK_DM, 0,
> > +						 dm_netlink_rcv, NULL,
> > +						 THIS_MODULE);
> 
> I think we're supposed to use the genetlink APIs here.  One for the net
> guys to check, please.
> 
ok, I can switch if that is the new recommended method.

> > +	if (!_dm_netlink_sock) {
> > +		r = -ENOBUFS;
> > +		goto notifier_out;
> > +	}
> >  	r = dme_cache_init(&_dme_cache, DM_EVENT_SKB_SIZE);
> > -	if (!r)
> > -		DMINFO("version 1.0.0 loaded");
> > +	if (r)
> > +		goto socket_out;
> > +
> > +	DMINFO("version 1.0.0 loaded");
> > +
> > +	return 0;
> > +
> > +socket_out:
> > +	sock_release(_dm_netlink_sock->sk_socket);
> > +notifier_out:
> > +	netlink_unregister_notifier(&dm_netlink_notifier);
> > +	DMERR("%s: dme_cache_init failed: %d", __FUNCTION__, r);
> >  
> >  	return r;
> >  }
> > @@ -100,4 +292,6 @@ int __init dm_netlink_init(void)
> >  void dm_netlink_exit(void)
> >  {
> >  	dme_cache_destroy(&_dme_cache);
> > +	sock_release(_dm_netlink_sock->sk_socket);
> > +	netlink_unregister_notifier(&dm_netlink_notifier);
> >  }
> > Index: linux/drivers/md/dm-netlink.h
> > ===================================================================
> > --- linux.orig/drivers/md/dm-netlink.h	2007-07-11 21:37:50.000000000 +0100
> > +++ linux/drivers/md/dm-netlink.h	2007-07-11 21:37:51.000000000 +0100
> > @@ -21,19 +21,22 @@
> >  #ifndef DM_NETLINK_H
> >  #define DM_NETLINK_H
> >  
> > -struct dm_event_cache;
> > +#include <linux/dm-netlink-if.h>
> > +
> > +struct dm_table;
> >  struct mapped_device;
> > -struct dm_event {
> > -	struct dm_event_cache *cdata;
> > -	struct mapped_device *md;
> > -	struct sk_buff *skb;
> > -	struct list_head elist;
> > -};
> > +struct dm_event;
> > +
> > +void dm_event_add(struct mapped_device *md, struct list_head *elist);
> >  
> >  #ifdef CONFIG_DM_NETLINK
> >  
> >  int dm_netlink_init(void);
> >  void dm_netlink_exit(void);
> > +void dm_netlink_send_events(struct list_head *events);
> > +
> > +void dm_path_event(enum dm_netlink_event_type evt_type, struct dm_table *t,
> > +                   const char *path, int nr_valid_paths);
> >  
> >  #else	/* CONFIG_DM_NETLINK */
> >  
> > @@ -44,6 +47,14 @@ static inline int __init dm_netlink_init
> >  static inline void dm_netlink_exit(void)
> >  {
> >  }
> > +static void inline dm_netlink_send_events(struct list_head *events)
> > +{
> > +}
> > +static void inline dm_path_event(enum dm_netlink_event_type evt_type,
> > +			  struct dm_table *t, const char *path,
> > +			  int nr_valid_paths)
> > +{
> > +}
> 
> Please use `static inline void', not `static void inline'.  Just a
> consistency thing.
> 

Done.

-andmike
--
Michael Anderson
andmike@us.ibm.com
