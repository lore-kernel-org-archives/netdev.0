From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for returning/setting
 egress port?
Date: Thu, 27 Apr 2017 22:06:13 -0700
Message-ID: <5902CDC5.5010209@gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33088 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966796AbdD1FG2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 01:06:28 -0400
In-Reply-To: <53e9dd2f-f40a-b43b-99c9-62f5ce3a665c@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-27 04:31 PM, Alexei Starovoitov wrote:
> On 4/27/17 1:41 AM, Jesper Dangaard Brouer wrote:
>> When registering/attaching a XDP/bpf program, we would just send the
>> file-descriptor for this port-map along (like we do with the bpf_prog
>> FD). Plus, it own ingress-port number this program is in the port-map.
>>
>> It is not clear to me, in-which-data-structure on the kernel-side we
>> store this reference to the port-map and ingress-port. As today we only
>> have the "raw" struct bpf_prog pointer. I see several options:
>>
>> 1. Create a new xdp_prog struct that contains existing bpf_prog,
>> a port-map pointer and ingress-port. (IMHO easiest solution)
>>
>> 2. Just create a new pointer to port-map and store it in driver rx-ring
>> struct (like existing bpf_prog), but this create a race-challenge
>> replacing (cmpxchg) the program (or perhaps it's not a problem as it
>> runs under rcu and RTNL-lock).
>>
>> 3. Extend bpf_prog to store this port-map and ingress-port, and have a
>> fast-way to access it.  I assume it will be accessible via
>> bpf_prog->bpf_prog_aux->used_maps[X] but it will be too slow for XDP.
> 
> I'm not sure I completely follow the 3 proposals.
> Are you suggesting to have only one netdev_array per program?
> Why not to allow any number like we do for tailcall+prog_array, etc?
> We can teach verifier to allow new helper
> bpf_tx_port(netdev_array, port_num);
> to only be used with netdev_array map type.
> It will fetch netdevice pointer from netdev_array[port_num]
> and will tx the packet into it.
> We can make it similar to bpf_tail_call(), so that program will
> finish on successful bpf_tx_port() or
> make it into 'delayed' tx which will be executed when program finishes.
> Not sure which approach is better.

My reaction would be to make it finish on success but would like to write
a few programs first and see. I can't think of any use _not_ to terminate
but maybe there is something I'm missing.

> 
> We can also extend this netdev_array into broadcast/multicast. Like
> bpf_tx_allports(&netdev_array);
> call from the program will xmit the packet to all netdevices
> in that 'netdev_array' map type.

Yep nice solution to the multicast problem.

> 
> The map-in-map support can be trivially extended to allow netdev_array,
> then the program can create N multicast groups of netdevices.
> Each multicast group == one netdev_array map.
> The user space will populate a hashmap with these netdev_arrays and
> bpf kernel side can select dynamically which multicast group to use
> to send the packets to.
> bpf kernel side may look like:
> struct bpf_netdev_array *netdev_array = bpf_map_lookup_elem(&hash, key);
> if (!netdev_array)
>   ...
> if (my_condition)
>    bpf_tx_allports(netdev_array);  /* broadcast to all netdevices */
> else
>    bpf_tx_port(netdev_array, port_num); /* tx into one netdevice */
> 
> that's an artificial example. Just trying to point out
> that we shouldn't restrict the feature too soon.
> 

That is more or less what I was thinking as well. The other question
I have though is should we have a bpf_redirect() call for the simple
case where I use the ifindex directly. This will be helpful for taking
existing programs from tc_cls into xdp. I think it makes sense to have
both bpf_tx_allports(), bpf_tx_port(), and bpf_redirect().

.John
