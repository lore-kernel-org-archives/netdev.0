From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sh_eth: NAPI requires netif_receive_skb()
Date: Thu, 26 Sep 2013 09:59:19 -0700
Message-ID: <1380214759.3165.201.camel@edumazet-glaptop>
References: <201309030303.11381.sergei.shtylyov@cogentembedded.com>
	 <20130904.141252.532474080722830977.davem@davemloft.net>
	 <Pine.LNX.4.64.1309261751200.11968@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1309261751200.11968@axis700.grange>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-26 at 18:12 +0200, Guennadi Liakhovetski wrote:
> Hi
> 
> On Wed, 4 Sep 2013, David Miller wrote:
> 
> > From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> > Date: Tue, 3 Sep 2013 03:03:10 +0400
> > 
> > > Driver supporting NAPI should use NAPI-specific function for receiving packets,
> > > so netif_rx() should be changed to netif_receive_skb().
> > > 
> > > Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> This patch breaks NFS boot on Armadillo800eva for me. Network 
> communication slows down to a crawl with
> 
> net eth0: Receive FIFO Overflow
> nfs: server 192.168.x.y not responding, still trying
> 
> With this patch reverted (e.g. in today's Linus tree snapshot) boot is 
> restored.

RX_RING_SIZE is 64

This driver refills the Rx ring buffers only _after_ the loop to drain
ready buffers. This was OK with the previous behavior (netif_rx() is
damn fast)

With this low amount of buffers, underrun can happen with the new code,
as netif_receive_skb() adds delay during the drain.

Most likely driver needs to refill buffers one by one (or small batches)
instead of in one go after the drain.





