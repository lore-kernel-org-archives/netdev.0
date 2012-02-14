From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] ixgbe: fix truesize calculation when merging active tail
 into lro skb
Date: Tue, 14 Feb 2012 09:21:10 -0800
Message-ID: <4F3A9806.2000102@intel.com>
References: <20120213135248.GA23457@sir.fritz.box>  <1329142322.2494.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1329169382.2307.14.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Brunner <chb@muc.de>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27951 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466Ab2BNRVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 12:21:11 -0500
In-Reply-To: <1329169382.2307.14.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2012 01:43 PM, Jeff Kirsher wrote:
> On Mon, 2012-02-13 at 15:12 +0100, Eric Dumazet wrote:
>> Le lundi 13 f=C3=A9vrier 2012 =C3=A0 14:52 +0100, Christian Brunner =
a =C3=A9crit :
>>> I'm seeing some page allocation failures with the ixgbe driver unde=
r heavy
>>> load. While looking after it, I came accoss the truesize handling. =
I suspect,
>>> that there is a small misstake in ixgbe_merge_active_tail(). (But I=
'm not
>>> really sure).
>>>
>>> Truesize allocation of the skb may be larger than skb->len, because
>>> ixgbe is allocating PAGE_SIZE/2 for received fragments. Hence we=20
>>> should use the truesize of the tail when merging.
>>>
>>> Signed-off-by: Christian Brunner <chb@muc.de>
>>> ---
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/driver=
s/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> index a42b0b2..c4d25af 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> @@ -1222,7 +1222,7 @@ static inline struct sk_buff *ixgbe_merge_act=
ive_tail(struct sk_buff *tail)
>>> =20
>>>  	head->len +=3D tail->len;
>>>  	head->data_len +=3D tail->len;
>>> -	head->truesize +=3D tail->len;
>>> +	head->truesize +=3D tail->truesize;
>>> =20
>>>  	IXGBE_CB(tail)->head =3D NULL;
>>> =20
>> You forgot CC Intel guys, but they usually catch netdev traffic :)
>>
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>
>>
> Thanks Eric for bringing this to my attention.
>
> Thanks Christian for the patch, I have added it to my queue.

The code itself is correct, but the comment isn't.  This code path is
applied only to the case where we are not using pages.  The default Rx
buffer size is actually about 3K when RSC is in use, which means
truesize is about 4.25K per buffer.

Thanks,

Alex
