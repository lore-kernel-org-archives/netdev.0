From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 05 Mar 2015 13:12:53 -0500 (EST)
Message-ID: <20150305.131253.2236103115559186359.davem@davemloft.net>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
	<CAOJe8K1_imrFKTafER6+RRFQfZPE3POGmpMbuxZ+NG6wG6hRyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: msekleta@redhat.com, netdev@vger.kernel.org, ast@plumgrid.com,
	jpirko@redhat.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757584AbbCESM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 13:12:59 -0500
In-Reply-To: <CAOJe8K1_imrFKTafER6+RRFQfZPE3POGmpMbuxZ+NG6wG6hRyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Thu, 5 Mar 2015 11:57:05 +0300

> On 3/4/15, Michal Sekletar <msekleta@redhat.com> wrote:
>> --- a/arch/powerpc/net/bpf_jit_comp.c
>> +++ b/arch/powerpc/net/bpf_jit_comp.c
>> @@ -399,6 +399,11 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32
>> *image,
>>  				PPC_SRWI(r_A, r_A, 12);
>>  			}
>>  			break;
>> +		case BPF_ANC | SKF_AD_VLAN_PROTO:
>> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
>> +			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
>> +							  vlan_proto));
> You're going to load a halfword, so lhz has to be used
> 
>> +			break;

Same bug in the sparc implementation too:

>> @@ -624,6 +624,9 @@ void bpf_jit_compile(struct bpf_prog *fp)
>>  					emit_and(r_A, r_TMP, r_A);
>>  				}
>>  				break;
>> +			case BPF_ANC | SKF_AD_VLAN_PROTO:
>> +				emit_skb_load32(vlan_proto, r_A);
>> +				break;
>>  			case BPF_LD | BPF_W | BPF_LEN:
>>  				emit_skb_load32(len, r_A);
>>  				break;

This needs to use emit_load16().

These JIT changes seem to have been done a little carelessly.
