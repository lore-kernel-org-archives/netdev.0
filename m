From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Fri, 13 Mar 2015 09:22:48 -0700
Message-ID: <55030ED8.4020209@plumgrid.com>
References: <1426213271-8363-1-git-send-email-ast@plumgrid.com> <1426213271-8363-2-git-send-email-ast@plumgrid.com> <5502B48B.7040909@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5502B48B.7040909@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/13/15 2:57 AM, Daniel Borkmann wrote:
> On 03/13/2015 03:21 AM, Alexei Starovoitov wrote:
>> introduce user accessible mirror of in-kernel 'struct sk_buff':
>
> For each member, I'd also add BUILD_BUG_ON()s similarly as we have in
> convert_bpf_extensions(). That way, people won't forget to adjust the
> code.

I thought about it, but didn't add it, since we already have them
in the same file several lines above this spot.
I think one build error per .c file should be enough to attract
attention.
Though I'll add a comment to convert_bpf_extensions() that build_bug_on
errors should be addressed in two places.
btw I've tried to do a common converter, but since offsets are different
and the way instructions are stored are also different it was messy.

> General idea for this offset map looks good, imho. Well defined members
> that are already exported to uapi e.g. through classic socket filters or
> other socket api places could be used here.

yes. exactly.

>> +struct __sk_buff {
>> +    __u32 len;
>> +    __u32 pkt_type;
>> +    __u32 mark;
>> +    __u32 ifindex;
>> +    __u32 queue_mapping;
>> +};
>
> I'd add a comment saying that fields may _only_ be safely added at
> the end of the structure. Rearranging or removing members here,
> naturally would break user space.

ok. will add a comment.

> The remaining fields we export in classic BPF would be skb->hash,
> skb->protocol, skb->vlan_tci, are we adding them as well to match
> up functionality with classic BPF? For example, I can see hash being
> useful as a key to be used with eBPF maps, etc.

I want to do skb->protocol and skb->vlan_tci differently and hopefully
more generically than classic did them, so they will come in the
follow on patches. skb->hash also should be done differently.
So yes. All of them are subjects of future patches/discussions.

>> +        /* several new insns need to be inserted. Make room for them */
>> +        insn_cnt += cnt - 1;
>> +        new_prog = bpf_prog_realloc(env->prog,
>> +                        bpf_prog_size(insn_cnt),
>> +                        GFP_USER);
>> +        if (!new_prog)
>> +            return -ENOMEM;
>
> Seems a bit expensive, do you think we could speculatively allocate a
> bit more space in bpf_prog_load() when we detect that we have access
> to ctx that we need to convert?

we already have extra space thanks to your commit 60a3b2253c413 :)))
The size is rounded up to page size and whole thing is made read-only
after it passes verifier.
So 99% of the time we don't reallocate anything.

>> +    case offsetof(struct __sk_buff, ifindex):
>> +        *insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
>> +                      offsetof(struct sk_buff, skb_iif));
>> +        break;
>
> This would only work for incoming skbs, but not outgoing ones
> f.e. in case of {cls,act}_bpf.

ahh, ok, will drop this field for now.

Thanks
