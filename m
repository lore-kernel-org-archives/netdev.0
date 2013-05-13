From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with
 TSO
Date: Mon, 13 May 2013 14:34:53 -0700
Message-ID: <51915C7D.2000407@broadcom.com>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
 <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
 <1368479644.13473.121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Michael Chan" <mchan@broadcom.com>, stable@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1368479644.13473.121.camel@edumazet-glaptop>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/13/2013 02:14 PM, Eric Dumazet wrote:
> On Mon, 2013-05-13 at 14:04 -0700, Nithin Nayak Sujir wrote:
>> From: Michael Chan <mchan@broadcom.com>
>>
>> The 5725 family of devices (asic rev 5762), corrupts TSO packets where
>> the buffer is within MSS bytes of a 4G boundary (4G, 8G etc.). Detect
>> this condition and trigger the workaround path.
>>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
>> ---
>>   drivers/net/ethernet/broadcom/tg3.c | 17 +++++++++++++++++
>>   1 file changed, 17 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
>> index 781be76..e285d76 100644
>> --- a/drivers/net/ethernet/broadcom/tg3.c
>> +++ b/drivers/net/ethernet/broadcom/tg3.c
>> @@ -7448,6 +7448,20 @@ static inline int tg3_4g_overflow_test(dma_addr_t mapping, int len)
>>   	return (base > 0xffffdcc0) && (base + len + 8 < base);
>>   }
>>
>> +/* Test for TSO DMA buffers that cross into regions which are within MSS bytes
>> + * of any 4GB boundaries: 4G, 8G, etc
>> + */
>> +static inline int tg3_4g_tso_overflow_test(struct tg3 *tp, dma_addr_t mapping,
>> +					   u32 len, u32 mss)
>> +{
>> +	if (tg3_asic_rev(tp) == ASIC_REV_5762 && mss) {
>> +		u32 base = (u32) mapping & 0xffffffff;
>> +
>> +		return ((base + len + (mss & 0x3fff)) < base);
>> +	}
>> +	return 0;
>> +}
>> +
>
> I am curious : Does this condition even triggers ?
>

Yes, it's a rare problem to occur and was reported in our lab. After we 
implemented this fix, the problem didn't happen again.


>
>
>
