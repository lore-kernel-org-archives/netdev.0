From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 2/2 v2] net: Remove VRF change to udp_sendmsg
Date: Wed, 9 Sep 2015 17:51:19 -0700
Message-ID: <CALx6S35Fwu5QsR-W=0LVzvZv_PGqbV3TGR9T5YRU65QCY0OgzQ@mail.gmail.com>
References: <1441835862-41403-1-git-send-email-dsa@cumulusnetworks.com>
	<1441835862-41403-2-git-send-email-dsa@cumulusnetworks.com>
	<CALx6S35scg=6vr9zPBD=_VPHGDwkq22hQM4Ce2roi4j5DXrYZw@mail.gmail.com>
	<55F0CD92.7080700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36733 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbIJAvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 20:51:20 -0400
Received: by ioii196 with SMTP id i196so42780169ioi.3
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 17:51:20 -0700 (PDT)
In-Reply-To: <55F0CD92.7080700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 9, 2015 at 5:23 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 9/9/15 6:04 PM, Tom Herbert wrote:
>>
>> On Wed, Sep 9, 2015 at 2:57 PM, David Ahern <dsa@cumulusnetworks.com>
>> wrote:
>>>
>>> Remove the VRF change in udp_sendmsg to set the source address. The VRF
>>> driver already has access to the packet on the TX path via the dst. It
>>> can be used to update the source address in the header. Since the VRF
>>> device is directly associated with a table use fib_table_lookup rather
>>> than the ip_route_output lookup functions.
>>>
>>> Function to update source address based on similar code in OVS.
>>>
>> I have the same comment as in v1 of this patch. Implementing address
>> selection by doing SNAT is not the right approach.
>
>
> Hi Tom:
>
> As I mentioned before this is not SNAT. The source address is being done at
> L3 just as it is in the non-VRF case, and it is only set if the prior layers
> have not.
>
It is NAT since you are changing the source address and modifying the
transport protocol checksum below IP and transport layer. There are a
bunch of side effects that you would need to consider. This is
creating custom APIs changing the semantics of address selection, and
also creates inconsistency between how addresses may be selected
between a connected and unconnected sockets. Consider that
ip_local_out_sk calls netfilter NF_INET_LOCAL_OUT hook before
dst->output, so then netfilter would start seeing packets with zero
source address???

A lot of design in the stack is predicated on inet_select_addr
returning the source address to use for sending a packet. This should
always return a reasonable address as an invariant, if someone wishes
to rewrite addresses at a lower layer that's fine, but that should be
defined as a NAT operation. If a device wants to weigh in on address
selection then we can define an ndo function for that as I mentioned
before.

Tom

> vrf_set_ip_saddr is called by vrf_output. Setting a probe on a test case
> shows:
>
> root@vm-wheezy:~# perf probe vrf_output
> Added new event:
>   probe:vrf_output     (on vrf_output)
>
> You can now use it in all perf tools, such as:
>
>         perf record -e probe:vrf_output -aR sleep 1
>
> root@vm-wheezy:~# perf record -e probe:vrf_output -a -g -- vrf-test -t dgram
> -I vrf10 -r 10.2.1.254
> 09/09/2015 11:19:40 Sent message:
> 09/09/2015 11:19:40     Hello world!
> 09/09/2015 11:19:40 Message from: 10.2.1.254:12345
> 09/09/2015 11:19:40     Hello world!
> [ perf record: Woken up 1 times to write data ]
> [ perf record: Captured and wrote 0.050 MB perf.data (1 samples) ]
>
> root@vm-wheezy:~# perf script --kallsyms /tmp/kallsyms
> vrf-test  2773 [002]   207.598817: probe:vrf_output: (ffffffff813a5959)
>         ffffffff813a595a vrf_output ([kernel.kallsyms])
>         ffffffff81451dd7 ip_local_out_sk ([kernel.kallsyms])
>         ffffffff81452cd7 ip_send_skb ([kernel.kallsyms])
>         ffffffff8147571e udp_send_skb ([kernel.kallsyms])
>         ffffffff81475f6f udp_sendmsg ([kernel.kallsyms])
>         ffffffff8147feec inet_sendmsg ([kernel.kallsyms])
>         ffffffff813ffc18 sock_sendmsg_nosec ([kernel.kallsyms])
>         ffffffff81401414 SYSC_sendto ([kernel.kallsyms])
>         ffffffff814015dd sys_sendto ([kernel.kallsyms])
>         ffffffff81526572 entry_SYSCALL_64_fastpath ([kernel.kallsyms])
>                    dc9d3 sendto (/lib/x86_64-linux-gnu/libc-2.13.so)
>                     3217 main (/root/bin/vrf-test)
>                    1eead __libc_start_main
> (/lib/x86_64-linux-gnu/libc-2.13.so)
>
> Packets are diverted to the VRF device via a static/custom dst which has the
> output operation set to vrf_output.
>
> David
>
