From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 3/3] tun: add eBPF based queue selection
 method
Date: Thu, 2 Nov 2017 11:24:16 +0800
Message-ID: <673b759a-cc35-e5db-4dd4-9677ab40d2a0@redhat.com>
References: <1509445938-4345-1-git-send-email-jasowang@redhat.com>
 <1509445938-4345-4-git-send-email-jasowang@redhat.com>
 <20171031184002-mutt-send-email-mst@kernel.org>
 <43c86606-2911-768d-704f-8b25e04cb47b@redhat.com>
 <20171101150458-mutt-send-email-mst@kernel.org>
 <20171101191213.2h5rlawpbnqtq662@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        willemdebruijn.kernel@gmail.com, tom@herbertland.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40350 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751428AbdKBDYX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 23:24:23 -0400
In-Reply-To: <20171101191213.2h5rlawpbnqtq662@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年11月02日 03:12, Alexei Starovoitov wrote:
> On Wed, Nov 01, 2017 at 03:59:48PM +0200, Michael S. Tsirkin wrote:
>> On Wed, Nov 01, 2017 at 09:02:03PM +0800, Jason Wang wrote:
>>>
>>> On 2017年11月01日 00:45, Michael S. Tsirkin wrote:
>>>>> +static void __tun_set_steering_ebpf(struct tun_struct *tun,
>>>>> +				    struct bpf_prog *new)
>>>>> +{
>>>>> +	struct bpf_prog *old;
>>>>> +
>>>>> +	old = rtnl_dereference(tun->steering_prog);
>>>>> +	rcu_assign_pointer(tun->steering_prog, new);
>>>>> +
>>>>> +	if (old) {
>>>>> +		synchronize_net();
>>>>> +		bpf_prog_destroy(old);
>>>>> +	}
>>>>> +}
>>>>> +
>>>> Is this really called under rtnl?
>>> Yes it is __tun_chr_ioctl() will call rtnl_lock().
>> Is the call from tun_free_netdev under rtnl too?
>>
>>>> If no then rtnl_dereference
>>>> is wrong. If yes I'm not sure you can call synchronize_net
>>>> under rtnl.
>>>>
>>> Are you worrying about the long wait? Looking at synchronize_net(), it does:
>>>
>>> void synchronize_net(void)
>>> {
>>>      might_sleep();
>>>      if (rtnl_is_locked())
>>>          synchronize_rcu_expedited();
>>>      else
>>>          synchronize_rcu();
>>> }
>>> EXPORT_SYMBOL(synchronize_net);
>>>
>>> Thanks
>> Not the wait - expedited is not a good thing to allow unpriveledged
>> userspace to do, it interrupts all VMs running on the same box.
>>
>> We could use a callback though the docs warn userspace can use that
>> to cause a DOS and needs to be limited.
> the whole __tun_set_steering_ebpf() looks odd to me.
> There is tun_attach_filter/tun_detach_filter pattern
> that works for classic BPF. Why for eBPF this strange
> synchronize_net() is there?
>

I'm not sure I get the question. eBPF here is used to do queue 
selection, so we could not reuse socket filter (tun_detach_filter use 
call_rcu()). cBPF could be used here, but I'm not quite sure it's worth 
to support it. And I agree we should use call_rcu() here.

Hope this answer your question.

Thanks
