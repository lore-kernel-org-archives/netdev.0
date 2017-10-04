From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying
 size
Date: Wed, 04 Oct 2017 21:27:13 +0200
Message-ID: <59D53611.5020907@iogearbox.net>
References: <20171002164129.47986-1-kraigatgoog@gmail.com> <20171002164129.47986-2-kraigatgoog@gmail.com> <5082193f-0b59-bc40-290f-4ef3709a1d26@fb.com> <59D3A12B.7010101@iogearbox.net> <CAEfhGixoRM_wRy_e9reCGq69XUM1w-1kKGErCUty=gEB8DbzfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>,
        netdev <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39582 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751183AbdJDT1W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 15:27:22 -0400
In-Reply-To: <CAEfhGixoRM_wRy_e9reCGq69XUM1w-1kKGErCUty=gEB8DbzfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2017 03:59 PM, Craig Gallek wrote:
> On Tue, Oct 3, 2017 at 10:39 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 10/03/2017 01:07 AM, Alexei Starovoitov wrote:
>>> On 10/2/17 9:41 AM, Craig Gallek wrote:
>>>>
>>>> +    /* Assume equally sized map definitions */
>>>> +    map_def_sz = data->d_size / nr_maps;
>>>> +    if (!data->d_size || (data->d_size % nr_maps) != 0) {
>>>> +        pr_warning("unable to determine map definition size "
>>>> +               "section %s, %d maps in %zd bytes\n",
>>>> +               obj->path, nr_maps, data->d_size);
>>>> +        return -EINVAL;
>>>> +    }
>>>
>>> this approach is not as flexible as done by samples/bpf/bpf_load.c
>>> where it looks at every map independently by walking symtab,
>>> but I guess it's ok.
>>
>> Regarding different map spec structs in a single prog: unless
>> we have a good use case why we would need it (and I'm not aware
>> of anything in particular), I would just go with a fixed size.
>> I did kind of similar sanity checks in bpf_fetch_maps_end() in
>> iproute2 loader as well.
>
> Split vote?  I'm happy to try to make this work with varying sizes,
> but I agree the usefulness seems low.  It would imply building map
> sections with different definition structures and we would then need a
> way to differentiate them.  If the goal is to allow for different map
> definition structures, I don't think size alone is a sufficient
> differentiator.

They would still all need to go to maps section, but you would end
up going with different structs for map specs, where they all would
need to overlap for the members in order for this to work. E.g. you
would have maps of both structs sitting in map section of a single
prog ...

struct bpf_map_spec_v1 {
	__u32 type;
	__u32 size_key;
	__u32 size_value;
	__u32 max_elem;
};

struct bpf_map_spec_v2 {
	__u32 type;
	__u32 size_key;
	__u32 size_value;
	__u32 max_elem;
	__u32 flags;
};

... rather than just using single spec everywhere consistently, and
have the members zeroed that are unused or such, so if there's no
real use-case for different structs (cannot think of any right now),
lets not add complexity for it until it's really required.
