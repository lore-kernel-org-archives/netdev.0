From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 1 Nov 2016 13:33:37 -0700
Message-ID: <CALx6S36o1ig4rhN3MTaD1OCJ3sQo_ghbkonde1JDf4S9X=YkZQ@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <CALx6S35BhiY7DVPetEDrLwgsR3sKTcm-bJ6og-6N329Znavkww@mail.gmail.com>
 <CACby=pkPQC92t3Y9-p9RRUv1_WL2uZMM6DRJFUc5-KP4B41hAA@mail.gmail.com>
 <CALx6S34ZVK1uHu_dYyh2w=k+8gP-H-nSPw-OgsMk9D2f4uE7jA@mail.gmail.com>
 <CACby=pnLzihLCFzT-HvB3Ovo-hC1b79Dr6iO74y5mMqPspHFBg@mail.gmail.com>
 <CALx6S35FYAQWk1p_PztBJ_ojio6OOdeYDb-AYQwZ0juxPj5gYQ@mail.gmail.com> <CACby=p=pjsSmu8EWWomm-MLE2E+H9BSs9Y2ZAiH2Jh67gScMsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35368 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750889AbcKAUdi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 16:33:38 -0400
Received: by mail-qk0-f196.google.com with SMTP id v138so10162812qka.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 13:33:38 -0700 (PDT)
In-Reply-To: <CACby=p=pjsSmu8EWWomm-MLE2E+H9BSs9Y2ZAiH2Jh67gScMsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 12:59 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 1 November 2016 at 12:27, Tom Herbert <tom@herbertland.com> wrote:
>> On Tue, Nov 1, 2016 at 12:11 PM, Thomas Graf <tgraf@suug.ch> wrote:
>>> You can do the same with act_pedit or cls_bpf at dev_queue_xmit()
>>> before or after you go into the encapsulation device. This is a tool
>>> for root, if you install a drop all ssh rule then you won't be able to
>>> log into the box anymore. If you modify the packet and render it
>>> invalid, the packet will be dropped.
>>> If you attach a VLAN header while VLAN offload is already set up, then
>>> the hardware will add another VLAN header, this is what I would
>>> expect. I truly hope that we don't have code which crashes if we
>>> dev_queue_xmit() garbage into any device. That would be horrible.
>>>
>>> Do you have a specific example that could be a problem?
>>
>> I believe Alexander was dealing with problems where drivers were not
>> properly handling IP extension headers. We regularly get reports about
>
> There are many ways to cause IP extension headers to be inserted. How
> is this specific to BPF or this series?
>
>> driver checksum failures on edge conditions. Making a fully functional
>
> Not sure what an "edge condition" is? Untrusted networks? How is
> drivers crashing on receive related to this series?
>
>> and efficient transmit data path is nontrivial, there are many
>> assumptions being made some documented some not. When drivers crash we
>> either fix the driver or the protocol stack that is doing something
>> bad.
>
> Tom, we have a dozen ways to modify packet content already and we have
> multiple ways to take raw packet data from userspace and inject them
> at dev_queue_xmit() level and some even above. What is different for
> lwtunnel_xmit()?
>
> This is entirely optional and nobody is forced to use any of this. If
> you don't trust the BPF program then you better not run in. It's about
> the same as trusting a random tc filter or iptables ruleset. The
> important point is that integrity is maintained at all times.I would
> love to address any specific concern.

You need to show that is integrity is maintained with these patches.
Part of this can be done, but part of this needs to be established in
testing.

I've already given specifics for at least one potential source of
issues in routing issues. I would like to know what happens if someone
rewrites an IPv4 packet into IPv6 packet or vice versa. AFAICT we
would be send an IPv6 using an IPv4 route, or an IPv4 using an IPv6
route. What is supposed to happen in these circumstances? What
actually happens?

Similarly, someone overwrites the whole packet with 0xff. What happens
when we try to send that?

Tom
