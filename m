From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH]e100 in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 16:33:04 +0300
Message-ID: <54957A90.50803@cogentembedded.com>
References: <000001d01c28$41c937c0$c55ba740$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux-nics@isotope.jf.intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net
To: Jia-Ju Bai <baijiaju1990@163.com>, todd.fujinaka@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:61725 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbaLTNdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 08:33:07 -0500
Received: by mail-lb0-f171.google.com with SMTP id w7so2088875lbi.2
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2014 05:33:05 -0800 (PST)
In-Reply-To: <000001d01c28$41c937c0$c55ba740$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/20/2014 10:40 AM, Jia-Ju Bai wrote:

> I have actually tested e100 driver on the real hardware(Intel 82559 PCI
> Ethernet Controller), and find some bugs:
> The target file is drivers/net/ethernet/intel/e100.c, which is used to build
> e100.ko.

> (1) The function pci_pool_create is called by e100_probe when initializing
> the ethernet card driver. But when pci_pool_create is failed, which means
> that it returns NULL to nic->cbs_pool, the system crash will happen. Because
> pci_pool_alloc (in e100_alloc_cbs in e100_up in e100_open) need to use
> nic->cbs_pool to allocate the resource, but it is NULL. I suggest that a
> check can be added in the code to detect whether pci_pool_create returns
> NULL.
> (2) In the normal process, netif_napi_add is called in e100_probe, but
> netif_napi_del is not called in e100_remove. However, many other ethernet
> card drivers call them in pairs, even in the error handling paths, such as
> r8169 and igb.

> Meanwhile, I also write the patch to fix the bugs. I have run the patch on
> the hardware, it can work normally and fix the above bugs.

> diff --git a/drivers/net/ethernet/intel/e100.c
> b/drivers/net/ethernet/intel/e100.c
> index 781065e..2631d3f 100644
> --- a/drivers/net/ethernet/intel/e100.c
> +++ b/drivers/net/ethernet/intel/e100.c
> @@ -2969,6 +2969,11 @@ static int e100_probe(struct pci_dev *pdev, const
> struct pci_device_id *ent)
>   			   nic->params.cbs.max * sizeof(struct cb),
>   			   sizeof(u32),
>   			   0);
> +	if(!(nic->cbs_pool))

    Oh, and the inner () not needed.

WBR, Sergei
