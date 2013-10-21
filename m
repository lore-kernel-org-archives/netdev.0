From: Jimmy PERCHET <jimmy.perchet@parrot.com>
Subject: Re: [PATCH RFC 4/5] net:stmmac: fix jumbo frame handling.
Date: Mon, 21 Oct 2013 18:28:48 +0200
Message-ID: <52655640.4060405@parrot.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-5-git-send-email-jimmy.perchet@parrot.com> <52652EE7.2060500@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jimmy.perchet@gmail.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:38324 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab3JUQ2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 12:28:43 -0400
In-Reply-To: <52652EE7.2060500@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/2013 15:40, Giuseppe CAVALLARO wrote:
> On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
>> This patch addresses several issues which prevent jumbo frames from working properly :
>> .jumbo frames' last descriptor was not closed
>> .several confusion regarding descriptor's max buffer size
>> .frags could not be jumbo
>>
>> Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
> 
> 
> Jimmy, thx for thi patch. BElow some my first notes.

Thanks a lot for this first review.

> I'll continue to look at the patch to verify if I missed
> soemthing. I kindly ask you, for the next version, to add
> more comments especially in the function to prepare the
> tx desc in order to help me on reviewing.

Sure ;)

I hope do v2 by next week.

I'm OK with most of your comments. Some additional
notes below:

>>   }
>> @@ -81,7 +81,7 @@ static inline void ndesc_end_tx_desc_on_ring(struct dma_desc *p, int ter)
>>
>>   static inline void norm_set_tx_desc_len_on_ring(struct dma_desc *p, int len)
>>   {
>> -    if (unlikely(len > BUF_SIZE_2KiB)) {
>> +    if (unlikely(len >= BUF_SIZE_2KiB)) {
> 
> we cannot manage a size of 2048 on normal desc
> 
> Pls you should verify to not break the back-compatibility.

IMHO, this actually fix the problem you think I create.
In current code, if len is equal to 2048, buffer1_size is set to 2048,
this is wrong because the max size is actually 2047...

> 
>>           p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
>>           p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
>>       } else



>>
>>   static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
>>   {
>> @@ -103,13 +90,13 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
>>       if (unlikely(priv->plat->has_gmac))
>>           /* Fill DES3 in case of RING mode */
>>           if (priv->dma_buf_sz >= BUF_SIZE_8KiB)
>> -            p->des3 = p->des2 + BUF_SIZE_8KiB;
>> +            p->des3 = p->des2 + BUF_SIZE_8KiB - 1;
> 
> is it correct? can you check?

The actual buffer's max size is 8191, so, in ring mode,
the second buffer must start at p->des2 + 8191.

>> -    priv->cur_tx++;
>> +    priv->cur_tx += nb_desc;
> 
> can we avoid to use the nb_desc?
Actually, it is a preparation for my 5th patch : I want to write cur_tx only once.
I can split this.



Best Regards,
Jimmy
