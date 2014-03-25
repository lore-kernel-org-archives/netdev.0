From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [RFC 1/2] pm: Introduce QoS requests per CPU
Date: Tue, 25 Mar 2014 19:44:53 +0100
Message-ID: <2896374.SoOPVJXu9Q@vostro.rjw.lan>
References: <1395753505-13180-1-git-send-email-amirv@mellanox.com> <1395753505-13180-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, linux-pm@vger.kernel.org,
	netdev@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	Len Brown <len.brown@intel.com>, yuvali@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1395753505-13180-2-git-send-email-amirv@mellanox.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, March 25, 2014 03:18:24 PM Amir Vadai wrote:
> Extend the current pm_qos_request API - to have pm_qos_request per core.
> When a global request is added, it is added under the global plist.
> When a core specific request is added, it is added to the core specific
> list.
> core number is saved in the request and later modify/delete operations
> are using it to access the right list.
> 
> When a cpu specific request is added/removed/updated, the target value
> of the specific core is recalculated to be the min/max (according to the
> constrain type) value of all the global and the cpu specific
> constraints.
> 
> If a global request is added/removed/updated, the target values of all
> the cpu's are recalculated.
> 
> During initialization, before the cpu specific data structures are
> allocated and initialized, only global target value is begin used.

I have to review this in detail (which rather won't be possible before
the next week), but in principle I don't really like it, because it
assumes that its users will know what's going to run on which CPU cores
and I'm not sure where that knowledge is going to come from.

> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  Documentation/trace/events-power.txt |   2 +
>  drivers/base/power/qos.c             |   6 +-
>  drivers/cpuidle/governors/menu.c     |   2 +-
>  include/linux/pm_qos.h               |  22 +++-
>  include/trace/events/power.h         |  20 ++--
>  kernel/power/qos.c                   | 221 ++++++++++++++++++++++++++---------
>  6 files changed, 205 insertions(+), 68 deletions(-)
> 
> diff --git a/Documentation/trace/events-power.txt b/Documentation/trace/events-power.txt
> index 3bd33b8..be54c6c 100644
> --- a/Documentation/trace/events-power.txt
> +++ b/Documentation/trace/events-power.txt
> @@ -68,6 +68,8 @@ The second parameter is the power domain target state.
>  The PM QoS events are used for QoS add/update/remove request and for
>  target/flags update.
>  
> +TODO: update documentation here
> +
>  pm_qos_add_request                 "pm_qos_class=%s value=%d"
>  pm_qos_update_request              "pm_qos_class=%s value=%d"
>  pm_qos_remove_request              "pm_qos_class=%s value=%d"
> diff --git a/drivers/base/power/qos.c b/drivers/base/power/qos.c
> index 5c1361a..d816f00 100644
> --- a/drivers/base/power/qos.c
> +++ b/drivers/base/power/qos.c
> @@ -105,7 +105,7 @@ EXPORT_SYMBOL_GPL(dev_pm_qos_flags);
>  s32 __dev_pm_qos_read_value(struct device *dev)
>  {
>  	return IS_ERR_OR_NULL(dev->power.qos) ?
> -		0 : pm_qos_read_value(&dev->power.qos->latency);
> +		0 : pm_qos_read_value(&dev->power.qos->latency, -1);
>  }
>  
>  /**
> @@ -143,9 +143,9 @@ static int apply_constraint(struct dev_pm_qos_request *req,
>  	switch(req->type) {
>  	case DEV_PM_QOS_LATENCY:
>  		ret = pm_qos_update_target(&qos->latency, &req->data.pnode,
> -					   action, value);
> +					   -1, action, value);
>  		if (ret) {
> -			value = pm_qos_read_value(&qos->latency);
> +			value = pm_qos_read_value(&qos->latency, -1);
>  			blocking_notifier_call_chain(&dev_pm_notifiers,
>  						     (unsigned long)value,
>  						     req);
> diff --git a/drivers/cpuidle/governors/menu.c b/drivers/cpuidle/governors/menu.c
> index cf7f2f0..edb7b4a 100644
> --- a/drivers/cpuidle/governors/menu.c
> +++ b/drivers/cpuidle/governors/menu.c
> @@ -287,7 +287,7 @@ again:
>  static int menu_select(struct cpuidle_driver *drv, struct cpuidle_device *dev)
>  {
>  	struct menu_device *data = &__get_cpu_var(menu_devices);
> -	int latency_req = pm_qos_request(PM_QOS_CPU_DMA_LATENCY);
> +	int latency_req = pm_qos_request_cpu(PM_QOS_CPU_DMA_LATENCY, smp_processor_id());
>  	int i;
>  	int multiplier;
>  	struct timespec t;
> diff --git a/include/linux/pm_qos.h b/include/linux/pm_qos.h
> index 5a95013..62a15ee 100644
> --- a/include/linux/pm_qos.h
> +++ b/include/linux/pm_qos.h
> @@ -40,6 +40,7 @@ enum pm_qos_flags_status {
>  struct pm_qos_request {
>  	struct plist_node node;
>  	int pm_qos_class;
> +	int cpu;
>  	struct delayed_work work; /* for pm_qos_update_request_timeout */
>  };
>  
> @@ -68,6 +69,11 @@ enum pm_qos_type {
>  	PM_QOS_MIN		/* return the smallest value */
>  };
>  
> +struct pm_qos_constraints_percpu  {
> +	struct plist_head list;
> +	s32 target_value;
> +};
> +
>  /*
>   * Note: The lockless read path depends on the CPU accessing target_value
>   * or effective_flags atomically.  Atomic access is only guaranteed on all CPU
> @@ -75,7 +81,11 @@ enum pm_qos_type {
>   */
>  struct pm_qos_constraints {
>  	struct plist_head list;
> -	s32 target_value;	/* Do not change to 64 bit */
> +	struct pm_qos_constraints_percpu __percpu *percpu;
> +	s32 target_value;	/* Do not change to 64 bit.
> +				 * Value will be overriden by percpu
> +				 * target_value if exists
> +				 */
>  	s32 default_value;
>  	enum pm_qos_type type;
>  	struct blocking_notifier_head *notifiers;
> @@ -106,12 +116,15 @@ static inline int dev_pm_qos_request_active(struct dev_pm_qos_request *req)
>  }
>  
>  int pm_qos_update_target(struct pm_qos_constraints *c, struct plist_node *node,
> +			 int cpu,
>  			 enum pm_qos_req_action action, int value);
>  bool pm_qos_update_flags(struct pm_qos_flags *pqf,
>  			 struct pm_qos_flags_request *req,
>  			 enum pm_qos_req_action action, s32 val);
> -void pm_qos_add_request(struct pm_qos_request *req, int pm_qos_class,
> -			s32 value);
> +void pm_qos_add_request_cpu(struct pm_qos_request *req, int pm_qos_class,
> +			    int cpu, s32 value);
> +#define pm_qos_add_request(req, pm_qos_class, value) \
> +	pm_qos_add_request_cpu(req, pm_qos_class, -1, value)
>  void pm_qos_update_request(struct pm_qos_request *req,
>  			   s32 new_value);
>  void pm_qos_update_request_timeout(struct pm_qos_request *req,
> @@ -119,10 +132,11 @@ void pm_qos_update_request_timeout(struct pm_qos_request *req,
>  void pm_qos_remove_request(struct pm_qos_request *req);
>  
>  int pm_qos_request(int pm_qos_class);
> +int pm_qos_request_cpu(int pm_qos_class, int cpu);
>  int pm_qos_add_notifier(int pm_qos_class, struct notifier_block *notifier);
>  int pm_qos_remove_notifier(int pm_qos_class, struct notifier_block *notifier);
>  int pm_qos_request_active(struct pm_qos_request *req);
> -s32 pm_qos_read_value(struct pm_qos_constraints *c);
> +s32 pm_qos_read_value(struct pm_qos_constraints *c, int cpu);
>  
>  #ifdef CONFIG_PM
>  enum pm_qos_flags_status __dev_pm_qos_flags(struct device *dev, s32 mask);
> diff --git a/include/trace/events/power.h b/include/trace/events/power.h
> index e5bf9a7..2e441e2 100644
> --- a/include/trace/events/power.h
> +++ b/include/trace/events/power.h
> @@ -340,42 +340,46 @@ TRACE_EVENT(pm_qos_update_request_timeout,
>  
>  DECLARE_EVENT_CLASS(pm_qos_update,
>  
> -	TP_PROTO(enum pm_qos_req_action action, int prev_value, int curr_value),
> +	TP_PROTO(enum pm_qos_req_action action, int cpu, int prev_value, int curr_value),
>  
> -	TP_ARGS(action, prev_value, curr_value),
> +	TP_ARGS(action, cpu, prev_value, curr_value),
>  
>  	TP_STRUCT__entry(
>  		__field( enum pm_qos_req_action, action         )
> +		__field( int,                    cpu            )
>  		__field( int,                    prev_value     )
>  		__field( int,                    curr_value     )
>  	),
>  
>  	TP_fast_assign(
>  		__entry->action = action;
> +		__entry->cpu = cpu;
>  		__entry->prev_value = prev_value;
>  		__entry->curr_value = curr_value;
>  	),
>  
> -	TP_printk("action=%s prev_value=%d curr_value=%d",
> +	TP_printk("action=%s cpu=%d prev_value=%d curr_value=%d",
>  		  __print_symbolic(__entry->action,
>  			{ PM_QOS_ADD_REQ,	"ADD_REQ" },
>  			{ PM_QOS_UPDATE_REQ,	"UPDATE_REQ" },
>  			{ PM_QOS_REMOVE_REQ,	"REMOVE_REQ" }),
> -		  __entry->prev_value, __entry->curr_value)
> +		  __entry->cpu, __entry->prev_value, __entry->curr_value)
>  );
>  
>  DEFINE_EVENT(pm_qos_update, pm_qos_update_target,
>  
> -	TP_PROTO(enum pm_qos_req_action action, int prev_value, int curr_value),
> +	TP_PROTO(enum pm_qos_req_action action, int cpu, int prev_value, int
> +		 curr_value),
>  
> -	TP_ARGS(action, prev_value, curr_value)
> +	TP_ARGS(action, cpu, prev_value, curr_value)
>  );
>  
>  DEFINE_EVENT_PRINT(pm_qos_update, pm_qos_update_flags,
>  
> -	TP_PROTO(enum pm_qos_req_action action, int prev_value, int curr_value),
> +	TP_PROTO(enum pm_qos_req_action action, int cpu, int prev_value,
> +		 int curr_value),
>  
> -	TP_ARGS(action, prev_value, curr_value),
> +	TP_ARGS(action, cpu, prev_value, curr_value),
>  
>  	TP_printk("action=%s prev_value=0x%x curr_value=0x%x",
>  		  __print_symbolic(__entry->action,
> diff --git a/kernel/power/qos.c b/kernel/power/qos.c
> index 8dff9b4..4a38329 100644
> --- a/kernel/power/qos.c
> +++ b/kernel/power/qos.c
> @@ -125,59 +125,124 @@ static const struct file_operations pm_qos_power_fops = {
>  };
>  
>  /* unlocked internal variant */
> -static inline int pm_qos_get_value(struct pm_qos_constraints *c)
> +static inline int pm_qos_get_value(struct pm_qos_constraints *c, int cpu)
>  {
> -	if (plist_head_empty(&c->list))
> +	struct pm_qos_constraints_percpu *cc;
> +	struct plist_head *clist = NULL;
> +	int val;
> +
> +	if (c->percpu && cpu >= 0) {
> +		cc = per_cpu_ptr(c->percpu, cpu);
> +		if (!plist_head_empty(&cc->list))
> +			clist= &cc->list;
> +	}
> +
> +	if (plist_head_empty(&c->list) && !clist)
>  		return c->default_value;
>  
>  	switch (c->type) {
>  	case PM_QOS_MIN:
> -		return plist_first(&c->list)->prio;
> -
> +		if (plist_head_empty(&c->list))
> +			return plist_first(clist)->prio;
> +		val = plist_first(&c->list)->prio;
> +		if (clist)
> +			val = min(val, plist_first(clist)->prio);
> +		return val;
>  	case PM_QOS_MAX:
> -		return plist_last(&c->list)->prio;
> -
> +		if (plist_head_empty(&c->list))
> +			return plist_last(clist)->prio;
> +		val = plist_last(&c->list)->prio;
> +		if (clist)
> +			val = max(val, plist_last(clist)->prio);
> +		return val;
>  	default:
>  		/* runtime check for not using enum */
>  		BUG();
> -		return PM_QOS_DEFAULT_VALUE;
>  	}
> +
> +	return PM_QOS_DEFAULT_VALUE;
>  }
>  
> -s32 pm_qos_read_value(struct pm_qos_constraints *c)
> +s32 pm_qos_read_value(struct pm_qos_constraints *c, int cpu)
>  {
> +	struct pm_qos_constraints_percpu *cc;
> +
> +	if (c->percpu && cpu >= 0) {
> +		cc = per_cpu_ptr(c->percpu, cpu);
> +		return cc->target_value;
> +	}
> +
>  	return c->target_value;
>  }
>  
> -static inline void pm_qos_set_value(struct pm_qos_constraints *c, s32 value)
> +static inline int _pm_qos_set_value(enum pm_qos_req_action act,
> +				    struct pm_qos_constraints *c, int cpu)
>  {
> +	struct pm_qos_constraints_percpu *cc = per_cpu_ptr(c->percpu, cpu);
> +	s32 value = pm_qos_get_value(c, cpu);
> +
> +	if (value == cc->target_value)
> +		return 0;
> +
> +	trace_pm_qos_update_target(act, cpu, c->target_value, value);
> +	cc->target_value = value;
> +
> +	return 1;
> +}
> +
> +static inline int pm_qos_set_value(enum pm_qos_req_action act,
> +				   struct pm_qos_constraints *c, int cpu)
> +{
> +	s32 value;
> +
> +	if (cpu >= 0)
> +		return _pm_qos_set_value(act, c, cpu);
> +
> +	value = pm_qos_get_value(c, -1);
> +	if (value == c->target_value)
> +		return 0;
> +
> +	trace_pm_qos_update_target(act, -1, c->target_value, value);
>  	c->target_value = value;
> +
> +	if (c->percpu) {
> +		for_each_possible_cpu(cpu)
> +			_pm_qos_set_value(act, c, cpu);
> +	}
> +
> +	return 1;
>  }
>  
> -/**
> - * pm_qos_update_target - manages the constraints list and calls the notifiers
> - *  if needed
> - * @c: constraints data struct
> - * @node: request to add to the list, to update or to remove
> - * @action: action to take on the constraints list
> - * @value: value of the request to add or update
> - *
> - * This function returns 1 if the aggregated constraint value has changed, 0
> - *  otherwise.
> - */
> -int pm_qos_update_target(struct pm_qos_constraints *c, struct plist_node *node,
> -			 enum pm_qos_req_action action, int value)
> +static int _pm_qos_update_target(struct pm_qos_constraints *c, struct plist_node *node,
> +				 enum pm_qos_req_action action, int value, int cpu)
>  {
>  	unsigned long flags;
> -	int prev_value, curr_value, new_value;
> +	int new_value;
> +	int ret;
> +	struct plist_head *plist;
>  
>  	spin_lock_irqsave(&pm_qos_lock, flags);
> -	prev_value = pm_qos_get_value(c);
>  	if (value == PM_QOS_DEFAULT_VALUE)
>  		new_value = c->default_value;
>  	else
>  		new_value = value;
>  
> +	if (cpu == -1) {
> +		plist = &c->list;
> +	} else {
> +		struct pm_qos_constraints_percpu *cc;
> +
> +		if (!c->percpu) {
> +			ret = 0;
> +			printk(KERN_ERR "%s: Can't set cpu constraint\n",
> +			       __func__);
> +			goto out;
> +		}
> +
> +		cc = per_cpu_ptr(c->percpu, cpu);
> +		plist = &cc->list;
> +	}
> +
>  	switch (action) {
>  	case PM_QOS_REMOVE_REQ:
>  		plist_del(node, &c->list);
> @@ -198,20 +263,39 @@ int pm_qos_update_target(struct pm_qos_constraints *c, struct plist_node *node,
>  		;
>  	}
>  
> -	curr_value = pm_qos_get_value(c);
> -	pm_qos_set_value(c, curr_value);
> +	ret =  pm_qos_set_value(action, c, cpu);
>  
> +out:
>  	spin_unlock_irqrestore(&pm_qos_lock, flags);
>  
> -	trace_pm_qos_update_target(action, prev_value, curr_value);
> -	if (prev_value != curr_value) {
> -		blocking_notifier_call_chain(c->notifiers,
> -					     (unsigned long)curr_value,
> -					     NULL);
> -		return 1;
> -	} else {
> -		return 0;
> +	if (ret) {
> +		if (c->notifiers)
> +			blocking_notifier_call_chain(c->notifiers,
> +						     0, /* XXX should change to notifier per core? */
> +						     /*(unsigned long)curr_value,*/
> +						     NULL);
>  	}
> +
> +	return ret;
> +}
> +
> +/**
> + * pm_qos_update_target - manages the constraints list and calls the notifiers
> + *  if needed
> + * @c: constraints data struct
> + * @node: request to add to the list, to update or to remove
> + * @cpu: core number, -1 for all
> + * @action: action to take on the constraints list
> + * @value: value of the request to add or update
> + *
> + * This function returns 1 if the aggregated constraint value has changed, 0
> + *  otherwise.
> + */
> +int pm_qos_update_target(struct pm_qos_constraints *c, struct plist_node *node,
> +			 int cpu,
> +			 enum pm_qos_req_action action, int value)
> +{
> +	return _pm_qos_update_target(c, node, action, value, -1);
>  }
>  
>  /**
> @@ -274,7 +358,7 @@ bool pm_qos_update_flags(struct pm_qos_flags *pqf,
>  
>  	spin_unlock_irqrestore(&pm_qos_lock, irqflags);
>  
> -	trace_pm_qos_update_flags(action, prev_value, curr_value);
> +	trace_pm_qos_update_flags(action, -1, prev_value, curr_value);
>  	return prev_value != curr_value;
>  }
>  
> @@ -286,10 +370,23 @@ bool pm_qos_update_flags(struct pm_qos_flags *pqf,
>   */
>  int pm_qos_request(int pm_qos_class)
>  {
> -	return pm_qos_read_value(pm_qos_array[pm_qos_class]->constraints);
> +	return pm_qos_read_value(pm_qos_array[pm_qos_class]->constraints, -1);
>  }
>  EXPORT_SYMBOL_GPL(pm_qos_request);
>  
> +/**
> + * pm_qos_request_cpu - returns current per cpu qos expectation
> + * @pm_qos_class: identification of which qos value is requested
> + * @cpu: core number
> + *
> + * This function returns the current target value for a core.
> + */
> +int pm_qos_request_cpu(int pm_qos_class, int cpu)
> +{
> +	return pm_qos_read_value(pm_qos_array[pm_qos_class]->constraints, cpu);
> +}
> +EXPORT_SYMBOL_GPL(pm_qos_request_cpu);
> +
>  int pm_qos_request_active(struct pm_qos_request *req)
>  {
>  	return req->pm_qos_class != 0;
> @@ -297,14 +394,14 @@ int pm_qos_request_active(struct pm_qos_request *req)
>  EXPORT_SYMBOL_GPL(pm_qos_request_active);
>  
>  static void __pm_qos_update_request(struct pm_qos_request *req,
> -			   s32 new_value)
> +				    s32 new_value)
>  {
>  	trace_pm_qos_update_request(req->pm_qos_class, new_value);
>  
>  	if (new_value != req->node.prio)
>  		pm_qos_update_target(
>  			pm_qos_array[req->pm_qos_class]->constraints,
> -			&req->node, PM_QOS_UPDATE_REQ, new_value);
> +			&req->node, req->cpu, PM_QOS_UPDATE_REQ, new_value);
>  }
>  
>  /**
> @@ -326,6 +423,7 @@ static void pm_qos_work_fn(struct work_struct *work)
>   * pm_qos_add_request - inserts new qos request into the list
>   * @req: pointer to a preallocated handle
>   * @pm_qos_class: identifies which list of qos request to use
> + * @cpu : cpu which the request belong to. -1 for global request
>   * @value: defines the qos request
>   *
>   * This function inserts a new entry in the pm_qos_class list of requested qos
> @@ -334,9 +432,8 @@ static void pm_qos_work_fn(struct work_struct *work)
>   * handle.  Caller needs to save this handle for later use in updates and
>   * removal.
>   */
> -
> -void pm_qos_add_request(struct pm_qos_request *req,
> -			int pm_qos_class, s32 value)
> +void pm_qos_add_request_cpu(struct pm_qos_request *req,
> +			    int pm_qos_class, int cpu, s32 value)
>  {
>  	if (!req) /*guard against callers passing in null */
>  		return;
> @@ -346,12 +443,13 @@ void pm_qos_add_request(struct pm_qos_request *req,
>  		return;
>  	}
>  	req->pm_qos_class = pm_qos_class;
> +	req->cpu = cpu;
>  	INIT_DELAYED_WORK(&req->work, pm_qos_work_fn);
>  	trace_pm_qos_add_request(pm_qos_class, value);
>  	pm_qos_update_target(pm_qos_array[pm_qos_class]->constraints,
> -			     &req->node, PM_QOS_ADD_REQ, value);
> +			     &req->node, cpu, PM_QOS_ADD_REQ, value);
>  }
> -EXPORT_SYMBOL_GPL(pm_qos_add_request);
> +EXPORT_SYMBOL_GPL(pm_qos_add_request_cpu);
>  
>  /**
>   * pm_qos_update_request - modifies an existing qos request
> @@ -364,7 +462,7 @@ EXPORT_SYMBOL_GPL(pm_qos_add_request);
>   * Attempts are made to make this code callable on hot code paths.
>   */
>  void pm_qos_update_request(struct pm_qos_request *req,
> -			   s32 new_value)
> +			       s32 new_value)
>  {
>  	if (!req) /*guard against callers passing in null */
>  		return;
> @@ -387,8 +485,8 @@ EXPORT_SYMBOL_GPL(pm_qos_update_request);
>   *
>   * After timeout_us, this qos request is cancelled automatically.
>   */
> -void pm_qos_update_request_timeout(struct pm_qos_request *req, s32 new_value,
> -				   unsigned long timeout_us)
> +void pm_qos_update_request_timeout(struct pm_qos_request *req,
> +				   s32 new_value, unsigned long timeout_us)
>  {
>  	if (!req)
>  		return;
> @@ -403,7 +501,7 @@ void pm_qos_update_request_timeout(struct pm_qos_request *req, s32 new_value,
>  	if (new_value != req->node.prio)
>  		pm_qos_update_target(
>  			pm_qos_array[req->pm_qos_class]->constraints,
> -			&req->node, PM_QOS_UPDATE_REQ, new_value);
> +			&req->node, req->cpu, PM_QOS_UPDATE_REQ, new_value);
>  
>  	schedule_delayed_work(&req->work, usecs_to_jiffies(timeout_us));
>  }
> @@ -431,7 +529,7 @@ void pm_qos_remove_request(struct pm_qos_request *req)
>  
>  	trace_pm_qos_remove_request(req->pm_qos_class, PM_QOS_DEFAULT_VALUE);
>  	pm_qos_update_target(pm_qos_array[req->pm_qos_class]->constraints,
> -			     &req->node, PM_QOS_REMOVE_REQ,
> +			     &req->node, req->cpu, PM_QOS_REMOVE_REQ,
>  			     PM_QOS_DEFAULT_VALUE);
>  	memset(req, 0, sizeof(*req));
>  }
> @@ -529,7 +627,7 @@ static int pm_qos_power_release(struct inode *inode, struct file *filp)
>  	return 0;
>  }
>  
> -
> +// TODO sysfs for non global
>  static ssize_t pm_qos_power_read(struct file *filp, char __user *buf,
>  		size_t count, loff_t *f_pos)
>  {
> @@ -543,7 +641,7 @@ static ssize_t pm_qos_power_read(struct file *filp, char __user *buf,
>  		return -EINVAL;
>  
>  	spin_lock_irqsave(&pm_qos_lock, flags);
> -	value = pm_qos_get_value(pm_qos_array[req->pm_qos_class]->constraints);
> +	value = pm_qos_get_value(pm_qos_array[req->pm_qos_class]->constraints, -1);
>  	spin_unlock_irqrestore(&pm_qos_lock, flags);
>  
>  	return simple_read_from_buffer(buf, count, f_pos, &value, sizeof(s32));
> @@ -581,10 +679,29 @@ static int __init pm_qos_power_init(void)
>  	BUILD_BUG_ON(ARRAY_SIZE(pm_qos_array) != PM_QOS_NUM_CLASSES);
>  
>  	for (i = PM_QOS_CPU_DMA_LATENCY; i < PM_QOS_NUM_CLASSES; i++) {
> -		ret = register_pm_qos_misc(pm_qos_array[i]);
> +		struct pm_qos_object *pm_qos = pm_qos_array[i];
> +		struct pm_qos_constraints *c = pm_qos->constraints;
> +
> +		c->percpu = alloc_percpu(struct pm_qos_constraints_percpu);
> +		if (!c->percpu) {
> +			printk(KERN_ERR "pm_qos_param: %s per cpu alloc failed\n",
> +			       pm_qos->name);
> +		} else {
> +			int cpu;
> +
> +			for_each_possible_cpu(cpu) {
> +				struct pm_qos_constraints_percpu *cc =
> +					per_cpu_ptr(c->percpu, cpu);
> +
> +				plist_head_init(&cc->list);
> +				cc->target_value = pm_qos_read_value(c, -1);
> +			}
> +		}
> +
> +		ret = register_pm_qos_misc(pm_qos);
>  		if (ret < 0) {
>  			printk(KERN_ERR "pm_qos_param: %s setup failed\n",
> -			       pm_qos_array[i]->name);
> +			       pm_qos->name);
>  			return ret;
>  		}
>  	}
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
