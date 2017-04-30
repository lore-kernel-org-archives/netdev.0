From: Alexei Starovoitov <ast@fb.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for returning/setting
 egress port?
Date: Sat, 29 Apr 2017 18:04:33 -0700
Message-ID: <eff4fc1b-072b-13ed-a606-065904a6c9c3@fb.com>
References: <58F7E9F3.5090604@iogearbox.net>
 <20170420025611.GA53935@ast-mbp.thefacebook.com>
 <20170420081051.77a41aa8@redhat.com>
 <20170420171006.GA97067@ast-mbp.thefacebook.com>
 <20170425113453.5c72080f@redhat.com>
 <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
 <59000EF6.1050204@gmail.com> <20170426111158.578b925e@redhat.com>
 <5900CC41.2070502@gmail.com> <c9b3ff9b-8938-3274-da29-c04f9da2a314@fb.com>
 <20170426205544.GA40859@C02RW35GFVH8> <20170427104121.32df2178@redhat.com>
 <53e9dd2f-f40a-b43b-99c9-62f5ce3a665c@fb.com>
 <20170428125842.6b144d20@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46677 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S378375AbdD3BFW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 21:05:22 -0400
In-Reply-To: <20170428125842.6b144d20@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 3:58 AM, Jesper Dangaard Brouer wrote:
> On Thu, 27 Apr 2017 16:31:14 -0700
> Alexei Starovoitov <ast@fb.com> wrote:
>
>> On 4/27/17 1:41 AM, Jesper Dangaard Brouer wrote:
>>> When registering/attaching a XDP/bpf program, we would just send the
>>> file-descriptor for this port-map along (like we do with the bpf_prog
>>> FD). Plus, it own ingress-port number this program is in the port-map.
>>>
>>> It is not clear to me, in-which-data-structure on the kernel-side we
>>> store this reference to the port-map and ingress-port. As today we only
>>> have the "raw" struct bpf_prog pointer. I see several options:
>>>
>>> 1. Create a new xdp_prog struct that contains existing bpf_prog,
>>> a port-map pointer and ingress-port. (IMHO easiest solution)
>>>
>>> 2. Just create a new pointer to port-map and store it in driver rx-ring
>>> struct (like existing bpf_prog), but this create a race-challenge
>>> replacing (cmpxchg) the program (or perhaps it's not a problem as it
>>> runs under rcu and RTNL-lock).
>>>
>>> 3. Extend bpf_prog to store this port-map and ingress-port, and have a
>>> fast-way to access it.  I assume it will be accessible via
>>> bpf_prog->bpf_prog_aux->used_maps[X] but it will be too slow for XDP.
>>
>> I'm not sure I completely follow the 3 proposals.
>> Are you suggesting to have only one netdev_array per program?
>
> Yes, but I can see you have a more clever idea below.
>
>> Why not to allow any number like we do for tailcall+prog_array, etc?
>
>> We can teach verifier to allow new helper
>>  bpf_tx_port(netdev_array, port_num);
>> to only be used with netdev_array map type.
>> It will fetch netdevice pointer from netdev_array[port_num]
>> and will tx the packet into it.
>
> I love it.
>
> I just don't like the "netdev" part of the name "netdev_array" as one
> basic ideas of a port tabel, is that a port can be anything that can
> consume a XDP_buff packet.  This generalization allow us to move code
> out of the drivers.  We might be on the same page, as I do imagine that
> netdev_array or port_array is just a struct bpf_map pointer, and the
> bpf_map->map_type will tell us that this bpf_map contains net_device
> pointers.  Thus, when later introducing a new type of redirect (like to
> a socket or remote-CPU) then we just add a new bpf_map_type for this,
> without needing to change anything in the drivers, right?

In theory, yes, but in practice I doubt it will be so easy.
We probably shouldn't allow very different types of netdev
into the same netdev_array or port_array (whatever the name).
They need to be similar enough, otherwise we'd have to do run-time
checks. If they're all the same, these checks can be done at
insertion time instead.

> Do you imagine that bpf-side bpf_tx_port() returns XDP_REDIRECT?
> Or does it return if the call was successful (e.g validate port_num
> existed in map)?

don't know :)
we need to brainstorm pros and cons.

> On the kernel side, we need to receive this info "port_array" and
> "port_num", given you don't provide the call a xdp_buff/ctx, then I
> assume you want the per-CPU temp-store solution.  Then during the
> XDP_REDIRECT action we call a core redirect function that based on the
> bpf_map_type does a lookup, and find the net_device ptr.

hmm. didn't think that far either :)
indeed makes sense to pass 'ctx' into such helper as well,
so it's easier to deal with original netdev.

>> We can make it similar to bpf_tail_call(), so that program will
>> finish on successful bpf_tx_port() or
>> make it into 'delayed' tx which will be executed when program finishes.
>> Not sure which approach is better.
>
> I know you are talking about something slightly different, about
> delaying TX.
>
> But I want to mention (as I've done before) that it is important (for
> me) that we get bulking working/integrated.   I imagine the driver will
> call a function that will delay the TX/redirect action and at the end
> of the NAPI cycle have a function that flush packets, bulk per
> destination port.
>
> I was wondering where to store these delayed TX packets, but now that
> we have an associated bpf_map data-structure (netdev_array), I'm thinking
> about storing packets (ordered by port) inside that.  And then have a
> bpf_tx_flush(netdev_array) call in the driver (for every port-table-map
> seen, which will likely be small).

makes sense to me as well.
Ideally we should try to make an api such, that batching or no-batching
can be kernel choice. The program will just do
xdp_tx_port(...something here...)
and the kernel does the best for performance. If it needs to delay
the result to do batching the api should allow that transparently.
Like right now xdp program does 'return XDP_TX;' and
on the kernel side we can either do immediate xmit (like we do today)
or can change it to do batching and programs don't need to change.

>> We can also extend this netdev_array into broadcast/multicast. Like
>> bpf_tx_allports(&netdev_array);
>> call from the program will xmit the packet to all netdevices
>> in that 'netdev_array' map type.
>
> When broadcasting you often don't want to broadcast the packet out of
> the incoming interface.  How can you support this?
>
> Normally you would know your ingress port, and then excluded that port
> in the broadcast.  But with many netdev_array's how do the program know
> it's own ingress port.

absolutely!
bpf_tx_allports() should somehow exclude the port packet arrived on.
What you're proposing about passing 'ctx' into this helper,
should solve it, I guess.

> Thanks a lot for all this input, I got a much more clear picture of how
> I can/should implement this :-)

awesome :) Let's brainstorm more and get John's opinion on it as well,
since sounds like he'll be heavy user of such api.
