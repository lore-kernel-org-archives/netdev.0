From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tg3: 5701 DMA corruption fix
Date: Thu, 17 Apr 2008 23:26:12 -0700 (PDT)
Message-ID: <20080417.232612.04456205.davem@davemloft.net>
References: <20080416222741.GA20272@localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net,
	tonyb@cybernetics.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44224
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752363AbYDRG0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:26:10 -0400
In-Reply-To: <20080416222741.GA20272@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 16 Apr 2008 15:27:41 -0700

> +		while (pci_id->vendor != 0) {
> +			bridge = pci_get_device(pci_id->vendor,
> +						pci_id->device,
> +						bridge);
> +			if (!bridge) {
> +				pci_id++;
> +				continue;
> +			}
> +			if (bridge->subordinate &&
> +			    (bridge->subordinate->number <=
> +			     tp->pdev->bus->number) &&
> +			    (bridge->subordinate->subordinate >=
> +			     tp->pdev->bus->number)) {
> +				tp->tg3_flags3 |= TG3_FLG3_5701_DMA_BUG;
> +				pci_dev_put(bridge);
> +				break;
> +			}
> +		}
> +	}

This code block will leak bridge device objects when the table
comparison check fails.

Probably the best thing to do is seperate the boolean check
from the other operations:

	bool match = false;
 ...
	if (bridge->subordinate &&
	    (bridge->subordinate->number <=
	     tp->pdev->bus->number) &&
	    (bridge->subordinate->subordinate >=
	     tp->pdev->bus->number))
		match = true;

	pci_dev_put_bridge(bridge);

	if (match) {
		tp->tg3_flags |= TG3_FLG3_5701_DMA_BUG;
		pci_dev_put(bridge);
	}

Please fix this up, and combine the version bump into this patch.

Thank you!
