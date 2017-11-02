From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 3/3] tun: add eBPF based queue selection
 method
Date: Thu, 2 Nov 2017 11:45:39 +0800
Message-ID: <30aa1418-9253-5721-a489-84cd6e1722c5@redhat.com>
References: <1509445938-4345-1-git-send-email-jasowang@redhat.com>
 <1509445938-4345-4-git-send-email-jasowang@redhat.com>
 <20171031184002-mutt-send-email-mst@kernel.org>
 <43c86606-2911-768d-704f-8b25e04cb47b@redhat.com>
 <20171101150458-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        willemdebruijn.kernel@gmail.com, tom@herbertland.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171101150458-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年11月01日 21:59, Michael S. Tsirkin wrote:
> On Wed, Nov 01, 2017 at 09:02:03PM +0800, Jason Wang wrote:
>>
>> On 2017年11月01日 00:45, Michael S. Tsirkin wrote:
>>>> +static void __tun_set_steering_ebpf(struct tun_struct *tun,
>>>> +				    struct bpf_prog *new)
>>>> +{
>>>> +	struct bpf_prog *old;
>>>> +
>>>> +	old = rtnl_dereference(tun->steering_prog);
>>>> +	rcu_assign_pointer(tun->steering_prog, new);
>>>> +
>>>> +	if (old) {
>>>> +		synchronize_net();
>>>> +		bpf_prog_destroy(old);
>>>> +	}
>>>> +}
>>>> +
>>> Is this really called under rtnl?
>> Yes it is __tun_chr_ioctl() will call rtnl_lock().
> Is the call from tun_free_netdev under rtnl too?

Looks not, need hold rtnl_lock() in tun_free_netdev in next version.

>
>>> If no then rtnl_dereference
>>> is wrong. If yes I'm not sure you can call synchronize_net
>>> under rtnl.
>>>
>> Are you worrying about the long wait? Looking at synchronize_net(), it does:
>>
>> void synchronize_net(void)
>> {
>>      might_sleep();
>>      if (rtnl_is_locked())
>>          synchronize_rcu_expedited();
>>      else
>>          synchronize_rcu();
>> }
>> EXPORT_SYMBOL(synchronize_net);
>>
>> Thanks
> Not the wait - expedited is not a good thing to allow unpriveledged
> userspace to do, it interrupts all VMs running on the same box.

Good point.

>
> We could use a callback though the docs warn userspace can use that
> to cause a DOS and needs to be limited.
>
>

Will do this in next version.

Thanks
