From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: Don't reorder loads/stores before marking
 mmap netlink frame as available
Date: Thu, 18 Dec 2014 12:36:57 -0500 (EST)
Message-ID: <20141218.123657.406400603290543610.davem@davemloft.net>
References: <20141216.175817.576861457076632402.davem@davemloft.net>
	<1418774579.9773.69.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141218103026.GA16239@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, dborkman@redhat.com, luto@amacapital.net,
	torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaLRRg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:36:59 -0500
In-Reply-To: <20141218103026.GA16239@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 18 Dec 2014 10:30:26 +0000

> Each mmap Netlink frame contains a status field which indicates
> whether the frame is unused, reserved, contains data or needs to
> be skipped. Both loads and stores may not be reordeded and must
> complete before the status field is changed and another CPU might
> pick up the frame for use. Use an smp_mb() to cover needs of both
> types of callers to netlink_set_status(), callers which have been
> reading data frame from the frame, and callers which have been
> filling or releasing and thus writing to the frame.
> 
> - Example code path requiring a smp_rmb():
>   memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, hdr->nm_len);
>   netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
> 
> - Example code path requiring a smp_wmb():
>   hdr->nm_uid	= from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
>   hdr->nm_gid	= from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);
>   netlink_frame_flush_dcache(hdr);
>   netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
> 
> Fixes: f9c228 ("netlink: implement memory mapped recvmsg()")
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Also applied and queued up for -stable, thanks Thomas.
