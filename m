From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH 06/10] bpf: sockmap with sk redirect support
Date: Fri, 18 Aug 2017 21:50:01 -0700
Message-ID: <5e3248bf-1951-5859-8cfb-4fdb641dcc41@fb.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
 <20170816053247.15445.69312.stgit@john-Precision-Tower-5810>
 <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com> <5995E738.9090803@gmail.com>
 <a6dafa0a-9cb2-6d70-5db7-fe44108a6c2c@fb.com> <599698D0.9040803@gmail.com>
 <653a9c34-c187-636d-40f4-eb74a819c3d5@fb.com> <5997B0C5.703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tgraf@suug.ch>, <netdev@vger.kernel.org>, <tom@herbertland.com>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48670 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750788AbdHSEua (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2017 00:50:30 -0400
In-Reply-To: <5997B0C5.703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/17 8:30 PM, John Fastabend wrote:
> So this is really close to what I proposed above. For a TX_SOCKMAP
> simply do not attach any programs,
>
>    bpf_create_map(BPF_MAP_TYPE_SOCKMAP, .... )
>    [...]
>
> For an RX_SOCKMAP,
>
>    bpf_create_map(BPF_MAP_TYPE_SOCKMAP, .... )
>    bpf_prog_attach(verdict_prog, map_fd, BPF_SMAP_STREAM_VERDICT, 0);
>    bpf_prog_attach(parse_prog, map_fd, BPF_SMAP_STREAM_PARSER, 0);
>
> With the new attach type (compared to the fd2 thing before) we can easily
> extend maps to contain other program types as needed. So in the future
> we might have TX_SOCKMAP, RX_SOCKMAP, FOO_SOCKMAP, ...

agree. that sounds as good generalization.

> I don't see the need to have the API enforce the map type via update
> specifiers bpf_{rx|tx}_sock_map_update. The programmer should "know"
> the type by virtue of the programs attached. This is more flexible
> as well because it allows a map to be TX only, RX only or TX/RX.

makes sense. good point.

> With this proposal we can relax the restriction where a sock can only
> be in a single map and even allow a sock to be in the same map multiple
> times. The limitation we do have to enforce is allowing a sock in the
> a map with different BPF_SMAP_STREAM_* programs. But I think this
> should be clear to the programmer (with good tracing functions and
> error codes).
>
> Slight aside: but by creating map size of 1 we have an object that
> contains programs and later we can attach a sock to it, looks like
> the following,
>
>       create_map(BPF_MAP_TYPE_SOCKMAP,...)
>       bpf_prog_attach(...)
>       [...]
>       bpf_update_map_elem(fd, map, key, flags)
>
> I think this is very close to your first approach where you suggested
> a program container object.

yep.

>> Or you have cases when two RX sockets need to redirect into each
>> other and in both cases strparser+verdict need to run?
> If we don't do rx, tx restrictions and use my suggestion here we
> don't have this limitation. OR because we allow socks in multiple
> maps now the user can simply put the sockets in different maps.

agree. good point as well.

>> In such case we need to allow bpf_sk_redirect_map() to use on
>> RX_SOCKMAP map as well,
>> but looking at current implementation you only allow one psock per map,
>> so two sockets forwarding to each other cannot work due to only one queue.
>> Am I missing anything from what you want to achieve?
> I don't think so. But lets get rid of the one psock per map, I took a shot
> at relaxing that today and was able to get it with a refcount on the psock
> which seems to work OK.

+1

> Also reorganizing the psock structure into clear sections tx_psock, rx_psock,
> general_psock will probably help readers.

nice. thanks!

>> Thoughts?
>>
> What do you think of my counter proposal I started coding it up and it
> actually (other than pushing code snippets around) seems to work out
> nicely with the existing code base. I think it is really a nice improvement.

ok. I think we're mostly on the same page and patches will
either bring us to the full agreement or show where we disagree :)
To clarify, I think the current code base is pretty good.
I'm only arguing to fix up the rough spots of the uapi to make
sure we don't corner ourselves with future extensions that I feel
inevitably will follow.
The feature itself is quite important and I feel a bit sad that it 
landed without enough due diligence. The RFC patches didn't get
much attentions and I didn't have time until now to look into them
in depth.
