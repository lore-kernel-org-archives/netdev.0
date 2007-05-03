From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Rework dev_base via list_head
Date: Thu, 03 May 2007 03:25:40 -0700 (PDT)
Message-ID: <20070503.032540.101470158.davem@davemloft.net>
References: <463894E8.6090204@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@sw.ru
To: xemul@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161429AbXECKZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:25:40 -0400
In-Reply-To: <463894E8.6090204@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@sw.ru>
Date: Wed, 02 May 2007 17:40:56 +0400

> Cleanup of dev_base list use, with the aim to simplify making
> device list per-namespace. In almost every occasion, use of
> dev_base variable and dev->next pointer could be easily replaced
> by  for_each_netdev loop. A few most complicated places were
> converted to using first_netdev()/next_netdev().
> 
> Fits 2.6.21-rc7 tree.
> 
> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> Acked-by: Kirill Korotaev <dev@openvz.org>

Overall this looks mostly good.

One thing I want to audit before applying this is
loop termination conditions.

With the old loop, if you do something like this:

	for (dev = dev_base; dev; dev = dev->next) {
		if (dev == what_I_want)
			break;
	}

you can test for a successful find after the loop with:

	if (dev) {
		I_found_it();
	}

That doesn't work with for_each_netdev(), if the loop
runs till the end of the list, the iterator will not
be left at NULL.

I just want to make sure you didn't leave any code around which wants
that behavior still.

This is one of the subtle things about using the list iterators in
linux/list.h, vs. a traditional by-hand singly linked list
implementation.
