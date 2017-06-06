From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net] net: stmmac: fix completely hung TX when using TSO
Date: Tue, 6 Jun 2017 12:01:08 +0200
Message-ID: <56b1194f-959e-e936-88e0-f52063c7ffa0@axis.com>
References: <20170606072501.16560-1-niklas.cassel@axis.com>
 <53a84a68-5014-7a92-5e78-f9f04aa948c6@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53a84a68-5014-7a92-5e78-f9f04aa948c6@st.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2017 10:00 AM, Giuseppe CAVALLARO wrote:
> Hi Niklas

Hello Peppe, Alex

> 
> I get the point and I acked the patch but Alex, please, can you confirm
> that this issue has never seen on your boxes where the TSO has been
> fully tested? The initial development (commit f748be531) introduces
> the following:
>     (last_segment) && (buff_size < TSO_MAX_BUFF_SIZE),
> ...

Since you need a packet where the txbuff size of last descriptor
has the exact size of 16K-1, depending on your workload,
it is possible to run your system for a very long time without
triggering the bug.

We noticed the problem since a test in our test suite fetches
the syslog. The syslog usually has a size that is not constant,
and the size usually increases with time.
During some of the test runs, far from all of them, we would
eventually end up with a packet of the exact size that triggers
the bug.

It should be possible to trigger the bug more easily if you
know what buffer size to write to your TCP socket, together
with some manual TCP corking.


Regards,
Niklas

> 
> On 6/6/2017 9:25 AM, Niklas Cassel wrote:
>> stmmac_tso_allocator can fail to set the Last Descriptor bit
>> on a descriptor that actually was the last descriptor.
>>
>> This happens when the buffer of the last descriptor ends
>> up having a size of exactly TSO_MAX_BUFF_SIZE.
>>
>> When the IP eventually reaches the next last descriptor,
>> which actually has the bit set, the DMA will hang.
>>
>> When the DMA hangs, we get a tx timeout, however,
>> since stmmac does not do a complete reset of the IP
>> in stmmac_tx_timeout, we end up in a state with
>> completely hung TX.
>>
>> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> 
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 68a188e74c54..440bea049a7f 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -2723,7 +2723,7 @@ static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
>>             priv->hw->desc->prepare_tso_tx_desc(desc, 0, buff_size,
>>               0, 1,
>> -            (last_segment) && (buff_size < TSO_MAX_BUFF_SIZE),
>> +            (last_segment) && (tmp_len <= TSO_MAX_BUFF_SIZE),
>>               0, 0);
>>             tmp_len -= TSO_MAX_BUFF_SIZE;
> 
> Regards
> Peppe
> 
> 
