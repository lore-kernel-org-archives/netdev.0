From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Tue, 18 Apr 2017 12:58:16 +0200
Message-ID: <58F5F148.1090700@iogearbox.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>    <1492007254.2855.10.camel@sipsolutions.net>     <20170412.111913.497795978751789475.davem@davemloft.net>        <1492011040.2855.18.camel@sipsolutions.net>     <20170414185144.GB41922@ast-mbp.thefacebook.com>        (sfid-20170414_205150_417889_20631AEB) <1492509349.2472.15.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, ast@kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46980 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752546AbdDRK6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 06:58:21 -0400
In-Reply-To: <1492509349.2472.15.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 11:55 AM, Johannes Berg wrote:
> On Fri, 2017-04-14 at 11:51 -0700, Alexei Starovoitov wrote:
>>
>> so today only 'len' field is needed,
>
> Correct, the other __sk_buff fields don't apply.
>
> It's more of an XDP model (with data/data_end), but as the SKB might be
> non-linear at this point I prefer to have the SKB so that skb data
> access (skb_copy_bits equivalent) works.

Note that for skbs the data / data_end model (aka direct read / write)
is also supported. There's also a bpf_skb_pull_data() helper that
pulls in data from non-linear parts if necessary (f.e. if data /
data_end test in the program fails). bpf_skb_load_bytes() is fine as
well, comes with function call overhead, though, but depending on the
use-case that might be just fine, too.

>> but the plan to add wifi specific
>> stuff to bpf context?
>
> Maybe, maybe not.
>
>> If so, adding these very wifi specific fields to __sk_buff will
>> confuse other program types,
>
> I don't think this is true - the verifier still checks that you can't
> actually use them. It might confuse authors though, if not documented
> well.

Yeah, *_is_valid_access() callbacks would need to reject these members
for most of the program types.

>> so new program type (like you did) and new 'struct bpf_wifi_md' are
>> probably cleaner.
>
> The problem is that I still need struct __wifi_sk_buff or so, and need
> to internally let it operate like an SKB, since I need
> bpf_skb_load_bytes().
>
> Now, bpf_helpers declares bpf_skb_load_bytes() to take an argument of
> type "struct __sk_buff *", and thus I either need to provide an alias
> to it, or cast every time I use this function.

Assuming you would introduce __wifi_sk_buff to the uapi, then it
would be that the kernel internally still operates on an skb, you'd
still call the program through BPF_PROG_RUN(prog, skb). However, your
*_convert_ctx_access() would map from __wifi_sk_buff to the actual
skb member, for example:

	[...]
	case offsetof(struct __wifi_sk_buff, len):
		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);

		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
				      offsetof(struct sk_buff, len));
		break;
	[...]

Your *_func_proto() would just reuse the available skb helpers like:

	switch (func_id) {
	case BPF_FUNC_skb_load_bytes:
		return &bpf_skb_load_bytes_proto;
	[...]
	}

So, it's not that you need a local struct xdp_buff -like definition
in the kernel and convert all helpers to it, reusing skb in kernel
works just fine this way.

The mapping in samples/bpf/bpf_helpers.h, for example, for mentioned
bpf_skb_load_bytes() would also work out of the box, since it takes a
void *ctx as an argument, so you can just pass the __wifi_sk_buff
pointer as ctx there from program side.

Assuming __wifi_sk_buff would get few wifi specific attributes over
time which cannot be reused in other types, it's probably fine to
go with a __wifi_sk_buff uapi definition. If helper functions dedicated
to wifi program type can extract all necessary information, it's
probably okay as well to go that route.

If the data passed to such a helper function would eventually be a
__wifi_sk_buff-like struct that gets extended with further attributes
over time, then it's probably easier to use __wifi_sk_buff itself as
a ctx instead of argument for helpers. Reason is that once a helper
is set in stone, you need to keep compatibility on the passed struct,
meaning you need to test the passed length of the struct like we do
in case of bpf_skb_get_tunnel_key() / bpf_skb_set_tunnel_key() helpers
and only copy meta data up to that length for older programs.

>> Physically the R1 register to bpf program will still be 'struct
>> sk_buff', but from bpf program side it will be:
>> struct bpf_wifi_md {
>>    __u32 len;
>>    __u32 wifi_things;
>> };
>
> Right, that would work immediately if it's only about the extra fields.
> But it's more about being able to call bpf_skb_load_bytes() easily.
>
> I don't even know if I want to add *any* wifi_things here at all. I
> don't actually have much data available directly at this point, or at
> least not in a format that would be useful, so I think it'd be better
> to have a BPF helper function to obtain wifi_things outside of the
> struct itself, passing the struct bpf_wifi_md * (and thus getting
> struct sk_buff * in the kernel code) to it.
>
>> At the same time if most of the __sk_buff fields can be useful to
>> wifimon, then just use it as-is (without restricting to 'len' only)
>> and add wifi specific fields to it with a comment.
>
> No, I don't think they can ever be useful.
>
> johannes
