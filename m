From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel
 encapsulation
Date: Tue, 1 Nov 2016 11:54:16 +0100
Message-ID: <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
References: <cover.1477959702.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46362 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1168704AbcKAKyV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 06:54:21 -0400
In-Reply-To: <cover.1477959702.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On 01.11.2016 01:37, Thomas Graf wrote:
> {Open question:
>  Tom brought up the question on whether it is safe to modify the packet
>  in artbirary ways before dst_output(). This is the equivalent to a raw
>  socket injecting illegal headers. This v2 currently assumes that
>  dst_output() is ready to accept invalid header values. This needs to be
>  verified and if not the case, then raw sockets or dst_output() handlers
>  must be fixed as well. Another option is to mark lwtunnel_output() as
>  read-only for now.}
> 
> This series implements BPF program invocation from dst entries via the
> lightweight tunnels infrastructure. The BPF program can be attached to
> lwtunnel_input(), lwtunnel_output() or lwtunnel_xmit() and sees an L3
> skb as context. input is read-only, output can write, xmit can write,
> push headers, and redirect.
> 
> Motiviation for this work:
>  - Restricting outgoing routes beyond what the route tuple supports
>  - Per route accounting byond realms
>  - Fast attachment of L2 headers where header does not require resolving
>    L2 addresses
>  - ILA like uses cases where L3 addresses are resolved and then routed
>    in an async manner
>  - Fast encapsulation + redirect. For now limited to use cases where not
>    setting inner and outer offset/protocol is OK.
> 
> A couple of samples on how to use it can be found in patch 04.

I do fear the complexity and debugability introduced by this patch set
quite a bit.

I wonder if architecturally it would be more feasible to add a generic
(bfp-)hook into into dst_output(_sk) and allow arbitrary metadata to be
added into the dsts.

BPF could then be able to access parts of the metadata in the attached
metadata dst entries and performing the matching this way?

The reason why I would prefer an approach like this: irregardless of the
routing lookup we would process the skb with bpf or not. This gives a
single point to debug, where instead in your approach we first must
figure out the corresponding bpf program and then check for it specifically.

Thanks,
Hannes
