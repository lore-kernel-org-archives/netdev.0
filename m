From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for
 returning/setting egress port?
Date: Fri, 28 Apr 2017 12:58:42 +0200
Message-ID: <20170428125842.6b144d20@redhat.com>
References: <58F7E9F3.5090604@iogearbox.net>
        <20170420025611.GA53935@ast-mbp.thefacebook.com>
        <20170420081051.77a41aa8@redhat.com>
        <20170420171006.GA97067@ast-mbp.thefacebook.com>
        <20170425113453.5c72080f@redhat.com>
        <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
        <59000EF6.1050204@gmail.com>
        <20170426111158.578b925e@redhat.com>
        <5900CC41.2070502@gmail.com>
        <c9b3ff9b-8938-3274-da29-c04f9da2a314@fb.com>
        <20170426205544.GA40859@C02RW35GFVH8>
        <20170427104121.32df2178@redhat.com>
        <53e9dd2f-f40a-b43b-99c9-62f5ce3a665c@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        brouer@redhat.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28848 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034955AbdD1K6u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 06:58:50 -0400
In-Reply-To: <53e9dd2f-f40a-b43b-99c9-62f5ce3a665c@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Apr 2017 16:31:14 -0700
Alexei Starovoitov <ast@fb.com> wrote:

> On 4/27/17 1:41 AM, Jesper Dangaard Brouer wrote:
> > When registering/attaching a XDP/bpf program, we would just send the
> > file-descriptor for this port-map along (like we do with the bpf_prog
> > FD). Plus, it own ingress-port number this program is in the port-map.
> >
> > It is not clear to me, in-which-data-structure on the kernel-side we
> > store this reference to the port-map and ingress-port. As today we only
> > have the "raw" struct bpf_prog pointer. I see several options:
> >
> > 1. Create a new xdp_prog struct that contains existing bpf_prog,
> > a port-map pointer and ingress-port. (IMHO easiest solution)
> >
> > 2. Just create a new pointer to port-map and store it in driver rx-ring
> > struct (like existing bpf_prog), but this create a race-challenge
> > replacing (cmpxchg) the program (or perhaps it's not a problem as it
> > runs under rcu and RTNL-lock).
> >
> > 3. Extend bpf_prog to store this port-map and ingress-port, and have a
> > fast-way to access it.  I assume it will be accessible via
> > bpf_prog->bpf_prog_aux->used_maps[X] but it will be too slow for XDP.  
> 
> I'm not sure I completely follow the 3 proposals.
> Are you suggesting to have only one netdev_array per program?

Yes, but I can see you have a more clever idea below.

> Why not to allow any number like we do for tailcall+prog_array, etc?

> We can teach verifier to allow new helper
>  bpf_tx_port(netdev_array, port_num);
> to only be used with netdev_array map type.
> It will fetch netdevice pointer from netdev_array[port_num]
> and will tx the packet into it.

I love it. 

I just don't like the "netdev" part of the name "netdev_array" as one
basic ideas of a port tabel, is that a port can be anything that can
consume a XDP_buff packet.  This generalization allow us to move code
out of the drivers.  We might be on the same page, as I do imagine that
netdev_array or port_array is just a struct bpf_map pointer, and the
bpf_map->map_type will tell us that this bpf_map contains net_device
pointers.  Thus, when later introducing a new type of redirect (like to
a socket or remote-CPU) then we just add a new bpf_map_type for this,
without needing to change anything in the drivers, right?

Do you imagine that bpf-side bpf_tx_port() returns XDP_REDIRECT?
Or does it return if the call was successful (e.g validate port_num
existed in map)?

On the kernel side, we need to receive this info "port_array" and
"port_num", given you don't provide the call a xdp_buff/ctx, then I
assume you want the per-CPU temp-store solution.  Then during the
XDP_REDIRECT action we call a core redirect function that based on the
bpf_map_type does a lookup, and find the net_device ptr.


> We can make it similar to bpf_tail_call(), so that program will
> finish on successful bpf_tx_port() or
> make it into 'delayed' tx which will be executed when program finishes.
> Not sure which approach is better.

I know you are talking about something slightly different, about
delaying TX.

But I want to mention (as I've done before) that it is important (for
me) that we get bulking working/integrated.   I imagine the driver will
call a function that will delay the TX/redirect action and at the end
of the NAPI cycle have a function that flush packets, bulk per
destination port.

I was wondering where to store these delayed TX packets, but now that
we have an associated bpf_map data-structure (netdev_array), I'm thinking
about storing packets (ordered by port) inside that.  And then have a
bpf_tx_flush(netdev_array) call in the driver (for every port-table-map
seen, which will likely be small).


> We can also extend this netdev_array into broadcast/multicast. Like
> bpf_tx_allports(&netdev_array);
> call from the program will xmit the packet to all netdevices
> in that 'netdev_array' map type.

When broadcasting you often don't want to broadcast the packet out of
the incoming interface.  How can you support this?

Normally you would know your ingress port, and then excluded that port
in the broadcast.  But with many netdev_array's how do the program know
it's own ingress port.


> The map-in-map support can be trivially extended to allow netdev_array,
> then the program can create N multicast groups of netdevices.
> Each multicast group == one netdev_array map.
> The user space will populate a hashmap with these netdev_arrays and
> bpf kernel side can select dynamically which multicast group to use
> to send the packets to.
> bpf kernel side may look like:
> struct bpf_netdev_array *netdev_array = bpf_map_lookup_elem(&hash, key);
> if (!netdev_array)
>    ...
> if (my_condition)
>     bpf_tx_allports(netdev_array);  /* broadcast to all netdevices */
> else
>     bpf_tx_port(netdev_array, port_num); /* tx into one netdevice */
> 
> that's an artificial example. Just trying to point out
> that we shouldn't restrict the feature too soon.
 
I like how you solve the multicast problem.  (But I do need to learn
some more of the inner-workings of bpf map-in-map to follow this
completely).

Thanks a lot for all this input, I got a much more clear picture of how
I can/should implement this :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
