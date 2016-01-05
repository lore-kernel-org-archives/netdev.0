From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Fix splice-bind deadlock
Date: Mon, 04 Jan 2016 23:23:28 -0500 (EST)
Message-ID: <20160104.232328.2119620215364418586.davem@davemloft.net>
References: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
	<87vb7ak08l.fsf@doppelsaurus.mobileactivedefense.com>
	<87d1ti1ogp.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk
To: rweikusat@mobileactivedefense.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbcAEEXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 23:23:30 -0500
In-Reply-To: <87d1ti1ogp.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Sun, 03 Jan 2016 18:56:38 +0000

> On 2015/11/06, Dmitry Vyukov reported a deadlock involving the splice
> system call and AF_UNIX sockets, 
> 
> http://lists.openwall.net/netdev/2015/11/06/24
> 
> The situation was analyzed as
> 
> (a while ago) A: socketpair()
> B: splice() from a pipe to /mnt/regular_file
> 	does sb_start_write() on /mnt
> C: try to freeze /mnt
> 	wait for B to finish with /mnt
> A: bind() try to bind our socket to /mnt/new_socket_name
> 	lock our socket, see it not bound yet
> 	decide that it needs to create something in /mnt
> 	try to do sb_start_write() on /mnt, block (it's
> 	waiting for C).
> D: splice() from the same pipe to our socket
> 	lock the pipe, see that socket is connected
> 	try to lock the socket, block waiting for A
> B:	get around to actually feeding a chunk from
> 	pipe to file, try to lock the pipe.  Deadlock.
> 
> on 2015/11/10 by Al Viro,
> 
> http://lists.openwall.net/netdev/2015/11/10/4
> 
> The patch fixes this by removing the kern_path_create related code from
> unix_mknod and executing it as part of unix_bind prior acquiring the
> readlock of the socket in question. This means that A (as used above)
> will sb_start_write on /mnt before it acquires the readlock, hence, it
> won't indirectly block B which first did a sb_start_write and then
> waited for a thread trying to acquire the readlock. Consequently, A
> being blocked by C waiting for B won't cause a deadlock anymore
> (effectively, both A and B acquire two locks in opposite order in the
> situation described above).
> 
> Dmitry Vyukov(<dvyukov@google.com>) tested the original patch.
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Applied and queued up for -stable, thanks Rainer.
