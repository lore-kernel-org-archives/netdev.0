From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCHSET] more iov_iter conversion in net/*
Date: Mon, 2 Feb 2015 06:53:39 +0000
Message-ID: <20150202065339.GU29656@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <20150201.222646.1280320067605385223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:32827 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbBBGxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 01:53:41 -0500
Content-Disposition: inline
In-Reply-To: <20150201.222646.1280320067605385223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 01, 2015 at 10:26:46PM -0800, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Sat, 31 Jan 2015 03:55:13 +0000
> 
> > 	->sendmsg() side of that business, now.  By the end of it, we
> > get all ->sendmsg() instances leaving iovec unchanged and ->msg_iter -
> > drained.
>  ...
> > 	The pile after that one will be dealing with the kernel_sendmsg and
> > kernel_recvmg callers - at that point we can start reaping benefits of
> > consistent way ->msg_iter is handled.  Note that after these changes if
> > iov_iter_kvec() is used to initialize ->msg_iter, we don't need the games
> > with get_fs()/set_fs() anymore; just sock_sendmsg()/sock_recvmsg() will do,
> > so quite a few of those kernel_{send,recv}msg() callers will turn into
> > sock_{send,recv}msg() ones.
> 
> The content of this series looks fine, but I really would like you
> to put proper "subsystem: " prefixes into the commit log header
> lines of these commits.
> 
> Patch 2 and 3 should use "ipv6: ", patch #4 should use whatever the
> name of that device driver "vmw_vmci: " or similar, etc.

Point...  Are you OK with tcp_send_syn_data() change in 8/18?  Basically,
tcp_sendmsg() treats short copy from userland as "send as much as we can,
stop at the first point where copy_from_user() fails", same as write(),
etc.; that much is unchanged, but the current mainline has a strange behaviour
in case when short copy happens within what would be packed into SYN packet -
if that happens, it still sends as much as possible, but it falls back to
separate SYN.  With this patch it simply sends shorter SYN+data packet instead.
The reason I went that way is that I wanted to avoid copying the same data
from userland twice and it was easy to do; I can preserve the current mainline
behaviour, but it'll cost making a backup copy of ->msg_iter in
tcp_send_syn_data(), only to never use it in normal case *and* do piles
of extra work (extra packet to send, repeated copying from userland) in case
of short copy.  Is there any reason not to combine SYN+data in case of short
copy?  Again, we do send exact same data, return the same value, etc. - you
need tcpdump to see the difference.

Al, off to figure out the proper Cc: for all those commits, so that
git-send-email would DTRT - if I need to edit commit messages, might
as well do that at the same time...
