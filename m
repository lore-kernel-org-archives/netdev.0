From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 15:29:00 -0700 (PDT)
Message-ID: <20080512.152900.220913361.davem@davemloft.net>
References: <20080507.184311.196815718.davem@davemloft.net>
	<d1c2719f0805072033u38dfffaes71aed3efbc8035c0@mail.gmail.com>
	<d1c2719f0805121522g4767f585h4b33790318f44264@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754703AbYELW3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 18:29:05 -0400
In-Reply-To: <d1c2719f0805121522g4767f585h4b33790318f44264@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Mon, 12 May 2008 15:22:55 -0700

> I did a quick prototype based on your idea of adding an "in_flight"
> field to skb_shared_info to track how many in-flight clones in the
> host. I tested
> it quickly and it doesn't work. After some thought it was obvious why it
> won't work. It's because what the TCP stack needs is to track how
> many in-flight pkts are in the host, but your proposed patch increments
> "in_flight" once on the 1st __skb_clone() to be sent to the driver, but
> decrements "in_flight" TWICE, one for each of the clones to be freed.
> I did a quick hack to make it work for my limited test case but I haven't
> figured out an acceptable (non-hack) solution.

That's easy to fix, only set the in_flight pointer in the child clone
skb.  Thanks for figuring that out.

> Continued testing, I discovered the problem I described below where
> "in_flight" may point to a tp that has already been freed can not be
> addressed by zapping skb_shinfo(skb)->in_flight in sock_wfree(). The
> reason is that pkts may be acked and freed by TCP before driver freeing
> up its clone copy (e.g., due to driver lazy reclaim...) When that happens
> the "host_inflight" accounting will get messed up.

Simply notice, when we're about to decrement in_flight, that the data
reference is one.  You can take appropriate actions if so.
