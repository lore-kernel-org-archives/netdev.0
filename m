From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V2 net-next 01/21] net-next/hinic: Initialize hw interface
Date: Tue, 25 Jul 2017 01:03:19 +0200
Message-ID: <20170724230318.GA26260@electric-eye.fr.zoreil.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <0febc61414e7908a7c8c0c2fa7c2b06b0f7524f7.1500454998.git.aviad.krawczyk@huawei.com>
 <20170719222740.GA1755@electric-eye.fr.zoreil.com>
 <33fbbf34-cdbe-81a8-dc33-2cd6cb6cf4ee@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bc.y@huawei.com, victor.gissin@huawei.com,
        zhaochen6@huawei.com, tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44077 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752734AbdGXXDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:03:36 -0400
Content-Disposition: inline
In-Reply-To: <33fbbf34-cdbe-81a8-dc33-2cd6cb6cf4ee@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aviad Krawczyk <aviad.krawczyk@huawei.com> :
[...]
> hinic_remove - If insmod failed and someone calls rmmod, we will get a
> crash because the resource are already free. Therefore we test if the
> device exists, please tell me if you meant to something different

The module won't even proceed through the pci_driver remove method if
the probe method failed. See drivers/pci/bus.c::pci_bus_add_device and
track 'dev->is_added'. You don't need to believe me: try it.

I have no idea where your crash comes from but something does not
look quite right.

(use module_pci_driver() to save some boilerplate code btw)

[...]
> The priv data is in type void * because the
> caller can use any struct that it wants, like the priv data in Linux
> (netdev, irq, tasklet, work..) -

I disagree. A driver is a piece of glue between hardware and software.
It fills a kernel's contract. It is not supposed to introduce opaque
data (even if it's hard to resist).

> we can change it but if we will pass different struct
> in the future, we will have to change the prototype of the functions.

It's fine. If I do something wrong - and at some point I will - I'd
rather have it detected at compile time. Nobody wants to waste precious
hardware lab testing time because of excess void *.

> According to the other void *:
> The wq struct is used for cmdq, sq and rq. Therefore the wqe is in type
> void *. There are 4 operations get_wqe, write_wqe, read_wqe and put_wqe - there
> is no option that one function will be fed with a wrong pointer because the caller
> should use what it got in get_wqe function.
> 
> When something is used as multiple types, it can be used as void * or union.
> Usually, I would prefer union. But, in this case if we will use union, maybe
> there is a chance of using the wrong wqe type in the wrong work queue type.

union * will at least catch being fed a wrong type. void * won't notice.

Let's take a practical example: hinic_sq_get_sges.

void hinic_sq_get_sges(void *wqe, struct hinic_sge *sges, int nr_sges)
                       ^^^^^^^^^
{
        struct hinic_sq_wqe *sq_wqe = (struct hinic_sq_wqe *)wqe;


static void free_all_tx_skbs(struct hinic_txq *txq)
{
        struct hinic_dev *nic_dev = netdev_priv(txq->netdev);
        struct hinic_sq *sq = txq->sq;
        struct hinic_sq_wqe *wqe;
[...]
                hinic_sq_get_sges(wqe, txq->free_sges, nr_sges);


static int free_tx_poll(struct napi_struct *napi, int budget)
{
[...]
        struct hinic_sq_wqe *wqe;
[...]
                hinic_sq_get_sges(wqe, txq->free_sges, nr_sges);


Why is it:

void hinic_sq_get_sges(void *wqe, ...

instead of:

void hinic_sq_get_sges(struct hinic_sq_wqe *wqe, ...

Because of a future change ?

-- 
Ueimor
