From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Wed, 19 Apr 2017 14:25:55 +0200
Message-ID: <49f993a6-d45a-71cf-3ade-e65f88088af7@stressinduktion.org>
References: <20170418215856.5fda7127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:34975 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1762936AbdDSMZ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 08:25:58 -0400
In-Reply-To: <20170418215856.5fda7127@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 18.04.2017 21:58, Jesper Dangaard Brouer wrote:
> 
> As I argued in NetConf presentation[1] (from slide #9) we need a port
> mapping table (instead of using ifindex'es).  Both for supporting
> other "port" types than net_devices (think sockets), and for
> sandboxing what XDP can bypass.
> 
> I want to create a new XDP action called XDP_REDIRECT, that instruct
> XDP to send the xdp_buff to another "port" (get translated into a
> net_device, or something else depending on internal port type).
> 
> Looking at the userspace/eBPF interface, I'm wondering what is the
> best API for "returning" this port number from eBPF?
> 
> The options I see is:
> 
> 1) Split-up the u32 action code, and e.g let the high-16-bit be the
>    port number and lower-16bit the (existing) action verdict.
> 
>  Pros: Simple API
>  Cons: Number of ports limited to 64K
> 
> 2) Extend both xdp_buff + xdp_md to contain a (u32) port number, allow
>    eBPF to update xdp_md->port.
> 
>  Pros: Larger number of ports.
>  Cons: This require some ebpf translation steps between xdp_buff <-> xdp_md.
>        (see xdp_convert_ctx_access)
> 
> 3) Extend only xdp_buff and create bpf_helper that set port in xdp_buff.
> 
>  Pros: Hides impl details, and allows helper to give eBPF code feedback
>        (on e.g. if port doesn't exist any longer)
>  Cons: Helper function call likely slower?
> 
> 
> (Cc'ed xdp-newbies as end-users might have an opinion on UAPI?)

I am not sure how the socket interface should look like, it seems to be
too far away to me right now.

Regarding having stable ifindexes, I wonder if we could do something:

int ifindexes_in_use_by_ebpf_program[] __section("ifindex") = {
1,2,3,8,9,10 };

and we can make sure that the ifindexes automatically stay stable for
the lifetime while the ebpf program is loaded?

Bye,
Hannes
