From: Robert Shearman <rshearma@brocade.com>
Subject: Re: MPLS outbound packets being dropped
Date: Mon, 7 Dec 2015 10:40:25 +0000
Message-ID: <56656219.7070009@brocade.com>
References: <CAJm+voUzeyccnn57U_LEDQNO1qyn9xEYMDOjvqWeW+awifuDCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa <roopa@cumulusnetworks.com>
To: Sam Russell <sam.h.russell@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:52250 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754647AbbLGKkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 05:40:43 -0500
In-Reply-To: <CAJm+voUzeyccnn57U_LEDQNO1qyn9xEYMDOjvqWeW+awifuDCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/15 10:20, Sam Russell wrote:
> tl;dr mpls_output expects skb->protocol to be set to correct
> ethertype, but it isn't
>
> https://github.com/torvalds/linux/blob/ede2059dbaf9c6557a49d466c8c7778343b208ff/net/mpls/mpls_iptunnel.c#L64
>
> Problem:
>
> I set up two interfaces pointed at each other, and added a static arp
> entry to minimise complexity
>
> ifconfig enp0s8 10.0.0.1/24 up
> ifconfig enp0s9 up
> arp -s 10.0.0.5 00:12:34:56:78:90
>
> I then added an MPLS route
>
> ./dev/iproute2/ip/ip route add 192.168.2.0/24 encap mpls 100 via inet
> 10.0.0.5 dev enp0s8
>
> I then tried to ping an IP in this route but got errors back
>
> ping 192.168.2.1
> * PING 192.168.2.1 (192.168.2.1) 56(84) bytes of data.
> * ping: sendmsg: Invalid argument
>
> I then recorded calls to skb_kfree
>
> ./tools/perf/perf record -e skb:kfree_skb -g -a
>
> This gave me the following packet trace:
>
>     100.00%   100.00%  ping     [kernel.kallsyms]  [k] kfree_skb
>                 |
>                 ---kfree_skb
>                    mpls_output
>                    lwtunnel_output
>                    ip_local_out_sk
>                    ip_send_skb
>                    ip_push_pending_frames
>                    raw_sendmsg
>                    inet_sendmsg
>                    sock_sendmsg
>                    ___sys_sendmsg
>                    __sys_sendmsg
>                    sys_sendmsg
>                    entry_SYSCALL_64_fastpath
>                    sendmsg
>                    0
>
> I then went through mpls_output.c and put printk() at every call to
> "goto drop" and found that this was being hit after failing to match
> skb->protocol
>
> https://github.com/torvalds/linux/blob/ede2059dbaf9c6557a49d466c8c7778343b208ff/net/mpls/mpls_iptunnel.c#L64
>
> My understanding is that skb->protocol is normally set after
> dst_output. For example, a ping packet hitting a normal IPv4 route
> should follow something like:
>
> raw_sendmsg
> ip_push_pending_frames
> ip_send_skb
> ip_local_out_sk
> dst_output
> ip_output
>
> ip_output() is the first place where skb->protocol gets set
>
> https://github.com/torvalds/linux/blob/dbd3393c56a8794fe596e7dd20d0efa613b9cf61/net/ipv4/ip_output.c#L356
>
> The path that a packet follows when hitting an MPLS route is as follows:
>
> raw_sendmsg
> ip_push_pending_frames
> ip_send_skb
> ip_local_out_sk
> dst_output
> lwtunnel_output
> mpls_output
>
> lwtunnel_output merely routes to the correct output function (mpls_output)
> mpls_output expects skb->protocol to be set, but nothing has set it
> yet, so it drops the packet!
>
> Any suggestions on how mpls_output should detect the protocol?

Thanks for reporting this and for your analysis.

We could write wrappers to lwtunnel_output for the v4 and v6 cases that 
set the protocol accordingly and then call lwtunnel_output, but since 
mpls_output relies on the AF-specific type of dst I think the simpler 
fix is to just test the type of the dst in mpls_output rather than 
skb->protocol.

Thanks,
Rob
