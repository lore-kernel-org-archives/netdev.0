From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 07:22:08 +0000
Message-ID: <20100106072208.GA6711@ff.dom.local>
References: <20100105230746.GA6612@del.dom.local> <4B43F72C.9090004@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755557Ab0AFHWW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B43F72C.9090004@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 05, 2010 at 09:36:28PM -0500, Michael Breuer wrote:
> On 1/5/2010 6:07 PM, Jarek Poplawski wrote:
>> David Miller wrote, On 12/27/2009 05:11 AM:
>>
>>    
>>> From: David Miller<davem@davemloft.net>
>>> Date: Sat, 26 Dec 2009 19:44:18 -0800 (PST)
>>>
>>>      
>>>> From: Stephen Hemminger<shemminger@linux-foundation.org>
>>>> Date: Sat, 26 Dec 2009 14:05:44 -0800
>>>>
>>>>        
>>>>> Other drivers may have same problem, I really think this ought
>>>>> to be done at higher level.
>>>>>          
>>>> I tend to agree with you, and I thought we had handled all
>>>> cases.  Let's simply make AF_PACKET linearize the link
>>>> level header before sending things out to the transmit path.
>>>>
>>>> I can work on this if you want.
>>>>        
>>> Actually Stephen, I took a look and I can't see how AF_PACKET
>>> can create this situation.
>>>
>>> It always copies into the linear area of the SKB it allocates
>>> for sendmsg() processing.  Whether the data comes from sendmsg
>>> data or the mmap() ring buffer.
>>>      
>> Actually, I think there is a bug in this place, but of course this
>> might be unconnected. Anyway, Michael, could you try this patch?
>> BTW, did you try with CONFIG_PACKET_MMAP disabled?
>>
>> Thanks,
>> Jarek P.
>> ----------------->
>>
>> Changing an skb after dev_queue_xmit() is illegal. And since it's
>> inconsistent to treat specially net_xmit_errno() non-zero return,
>> while ignoring other dev_queue_xmit() errors, there is no reason
>> to break the loop in tpacket_snd() in this case.
>>
>> With debugging by: Stephen Hemminger<shemminger@linux-foundation.org>
>>
>> Reported-by: Michael Breuer<mbreuer@majjas.com>
>> Signed-off-by: Jarek Poplawski<jarkao2@gmail.com>
>> ---
>>
>>   net/packet/af_packet.c |    8 +++-----
>>   1 files changed, 3 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index e0516a2..984a1fa 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1021,8 +1021,9 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>>
>>   		status = TP_STATUS_SEND_REQUEST;
>>   		err = dev_queue_xmit(skb);
>> -		if (unlikely(err>  0&&  (err = net_xmit_errno(err)) != 0))
>> -			goto out_xmit;
>> +		if (unlikely(err>  0))
>> +			err = net_xmit_errno(err);
>> +
>>   		packet_increment_head(&po->tx_ring);
>>   		len_sum += tp_len;
>>   	} while (likely((ph != NULL) ||
>> @@ -1033,9 +1034,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>>   	err = len_sum;
>>   	goto out_put;
>>
>> -out_xmit:
>> -	skb->destructor = sock_wfree;
>> -	atomic_dec(&po->tx_ring.pending);
>>   out_status:
>>   	__packet_set_status(po, ph, status);
>>   	kfree_skb(skb);
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>    
> This patch solves the original reported oops - as did Steven's patch of  
> 12/26: [PATCH] sky2: make sure ethernet header is in transmit skb (I ran  
> without Steven's patch and with this patch).
>
> Oddly, with this patch vs. Steven's - I'm getting software interrupt  
> errors sporadically while not under load - with Steven's I get the  
> frequently while under load (as per nethogs). For example:
> Jan  5 21:29:00 mail kernel: sky2 0000:06:00.0: error interrupt  
> status=0x40000008
> Jan  5 21:29:00 mail kernel: sky2 software interrupt status 0x40000008
> Jan  5 21:29:00 mail kernel: sky2 Tx ring pending=124...125 report=125  
> done=125
> Jan  5 21:29:00 mail kernel: 124: 0xb38de0be(5374)
> Jan  5 21:29:00 mail kernel: sky2 0000:06:00.0: error interrupt status=0x8
> Jan  5 21:29:00 mail kernel: sky2 software interrupt status 0x8
> Jan  5 21:29:00 mail kernel: sky2 Tx ring pending=126...127 report=126  
> done=127
> Jan  5 21:29:00 mail kernel: 126: 0xb38d80be(9014)
>
> I also believe (can't prove yet) that my load test is slower with this  
> patch vs. the sky2 patch.
>
> Is it possible that this patch is causing the transmission to  
> momentarily halt such that the overall utilization appears low at the  
> time I see the interrupt errors, vs. the other patch which perhaps  
> doesn't interrupt the traffic flow quite so much?

Yes, without this patch xmit could be stopped earlier on some kind of
errors, with retransmit of the last message possible. On the other
hand, other dev_queue_xmit() (negative) errors, are ignored. So this
place could be still improved by adding proper err handling (or
removing getting err return from dev_queue_xmit() at all).

Anyway, I think this patch should be a safe proposal for stable. If
so, David, please add Michael's "Tested-by".

>
> I haven't run yet with CONFIG_PACKET_MMAP disabled.
>
This should behave similarly as MMAP with this patch or maybe even
better in case of errors.

Thanks,
Jarek P.
