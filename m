From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] sunvnet: Re-check for a VIO_DESC_READY
 data descriptor after short udelay()
Date: Mon, 01 Sep 2014 20:47:15 -0700 (PDT)
Message-ID: <20140901.204715.2121922580015092507.davem@davemloft.net>
References: <20140829201809.GH14753@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbaIBDrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 23:47:17 -0400
In-Reply-To: <20140829201809.GH14753@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 29 Aug 2014 16:18:09 -0400

> @@ -398,6 +398,20 @@ again:
>  		err = vnet_walk_rx_one(port, dr, start, &ack);
>  		if (err == -ECONNRESET)
>  			return err;
> +		if (err != 0)  {
> +			/* The descriptor was not READY. Retry with a
> +			 * small delay, in case we have a bursty sender
> +			 * that is actively populating the descriptors, to
> +			 * reduce the overhead of stopping and re-entering
> +			 * which would involve expensive LDC messages.
> +			 */
> +			if (retries++ < 3) {
> +				udelay(4);
> +				goto again;
> +			} else {
> +				break;
> +			}
> +		}

I'm definitely not happy with this.

If there were no more packets coming, this is wasted useless polling
time in atomic context.

Everything should be event based, and we should not be compensating
and making sacrifices for a producer slower than we are as a consumer.
