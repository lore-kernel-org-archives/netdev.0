From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 2/7] stmmac: review barriers
Date: Thu, 04 Apr 2013 08:06:27 +0200
Message-ID: <515D1863.2070801@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com> <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com> <20130403085106.GA2039@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>,
	sergei.shtylyov@cogentembedded.com
To: Shiraz HASHIM <shiraz.hashim@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:51829 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756257Ab3DDGGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 02:06:41 -0400
In-Reply-To: <20130403085106.GA2039@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ciao Shiraz!

On 4/3/2013 10:51 AM, Shiraz HASHIM wrote:
> Hi Giuseppe,
>
> On Wed, Apr 03, 2013 at 01:41:24PM +0800, Giuseppe CAVALLARO wrote:
>> In all my tests performed on SH4 and ARM A9 platforms, I've never met problems
>> that can be fixed by using memory barriers. In the past there was some issues
>> on SMP ARM but fixed by reviewing xmit spinlock.
>
> The problem which was addressed was not because of SMP IMO. It was
> rather due to the fact that the write to the GMAC descriptor (which
> happens to be in normal memory) has to be ordered with respect to GMAC
> DMA as observer. Isn't it ?

Hmm yes you are right, now I remember that this was a code reordering
issue especially when we had looked at the commit:

stmmac: add memory barriers at appropriate places
  eb0dc4bb2e22c04964d

>> Further barriers have been added in the commits too: 8e83989106562326bf
>>
>> This patch is to use the smp_wbm instead of wbm because the driver
>                             ^^^^^^^^^^^^^^^^^^^^^^
> Perhaps you meant smp_wmb and wmb

sure.

from the commit:
stmmac: Fix for nfs hang on multiple reboot
    8e83989106562326bf

I had not understand if the problem was related to the SMP or to the
code ordering.
>
>> runs on UP systems. Then, IMO it could make sense to only maintain the barriers
>> just in places where we touch the dma owner bits (that is the
>> only real critical path as we had seen and fixed in the commit:
>> eb0dc4bb2e22c04964d).
>
> Replacing wmb by smp_wmb may not be a good idea as we need to order
> the store transaction to the descriptor with respect to GMAC DMA and
> using smp_* version would just be compiler barrier in uniprocessor
> systems.

Yes this what I wanted although the main point remains pending.
On my side, on SH4 (UP) and ARM (SMP) with several different
compiler and flags I have never seen problems and no barriers
are needed.

Especially in the commit "stmmac: Fix for nfs hang on multiple reboot"
the description of the problem looks to be quite obscure and I cannot
find any "particular" relation with extra barrier.

In fact, if we can demonstrate that barriers are needed no problem to
keep them in the code. Otherwise I prefer to remove them.

What do you think?

Cheers
peppe

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
>> -		wmb();
>
> Since it is a loop, shouldn't we ensure that the ownership of a tx
> descriptor is set before next descriptor in chain is programmed ?
>
>>   	}
>>
>>   	/* Finalize the latest segment. */
>>   	priv->hw->desc->close_tx_desc(desc);
>>
>> -	wmb();
>>   	/* According to the coalesce parameter the IC bit for the latest
>>   	 * segment could be reset and the timer re-started to invoke the
>>   	 * stmmac_tx function. This approach takes care about the fragments.
>> @@ -1821,9 +1819,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	} else
>>   		priv->tx_count_frames = 0;
>>
>> +	smp_wmb();
>
> Please reconsider, may be keeping wmb is better.
>
>>   	/* To avoid raise condition */
>>   	priv->hw->desc->set_tx_owner(first);
>> -	wmb();
>
> Not sure about this, perhaps can be removed.
>
>>
>>   	priv->cur_tx++;
>>
>> @@ -1899,9 +1897,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
>>
>>   			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
>>   		}
>> -		wmb();
>> +		smp_wmb();
>>   		priv->hw->desc->set_rx_owner(p);
>> -		wmb();
>
> Similarly this is a part of a loop, we need to see if set rx owner
> should be reflected before next descriptor program.
>
> --
> regards
> Shiraz
>
