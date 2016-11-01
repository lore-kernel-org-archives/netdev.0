From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 1 Nov 2016 12:27:29 -0700
Message-ID: <CALx6S35FYAQWk1p_PztBJ_ojio6OOdeYDb-AYQwZ0juxPj5gYQ@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <CALx6S35BhiY7DVPetEDrLwgsR3sKTcm-bJ6og-6N329Znavkww@mail.gmail.com>
 <CACby=pkPQC92t3Y9-p9RRUv1_WL2uZMM6DRJFUc5-KP4B41hAA@mail.gmail.com>
 <CALx6S34ZVK1uHu_dYyh2w=k+8gP-H-nSPw-OgsMk9D2f4uE7jA@mail.gmail.com> <CACby=pnLzihLCFzT-HvB3Ovo-hC1b79Dr6iO74y5mMqPspHFBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:32893 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbcKAT1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 15:27:31 -0400
Received: by mail-qt0-f194.google.com with SMTP id n6so3016651qtd.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 12:27:31 -0700 (PDT)
In-Reply-To: <CACby=pnLzihLCFzT-HvB3Ovo-hC1b79Dr6iO74y5mMqPspHFBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 12:11 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 1 November 2016 at 11:51, Tom Herbert <tom@herbertland.com> wrote:
>> On Tue, Nov 1, 2016 at 11:20 AM, Thomas Graf <tgraf@suug.ch> wrote:
>>> The headers cannot be extended or reduced so the offsets always remain
>>> correct. What can happen is that the header contains invalid data.
>>>
>> If we can't add/remove headers then doesn't that really limit the
>> utility of these patches? My assumption was that BPF+LWT is needed to
>> allow users to define and implement their own encapsulations, EH
>> insertion, packet modification, etc.
>
> I thought you were specifically referring to lwtunnel_output(). You
> can extend headers at lwtunnel_xmit() but you can't for
> lwtunnel_output() and lwtunnel_input(). The xmit hook is in
> ip_finish_output2() where it is fine to do so. We have existing code
> doing this there.
>
>>> You keep saying this "middle in the stack" but the point is exactly
>>> the same as a raw socket with IPPROTO_RAW and hdrincl, see
>>> rawv6_sendmsg() and rawv6_send_hdrincl(). An IPv6 raw socket can feed
>>> arbitrary garbage into dst_output(). IPv4 does some minimal sanity
>>> checks.
>>>
>> What I mean is that an admin can create a BPF program that run on any
>> user packets (for instance default route could be set). This would be
>> in the path of TCP, UDP, and other protocols tightly integrated with
>> the stack. Packets being routed may be encapsulated, VLAN, have
>> checksum offload, GORed set etc. They also might be looped back in
>> which case the settings in skbuff become receive parameters.
>
> You can do the same with act_pedit or cls_bpf at dev_queue_xmit()
> before or after you go into the encapsulation device. This is a tool
> for root, if you install a drop all ssh rule then you won't be able to
> log into the box anymore. If you modify the packet and render it
> invalid, the packet will be dropped.
> If you attach a VLAN header while VLAN offload is already set up, then
> the hardware will add another VLAN header, this is what I would
> expect. I truly hope that we don't have code which crashes if we
> dev_queue_xmit() garbage into any device. That would be horrible.
>
> Do you have a specific example that could be a problem?

I believe Alexander was dealing with problems where drivers were not
properly handling IP extension headers. We regularly get reports about
driver checksum failures on edge conditions. Making a fully functional
and efficient transmit data path is nontrivial, there are many
assumptions being made some documented some not. When drivers crash we
either fix the driver or the protocol stack that is doing something
bad.

Tom
