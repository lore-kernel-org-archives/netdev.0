From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Tue, 18 Apr 2017 13:54:45 -0700
Message-ID: <58F67D15.3050308@gmail.com>
References: <20170418215856.5fda7127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33996 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752310AbdDRUzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 16:55:04 -0400
In-Reply-To: <20170418215856.5fda7127@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-18 12:58 PM, Jesper Dangaard Brouer wrote:
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

How about doing this the same way redirect is done in the tc case? I have this
patch under test,

 https://github.com/jrfastab/linux/commit/e78f5425d5e3c305b4170ddd85c61c2e15359fee

that should give you some idea. It just needs a port mapping table in the
bpf_tx_xdp() call.


> (Cc'ed xdp-newbies as end-users might have an opinion on UAPI?)
> 
