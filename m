From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V2 net-next 01/21] net-next/hinic: Initialize hw interface
Date: Tue, 25 Jul 2017 17:50:38 +0300
Message-ID: <01800b7a-c11d-980f-0e5e-d4684eaa0f2a@huawei.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <0febc61414e7908a7c8c0c2fa7c2b06b0f7524f7.1500454998.git.aviad.krawczyk@huawei.com>
 <20170719222740.GA1755@electric-eye.fr.zoreil.com>
 <33fbbf34-cdbe-81a8-dc33-2cd6cb6cf4ee@huawei.com>
 <20170724230318.GA26260@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <bc.y@huawei.com>,
        <victor.gissin@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:10267 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752327AbdGYOvD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:51:03 -0400
In-Reply-To: <20170724230318.GA26260@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

hinic_remove - you are right, it is over safe code. We can remove it without
any crash. This case has never happened.

void * - I meant the problem is not in rq or sq, it can be in wq. But you confirmed
that it is ok to use union instead of the void* in wq. So, we will use union in wq.c
and in rq - rq_wqe and in sq - sq_wqe.

module_pci_driver - is not used in other drivers in the same segments, it is necessary?

Thanks,
Aviad


On 7/25/2017 2:03 AM, Francois Romieu wrote:
> Aviad Krawczyk <aviad.krawczyk@huawei.com> :
> [...]
>> hinic_remove - If insmod failed and someone calls rmmod, we will get a
>> crash because the resource are already free. Therefore we test if the
>> device exists, please tell me if you meant to something different
> 
> The module won't even proceed through the pci_driver remove method if
> the probe method failed. See drivers/pci/bus.c::pci_bus_add_device and
> track 'dev->is_added'. You don't need to believe me: try it.
> 
> I have no idea where your crash comes from but something does not
> look quite right.
> 
> (use module_pci_driver() to save some boilerplate code btw)
> 
> [...]
>> The priv data is in type void * because the
>> caller can use any struct that it wants, like the priv data in Linux
>> (netdev, irq, tasklet, work..) -
> 
> I disagree. A driver is a piece of glue between hardware and software.
> It fills a kernel's contract. It is not supposed to introduce opaque
> data (even if it's hard to resist).
> 
>> we can change it but if we will pass different struct
>> in the future, we will have to change the prototype of the functions.
> 
> It's fine. If I do something wrong - and at some point I will - I'd
> rather have it detected at compile time. Nobody wants to waste precious
> hardware lab testing time because of excess void *.
> 
>> According to the other void *:
>> The wq struct is used for cmdq, sq and rq. Therefore the wqe is in type
>> void *. There are 4 operations get_wqe, write_wqe, read_wqe and put_wqe - there
>> is no option that one function will be fed with a wrong pointer because the caller
>> should use what it got in get_wqe function.
>>
>> When something is used as multiple types, it can be used as void * or union.
>> Usually, I would prefer union. But, in this case if we will use union, maybe
>> there is a chance of using the wrong wqe type in the wrong work queue type.
> 
> union * will at least catch being fed a wrong type. void * won't notice.
> 
> Let's take a practical example: hinic_sq_get_sges.
> 
> void hinic_sq_get_sges(void *wqe, struct hinic_sge *sges, int nr_sges)
>                        ^^^^^^^^^
> {
>         struct hinic_sq_wqe *sq_wqe = (struct hinic_sq_wqe *)wqe;
> 
> 
> static void free_all_tx_skbs(struct hinic_txq *txq)
> {
>         struct hinic_dev *nic_dev = netdev_priv(txq->netdev);
>         struct hinic_sq *sq = txq->sq;
>         struct hinic_sq_wqe *wqe;
> [...]
>                 hinic_sq_get_sges(wqe, txq->free_sges, nr_sges);
> 
> 
> static int free_tx_poll(struct napi_struct *napi, int budget)
> {
> [...]
>         struct hinic_sq_wqe *wqe;
> [...]
>                 hinic_sq_get_sges(wqe, txq->free_sges, nr_sges);
> 
> 
> Why is it:
> 
> void hinic_sq_get_sges(void *wqe, ...
> 
> instead of:
> 
> void hinic_sq_get_sges(struct hinic_sq_wqe *wqe, ...
> 
> Because of a future change ?
> 
