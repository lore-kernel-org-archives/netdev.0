From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2] sky2: Fix oops in sky2_xmit_frame() after TX timeout
Date: Mon, 4 Jan 2010 19:48:41 +0100
Message-ID: <20100104184841.GA3106@del.dom.local>
References: <4B3C8323.1080301@ring3k.org>
 <4B3CF2C4.5070203@gmail.com>
 <4B3D38FB.40105@ring3k.org>
 <20100101183155.GA8519@del.dom.local>
 <4B41560C.4040500@gmail.com>
 <20100104134904.GA18583@ff.dom.local>
 <20100104102637.16734638@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Berck E. Nash" <flyboy@gmail.com>,
	Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org,
	dhazelton@enter.net, mbreuer@majjas.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:48560 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab0ADSst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 13:48:49 -0500
Received: by fxm25 with SMTP id 25so9016155fxm.21
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2010 10:48:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100104102637.16734638@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2010 at 10:26:37AM -0800, Stephen Hemminger wrote:
> > -	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
> > +	/* Wake unless it's detached, and called e.g. from sky2_down() */
> > +	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 &&
> > +	    likely(netif_device_present(dev)))
> >  		netif_wake_queue(dev);
> >  }
> >
> 
> The likely() seems unnecessary noise here. It can't possibly matter that
> much.

OK. Thanks,
Jarek P.
------------> (take 2)

During TX timeout procedure dev could be awoken too early, e.g. by
sky2_complete_tx() called from sky2_down(). Then sky2_xmit_frame()
can run while buffers are freed causing an oops. This patch fixes it
by adding netif_device_present() test in sky2_tx_complete().

Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=14925

With debugging by: Mike McCormack <mikem@ring3k.org>

Reported-by: Berck E. Nash <flyboy@gmail.com>
Tested-by: Berck E. Nash <flyboy@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 drivers/net/sky2.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 1c01b96..7650f73 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1844,7 +1844,8 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 	sky2->tx_cons = idx;
 	smp_mb();
 
-	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
+	/* Wake unless it's detached, and called e.g. from sky2_down() */
+	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 && netif_device_present(dev))
 		netif_wake_queue(dev);
 }
 
