From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 05 Mar 2015 08:52:59 -0800
Message-ID: <54F889EB.7000203@plumgrid.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <20150305103715.GA3432@morgoth.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:42012 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757950AbbCEQw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 11:52:56 -0500
Received: by igkb16 with SMTP id b16so47423928igk.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 08:52:55 -0800 (PST)
In-Reply-To: <20150305103715.GA3432@morgoth.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/15 2:37 AM, Michal Sekletar wrote:
> On Wed, Mar 04, 2015 at 01:03:50PM -0800, Alexei Starovoitov wrote:
>> On 3/4/15 12:41 PM, Michal Sekletar wrote:
>>> This commit introduces new BPF extension. It makes possible to load value of
>>> skb->vlan_proto (vlan tpid) to register A.
>>>
>>> Currently, vlan header is removed from frame and information is available to
>>> userspace only via tpacket interface. Hence, it is not possible to install
>>> filter which uses value of vlan tpid field.
>>>
>>> AFAICT only way how to filter based on tpid value is to reconstruct original
>>> frame encapsulation and interpret BPF filter code in userspace. Doing that is
>>> way slower than doing filtering in kernel.
>>>
>>> Cc: Alexei Starovoitov <ast@plumgrid.com>
>>> Cc: Jiri Pirko <jpirko@redhat.com>
>>> Signed-off-by: Michal Sekletar <msekleta@redhat.com>
>>> ---
>>> @@ -282,6 +282,7 @@ Possible BPF extensions are shown in the following table:
>>>     vlan_tci                              skb_vlan_tag_get(skb)
>>>     vlan_pr                               skb_vlan_tag_present(skb)
>>>     rand                                  prandom_u32()
>>> +  vlan_proto                            skb->vlan_proto
>>
>> the patch is correct and looks clean, but I don't understand
>> the motivation for the patch.
>
> Way how libpcap currently uses BPF extensions is not compatible with old
> behavior where actual value of tpid field was checked. I wanted to address
> that, i.e. if "vlan" keyword is used as filter expression, libpcap should
> install a filter such that only ethernet frames having tpid value of 0x8100 or
> 0x9100 will pass. That is not the case with current libpcap git and 4.0-rc1
> kernel.
>
> Given that I broke libpcap as described above I tried to come up with the way
> how to fix that. However I realized that with recent kernels there is no other
> way than adding new BPF extension.
>
>> There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
>> two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
>
> Any reason why ETH_P_QINQ1, ETH_P_QINQ2, ETH_P_QINQ3 no longer works? If I
> understand correctly, you are basically saying, that there is no point checking
> for vlan tpid because PF_PACKET socket will never receive frame having other
> tpid value than above two anyway.
>
> So bottom line is that I wanted to grant userspace programs more flexibility,
> and you are saying that it is pointless because for example if outer tpid is
> 0x9100 socket will never receive the frame. If that is the case then
> disregard the patch.

steering towards vlan device happens only for ETH_P_8021Q and
ETH_P_8021AD. Non-standard 0x9100 and other tags won't be popped into
skb metadata and will stay as-is in the packet body.
If the meaning of 'vlan 100' in libpcap is to detect all possible
vlan tpid then bpf program would need to check VLAN_TAG_PRESENT
(that would mean vlan_proto is either 0x8100 or 0x88A8)
and parse packet body for tpids 0x9[123]00.
Whether we add access to skb->vlan_proto or not, the program would
still need to do the above steps, but instead of checking for
vlan_tag_present only, it would need to do vlan_proto==0x8100
or vlan_proto=0x88a8 and then parse the packet for tpid=0x9[123]00
so adding access to vlan_proto will not simplify libpcap job.
At this point I think it's up to Dave to decide whether we need
this patch (after fixing the issue pointed by Denis) or not.
imo there is a benefit of giving programs more visibility into
skb metadata.
