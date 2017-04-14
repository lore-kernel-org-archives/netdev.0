From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Sat, 15 Apr 2017 00:18:19 +0200
Message-ID: <58F14AAB.50201@iogearbox.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net> <20170413042036.GA46229@ast-mbp.thefacebook.com> <20170413.113722.2174945057832588335.davem@davemloft.net> <20170414110525.41317f5a@redhat.com> <20170414192814.GD41922@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42519 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbdDNWS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 18:18:27 -0400
In-Reply-To: <20170414192814.GD41922@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2017 09:28 PM, Alexei Starovoitov wrote:
> On Fri, Apr 14, 2017 at 11:05:25AM +0200, Jesper Dangaard Brouer wrote:
>>>
>>> We are consistently finding that there is this real need to
>>> communicate XDP capabilities, or somehow verify that the needs
>>> of an XDP program can be satisfied by a given implementation.
>>
>> I fully agree that we need some way to express capabilities[1]
>>
>>> Maximum headroom is just one.
>
> I don't like the idea of asking program author to explain capabilities
> to the kernel. Right now the verifier already understands more about
> the program than human does. If the verifier cannot deduct from the
> insns what program will be doing, it's pretty much guarantee
> that program author has no idea either.
> If we add 'required_headroom' as an extra flag to BPF_PROG_LOAD,
> the users will just pass something like 64 or 128 whereas the program
> might only be doing IPIP encap and that will cause kernel to
> provide extra headroom for no good reason or reject the program
> whereas it could have run just fine.

Fully agree, such an extension is likely to be used wrongly or with
some default size as we have right now with XDP_PACKET_HEADROOM to
cover most use cases in order to not bother the user to deal with
this resp. not to complicate things more.

> So I very much agree with this part:
>> ... or somehow verify that the needs
>> of an XDP program can be satisfied by a given implementation.
>
> we already have cb_access, dst_needed, xdp_adjust_head flags
> that verifier discovers in the program.
> For headroom we need one more. The verifier can see
> the constant passed into bpf_xdp_adjust_head().
> It's trickier if it's a variable, but the verifier can estimate min/max
> of the variable already and worst case it can say that it
> will be XDP_PACKET_HEADROOM.

+1, we should try hard to reuse such information from the verifier
to determine specific requirements the program has, and check against
them at prog attach time. This works okay so far for the already
mentioned bits in struct bpf_prog, and could be further extended.

> If the program is doing variable length bpf_xdp_adjust_head(),
> the human has no idea how much they need and cannot tell kernel anyway.
