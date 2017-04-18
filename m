From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Tue, 18 Apr 2017 11:55:49 +0200
Message-ID: <1492509349.2472.15.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
         <1492007254.2855.10.camel@sipsolutions.net>
         <20170412.111913.497795978751789475.davem@davemloft.net>
         <1492011040.2855.18.camel@sipsolutions.net>
         <20170414185144.GB41922@ast-mbp.thefacebook.com>
         (sfid-20170414_205150_417889_20631AEB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47564 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751228AbdDRJzy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 05:55:54 -0400
In-Reply-To: <20170414185144.GB41922@ast-mbp.thefacebook.com> (sfid-20170414_205150_417889_20631AEB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-14 at 11:51 -0700, Alexei Starovoitov wrote:
> 
> so today only 'len' field is needed,

Correct, the other __sk_buff fields don't apply.

It's more of an XDP model (with data/data_end), but as the SKB might be
non-linear at this point I prefer to have the SKB so that skb data
access (skb_copy_bits equivalent) works.

> but the plan to add wifi specific
> stuff to bpf context?

Maybe, maybe not.

> If so, adding these very wifi specific fields to __sk_buff will
> confuse other program types,

I don't think this is true - the verifier still checks that you can't
actually use them. It might confuse authors though, if not documented
well.

> so new program type (like you did) and new 'struct bpf_wifi_md' are
> probably cleaner.

The problem is that I still need struct __wifi_sk_buff or so, and need
to internally let it operate like an SKB, since I need
bpf_skb_load_bytes().

Now, bpf_helpers declares bpf_skb_load_bytes() to take an argument of
type "struct __sk_buff *", and thus I either need to provide an alias
to it, or cast every time I use this function.

> Physically the R1 register to bpf program will still be 'struct
> sk_buff', but from bpf program side it will be:
> struct bpf_wifi_md {
>   __u32 len;
>   __u32 wifi_things;
> };

Right, that would work immediately if it's only about the extra fields.
But it's more about being able to call bpf_skb_load_bytes() easily.

I don't even know if I want to add *any* wifi_things here at all. I
don't actually have much data available directly at this point, or at
least not in a format that would be useful, so I think it'd be better
to have a BPF helper function to obtain wifi_things outside of the
struct itself, passing the struct bpf_wifi_md * (and thus getting
struct sk_buff * in the kernel code) to it.


> At the same time if most of the __sk_buff fields can be useful to
> wifimon, then just use it as-is (without restricting to 'len' only)
> and add wifi specific fields to it with a comment.

No, I don't think they can ever be useful.

johannes
