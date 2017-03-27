From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Mon, 27 Mar 2017 18:44:22 +0100
Message-ID: <c8ec25cb-0369-a1b3-9f5b-dfd1ed6f9148@synopsys.com>
References: <20170325072621.GA20997@Red>
 <74765cbf-897a-67a1-7f42-337bf7dff6a8@synopsys.com>
 <20170327170058.GA8441@Red>
 <20170327.102831.1248194814523871799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <Joao.Pinto@synopsys.com>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <thierry.reding@gmail.com>,
        <sergei.shtylyov@cogentembedded.com>, <f.fainelli@gmail.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:57279 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbdC0Rod (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 13:44:33 -0400
In-Reply-To: <20170327.102831.1248194814523871799.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 6:28 PM de 3/27/2017, David Miller escreveu:
> From: Corentin Labbe <clabbe.montjoie@gmail.com>
> Date: Mon, 27 Mar 2017 19:00:58 +0200
> 
>> On Mon, Mar 27, 2017 at 04:26:48PM +0100, Joao Pinto wrote:
>>> Hi David,
>>>
>>> Às 7:26 AM de 3/25/2017, Corentin Labbe escreveu:
>>>> On Fri, Mar 24, 2017 at 05:16:45PM +0000, Joao Pinto wrote:
>>>>> For cores that have more than 1 TX queue configured, the kernel would crash,
>>>>> since only one TX queue is permitted by default.
>>>>>
>>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>>> ---
>>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>>> index 3827952..1eab084 100644
>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>>> @@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>>>>>  	struct stmmac_rx_queue *rx_q =
>>>>>  		container_of(napi, struct stmmac_rx_queue, napi);
>>>>>  	struct stmmac_priv *priv = rx_q->priv_data;
>>>>> -	u32 tx_count = priv->dma_cap.number_tx_queues;
>>>>> +	u32 tx_count = priv->plat->tx_queues_to_use;
>>>>>  	u32 chan = rx_q->queue_index;
>>>>>  	u32 work_done = 0;
>>>>>  	u32 queue = 0;
>>>>> -- 
>>>>> 2.9.3
>>>>>
>>>>
>>>> This patch fix the performance issue on dwmac-sun8i only.
>>>> The dwmac-sunxi is still broken.
>>>>
>>>
>>> This patch series can be upstreamed please, since they make 2 fixes, one of them
>>> solving the problem in dwmac-sun8i.
>>>
>>> Thanks.
>>
>> As I said in a previous answer, finaly dwmac-sun8i is still broken.
>> Adding thoses 2 patch will just made the revert harder.
> 
> I agree.

For what I am understanding, SoCs base on Core versions >= 4.00 are working
properly and for some reason SoCs based on older versions are not working.

This fix is necessary, since if you have a diferent configured tx_queues_to_use
in the driver and priv->dma_cap.number_tx_queues in the core, this can lead to
kernel crashes.

The other fix (netdev resources release) is also necessary, since when you
release the driver its crashes, because the rx queue struct is freed before
releasing the netdevs.

We can revert, but I think it might not solve the issue. We can break the
"multiple buffers" patch into "rx multilple buffers" and "tx multiple buffers",
but will that actually work? We can give it a try, I don't mind making a new
multiple buffers patch broken into 2, that can be tested by new cores and older
cores.

Joao
