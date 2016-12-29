From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: davinci_cpdma: fix access to
 uninitialized variable in cpdma_chan_set_descs()
Date: Thu, 29 Dec 2016 10:04:01 -0600
Message-ID: <9394fcbe-b285-ce9f-03c9-60e694cc1c0d@ti.com>
References: <20161228234213.22166-1-grygorii.strashko@ti.com>
 <20161229014904.GA22718@khorivan>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161229014904.GA22718@khorivan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ivan,

On 12/28/2016 07:49 PM, Ivan Khoronzhuk wrote:
> On Wed, Dec 28, 2016 at 05:42:13PM -0600, Grygorii Strashko wrote:
>> Now below code sequence causes "Unable to handle kernel NULL pointer
>> dereference.." exception and system crash during CPSW CPDMA initialization:
>>
>> cpsw_probe
>> |-cpdma_chan_create (TX channel)
>>   |-cpdma_chan_split_pool
>>     |-cpdma_chan_set_descs(for TX channels)
>>     |-cpdma_chan_set_descs(for RX channels) [1]
>>
>> - and -
>> static void cpdma_chan_set_descs(struct cpdma_ctlr *ctlr,
>> 				 int rx, int desc_num,
>> 				 int per_ch_desc)
>> {
>> 	struct cpdma_chan *chan, *most_chan = NULL;
>>
>> ...
>>
>> 	for (i = min; i < max; i++) {
>> 		chan = ctlr->channels[i];
>> 		if (!chan)
>> 			continue;
>> ...
>>
>> 		if (most_dnum < chan->desc_num) {
>> 			most_dnum = chan->desc_num;
>> 			most_chan = chan;
>> 		}
>> 	}
>> 	/* use remains */
>> 	most_chan->desc_num += desc_cnt; [2]
>> }
>>
>> So, most_chan value will never be reassigned when cpdma_chan_set_descs() is
>> called second time [1], because there are no RX channels yet and system
>> will crash at [2].
> 
> How did you get this?
> I just remember as I fixed it before sending patchset.
> 
> Maybe it was some experiment with it.
> I just wonder and want to find actual reason what's happening.
> 
> Look bellow:
> 
> cpsw_probe
> |-cpdma_chan_create (TX channel)
>   |-cpdma_chan_split_pool
>     |-cpdma_chan_set_descs(for TX channels)
>     |-cpdma_chan_set_descs(for RX channels) [1]
> 
> |-cpdma_chan_set_descs(for RX channels) in case you'be described has to be
> called with rx_desc_num = 0, because all descs are assigned already for tx
> channel. And, if desc_num = 0, cpdma_chan_set_descs just exits and no issues.
> So, could you please explain how you get this, in what circumstances.

You are right. I've hit this issue while working on other feature which allows
to split pool between RX and TX path and as part of it cpdma_chan_set_descs()
is called with different set of arguments. I probably will just squash it in my changes or 
or send as part of my series.


-- 
regards,
-grygorii
