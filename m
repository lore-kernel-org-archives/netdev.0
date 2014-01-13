From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 6/6] net: mvneta: implement rx_copybreak
Date: Mon, 13 Jan 2014 10:13:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D458FB3@AcuExch.aculab.com>
References: <1389525848-1814-1-git-send-email-w@1wt.eu>
 <1389525848-1814-7-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: 'Willy Tarreau' <w@1wt.eu>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51406 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751256AbaAMKPR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 05:15:17 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18521-06 for <netdev@vger.kernel.org>;
 Mon, 13 Jan 2014 10:15:13 +0000 (GMT)
In-Reply-To: <1389525848-1814-7-git-send-email-w@1wt.eu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau
> calling dma_map_single()/dma_unmap_single() is quite expensive compared
> to copying a small packet. So let's copy short frames and keep the buffers
> mapped. We set the limit to 256 bytes which seems to give good results both
> on the XP-GP board and on the AX3/4.

Which architecture is this?
I presume it is one that needs iommu setup and/or cache flushing.

> The Rx small packet rate increased by 16.4% doing this, from 486kpps to
> 573kpps. It is worth noting that even the call to the function
> dma_sync_single_range_for_cpu() is expensive (300 ns) although less
> than dma_unmap_single(). Without it, the packet rate raises to 711kpps
> (+24% more). Thus on systems where coherency from device to CPU is
> guaranteed by a snoop control unit, this patch should provide even more
> gains, and probably rx_copybreak could be increased.

Is that the right way around?
If cache coherency is guaranteed then I'd have thought that the dma sync
would be a nop.
...
> +			memcpy(skb_put(skb, rx_bytes),
> +			       data + MVNETA_MH_SIZE + NET_SKB_PAD,
> +			       rx_bytes);

You can probably arrange for the copy to be fully aligned since
the partial words at both ends can be safely read and written.
That might speed things up further.

	David
