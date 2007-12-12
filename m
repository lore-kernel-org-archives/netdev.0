From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC] net: napi fix
Date: Wed, 12 Dec 2007 12:29:23 -0500
Message-ID: <47601A73.5010804@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1908 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750913AbXLLRar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 12:30:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[I apologize for loosing threading, I'm replying from the archives]

 > The problem is that the driver is doing a NAPI completion and
 > re-enabling chip interrupts with work_done == weight, and that is
 > illegal.

The only time at least myri10ge will do this is due to
the !netif_running(netdev) check.   Eg, from myri10ge's poll:

	work_done = myri10ge_clean_rx_done(mgp, budget);

	if (work_done < budget || !netif_running(netdev)) {
		netif_rx_complete(netdev, napi);
		put_be32(htonl(3), mgp->irq_claim);
	}

Is the netif_running() check even required? Is this just
a bad way to solve a race with running NAPI at down() time
that would be better solved by putting a napi_synchronize()
in the driver's down() routine?

I'd rather fix this right than add another check to a
questionable code path.

Thanks,

Drew
