From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH 2/3] xen: modify xenstore watch event interface
Date: Fri, 6 Jan 2017 15:38:31 +0000
Message-ID: <20e9b6ff85a740b89390c6af956b8c96@AMSPEX02CL03.citrite.net>
References: <20170106150544.10836-1-jgross@suse.com>
 <20170106150544.10836-3-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
        "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
        Roger Pau Monne <roger.pau@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Juergen Gross <jgross@suse.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:44372 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdAFPie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 10:38:34 -0500
In-Reply-To: <20170106150544.10836-3-jgross@suse.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Juergen Gross [mailto:jgross@suse.com]
> Sent: 06 January 2017 15:06
> To: linux-kernel@vger.kernel.org; xen-devel@lists.xenproject.org
> Cc: boris.ostrovsky@oracle.com; Juergen Gross <jgross@suse.com>;
> konrad.wilk@oracle.com; Roger Pau Monne <roger.pau@citrix.com>; Wei Liu
> <wei.liu2@citrix.com>; Paul Durrant <Paul.Durrant@citrix.com>;
> netdev@vger.kernel.org
> Subject: [PATCH 2/3] xen: modify xenstore watch event interface
> 
> Today a Xenstore watch event is delivered via a callback function
> declared as:
> 
> void (*callback)(struct xenbus_watch *,
>                  const char **vec, unsigned int len);
> 
> As all watch events only ever come with two parameters (path and token)
> changing the prototype to:
> 
> void (*callback)(struct xenbus_watch *,
>                  const char *path, const char *token);
> 
> is the natural thing to do.
> 
> Apply this change and adapt all users.
> 
> Cc: konrad.wilk@oracle.com
> Cc: roger.pau@citrix.com
> Cc: wei.liu2@citrix.com
> Cc: paul.durrant@citrix.com
> Cc: netdev@vger.kernel.org
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>

