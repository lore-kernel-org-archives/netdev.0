From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git)] stmmac: fix and review whole driver locking
Date: Mon, 8 Sep 2014 08:08:37 +0200
Message-ID: <540D47E5.7030005@st.com>
References: <1409637603-17347-1-git-send-email-peppe.cavallaro@st.com> <20140904.222240.631527743151693875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bigeasy@linutronix.de>,
	<khoroshilov@ispras.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:55177 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751424AbaIHGIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 02:08:51 -0400
In-Reply-To: <20140904.222240.631527743151693875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/2014 7:22 AM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Tue, 2 Sep 2014 08:00:03 +0200
>
>> The patch reviews the tx lock removing it because the driver
>> claims the resource in NAPI context and, as designed, can run
>> w/o any own extra lock (so just netif_tx_lock).
>> This shows an impact on performances too.
>
> It's not that simple, you have to make some changes if you really
> want to allow these two threads of control to run asynchronously.
>
> Look at this comment from tg3_tx() in the tg3 driver for example:
>
> ====================
> 	tnapi->tx_cons = sw_idx;
>
> 	/* Need to make the tx_cons update visible to tg3_start_xmit()
> 	 * before checking for netif_queue_stopped().  Without the
> 	 * memory barrier, there is a small possibility that tg3_start_xmit()
> 	 * will miss it and cause the queue to be stopped forever.
> 	 */
> 	smp_mb();
>
> 	if (unlikely(netif_tx_queue_stopped(txq) &&
> ====================
>
> With the lock removed, these two code paths will operate and execute
> completely in parallel with eachother.  Therefore the updates of
> certain TX ring state variables will need to be strictly ordered.

Thanks David for your feedback.

I will take care about this note and analyze the code that in some
parts already forces some instruction to be ordered...maybe it could
cover the problem; indeed, I had not seen any issue when stressing the 
driver on SMP systems also when run more then one nuttcp/iperf/netperf 
instances  (supposing that my tests were ok to trigger the case).

I let you know and in case of news I rework the patch w/o w/ locks
for tx path. I will also do all the tests on my platforms before
sending.

peppe
