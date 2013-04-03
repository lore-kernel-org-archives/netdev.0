From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 2/7] stmmac: review barriers
Date: Wed, 03 Apr 2013 09:28:28 +0200
Message-ID: <515BDA1C.8010503@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>  <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com> <1364973523.13853.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:35431 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763014Ab3DCH2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 03:28:32 -0400
In-Reply-To: <1364973523.13853.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2013 9:18 AM, Eric Dumazet wrote:
> On Wed, 2013-04-03 at 07:41 +0200, Giuseppe CAVALLARO wrote:
>> In all my tests performed on SH4 and ARM A9 platforms, I've never met problems
>> that can be fixed by using memory barriers. In the past there was some issues
>> on SMP ARM but fixed by reviewing xmit spinlock.
>>
>> Further barriers have been added in the commits too: 8e83989106562326bf
>>
>> This patch is to use the smp_wbm instead of wbm because the driver
>> runs on UP systems. Then, IMO it could make sense to only maintain the barriers
>> just in places where we touch the dma owner bits (that is the
>> only real critical path as we had seen and fixed in the commit:
>> eb0dc4bb2e22c04964d).
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Cc: Deepak Sikri <deepak.sikri@st.com>
>> Cc: Shiraz Hashim <shiraz.hashim@st.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 +++------
>>   1 files changed, 3 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 8b69e3b..c92dcbc 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1797,15 +1797,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>>   		priv->tx_skbuff[entry] = NULL;
>>   		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
>>   						priv->mode);
>> -		wmb();
>> +		smp_wmb();
>>   		priv->hw->desc->set_tx_owner(desc);
>
> This looks pretty bogus to me.
>
> If arch is UP, smp_wmb() is empty.
>
> So why are you using it ?
>
> Barrier here is not to protect the interaction with another cpu, but the
> NIC itself.
>
> If there is no need for barrier as you claim in changelog, don't add a
> fake smp_wmb().
>

ok I'll do it because I do not need any barrier when test on my UP and
SMP. Barriers were added for SPEAr but I have never seen problems
although I have not done too many tests on these platforms. I usually
run on other ST ARM box but, as rule of thumb, similar to some SPEAr
for CPU and MAC.
At any rate, if somebody aims to have them we will discuss in this
mailing list to understand why/where these have to be placed in the code

peppe
