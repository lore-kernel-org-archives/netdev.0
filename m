From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] qlge: Move TX completion processing to
 send path.
Date: Thu, 20 Aug 2009 02:18:54 -0700 (PDT)
Message-ID: <20090820.021854.254431313.davem@davemloft.net>
References: <1250725991-7155-1-git-send-email-ron.mercer@qlogic.com>
	<1250725991-7155-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752799AbZHTJSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:18:42 -0400
In-Reply-To: <1250725991-7155-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 19 Aug 2009 16:53:09 -0700

> @@ -1205,6 +1205,7 @@ struct bq_desc {
>  };
>  
>  #define QL_TXQ_IDX(qdev, skb) (smp_processor_id()%(qdev->tx_ring_count))
> +#define TXQ_CLEAN_TIME (HZ/4)
>  
>  struct tx_ring {
>  	/*

Running this every 1/4 of a second, even when no TX activity is
happening, is very bad for power management.

And starting the timer in response to whether there are TX queue
entries active or not will add overhead and races.

This really isn't workable.

I really and truly believe that the best place for this is in NAPI
context.  So bring back the MSI-X vector for TX completions, and
make it schedule a NAPI poll.

