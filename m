From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [3.15-rc3] Bisected: xen-netback mangles packets between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Fri, 2 May 2014 18:28:18 +0200
Message-ID: <35970097.20140502182818@eikelenboom.it>
References: <395225650.20140430124506@eikelenboom.it>  <536162D3.5080307@citrix.com> <94755525.20140501002553@eikelenboom.it>  <53624E25.8040404@citrix.com> <1810270947.20140501155911@eikelenboom.it>  <53626C39.3030304@citrix.com> <928229683.20140501193936@eikelenboom.it>  <198418193.20140501213951@eikelenboom.it> <5363A508.1000602@citrix.com>  <653156457.20140502160632@eikelenboom.it> <5363AFED.5080601@citrix.com> <1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com> <5363B929.1000502@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	<xen-devel@lists.xen.org>, Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:51849 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbaEBQ2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 12:28:22 -0400
In-Reply-To: <5363B929.1000502@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Friday, May 2, 2014, 5:26:33 PM, you wrote:

> On 02/05/14 16:21, Eric Dumazet wrote:
>> On Fri, 2014-05-02 at 15:47 +0100, Zoltan Kiss wrote:
>>
>>> Sorry, I was misleading and wrong. Can you try out this scenario with
>>> the attached patch?
>>
>> Guys, I already told you skb->truesize 'mismatch' could not explain
>> packet corruptions. This comes from an expert in this matter, you can
>> trust me.
>>
>> What could happens here is that TCP stack merges skbs (TCP coalescing)
> These packets shouldn't reach Dom0's TCP stack at all, 
> bridge/openvswitch grabs them before. And in the sending/receiving guest 
> these skbs don't have this flag.
> However generally it is possible that a guest talks directly to Dom0, in 
> which case your proposed fix could be valid.

I just tested Eric's patch alone .. and:

- It lasts longer .. the first upload goes OK (previously it would already bail out on 
  the first one)
- We still hit the "xenvif_handle_frag_list" path while uploading, but no "tx_frag_overflow" 
  occurred.

- But it bails out on the second upload .. with the message
  "_ssl.c:1415: error:140943FC:SSL routines:SSL3_READ_BYTES:sslv3 alert bad record mac"
- We also hit the "xenvif_handle_frag_list" path while uploading and this time we 
  also hit the "tx_frag_overflow" case.

--
Sander

>>
>> Problem is that SKBTX_DEV_ZEROCOPY addition did not take care of this.
>>
>> We have to forbid these merges from happening, because one skb has a
>> single destructor_arg.
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 1b62343f5837..85995a14aafc 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3838,7 +3839,10 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>>               return true;
>>       }
>>
>> -     if (skb_has_frag_list(to) || skb_has_frag_list(from))
>> +     if (skb_has_frag_list(to) ||
>> +         skb_has_frag_list(from) ||
>> +         (skb_shinfo(to)->tx_flags & SKBTX_DEV_ZEROCOPY) ||
>> +         (skb_shinfo(from)->tx_flags & SKBTX_DEV_ZEROCOPY))
>>               return false;
>>
>>       if (skb_headlen(from) != 0) {
>>
>>
>>
>>
>>
>>
