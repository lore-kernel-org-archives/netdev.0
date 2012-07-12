From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Thu, 12 Jul 2012 09:14:19 +0200
Message-ID: <1342077259.3265.8232.camel@edumazet-glaptop>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
	 <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36418 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049Ab2GLHOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 03:14:24 -0400
Received: by bkwj10 with SMTP id j10so1843292bkw.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 00:14:22 -0700 (PDT)
In-Reply-To: <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 17:26 -0700, Alexander Duyck wrote:
> This change adds capabilities to the driver for batching the MMIO write
> involved with transmits.  Most of the logic is based off of the code for
> the qdisc scheduling.
> 
> What I did is break the transmit path into two parts.  We already had the
> ndo_start_xmit function which has been there all along.  The part I added
> was ndo_complete_xmit which is meant to handle notifying the hardware that
> frames are ready for delivery.
> 
> To control all of this I added a net sysfs value for the Tx queues called
> dispatch_limit.  When 0 it indicates that all frames will notify hardware
> immediately.  When 1 or more the netdev_complete_xmit call will queue up to
> that number of packets, and when the value is exceeded it will notify the
> hardware and reset the pending frame dispatch count.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

The idea is good, but do we really need so complex schem ?

Most of the transmits are done from __qdisc_run()

We could add logic in __qdisc_run()/qdisc_restart()

qdisc_run_end() would then have to call ndo_complete_xmit() to make
sure the MMIO is done.
