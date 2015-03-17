From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access 'protocol' and
 'vlan_tci' fields
Date: Tue, 17 Mar 2015 10:56:03 -0700
Message-ID: <55086AB3.9030405@plumgrid.com>
References: <1426554362-29991-1-git-send-email-ast@plumgrid.com> <5507F253.9000806@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37486 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbbCQR4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 13:56:00 -0400
Received: by igcqo1 with SMTP id qo1so19982947igc.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 10:56:00 -0700 (PDT)
In-Reply-To: <5507F253.9000806@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/17/15 2:22 AM, Daniel Borkmann wrote:
> On 03/17/2015 02:06 AM, Alexei Starovoitov wrote:
>> as a follow on to patch 70006af95515 ("bpf: allow eBPF access skb
>> fields")
>> this patch allows 'protocol' and 'vlan_tci' fields to be accessible
>> from extended BPF programs.
>>
>> The usage of 'protocol', 'vlan_present' and 'vlan_tci' fields is the
>> same as
>> corresponding SKF_AD_PROTOCOL, SKF_AD_VLAN_TAG_PRESENT and
>> SKF_AD_VLAN_TAG
>> accesses in classic BPF.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Ok, code looks good to me.
>
>> 1.
>> I was thinking to drop ntohs() from 'protocol' field for extended BPF,
>> since
>> the programs could do:
>> if (skb->protocol == htons(ETH_P_IP))
>> which would have saved one or two cpu cycles.
>> But having similar behavior between classic and extended seems to be
>> better.
>
> I'm thinking that skb->protocol == htons(ETH_P_IP) might actually
> be more obvious, and, as you mentioned, the compiler can already
> resolve the htons() during compile time instead of runtime, which
> would be another plus.
>
> Either behavior we should document later anyway.
>
> The question to me here is, do we need to keep similar behavior?
>
> After all, the way of programming both from a user perspective is
> quite different (i.e. bpf_asm versus C/LLVM).

yeah. we don't have to. Somehow I felt that keeping ntohs will make
it easier for folks moving from classic to extended, but I guess
they're different enough, so no point wasting run time cycles.

> Similarly, I was wondering, if just exporting raw skb->vlan_tci is
> already sufficient, and the user can e.g. write helpers to extract
> bits himself from that protocol field?

yes. I thought about the same. Currently VLAN_TAG_PRESENT bit is not
officially exposed to user space, but implicitly, since that bit
is always cleared when we return tci to user space and it's always
set when drivers indicate that vlan header was present in the packet.
So I think we can return skb->vlan_tci as-is, since it will save
one load in bpf program which will be able to do
if (skb->vlan_tci != 0) /* vlan header is present */
      vid = skb->vlan_tci & 0x0fff;
compiler will optimize above two accesses into single load and will
reuse the register in 2nd line.
