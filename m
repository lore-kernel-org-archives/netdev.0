From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC V2 PATCH 17/25] net/netpolicy: introduce netpolicy_pick_queue
Date: Thu, 4 Aug 2016 20:51:32 -0700
Message-ID: <CALx6S37NbXVh-vS=Vxrm_8qhhOsOkPy-+hLTUGk=E57yKBkCyQ@mail.gmail.com>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com> <1470339389-8542-18-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@redhat.com>, peterz@infradead.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, akpm@linux-foundation.org,
	Kees Cook <keescook@chromium.org>, viro@zeniv.linux.org.uk,
	gorcunov@openvz.org, John Stultz <john.stultz@linaro.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Decotigny <decot@googlers.com>,
	Florian Westphal <fw@strlen.de>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, rdunlap@infradead.org,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
To: "Liang, Kan" <kan.liang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470339389-8542-18-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 4, 2016 at 12:36 PM,  <kan.liang@intel.com> wrote:
> From: Kan Liang <kan.liang@intel.com>
>
> To achieve better network performance, the key step is to distribute the
> packets to dedicated queues according to policy and system run time
> status.
>
> This patch provides an interface which can return the proper dedicated
> queue for socket/task. Then the packets of the socket/task will be
> redirect to the dedicated queue for better network performance.
>
> For selecting the proper queue, currently it uses round-robin algorithm
> to find the available object from the given policy object list. The
> algorithm is good enough for now. But it could be improved by some
> adaptive algorithm later.
>
Seriously? You want to all of this code so we revert to TX queue
selection by round robin?

