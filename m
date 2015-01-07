From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Wed, 07 Jan 2015 14:00:25 -0800
Message-ID: <54ADAC79.5080608@gmail.com>
References: <CAADnVQLGLy5w8fcUKdVG6g6EpMJ=n=NMn=pq+mdYSqAOJdtk=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:61552 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbbAGWAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:00:43 -0500
Received: by mail-ob0-f176.google.com with SMTP id vb8so5405338obc.7
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 14:00:42 -0800 (PST)
In-Reply-To: <CAADnVQLGLy5w8fcUKdVG6g6EpMJ=n=NMn=pq+mdYSqAOJdtk=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2015 01:17 PM, Alexei Starovoitov wrote:
> On Tue, Jan 6, 2015 at 9:37 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>>> - above plus put_header_graph() which will allow to
>>>     rearrange some fixed sized headers ?
>>
>> OK but I'm not sure where/if these devices exist. Maybe your
>> thinking of a software dataplane case? Would get_headers return
>> some headers/fields but not include them in the graph and then
>> expect the user to build a graph with them if the user needs
>> them. Are there restrictions on how the graph can be built
>> out? I guess I'm working with the assumption that the device
>> returns a complete parse graph for all combinations it supports.
>
> ahh. I thought that get_hdr_graph() will return one
> that is currently configured and put_hdr_graph()
> will try to configure new sequence of headers.
> I think returning all possible combinations is not practical,
> since number of such combinations can be very large for
> some hw.

Agree here I think it should return the currently configured
and active hdr graph. Just to be clear I had assumed that any driver
that supported put_header_graph would also support a put_headers
call. basically your case 3 below.

> Also it seems that 4/11 patch and rocker_header_nodes[]
> in particular describing one graph instead of
> all possible?

It returns the one and only graph rocker supports now or at least
the graph of supported headers as I read the rocker code. As
rocker becomes more flexible I would expect this to grow including
tunnels, stacked headers, tcp, etc.

>
>>> - above plus put_header() ?
>>>     I'm having a hard time envisioning how that would
>>>     look like.
>>
>> This case makes more sense to me. The user supplies the definition
>> of the headers and the graph showing how they are related and the
>> driver can program the parser to work correctly.
>
> yes, assuming that put_hdr_graph() programs one
> sequence of jumping through hdrs...
> but I think it's also fine if you do one put_hdrs_and_graph()
> function as you described.
>
>> To be honest though I would really be happy getting the 1st option
>> working.
>
> agree.
> as long as we don't screw up get*() semantics that
> prevent clean put*() logic :)
> To illustrate my point:
> if hw parser can parse 2 vlans and there is
> no way to configure it to do zero, one or three, it's perfectly
> fine for put_hdr_graph() to fail when it tries to configure
> something different.
> But if hw can be configured to do 1 vlan or 2 vlans, it
> would be overkill to pass both graphs in get().
> Just pass one that is currently active and let put() try things?

This is what I intended. I think it is good enough.

> I think get_hdrs() on its own is good enough indication
> to the user what hw is capable of and hdr_graph is
> just a jump table between them. If hw can parse vxlan
> without vxlan extensions it will be clearly seen in get_hdrs,
> so no point trying to do put_hdrs() with some new
> definition of vxlan unless parser is fully programmable.
> that's where I was going with my category 2 where
> only put_hdr_graph() exists... imo it will fit trident
> and alta models ?
> Personally I believe that we should design this API
> with as much as possible real hw in mind.
> rocker can support different models of hw...
>

Yep. Which is why at some point I would like to program up
a couple other "worlds" for rocker that have different pipelines.
This would allow experimenting with more then the current static
model rocker uses.


-- 
John Fastabend         Intel Corporation
