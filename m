From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next v3 0/4] net: mvneta: improve rx/tx performance
Date: Mon, 20 Feb 2017 15:21:35 +0100
Message-ID: <877f4laqog.fsf@free-electrons.com>
References: <20170220125344.3555-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, <mw@semihalf.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56447 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753255AbdBTOVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 09:21:38 -0500
In-Reply-To: <20170220125344.3555-1-jszhang@marvell.com> (Jisheng Zhang's
        message of "Mon, 20 Feb 2017 20:53:40 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jisheng,
 
 On lun., févr. 20 2017, Jisheng Zhang <jszhang@marvell.com> wrote:

> In hot code path such as mvneta_rx_swbm(), we access fields of rx_desc
> and tx_desc. These DMA descs are allocated by dma_alloc_coherent, they
> are uncacheable if the device isn't cache coherent, reading from
> uncached memory is fairly slow.
>
> patch1 reuses the read out status to getting status field of rx_desc
> again.
>
> patch2 avoids getting buf_phys_addr from rx_desc again in
> mvneta_rx_hwbm by reusing the phys_addr variable.
>
> patch3 avoids reading from tx_desc as much as possible by store what
> we need in local variable.
>
> We get the following performance data on Marvell BG4CT Platforms
> (tested with iperf):
>
> before the patch:
> sending 1GB in mvneta_tx()(disabled TSO) costs 793553760ns
>
> after the patch:
> sending 1GB in mvneta_tx()(disabled TSO) costs 719953800ns
>
> we saved 9.2% time.
>
> patch4 uses cacheable memory to store the rx buffer DMA address.
>
> We get the following performance data on Marvell BG4CT Platforms
> (tested with iperf):
>
> before the patch:
> recving 1GB in mvneta_rx_swbm() costs 1492659600 ns
>
> after the patch:
> recving 1GB in mvneta_rx_swbm() costs 1421565640 ns

Could you explain who you get this number?

receiving 1GB in 1.42 second means having a bandwidth of
8/1.42=5.63 Gb/s, that means that you are using at least a 10Gb
interface.

When I used iperf I didn't have this kind of granularity:
iperf -c 192.168.10.1 -n 1024M
------------------------------------------------------------
Client connecting to 192.168.10.19, TCP port 5001
TCP window size: 43.8 KByte (default)
------------------------------------------------------------
[  3] local 192.168.10.28 port 53086 connected with 192.168.10.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 9.1 sec  1.00 GBytes   942 Mbits/sec

Also without HWBM enabled (so with the same configuration of your test),
I didn't noticed any improvement with the patch set applied. But at
least I didn't see any regression with or without HWBM.

Gregory

>
> We saved 4.76% time.
>
> Basically, patch1 and patch4 do what Arnd mentioned in [1].
>
> Hi Arnd,
>
> I added "Suggested-by you" tag, I hope you don't mind ;)
>
> Thanks
>
> [1] https://www.spinics.net/lists/netdev/msg405889.html
>
> Since v2:
>   - add Gregory's ack to patch1
>   - only get rx buffer DMA address from cacheable memory for mvneta_rx_swbm()
>   - add patch 2 to read rx_desc->buf_phys_addr once in mvneta_rx_hwbm()
>   - add patch 3 to avoid reading from tx_desc as much as possible
>
> Since v1:
>   - correct the performance data typo
>
>
> Jisheng Zhang (4):
>   net: mvneta: avoid getting status from rx_desc as much as possible
>   net: mvneta: avoid getting buf_phys_addr from rx_desc again
>   net: mvneta: avoid reading from tx_desc as much as possible
>   net: mvneta: Use cacheable memory to store the rx buffer DMA address
>
>  drivers/net/ethernet/marvell/mvneta.c | 80 +++++++++++++++++++----------------
>  1 file changed, 43 insertions(+), 37 deletions(-)
>
> -- 
> 2.11.0
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
