From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: inet_diag: zero out uninitialized
 idiag_{src,dst} fields
Date: Thu, 19 Dec 2013 14:56:22 -0500 (EST)
Message-ID: <20131219.145622.2200263458055643644.davem@davemloft.net>
References: <1387237119-10780-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: darkjames-ws@darkjames.pl, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab3LST4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:56:24 -0500
In-Reply-To: <1387237119-10780-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 17 Dec 2013 00:38:39 +0100

> Jakub reported while working with nlmon netlink sniffer that parts of
> the inet_diag_sockid are not initialized when r->idiag_family != AF_INET6.
> That is, fields of r->id.idiag_src[1 ... 3], r->id.idiag_dst[1 ... 3].
> 
> In fact, it seems that we can leak 6 * sizeof(u32) byte of kernel [slab]
> memory through this. At least, in udp_dump_one(), we allocate a skb in ...
> 
>   rep = nlmsg_new(sizeof(struct inet_diag_msg) + ..., GFP_KERNEL);
> 
> ... and then pass that to inet_sk_diag_fill() that puts the whole struct
> inet_diag_msg into the skb, where we only fill out r->id.idiag_src[0],
> r->id.idiag_dst[0] and leave the rest untouched:
> 
>   r->id.idiag_src[0] = inet->inet_rcv_saddr;
>   r->id.idiag_dst[0] = inet->inet_daddr;
> 
> struct inet_diag_msg embeds struct inet_diag_sockid that is correctly /
> fully filled out in IPv6 case, but for IPv4 not.
> 
> So just zero them out by using plain memset (for this little amount of
> bytes it's probably not worth the extra check for idiag_family == AF_INET).
> 
> Similarly, fix also other places where we fill that out.
> 
> Reported-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks.
