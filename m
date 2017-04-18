From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Tue, 18 Apr 2017 13:28:02 +0200
Message-ID: <1492514882.2472.22.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
                 <1492007254.2855.10.camel@sipsolutions.net>
                 <20170412.111913.497795978751789475.davem@davemloft.net>
                 <1492011040.2855.18.camel@sipsolutions.net>
                 <20170414185144.GB41922@ast-mbp.thefacebook.com>
                 (sfid-20170414_205150_417889_20631AEB) <1492509349.2472.15.camel@sipsolutions.net>
         <58F5F148.1090700@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <58F5F148.1090700-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-04-18 at 12:58 +0200, Daniel Borkmann wrote:
> 
> Note that for skbs the data / data_end model (aka direct read /
> write) is also supported. There's also a bpf_skb_pull_data() helper
> that pulls in data from non-linear parts if necessary (f.e. if data /
> data_end test in the program fails). bpf_skb_load_bytes() is fine as
> well, comes with function call overhead, though, but depending on the
> use-case that might be just fine, too.

Yeah. I did see this, I just wasn't convinced I wanted the program to
be able to modify the SKB that way. OTOH, it doesn't actually matter if
it does this since that doesn't fundamentally change the SKB, so I
might as well allow it - and hook up data/data_end. In many cases, the
decision will be taken on the 802.11 header only, and that will be in
the linear portion anyway (with any self-respecting driver :p)

> Yeah, *_is_valid_access() callbacks would need to reject these
> members for most of the program types.

Yes, but that's the default case, so there's no real danger.

> Assuming you would introduce __wifi_sk_buff to the uapi, then it
> would be that the kernel internally still operates on an skb, you'd
> still call the program through BPF_PROG_RUN(prog, skb). However, your
> *_convert_ctx_access() would map from __wifi_sk_buff to the actual
> skb member, for example:
> 
> 	[...]
> 	case offsetof(struct __wifi_sk_buff, len):
> 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
> 
> 		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
> 				      offsetof(struct sk_buff, len));
> 		break;
> 	[...]
> 
> Your *_func_proto() would just reuse the available skb helpers like:
> 
> 	switch (func_id) {
> 	case BPF_FUNC_skb_load_bytes:
> 		return &bpf_skb_load_bytes_proto;
> 	[...]
> 	}
> 
> So, it's not that you need a local struct xdp_buff -like definition
> in the kernel and convert all helpers to it, reusing skb in kernel
> works just fine this way.

Sure.

> The mapping in samples/bpf/bpf_helpers.h, for example, for mentioned
> bpf_skb_load_bytes() would also work out of the box, since it takes a
> void *ctx as an argument, so you can just pass the __wifi_sk_buff
> pointer as ctx there from program side.

Hah. That's what I was missing - I always assumed the argument was
"struct __sk_buff *" without ever checking that assumption.

> Assuming __wifi_sk_buff would get few wifi specific attributes over
> time which cannot be reused in other types, it's probably fine to
> go with a __wifi_sk_buff uapi definition. If helper functions
> dedicated to wifi program type can extract all necessary information,
> it's probably okay as well to go that route.

The thing is that __wifi_sk_buff doesn't have much information that's
generally useful available - for example, there's not much point in
allowing it to access the raw rate data, having the actual converted
bitrate is much more useful, and that requires a function call since I
don't want the overhead of calculating that in cases the program
doesn't need it.

> If the data passed to such a helper function would eventually be a
> __wifi_sk_buff-like struct that gets extended with further attributes
> over time, then it's probably easier to use __wifi_sk_buff itself as
> a ctx instead of argument for helpers. Reason is that once a helper
> is set in stone, you need to keep compatibility on the passed struct,
> meaning you need to test the passed length of the struct like we do
> in case of bpf_skb_get_tunnel_key() / bpf_skb_set_tunnel_key()
> helpers and only copy meta data up to that length for older programs.

Right.

johannes
