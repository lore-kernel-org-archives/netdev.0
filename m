From: Shaw Vrana <shawvrana@gmail.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Thu, 20 Apr 2006 19:42:06 -0700
Message-ID: <200604201942.07009.shawvrana@acm.org>
References: <200604201035.00100.shaw@vranix.com> <20060421013340.GA29123@gondor.apana.org.au> <1145578214.3195.6.camel@rh4>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_/ZESEQAxXh4ox2d"
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, shawvrana@gmail.com,
	netdev@vger.kernel.org, "Auke Kok" <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.204]:16621 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750876AbWDUCmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 22:42:16 -0400
Received: by nz-out-0102.google.com with SMTP id n1so355897nzf
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 19:42:16 -0700 (PDT)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1145578214.3195.6.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_/ZESEQAxXh4ox2d
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 20 April 2006 17:10, Michael Chan wrote:
> In tg3_remove_one(), we call flush_scheduled_work() in case the
> reset_task is still pending. Here, it is safe to call
> flush_scheduled_work() because we're not holding the rtnl. Again, when
> it runs, nothing bad will happen because it will see netif_running() ==
> 0.

I'll bite!  Here's a patch to add a call to flush_scheduled_work() in 
e1000_down.  It's against 2.6.16.9.

Shaw

--Boundary-00=_/ZESEQAxXh4ox2d
Content-Type: text/x-diff;
  charset="iso-8859-6";
  name="e1000_flush_in_close.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="e1000_flush_in_close.patch"

diff -u -uprN -X linux-2.6.16.9/Documentation/dontdiff linux-2.6.16.9/drivers/net/e1000/e1000_main.c linux-2.6.16.9-patch/drivers/net/e1000/e1000_main.c
--- linux-2.6.16.9/drivers/net/e1000/e1000_main.c	2006-04-18 23:10:14.000000000 -0700
+++ linux-2.6.16.9-patch/drivers/net/e1000/e1000_main.c	2006-04-20 19:36:55.000000000 -0700
@@ -538,6 +538,7 @@ e1000_down(struct e1000_adapter *adapter
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
+	flush_scheduled_work();	
 
 #ifdef CONFIG_E1000_NAPI
 	netif_poll_disable(netdev);

--Boundary-00=_/ZESEQAxXh4ox2d--
