From: "Figo.zhang" <figo1802@gmail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Sat, 06 Mar 2010 10:40:50 +0800
Message-ID: <1267843250.2669.7.camel@myhost>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	 <1267798077.2576.17.camel@myhost>
	 <f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
	 <20100305082218.4f734857@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41053 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205Ab0CFCkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 21:40:55 -0500
Received: by gyd10 with SMTP id 10so128964gyd.19
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 18:40:54 -0800 (PST)
In-Reply-To: <20100305082218.4f734857@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> One of the requirements for NAPI to work is that the IRQ is level triggered.
> Otherwise there can be a race between packet arrival and the end of
> NAPI processing:
> 
> static int ks8695_poll(struct napi_struct *napi, int budget)
> {
> 	struct ks8695_priv *ksp = container_of(napi, struct ks8695_priv, napi);
> 	unsigned long  work_done;
> 
> 	unsigned long isr = readl(KS8695_IRQ_VA + KS8695_INTEN);
> 	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
> 
> 	work_done = ks8695_rx(ksp, budget);
> 
> 	if (work_done < budget) {
> 		unsigned long flags;
> 		spin_lock_irqsave(&ksp->rx_lock, flags);
> >>> packet arrives >>
> 		/*enable rx interrupt*/
> 		writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);
> >>> or here >>
> 		__napi_complete(napi);
> 		spin_unlock_irqrestore(&ksp->rx_lock, flags);
> 

yes, it is right, it maybe a race condition. so you can motify
ks8695_poll() to try, like this:

		__napi_complete(napi);
		/*enable rx interrupt*/
		writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN); 


Best,
Figo.zhang

