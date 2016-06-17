From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 13/18] net: Add offload kernel net stack packet type
Date: Sat, 18 Jun 2016 01:54:46 +0300
Message-ID: <CALzJLG9=07D_VySJ8TCLXSbhjmzKy--utmu9RHE2bqrE7hkCVg@mail.gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-14-git-send-email-saeedm@mellanox.com> <576413FE.3010703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34750 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbcFQWzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 18:55:07 -0400
Received: by mail-yw0-f195.google.com with SMTP id b75so10350906ywe.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 15:55:06 -0700 (PDT)
In-Reply-To: <576413FE.3010703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 6:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 06/17/2016 04:43 PM, Saeed Mahameed wrote:
>>
>> From: Maor Gottlieb <maorg@mellanox.com>
>>
>> Add new packet type to skip kernel specific protocol handlers.
>>
>> This is needed so device drivers can pass packets up to user space
>> (af_packet/tcpdump, etc..) without the need for them to go through
>> the whole kernel data path.
>>
>> Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
>> CC: David S. Miller <davem@davemloft.net>
>> CC: Patrick McHardy <kaber@trash.net>
>> CC: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> ---
>>   include/linux/skbuff.h         | 6 +++---
>>   include/uapi/linux/if_packet.h | 1 +
>>   net/core/dev.c                 | 4 ++++
>>   3 files changed, 8 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index dc0fca7..359724e 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -694,14 +694,14 @@ struct sk_buff {
>>
>>   /* if you move pkt_type around you also must adapt those constants */
>>   #ifdef __BIG_ENDIAN_BITFIELD
>> -#define PKT_TYPE_MAX   (7 << 5)
>> +#define PKT_TYPE_MAX   (8 << 5)
>>   #else
>> -#define PKT_TYPE_MAX   7
>> +#define PKT_TYPE_MAX   8
>>   #endif
>
>
> Aehm ... did you actually test this with BPF ?!
>
> PKT_TYPE_MAX is a mask (naming could be better no doubt), see also function
> convert_skb_access():
>
> [...]
>         case SKF_AD_PKTTYPE:
>                 *insn++ = BPF_LDX_MEM(BPF_B, dst_reg, src_reg,
> PKT_TYPE_OFFSET());
>                 *insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, PKT_TYPE_MAX);
> #ifdef __BIG_ENDIAN_BITFIELD
>                 *insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, 5);
> #endif
>                 break;
> [...]
>
> Also, dunno if it's worth burning a skb bit for one driver.
>

oops! it didn't occur to me that it was used as a mask!
does this mean we are out of PKT_TYPE flags ?
Maybe we can use skb->mark instead ? any ideas ?

Also i am not sure it is a one driver thing, i know about other
examples where some device drivers set skb->protocol to 0xffff to
achieve the same ! which i didn't like.
