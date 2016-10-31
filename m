From: Tom Herbert <tom@herbertland.com>
Subject: Re: XDP question - how much can BPF change in xdp_buff?
Date: Mon, 31 Oct 2016 13:29:23 -0700
Message-ID: <CALx6S37bfMpMhWTSL-WzumGfqywi0oJPnLqj_yEUs61AtyLZKA@mail.gmail.com>
References: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36235 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946342AbcJaU3Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:29:25 -0400
Received: by mail-qk0-f172.google.com with SMTP id o68so177336599qkf.3
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:29:25 -0700 (PDT)
In-Reply-To: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 11:31 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
> So I've [finally] started looking into implementing XDP
> for qede, and there's one thing I feel like I'm missing in
> regard to XDP_TX - what's the guarantee/requirement
> that the bpf program isn't going to transmute some fields
> of the rx packet in a way that would prevent the forwarding?
>
I think there are really two separate questions you're probably
asking. 1) Can XDP modify a packet in such a way that it won't be
forwarded by the driver when XDP_TX is returned, ie. driver would drop
packet  2) Does anything prevent the BPF program from modifying the
packet such that it becomes malformed (bad checksum, mangled headers,
etc.).

I believe the answer to #1 is "no", the XDP interface assumes raw
packets. If program returns XDP_TX then the driver will forward the
raw packet without any further consideration.

The answer to #2 is "no", there is no check that packet produced is
sensible. We assume that the user setting the XDP program knows what
they are doing.

> E.g., can a BPF change the TCP payload of an incoming packet
> without correcting its TCP checksum, and then expect the
> driver to transmit it [via XDP_TX]? If not, how is this enforced [if at all]?
>
It's not enforced. If program doesn't update a checksum then we assume
that forwarded packet is dropped at the receiver.

> [Looked at samples/bpf/xdp2_kern.c which manipulates the
> UDP header; so I'm not certain what prevents it from doing
> the same when checksum modifications would be required]
>
>
>
