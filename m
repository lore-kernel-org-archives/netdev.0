From: Alexei Starovoitov <ast@fb.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for returning/setting
 egress port?
Date: Sat, 29 Apr 2017 18:35:40 -0700
Message-ID: <eba8e7e4-e24b-82cc-5823-906716e9edc2@fb.com>
References: <58F7E9F3.5090604@iogearbox.net>
 <20170420025611.GA53935@ast-mbp.thefacebook.com>
 <20170420081051.77a41aa8@redhat.com>
 <20170420171006.GA97067@ast-mbp.thefacebook.com>
 <20170425113453.5c72080f@redhat.com>
 <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
 <59000EF6.1050204@gmail.com> <20170426111158.578b925e@redhat.com>
 <5900CC41.2070502@gmail.com> <c9b3ff9b-8938-3274-da29-c04f9da2a314@fb.com>
 <20170426205544.GA40859@C02RW35GFVH8> <20170427104121.32df2178@redhat.com>
 <53e9dd2f-f40a-b43b-99c9-62f5ce3a665c@fb.com> <5902CDC5.5010209@gmail.com>
 <b15f490d-5490-e309-9626-d35b8e932483@fb.com>
 <dd965e88-b9fd-4d58-4272-07588b842252@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "Andy Gospodarek" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50604 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754219AbdD3BgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 21:36:08 -0400
In-Reply-To: <dd965e88-b9fd-4d58-4272-07588b842252@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 12:43 PM, Hannes Frederic Sowa wrote:
> On 28.04.2017 07:30, Alexei Starovoitov wrote:
>> On 4/27/17 10:06 PM, John Fastabend wrote:
>>> That is more or less what I was thinking as well. The other question
>>> I have though is should we have a bpf_redirect() call for the simple
>>> case where I use the ifindex directly. This will be helpful for taking
>>> existing programs from tc_cls into xdp. I think it makes sense to have
>>> both bpf_tx_allports(), bpf_tx_port(), and bpf_redirect().
>>
>> I think so too.
>> Once netdevice is stored into netdev_array map the netdevice is pinned
>> and we need to figure out what to do if somebody tries to delete it.
>> Should we add a new netlink notifier that this netdev's refcnt is
>> almost zero and it's only in netdev_array(s) ?
>
> We basically do that automatically in netdev_wait_allrefs:
>
> pr_emerg("unregister_netdevice: waiting for %s to become free. Usage
> count = %d\n",
>          dev->name, refcnt);
>
> It is a very unpleasant warning and users probably think about a bug in
> the kernel at first.
>
> I don't think we should wait for user space to clean that up but have to
> do it automatically from the kernel. Maybe we can introduce a special
> value that basically NOPs the transmission. The hash table itself would
> install a netdevice notifier and would clean all tables. Could
> definitely cause some storm in the kernel, if a lot of keys are mapped
> to the same interface.
>
>> or should it be deleted from the array(s) automatically and
>> then user space will be notified post-deletion?
>> Both approaches have their pros and cons.
>
> I am leaning more towards deleting it automatically. But walking all
> tables and in there all keys might cause some unwanted load spikes.

yeah, when netdev is being unregistered we have to drop the ref
to avoid the warning.

Speaking of delete notifiers for maps.
Until recently all deletions were explicit and the program
could do extra perf_event_submit() if it needed to notify
user space of deletion.
But right now we have LRU map that deletes automatically and this
netdev_array will be deleting automatically too, so we probably
need some sort of generic map notifier for all map types.
It can be as simple as user space sleeping on read(map_fd, buf);
or waiting for epoll on map_fd and kernel wakes it up
when map element is deleted and pushes 'key/value' pair
into the buf. That should be generic for all map types,
but it needs some mechanism to avoid blocking, since number
of deletions can be huge. Something similar to perf's event record
'lost N records' should do the trick.
