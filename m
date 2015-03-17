From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access 'protocol' and
 'vlan_tci' fields
Date: Tue, 17 Mar 2015 19:14:24 +0100
Message-ID: <55086F00.70901@iogearbox.net>
References: <1426554362-29991-1-git-send-email-ast@plumgrid.com> <5507F253.9000806@iogearbox.net> <55086AB3.9030405@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55086AB3.9030405-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/17/2015 06:56 PM, Alexei Starovoitov wrote:
> On 3/17/15 2:22 AM, Daniel Borkmann wrote:
>> On 03/17/2015 02:06 AM, Alexei Starovoitov wrote:
...
>>> I was thinking to drop ntohs() from 'protocol' field for extended BPF,
>>> since
>>> the programs could do:
>>> if (skb->protocol == htons(ETH_P_IP))
>>> which would have saved one or two cpu cycles.
>>> But having similar behavior between classic and extended seems to be
>>> better.
>>
>> I'm thinking that skb->protocol == htons(ETH_P_IP) might actually
>> be more obvious, and, as you mentioned, the compiler can already
>> resolve the htons() during compile time instead of runtime, which
>> would be another plus.
>>
>> Either behavior we should document later anyway.
>>
>> The question to me here is, do we need to keep similar behavior?
>>
>> After all, the way of programming both from a user perspective is
>> quite different (i.e. bpf_asm versus C/LLVM).
>
> yeah. we don't have to. Somehow I felt that keeping ntohs will make
> it easier for folks moving from classic to extended, but I guess
> they're different enough, so no point wasting run time cycles.

Yes, I think that case seems reasonable in my opinion.

>> Similarly, I was wondering, if just exporting raw skb->vlan_tci is
>> already sufficient, and the user can e.g. write helpers to extract
>> bits himself from that protocol field?
>
> yes. I thought about the same. Currently VLAN_TAG_PRESENT bit is not
> officially exposed to user space, but implicitly, since that bit
> is always cleared when we return tci to user space and it's always
> set when drivers indicate that vlan header was present in the packet.

Right.

> So I think we can return skb->vlan_tci as-is, since it will save
> one load in bpf program which will be able to do
> if (skb->vlan_tci != 0) /* vlan header is present */
>       vid = skb->vlan_tci & 0x0fff;
> compiler will optimize above two accesses into single load and will
> reuse the register in 2nd line.

Ok, I'm not sure what's best in the vlan_tci case. I think both
options are a possible way to move forward. If the compiler can
further optimize the latter, it might be the better option. I'll
leave that to you. ;)

Thanks,
Daniel
