From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 16:28:47 +0200
Message-ID: <58F8C59F.1040009@iogearbox.net>
References: <1492637460.22185.6.camel@sipsolutions.net>                  (sfid-20170419_233114_060429_CAFE85B8) <1492640459.22185.7.camel@sipsolutions.net>              <58F7FA6D.5030000@iogearbox.net>        <1492668065.3109.1.camel@sipsolutions.net> <58F8C160.6010905@iogearbox.net> <1492697865.3109.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37089 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946350AbdDTO2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:28:51 -0400
In-Reply-To: <1492697865.3109.7.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 04:17 PM, Johannes Berg wrote:
> On Thu, 2017-04-20 at 16:10 +0200, Daniel Borkmann wrote:
>>
>> I think this would be a rather more complex operation on the BPF
>> side, it would need changes from LLVM (which assumes initial ctx sits
>> in r1), verifier for tracking this ctx2, all the way down to JITs
>> plus some way to handle 1 and 2 argument program calls generically.
>> Much easier to pass additional meta data for the program via cb[],
>> for example.
>
> Yeah, it did seem very complex :)
>
>>> Alternatively I can clear another pointer (u64) in the CB, store a
>>> pointer there, and always emit code following that pointer - should
>>> be possible right?
>>
>> What kind of pointer? If it's something like data_end as read-only,
>> then this needs to be tracked in the verifier in addition, of course.
>> Other option you could do (depending on what you want to achieve) is
>> to have a bpf_probe_read() version as a helper for your prog type
>> that would further walk that pointer/struct (similar to tracing)
>> where this comes w/o any backward compat guarantees, though.
>
> I meant something like this
>
> struct wifi_cb {
> 	struct wifi_data *wifi_data;
> 	...
> 	void *data_end; // with BUILD_BUG_ON to the right offset
> };
>
> Then struct wifi_data can contain extra data that doesn't fit into
> wifi_cb, like the stuff I evicted for *data_end and *wifi_data. Let's
> say one of those fields is "u64 boottime_ns;" (as I did in my patch
> now), so we have
>
> struct wifi_data {
> 	u64 boottime_ns;
> };
>
> then I can still have
>
> struct __wifi_sk_buff {
> 	u32 len;
> 	u32 data;
> 	u32 data_end;
> 	u32 boottime_ns; // this is strange but
> 			 // seems to be done this way?
> };
>
> And then when boottime_ns is accessed, I can have:
>
>          case offsetof(struct __wifi_sk_buff, boottime_ns):
>                  off  = si->off;
>                  off -= offsetof(struct __wifi_sk_buff, boottime_ns);
>                  off += offsetof(struct sk_buff, cb);
>                  off += offsetof(struct wifi_cb, wifi_data);
>                  *insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), si->dst_reg,
>                                        si->src_reg, off);
> 		off = offsetof(struct wifi_data, boottime_ns);
> 		*isns++ = BPF_LDX_MEM(BPF_SIZEOF(u64), si->dst_reg,
> 				      si->src_reg, off);
>                  break;
>
> no?
>
> It seems to me this should work, and essentially emit code to follow
> the pointer to inside struct wifi_data. Assuming

I see what you mean now. Yes, that's fine. We already do something
similar essentially with skb->ifindex access already (skb->dev +
dev->ifindex), f.e.:

[...]
	case offsetof(struct __sk_buff, ifindex):
		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);

		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, dev),
				      si->dst_reg, si->src_reg,
				      offsetof(struct sk_buff, dev));
		*insn++ = BPF_JMP_IMM(BPF_JEQ, si->dst_reg, 0, 1);
		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
				      offsetof(struct net_device, ifindex));
		break;
[...]

Which is not too different from the above. You'd probably need to
populate the struct wifi_data each time if you place it onto the
stack, but perhaps could be optimized by storing that somewhere
else (e.g. somewhere via netdev, etc) and walking the pointer from
there, which would also spare you the cb[] save/restore.
