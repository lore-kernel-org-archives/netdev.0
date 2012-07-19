From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH v4] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Thu, 19 Jul 2012 09:00:51 +0800
Message-ID: <50075C43.7000706@huawei.com>
References: <1342079415-9631-1-git-send-email-gaofeng@cn.fujitsu.com> <5005CF5D.9070905@intel.com> <20120718122106.GB25563@hmsreliant.think-freely.org> <5006C3CA.3010007@intel.com> <20120718142632.GF25563@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Eric Dumazet <edumazet@google.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120718142632.GF25563@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>>  static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)

>>>>>  {
>>>>>  	struct cgroup_netprio_state *cs;
>>>>> -	int ret;
>>>>> +	int ret = -EINVAL;
>>>>>
>>>>>  	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
>>>>>  	if (!cs)
>>>>>  		return ERR_PTR(-ENOMEM);
>>>>>
>>>>> -	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx) {
>>>>> -		kfree(cs);
>>>>> -		return ERR_PTR(-EINVAL);
>>>>> -	}
>>>>> +	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx)
>>>>> +		goto out;
>>>>>
>>>>>  	ret = get_prioidx(&cs->prioidx);
>>>>> -	if (ret != 0) {
>>>>> +	if (ret < 0) {
>>>>>  		pr_warn("No space in priority index array\n");
>>>>> -		kfree(cs);
>>>>> -		return ERR_PTR(ret);
>>>>> +		goto out;
>>>>> +	}
>>>>> +
>>>>> +	ret = update_netdev_tables();
>>>>> +	if (ret < 0) {
>>>>> +		put_prioidx(cs->prioidx);
>>>>> +		goto out;
>>>>>  	}
>>>>
>>>> Gao,
>>>>
>>>> This introduces a null ptr dereference when netprio_cgroup is built
>>>> into the kernel because update_netdev_tables() depends on init_net.
>>>> However cgrp_create is being called by cgroup_init before
>>>> do_initcalls() is called and before net_dev_init().
>>>>
>>>> .John
>>>>
>>> Not sure I follow here John.  Shouldn't init_net be initialized prior to any
>>> network devices getting registered?  In other words, shouldn't for_each_netdev
>>> just result in zero iterations through the loop?
>>> Neil
>>>
>>
>> init_net _is_ initialized prior to any network devices getting
>> registered but not before cgrp_create called via cgroup_init.
>>
>> #define for_each_netdev(net, d)         \
>>                 list_for_each_entry(d, &(net)->dev_base_head, dev_list)
>>
>> but dev_base_head is zeroed at this time. In netdev_init we have,
>>
>>         INIT_LIST_HEAD(&net->dev_base_head);
>>
>> but we haven't got that far yet because cgroup_init is called
>> before do_initcalls().
>>
> ok, I see that, and it makes sense, but at this point I'm more concerned with
> cgroups getting initalized twice.  The early_init flag is clear in the
> cgroup_subsystem for netprio, so we really shouldn't be getting initalized from
> cgroup_init. We should be getting initalized from the module_init() call that

> we register

If the early_init flag is set, a cgroup subsys will be initialized from
cgroup_early_init(), otherwise cgroup_init().

If netprio is built as a module, the subsys will be initailized from module_init(),
otherwise cgroup_init() (in this case cgroup_load_subsys() called in module_init()
is a no-op).

So it won't get initialized twice.
