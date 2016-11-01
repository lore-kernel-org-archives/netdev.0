From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 3/5] bpf: BPF for lightweight tunnel
 encapsulation
Date: Tue, 1 Nov 2016 14:11:58 -0600
Message-ID: <0bfff5e0-cd4a-4d69-d54c-7d6dbf237db7@cumulusnetworks.com>
References: <cover.1477959702.git.tgraf@suug.ch>
 <d8c7e07ac7d289a2846af8d659287f3512a4edec.1477959702.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33126 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752596AbcKAUMB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 16:12:01 -0400
Received: by mail-pf0-f179.google.com with SMTP id d2so25465969pfd.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 13:12:00 -0700 (PDT)
In-Reply-To: <d8c7e07ac7d289a2846af8d659287f3512a4edec.1477959702.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 6:37 PM, Thomas Graf wrote:
> Register two new BPF prog types BPF_PROG_TYPE_LWT_IN and
> BPF_PROG_TYPE_LWT_OUT which are invoked if a route contains a
> LWT redirection of type LWTUNNEL_ENCAP_BPF.
> 
> The separate program types are required because manipulation of
> packet data is only allowed on the output and transmit path as
> the subsequent dst_input() call path assumes an IP header
> validated by ip_rcv(). The BPF programs will be handed an skb
> with the L3 header attached and may return one of the following
> return codes:
> 
>  BPF_OK - Continue routing as per nexthop
>  BPF_DROP - Drop skb and return EPERM
>  BPF_REDIRECT - Redirect skb to device as per redirect() helper.
>                 (Only valid on lwtunnel_xmit() hook)
> 
> The return codes are binary compatible with their TC_ACT_
> relatives to ease compatibility.
> 
> A new helper bpf_skb_push() is added which allows to preprend an
> L2 header in front of the skb, extend the existing L3 header, or
> both. This allows to address a wide range of issues:
>  - Optimize L2 header construction when L2 information is always
>    static to avoid ARP/NDisc lookup.
>  - Extend IP header to add additional IP options.
>  - Perform simple encapsulation where offload is of no concern.
>    (The existing funtionality to attach a tunnel key to the skb
>     and redirect to a tunnel net_device to allow for offload
>     continues to work obviously).

have you tested the adding of headers with large packets hitting gso and fragmentation? Wondering if mtu is used properly when headers are added and the lwt->headroom is not accounted. See 14972cbd34ff668c390cbd2e6497323484c9e812
