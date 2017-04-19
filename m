From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Wed, 19 Apr 2017 14:33:27 +0200
Message-ID: <58F75917.1050409@iogearbox.net>
References: <20170418215856.5fda7127@redhat.com>        <58F67D15.3050308@gmail.com> <20170419140019.366fb1fb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45083 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763200AbdDSMde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 08:33:34 -0400
In-Reply-To: <20170419140019.366fb1fb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2017 02:00 PM, Jesper Dangaard Brouer wrote:
> On Tue, 18 Apr 2017 13:54:45 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
>> On 17-04-18 12:58 PM, Jesper Dangaard Brouer wrote:
>>>
>>> As I argued in NetConf presentation[1] (from slide #9) we need a port
>>> mapping table (instead of using ifindex'es).  Both for supporting
>>> other "port" types than net_devices (think sockets), and for
>>> sandboxing what XDP can bypass.
>>>
>>> I want to create a new XDP action called XDP_REDIRECT, that instruct
>>> XDP to send the xdp_buff to another "port" (get translated into a
>>> net_device, or something else depending on internal port type).
>>>
>>> Looking at the userspace/eBPF interface, I'm wondering what is the
>>> best API for "returning" this port number from eBPF?
>>>
>>> The options I see is:
>>>
>>> 1) Split-up the u32 action code, and e.g let the high-16-bit be the
>>>     port number and lower-16bit the (existing) action verdict.
>>>
>>>   Pros: Simple API
>>>   Cons: Number of ports limited to 64K
>>>
>>> 2) Extend both xdp_buff + xdp_md to contain a (u32) port number, allow
>>>     eBPF to update xdp_md->port.
>>>
>>>   Pros: Larger number of ports.
>>>   Cons: This require some ebpf translation steps between xdp_buff <-> xdp_md.
>>>         (see xdp_convert_ctx_access)
>>>
>>> 3) Extend only xdp_buff and create bpf_helper that set port in xdp_buff.
>>>
>>>   Pros: Hides impl details, and allows helper to give eBPF code feedback
>>>         (on e.g. if port doesn't exist any longer)
>>>   Cons: Helper function call likely slower?
>>
>> How about doing this the same way redirect is done in the tc case? I have this
>> patch under test,
>>
>>   https://github.com/jrfastab/linux/commit/e78f5425d5e3c305b4170ddd85c61c2e15359fee
>
> I have been looking at this approach, which is close to option #3 above.
>
> The problem with your implementation that you use a per-cpu store.
> This creates the problem of storing state between packets. First packet
> can call helper bpf_xdp_redirect() setting an ifindex, but program can
> still return XDP_PASS.  Next packet can call XDP_REDIRECT and use the
> ifindex set from the first packet.  IMHO this is a problematic API to
> expose.
>
> I do see that the TC interface that uses the same approach, via helper
> bpf_redirect().  Maybe it have the same API problem?  Looking at
> sch_handle_ingress() I don't see this is handled (e.g. by always
> clearing this_cpu_ptr(redirect_info)->ifindex = 0).

It's cleared in {skb,xdp}_do_redirect() right after fetching the
ifindex. I think this approach is just fine. The example described
above is a misuse of the API by a buggy program calling bpf_xdp_redirect()
and returning XDP_PASS while another time it returns XDP_REDIRECT
without the bpf_xdp_redirect() helper, sounds very exotic, but it's
as buggy as, say, a program doing the csum update wrong, a program
writing the wrong data to the packet, doing adjust head on the wrong
header offset, jumping into the wrong tail call entry and other things.

I think encoding this into an action code is rather limiting, f.e.
where would we place a flags argument if needed in future? Would
that mean, we need a XDP_REDIRECT2 return code that also allows for
encoding flags?

Thanks,
Daniel