> The selected object will be stored in hashtable. So it does not need to
> go through the whole object list every time.
>
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  include/linux/netpolicy.h |   5 ++
>  net/core/netpolicy.c      | 136 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 141 insertions(+)
>
> diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
> index 5900252..a522015 100644
> --- a/include/linux/netpolicy.h
> +++ b/include/linux/netpolicy.h
> @@ -97,6 +97,7 @@ extern void update_netpolicy_sys_map(void);
>  extern int netpolicy_register(struct netpolicy_instance *instance,
>                               enum netpolicy_name policy);
>  extern void netpolicy_unregister(struct netpolicy_instance *instance);
> +extern int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx);
>  #else
>  static inline void update_netpolicy_sys_map(void)
>  {
> @@ -111,6 +112,10 @@ static inline void netpolicy_unregister(struct netpolicy_instance *instance)
>  {
>  }
>
> +static inline int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
> +{
> +       return 0;
> +}
>  #endif
>
>  #endif /*__LINUX_NETPOLICY_H*/
> diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
> index 3605761..98ca430 100644
> --- a/net/core/netpolicy.c
> +++ b/net/core/netpolicy.c
> @@ -290,6 +290,142 @@ static void netpolicy_record_clear_dev_node(struct net_device *dev)
>         spin_unlock_bh(&np_hashtable_lock);
>  }
>
> +static struct netpolicy_object *get_avail_object(struct net_device *dev,
> +                                                enum netpolicy_name policy,
> +                                                bool is_rx)
> +{
> +       int dir = is_rx ? NETPOLICY_RX : NETPOLICY_TX;
> +       struct netpolicy_object *tmp, *obj = NULL;
> +       int val = -1;
> +
> +       /* Check if net policy is supported */
> +       if (!dev || !dev->netpolicy)
> +               return NULL;
> +
> +       /* The system should have queues which support the request policy. */
> +       if ((policy != dev->netpolicy->cur_policy) &&
> +           (dev->netpolicy->cur_policy != NET_POLICY_MIX))
> +               return NULL;
> +
> +       spin_lock_bh(&dev->np_ob_list_lock);
> +       list_for_each_entry(tmp, &dev->netpolicy->obj_list[dir][policy], list) {
> +               if ((val > atomic_read(&tmp->refcnt)) ||
> +                   (val == -1)) {
> +                       val = atomic_read(&tmp->refcnt);
> +                       obj = tmp;
> +               }
> +       }
> +
> +       if (WARN_ON(!obj)) {
> +               spin_unlock_bh(&dev->np_ob_list_lock);
> +               return NULL;
> +       }
> +       atomic_inc(&obj->refcnt);
> +       spin_unlock_bh(&dev->np_ob_list_lock);
> +
> +       return obj;
> +}
> +
> +static int get_avail_queue(struct netpolicy_instance *instance, bool is_rx)
> +{
> +       struct netpolicy_record *old_record, *new_record;
> +       struct net_device *dev = instance->dev;
> +       unsigned long ptr_id = (uintptr_t)instance->ptr;
> +       int queue = -1;
> +
> +       spin_lock_bh(&np_hashtable_lock);
> +       old_record = netpolicy_record_search(ptr_id);
> +       if (!old_record) {
> +               pr_warn("NETPOLICY: doesn't registered. Remove net policy settings!\n");
> +               instance->policy = NET_POLICY_INVALID;
> +               goto err;
> +       }
> +
> +       if (is_rx && old_record->rx_obj) {
> +               queue = old_record->rx_obj->queue;
> +       } else if (!is_rx && old_record->tx_obj) {
> +               queue = old_record->tx_obj->queue;
> +       } else {
> +               new_record = kzalloc(sizeof(*new_record), GFP_KERNEL);
> +               if (!new_record)
> +                       goto err;
> +               memcpy(new_record, old_record, sizeof(*new_record));
> +
> +               if (is_rx) {
> +                       new_record->rx_obj = get_avail_object(dev, new_record->policy, is_rx);
> +                       if (!new_record->dev)
> +                               new_record->dev = dev;
> +                       if (!new_record->rx_obj) {
> +                               kfree(new_record);
> +                               goto err;
> +                       }
> +                       queue = new_record->rx_obj->queue;
> +               } else {
> +                       new_record->tx_obj = get_avail_object(dev, new_record->policy, is_rx);
> +                       if (!new_record->dev)
> +                               new_record->dev = dev;
> +                       if (!new_record->tx_obj) {
> +                               kfree(new_record);
> +                               goto err;
> +                       }
> +                       queue = new_record->tx_obj->queue;
> +               }
> +               /* update record */
> +               hlist_replace_rcu(&old_record->hash_node, &new_record->hash_node);
> +               kfree(old_record);
> +       }
> +err:
> +       spin_unlock_bh(&np_hashtable_lock);
> +       return queue;
> +}
> +
> +static inline bool policy_validate(struct netpolicy_instance *instance)
> +{
> +       struct net_device *dev = instance->dev;
> +       enum netpolicy_name cur_policy;
> +
> +       cur_policy = dev->netpolicy->cur_policy;
> +       if ((instance->policy == NET_POLICY_NONE) ||
> +           (cur_policy == NET_POLICY_NONE))
> +               return false;
> +
> +       if (((cur_policy != NET_POLICY_MIX) && (cur_policy != instance->policy)) ||
> +           ((cur_policy == NET_POLICY_MIX) && (instance->policy == NET_POLICY_CPU))) {
> +               pr_warn("NETPOLICY: %s current device policy %s doesn't support required policy %s! Remove net policy settings!\n",
> +                       dev->name, policy_name[cur_policy],
> +                       policy_name[instance->policy]);
> +               return false;
> +       }
> +       return true;
> +}
> +
> +/**
> + * netpolicy_pick_queue() - Find proper queue
> + * @instance:  NET policy per socket/task instance info
> + * @is_rx:     RX queue or TX queue
> + *
> + * This function intends to find the proper queue according to policy.
> + * For selecting the proper queue, currently it uses round-robin algorithm
> + * to find the available object from the given policy object list.
> + * The selected object will be stored in hashtable. So it does not need to
> + * go through the whole object list every time.
> + *
> + * Return: negative on failure, otherwise on the assigned queue
> + */
> +int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
> +{
> +       struct net_device *dev = instance->dev;
> +
> +       if (!dev || !dev->netpolicy)
> +               return -EINVAL;
> +
> +       if (!policy_validate(instance))
> +               return -EINVAL;
> +
> +       return get_avail_queue(instance, is_rx);
> +}
> +EXPORT_SYMBOL(netpolicy_pick_queue);
> +
>  /**
>   * netpolicy_register() - Register per socket/task policy request
>   * @instance:  NET policy per socket/task instance info
> --
> 2.5.5
>
