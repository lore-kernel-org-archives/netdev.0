From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 1/3] net: ethernet: ti: cpdma: fix lockup in
 cpdma_ctlr_destroy()
Date: Tue, 26 Jul 2016 19:02:53 +0300
Message-ID: <88f436f2-afe9-6a98-5887-95a1d910b57f@ti.com>
References: <20160722135847.20557-1-grygorii.strashko@ti.com>
 <20160722135847.20557-2-grygorii.strashko@ti.com>
 <fcce1940-3ca2-f5ad-bc71-8ab902c14266@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fcce1940-3ca2-f5ad-bc71-8ab902c14266@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/23/2016 09:24 AM, Ivan Khoronzhuk wrote:
> 
> 
> On 22.07.16 16:58, Grygorii Strashko wrote:
>> Fix deadlock in cpdma_ctlr_destroy() which is triggered now on
>> cpsw module removal:
>>  cpsw_remove()
>>  - cpdma_ctlr_destroy()
>>    - spin_lock_irqsave(&ctlr->lock, flags)
>>    - cpdma_ctlr_stop()
>>      - spin_lock_irqsave(&ctlr->lock, flags); <- deadlock
>>    - cpdma_chan_destroy()
>>      - spin_lock_irqsave(&ctlr->lock, flags); <- deadlock
>>
>> The issue has not been observed before because CPDMA channels have
>> been destroyed manually by CPSW until commit d941ebe88a41 ("net:
>> ethernet: ti: cpsw: use destroy ctlr to destroy channels") was merged.
>>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>  drivers/net/ethernet/ti/davinci_cpdma.c | 2 --
>>  1 file changed, 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c
>> b/drivers/net/ethernet/ti/davinci_cpdma.c
>> index a68652a..89242e9 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>> @@ -436,7 +436,6 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
>>      if (!ctlr)
>>          return -EINVAL;
>>
>> -    spin_lock_irqsave(&ctlr->lock, flags);
> Should ctlr->state be checked under lock?
> Seems like here should be used unlocked static versions of
> cpdma_ctlr_stop() and cpdma_chan_destroy() instead.

As per my understanding it's not expected the ctlr->state will be changed at this 
moment as all net devices has been unregistered already.

> 
>>      if (ctlr->state != CPDMA_STATE_IDLE)

May be I can move above check in cpdma_ctlr_stop() instead.
What do you think?

>>          cpdma_ctlr_stop(ctlr);
>>
>> @@ -444,7 +443,6 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
>>          cpdma_chan_destroy(ctlr->channels[i]);
>>
>>      cpdma_desc_pool_destroy(ctlr->pool);
>> -    spin_unlock_irqrestore(&ctlr->lock, flags);
>>      return ret;
>>  }
>>  EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
>>
> 


-- 
regards,
-grygorii
