From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Sun, 21 Sep 2008 01:04:58 -0700 (PDT)
Message-ID: <20080921.010458.216237442.davem@davemloft.net>
References: <1221387956.9204.7.camel@fry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johaahn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbYIUIFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 04:05:11 -0400
In-Reply-To: <1221387956.9204.7.camel@fry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Baudy <johaahn@gmail.com>
Date: Sun, 14 Sep 2008 12:25:56 +0200

> Sendfile() over UDP socket are currently limited to ~ 64KBytes file
> (max cork.length).  Indeed, if you run sendfile() with a file size >
> 64KBytes over UDP socket, system call will stop and return ~64KBytes
> without sending anything on the network.  This patch is pushing
> ongoing frames when frames buffer is full, to prevent overflow.
>
> Signed-off-by: Johann Baudy <johann.baudy@gmail.com>

Applications which work over datagram protocols must perform their own
segmentation.  It is not like doing a send over a stream protocol like
TCP, where you can use whatever length you want for send calls and
segmentation is done for the application.

If you look, this is what things like NFS using SUNRPC over UDP do.
They have a transmission unit for the data transfer and use that for
each "send".

A sendfile() with length >= 64K is the same as a sendmsg() with such a
length, which is defined as:

	if (len > 0xFFFF)
		return -EMSGSIZE;

So we could technically even return an error for this sendfile() over
UDP case.