xen-netback changes...

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> ---
>  drivers/block/xen-blkback/xenbus.c         |  6 +++---
>  drivers/net/xen-netback/xenbus.c           |  8 ++++----
>  drivers/xen/cpu_hotplug.c                  |  5 ++---
>  drivers/xen/manage.c                       |  6 +++---
>  drivers/xen/xen-balloon.c                  |  2 +-
>  drivers/xen/xen-pciback/xenbus.c           |  2 +-
>  drivers/xen/xenbus/xenbus.h                |  6 +++---
>  drivers/xen/xenbus/xenbus_client.c         |  4 ++--
>  drivers/xen/xenbus/xenbus_dev_frontend.c   | 21 ++++++++-------------
>  drivers/xen/xenbus/xenbus_probe.c          | 11 ++++-------
>  drivers/xen/xenbus/xenbus_probe_backend.c  |  8 ++++----
>  drivers/xen/xenbus/xenbus_probe_frontend.c | 14 +++++++-------
>  drivers/xen/xenbus/xenbus_xs.c             | 29 ++++++++++++++---------------
>  include/xen/xenbus.h                       |  6 +++---
>  14 files changed, 59 insertions(+), 69 deletions(-)
> 
> diff --git a/drivers/block/xen-blkback/xenbus.c b/drivers/block/xen-
> blkback/xenbus.c
> index 415e79b..8fe61b5 100644
> --- a/drivers/block/xen-blkback/xenbus.c
> +++ b/drivers/block/xen-blkback/xenbus.c
> @@ -38,8 +38,8 @@ struct backend_info {
>  static struct kmem_cache *xen_blkif_cachep;
>  static void connect(struct backend_info *);
>  static int connect_ring(struct backend_info *);
> -static void backend_changed(struct xenbus_watch *, const char **,
> -			    unsigned int);
> +static void backend_changed(struct xenbus_watch *, const char *,
> +			    const char *);
>  static void xen_blkif_free(struct xen_blkif *blkif);
>  static void xen_vbd_free(struct xen_vbd *vbd);
> 
> @@ -661,7 +661,7 @@ static int xen_blkbk_probe(struct xenbus_device
> *dev,
>   * ready, connect.
>   */
>  static void backend_changed(struct xenbus_watch *watch,
> -			    const char **vec, unsigned int len)
> +			    const char *path, const char *token)
>  {
>  	int err;
>  	unsigned major;
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index 3124eae..d8a40fa 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -723,7 +723,7 @@ static int xen_net_read_mac(struct xenbus_device
> *dev, u8 mac[])
>  }
> 
>  static void xen_net_rate_changed(struct xenbus_watch *watch,
> -				const char **vec, unsigned int len)
> +				 const char *path, const char *token)
>  {
>  	struct xenvif *vif = container_of(watch, struct xenvif, credit_watch);
>  	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
> @@ -780,7 +780,7 @@ static void xen_unregister_credit_watch(struct xenvif
> *vif)
>  }
> 
>  static void xen_mcast_ctrl_changed(struct xenbus_watch *watch,
> -				   const char **vec, unsigned int len)
> +				   const char *path, const char *token)
>  {
>  	struct xenvif *vif = container_of(watch, struct xenvif,
>  					  mcast_ctrl_watch);
> @@ -855,8 +855,8 @@ static void unregister_hotplug_status_watch(struct
> backend_info *be)
>  }
> 
>  static void hotplug_status_changed(struct xenbus_watch *watch,
> -				   const char **vec,
> -				   unsigned int vec_size)
> +				   const char *path,
> +				   const char *token)
>  {
>  	struct backend_info *be = container_of(watch,
>  					       struct backend_info,
> diff --git a/drivers/xen/cpu_hotplug.c b/drivers/xen/cpu_hotplug.c
> index 5676aef..7a4daa2 100644
> --- a/drivers/xen/cpu_hotplug.c
> +++ b/drivers/xen/cpu_hotplug.c
> @@ -68,13 +68,12 @@ static void vcpu_hotplug(unsigned int cpu)
>  }
> 
>  static void handle_vcpu_hotplug_event(struct xenbus_watch *watch,
> -					const char **vec, unsigned int len)
> +				      const char *path, const char *token)
>  {
>  	unsigned int cpu;
>  	char *cpustr;
> -	const char *node = vec[XS_WATCH_PATH];
> 
> -	cpustr = strstr(node, "cpu/");
> +	cpustr = strstr(path, "cpu/");
>  	if (cpustr != NULL) {
>  		sscanf(cpustr, "cpu/%u", &cpu);
>  		vcpu_hotplug(cpu);
> diff --git a/drivers/xen/manage.c b/drivers/xen/manage.c
> index 26e5e85..ca62c09 100644
> --- a/drivers/xen/manage.c
> +++ b/drivers/xen/manage.c
> @@ -218,7 +218,7 @@ static struct shutdown_handler shutdown_handlers[]
> = {
>  };
> 
>  static void shutdown_handler(struct xenbus_watch *watch,
> -			     const char **vec, unsigned int len)
> +			     const char *path, const char *token)
>  {
>  	char *str;
>  	struct xenbus_transaction xbt;
> @@ -266,8 +266,8 @@ static void shutdown_handler(struct xenbus_watch
> *watch,
>  }
> 
>  #ifdef CONFIG_MAGIC_SYSRQ
> -static void sysrq_handler(struct xenbus_watch *watch, const char **vec,
> -			  unsigned int len)
> +static void sysrq_handler(struct xenbus_watch *watch, const char *path,
> +			  const char *token)
>  {
>  	char sysrq_key = '\0';
>  	struct xenbus_transaction xbt;
> diff --git a/drivers/xen/xen-balloon.c b/drivers/xen/xen-balloon.c
> index 79865b8..e7715cb 100644
> --- a/drivers/xen/xen-balloon.c
> +++ b/drivers/xen/xen-balloon.c
> @@ -55,7 +55,7 @@ static int register_balloon(struct device *dev);
> 
>  /* React to a change in the target key */
>  static void watch_target(struct xenbus_watch *watch,
> -			 const char **vec, unsigned int len)
> +			 const char *path, const char *token)
>  {
>  	unsigned long long new_target;
>  	int err;
> diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-
> pciback/xenbus.c
> index 3f0aee0..3814b44 100644
> --- a/drivers/xen/xen-pciback/xenbus.c
> +++ b/drivers/xen/xen-pciback/xenbus.c
> @@ -652,7 +652,7 @@ static int xen_pcibk_setup_backend(struct
> xen_pcibk_device *pdev)
>  }
> 
>  static void xen_pcibk_be_watch(struct xenbus_watch *watch,
> -			     const char **vec, unsigned int len)
> +			       const char *path, const char *token)
>  {
>  	struct xen_pcibk_device *pdev =
>  	    container_of(watch, struct xen_pcibk_device, be_watch);
> diff --git a/drivers/xen/xenbus/xenbus.h b/drivers/xen/xenbus/xenbus.h
> index 6a80c1e..bd95c21 100644
> --- a/drivers/xen/xenbus/xenbus.h
> +++ b/drivers/xen/xenbus/xenbus.h
> @@ -39,8 +39,8 @@ struct xen_bus_type {
>  	int (*get_bus_id)(char bus_id[XEN_BUS_ID_SIZE], const char
> *nodename);
>  	int (*probe)(struct xen_bus_type *bus, const char *type,
>  		     const char *dir);
> -	void (*otherend_changed)(struct xenbus_watch *watch, const char
> **vec,
> -				 unsigned int len);
> +	void (*otherend_changed)(struct xenbus_watch *watch, const char
> *path,
> +				 const char *token);
>  	struct bus_type bus;
>  };
> 
> @@ -83,7 +83,7 @@ int xenbus_dev_resume(struct device *dev);
>  int xenbus_dev_cancel(struct device *dev);
> 
>  void xenbus_otherend_changed(struct xenbus_watch *watch,
> -			     const char **vec, unsigned int len,
> +			     const char *path, const char *token,
>  			     int ignore_on_shutdown);
> 
>  int xenbus_read_otherend_details(struct xenbus_device *xendev,
> diff --git a/drivers/xen/xenbus/xenbus_client.c
> b/drivers/xen/xenbus/xenbus_client.c
> index 23edf53..9586c24 100644
> --- a/drivers/xen/xenbus/xenbus_client.c
> +++ b/drivers/xen/xenbus/xenbus_client.c
> @@ -115,7 +115,7 @@ EXPORT_SYMBOL_GPL(xenbus_strstate);
>  int xenbus_watch_path(struct xenbus_device *dev, const char *path,
>  		      struct xenbus_watch *watch,
>  		      void (*callback)(struct xenbus_watch *,
> -				       const char **, unsigned int))
> +				       const char *, const char *))
>  {
>  	int err;
> 
> @@ -153,7 +153,7 @@ EXPORT_SYMBOL_GPL(xenbus_watch_path);
>  int xenbus_watch_pathfmt(struct xenbus_device *dev,
>  			 struct xenbus_watch *watch,
>  			 void (*callback)(struct xenbus_watch *,
> -					const char **, unsigned int),
> +					  const char *, const char *),
>  			 const char *pathfmt, ...)
>  {
>  	int err;
> diff --git a/drivers/xen/xenbus/xenbus_dev_frontend.c
> b/drivers/xen/xenbus/xenbus_dev_frontend.c
> index e2bc9b3..e4b9847 100644
> --- a/drivers/xen/xenbus/xenbus_dev_frontend.c
> +++ b/drivers/xen/xenbus/xenbus_dev_frontend.c
> @@ -258,26 +258,23 @@ static struct watch_adapter
> *alloc_watch_adapter(const char *path,
>  }
> 
>  static void watch_fired(struct xenbus_watch *watch,
> -			const char **vec,
> -			unsigned int len)
> +			const char *path,
> +			const char *token)
>  {
>  	struct watch_adapter *adap;
>  	struct xsd_sockmsg hdr;
> -	const char *path, *token;
> -	int path_len, tok_len, body_len, data_len = 0;
> +	const char *token_caller;
> +	int path_len, tok_len, body_len;
>  	int ret;
>  	LIST_HEAD(staging_q);
> 
>  	adap = container_of(watch, struct watch_adapter, watch);
> 
> -	path = vec[XS_WATCH_PATH];
> -	token = adap->token;
> +	token_caller = adap->token;
> 
>  	path_len = strlen(path) + 1;
> -	tok_len = strlen(token) + 1;
> -	if (len > 2)
> -		data_len = vec[len] - vec[2] + 1;
> -	body_len = path_len + tok_len + data_len;
> +	tok_len = strlen(token_caller) + 1;
> +	body_len = path_len + tok_len;
> 
>  	hdr.type = XS_WATCH_EVENT;
>  	hdr.len = body_len;
> @@ -288,9 +285,7 @@ static void watch_fired(struct xenbus_watch *watch,
>  	if (!ret)
>  		ret = queue_reply(&staging_q, path, path_len);
>  	if (!ret)
> -		ret = queue_reply(&staging_q, token, tok_len);
> -	if (!ret && len > 2)
> -		ret = queue_reply(&staging_q, vec[2], data_len);
> +		ret = queue_reply(&staging_q, token_caller, tok_len);
> 
>  	if (!ret) {
>  		/* success: pass reply list onto watcher */
> diff --git a/drivers/xen/xenbus/xenbus_probe.c
> b/drivers/xen/xenbus/xenbus_probe.c
> index 6baffbb..74888ca 100644
> --- a/drivers/xen/xenbus/xenbus_probe.c
> +++ b/drivers/xen/xenbus/xenbus_probe.c
> @@ -169,7 +169,7 @@ int xenbus_read_otherend_details(struct
> xenbus_device *xendev,
>  EXPORT_SYMBOL_GPL(xenbus_read_otherend_details);
> 
>  void xenbus_otherend_changed(struct xenbus_watch *watch,
> -			     const char **vec, unsigned int len,
> +			     const char *path, const char *token,
>  			     int ignore_on_shutdown)
>  {
>  	struct xenbus_device *dev =
> @@ -180,18 +180,15 @@ void xenbus_otherend_changed(struct
> xenbus_watch *watch,
>  	/* Protect us against watches firing on old details when the otherend
>  	   details change, say immediately after a resume. */
>  	if (!dev->otherend ||
> -	    strncmp(dev->otherend, vec[XS_WATCH_PATH],
> -		    strlen(dev->otherend))) {
> -		dev_dbg(&dev->dev, "Ignoring watch at %s\n",
> -			vec[XS_WATCH_PATH]);
> +	    strncmp(dev->otherend, path, strlen(dev->otherend))) {
> +		dev_dbg(&dev->dev, "Ignoring watch at %s\n", path);
>  		return;
>  	}
> 
>  	state = xenbus_read_driver_state(dev->otherend);
> 
>  	dev_dbg(&dev->dev, "state is %d, (%s), %s, %s\n",
> -		state, xenbus_strstate(state), dev->otherend_watch.node,
> -		vec[XS_WATCH_PATH]);
> +		state, xenbus_strstate(state), dev->otherend_watch.node,
> path);
> 
>  	/*
>  	 * Ignore xenbus transitions during shutdown. This prevents us doing
> diff --git a/drivers/xen/xenbus/xenbus_probe_backend.c
> b/drivers/xen/xenbus/xenbus_probe_backend.c
> index f46b4dc..b0bed4f 100644
> --- a/drivers/xen/xenbus/xenbus_probe_backend.c
> +++ b/drivers/xen/xenbus/xenbus_probe_backend.c
> @@ -181,9 +181,9 @@ static int xenbus_probe_backend(struct
> xen_bus_type *bus, const char *type,
>  }
> 
>  static void frontend_changed(struct xenbus_watch *watch,
> -			    const char **vec, unsigned int len)
> +			     const char *path, const char *token)
>  {
> -	xenbus_otherend_changed(watch, vec, len, 0);
> +	xenbus_otherend_changed(watch, path, token, 0);
>  }
> 
>  static struct xen_bus_type xenbus_backend = {
> @@ -204,11 +204,11 @@ static struct xen_bus_type xenbus_backend = {
>  };
> 
>  static void backend_changed(struct xenbus_watch *watch,
> -			    const char **vec, unsigned int len)
> +			    const char *path, const char *token)
>  {
>  	DPRINTK("");
> 
> -	xenbus_dev_changed(vec[XS_WATCH_PATH], &xenbus_backend);
> +	xenbus_dev_changed(path, &xenbus_backend);
>  }
> 
>  static struct xenbus_watch be_watch = {
> diff --git a/drivers/xen/xenbus/xenbus_probe_frontend.c
> b/drivers/xen/xenbus/xenbus_probe_frontend.c
> index d7b77a6..19e45ce 100644
> --- a/drivers/xen/xenbus/xenbus_probe_frontend.c
> +++ b/drivers/xen/xenbus/xenbus_probe_frontend.c
> @@ -86,9 +86,9 @@ static int xenbus_uevent_frontend(struct device *_dev,
> 
> 
>  static void backend_changed(struct xenbus_watch *watch,
> -			    const char **vec, unsigned int len)
> +			    const char *path, const char *token)
>  {
> -	xenbus_otherend_changed(watch, vec, len, 1);
> +	xenbus_otherend_changed(watch, path, token, 1);
>  }
> 
>  static void xenbus_frontend_delayed_resume(struct work_struct *w)
> @@ -153,11 +153,11 @@ static struct xen_bus_type xenbus_frontend = {
>  };
> 
>  static void frontend_changed(struct xenbus_watch *watch,
> -			     const char **vec, unsigned int len)
> +			     const char *path, const char *token)
>  {
>  	DPRINTK("");
> 
> -	xenbus_dev_changed(vec[XS_WATCH_PATH], &xenbus_frontend);
> +	xenbus_dev_changed(path, &xenbus_frontend);
>  }
> 
> 
> @@ -332,13 +332,13 @@ static
> DECLARE_WAIT_QUEUE_HEAD(backend_state_wq);
>  static int backend_state;
> 
>  static void xenbus_reset_backend_state_changed(struct xenbus_watch *w,
> -					const char **v, unsigned int l)
> +					const char *path, const char *token)
>  {
> -	if (xenbus_scanf(XBT_NIL, v[XS_WATCH_PATH], "", "%i",
> +	if (xenbus_scanf(XBT_NIL, path, "", "%i",
>  			 &backend_state) != 1)
>  		backend_state = XenbusStateUnknown;
>  	printk(KERN_DEBUG "XENBUS: backend %s %s\n",
> -			v[XS_WATCH_PATH],
> xenbus_strstate(backend_state));
> +	       path, xenbus_strstate(backend_state));
>  	wake_up(&backend_state_wq);
>  }
> 
> diff --git a/drivers/xen/xenbus/xenbus_xs.c
> b/drivers/xen/xenbus/xenbus_xs.c
> index 4c49d87..ebc768f 100644
> --- a/drivers/xen/xenbus/xenbus_xs.c
> +++ b/drivers/xen/xenbus/xenbus_xs.c
> @@ -64,8 +64,8 @@ struct xs_stored_msg {
>  		/* Queued watch events. */
>  		struct {
>  			struct xenbus_watch *handle;
> -			char **vec;
> -			unsigned int vec_size;
> +			const char *path;
> +			const char *token;
>  		} watch;
>  	} u;
>  };
> @@ -765,7 +765,7 @@ void unregister_xenbus_watch(struct xenbus_watch
> *watch)
>  		if (msg->u.watch.handle != watch)
>  			continue;
>  		list_del(&msg->list);
> -		kfree(msg->u.watch.vec);
> +		kfree(msg->u.watch.path);
>  		kfree(msg);
>  	}
>  	spin_unlock(&watch_events_lock);
> @@ -833,11 +833,10 @@ static int xenwatch_thread(void *unused)
> 
>  		if (ent != &watch_events) {
>  			msg = list_entry(ent, struct xs_stored_msg, list);
> -			msg->u.watch.handle->callback(
> -				msg->u.watch.handle,
> -				(const char **)msg->u.watch.vec,
> -				msg->u.watch.vec_size);
> -			kfree(msg->u.watch.vec);
> +			msg->u.watch.handle->callback(msg-
> >u.watch.handle,
> +						      msg->u.watch.path,
> +						      msg->u.watch.token);
> +			kfree(msg->u.watch.path);
>  			kfree(msg);
>  		}
> 
> @@ -903,24 +902,24 @@ static int process_msg(void)
>  	body[msg->hdr.len] = '\0';
> 
>  	if (msg->hdr.type == XS_WATCH_EVENT) {
> -		msg->u.watch.vec = split(body, msg->hdr.len,
> -					 &msg->u.watch.vec_size);
> -		if (IS_ERR(msg->u.watch.vec)) {
> -			err = PTR_ERR(msg->u.watch.vec);
> +		if (count_strings(body, msg->hdr.len) != 2) {
> +			err = -EINVAL;
>  			kfree(msg);
> +			kfree(body);
>  			goto out;
>  		}
> +		msg->u.watch.path = (const char *)body;
> +		msg->u.watch.token = (const char *)strchr(body, '\0') + 1;
> 
>  		spin_lock(&watches_lock);
> -		msg->u.watch.handle = find_watch(
> -			msg->u.watch.vec[XS_WATCH_TOKEN]);
> +		msg->u.watch.handle = find_watch(msg->u.watch.token);
>  		if (msg->u.watch.handle != NULL) {
>  			spin_lock(&watch_events_lock);
>  			list_add_tail(&msg->list, &watch_events);
>  			wake_up(&watch_events_waitq);
>  			spin_unlock(&watch_events_lock);
>  		} else {
> -			kfree(msg->u.watch.vec);
> +			kfree(body);
>  			kfree(msg);
>  		}
>  		spin_unlock(&watches_lock);
> diff --git a/include/xen/xenbus.h b/include/xen/xenbus.h
> index 98f73a2..869c816 100644
> --- a/include/xen/xenbus.h
> +++ b/include/xen/xenbus.h
> @@ -61,7 +61,7 @@ struct xenbus_watch
> 
>  	/* Callback (executed in a process context with no locks held). */
>  	void (*callback)(struct xenbus_watch *,
> -			 const char **vec, unsigned int len);
> +			 const char *path, const char *token);
>  };
> 
> 
> @@ -193,11 +193,11 @@ void xenbus_probe(struct work_struct *);
>  int xenbus_watch_path(struct xenbus_device *dev, const char *path,
>  		      struct xenbus_watch *watch,
>  		      void (*callback)(struct xenbus_watch *,
> -				       const char **, unsigned int));
> +				       const char *, const char *));
>  __printf(4, 5)
>  int xenbus_watch_pathfmt(struct xenbus_device *dev, struct
> xenbus_watch *watch,
>  			 void (*callback)(struct xenbus_watch *,
> -					  const char **, unsigned int),
> +					  const char *, const char *),
>  			 const char *pathfmt, ...);
> 
>  int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state
> new_state);
> --
> 2.10.2
