From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCHSET] more iov_iter conversion in net/*
Date: Sun, 01 Feb 2015 23:05:43 -0800 (PST)
Message-ID: <20150201.230543.805545555059024836.davem@davemloft.net>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
	<20150201.222646.1280320067605385223.davem@davemloft.net>
	<20150202065339.GU29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbbBBHFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 02:05:47 -0500
In-Reply-To: <20150202065339.GU29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 2 Feb 2015 06:53:39 +0000

> Point...  Are you OK with tcp_send_syn_data() change in 8/18?  Basically,
> tcp_sendmsg() treats short copy from userland as "send as much as we can,
> stop at the first point where copy_from_user() fails", same as write(),
> etc.; that much is unchanged, but the current mainline has a strange behaviour
> in case when short copy happens within what would be packed into SYN packet -
> if that happens, it still sends as much as possible, but it falls back to
> separate SYN.  With this patch it simply sends shorter SYN+data packet instead.
> The reason I went that way is that I wanted to avoid copying the same data
> from userland twice and it was easy to do; I can preserve the current mainline
> behaviour, but it'll cost making a backup copy of ->msg_iter in
> tcp_send_syn_data(), only to never use it in normal case *and* do piles
> of extra work (extra packet to send, repeated copying from userland) in case
> of short copy.  Is there any reason not to combine SYN+data in case of short
> copy?  Again, we do send exact same data, return the same value, etc. - you
> need tcpdump to see the difference.

I think dropping down to plain SYN in the short copy case was just based
upon a blanket decision to not do SYN+DATA if anything out of the
ordinary happens, rathe than an explicit policy decision.  So that change
should be OK.
