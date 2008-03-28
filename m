From: David Miller <davem@davemloft.net>
Subject: Re: Network/block layer race.
Date: Fri, 28 Mar 2008 13:40:53 -0700 (PDT)
Message-ID: <20080328.134053.122172549.davem@davemloft.net>
References: <20080328092036.GA11924@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: axboe@kernel.dk, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54491
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752533AbYC1Uk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 16:40:58 -0400
In-Reply-To: <20080328092036.GA11924@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Mar 2008 12:20:36 +0300

> There is a race between ->sendpage() and block layer, when the latter
> can override the page while it is queued in hardware, qdisk or tcp
> queue. Although page's reference counter is handled correctly, and page
> will not be freed until fully transferred, block layer can reuse it,
> since it assumes that after ->sendpage() returns, page is no longer
> used. It is invalid assumption, but there is no way currently to
> determine when page is no longer used by network except invoke a
> callback during skb freeing.

It is well known that between when a page is given to sendfile path
and it is actually transmitted to the network the kernel can write
into that page multiple times.

That's why we only allow sendfile over device paths that support
checksum offloading, since the page contents can change freely at any
moment in time.

The refrence counting is to prevent leaks, rather than to protect
the integrity of the contents.

If content protection is desired, higher level things are needed.
For example, SAMBA only uses sendfile() if the remote client
has an OP lock on the file in question.
