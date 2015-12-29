From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Tue, 29 Dec 2015 12:16:08 -0500
Message-ID: <CAEfhGiyPDqqr5x65hm99uX6NJd7pKcJus_pK88aL4JHnyrMz0A@mail.gmail.com>
References: <CAEfhGiwWYtJqzkDAiptkd9NE+j6wquFBnoWmzNipALGUDH0kHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33884 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbbL2RQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 12:16:11 -0500
Received: by mail-lb0-f171.google.com with SMTP id pv2so120761464lbb.1
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 09:16:10 -0800 (PST)
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com. [209.85.217.174])
        by smtp.gmail.com with ESMTPSA id 140sm1952260lfz.21.2015.12.29.09.16.08
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 09:16:09 -0800 (PST)
Received: by mail-lb0-f174.google.com with SMTP id sv6so99023534lbb.0
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 09:16:08 -0800 (PST)
In-Reply-To: <CAEfhGiwWYtJqzkDAiptkd9NE+j6wquFBnoWmzNipALGUDH0kHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 26, 2015 at 2:05 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> On Thu, Dec 24, 2015 at 11:36 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Tue, Dec 22, 2015 at 03:05:09PM -0500, Craig Gallek wrote:
>>> +     /* temporarily advance data past protocol header */
>>> +     if (skb_headlen(skb) < hdr_len || !skb_pull_inline(skb, hdr_len)) {
>>
>> though bpf core will read just fine past linear part of the packet,
>> here we're limiting this feature only to packets where udp header is
>> part of headlen. Will it make it somewhat unreliable?
>> May be we can avoid doing this pull/push and use negative load
>> instructions with SKF_NET_OFF ? Something like:
>> load_word(skb, SKF_NET_OFF + sizeof(struct udphdr)));
> This is an excellent point and will be even more relevant for TCP.
> I'll try to get this to work for v2.
Looking at this more closely, I think the right thing to do is to
simply change the headlen check here to pskb_may_pull.  This mirrors
the behavior in the receive path when pulling headers.  It will also
maintain the convention of passing an skb to the bpf filter with the
data pointer advanced to the payload.
