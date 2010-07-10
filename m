From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: why doesn't close() wake a blocked read() --- and what should
 i do  about it?
Date: Sat, 10 Jul 2010 01:18:37 +0100
Message-ID: <1278721117.2078.43.camel@achroite.uk.solarflarecom.com>
References: <AANLkTin4ugMqekRX389XxPx_R8Nu2cWYCLYtpU5rSrsU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: enh <enh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42900 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab0GJASk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 20:18:40 -0400
In-Reply-To: <AANLkTin4ugMqekRX389XxPx_R8Nu2cWYCLYtpU5rSrsU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-07-09 at 16:38 -0700, enh wrote:
> on Android (Linux 2.6.32), if one thread is in accept(2) and another
> thread calls close(2) on that socket, the first thread returns with an
> error.

This suffers from the same race condition you describe below: you don't
know whether the first thread is actually in accept() or is just about
to call it using the file descriptor you're invalidating.

> likewise if the first thread is in recv(2) waiting for a
> datagram packet. but if the first thread is just doing a regular
> read(2), it's not woken. (similarly for write(2).) this is unfortunate
> for me, because that's not how Java is supposed to work
> (http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=4344135); calling
> Socket.close from another thread is the way you're supposed to unblock
> such things. apps need this so they can free up threads. (and i'm
> trying to fix the VM so apps can do this.)
> 
> it's well documented on the web that this is how linux behaves, though
> i didn't find any explanation of why, or why there's the discrepancy
> between read(2) and other similar operations. or is this just a bug?

I don't see any good reason for this behaviour, but even if the
behaviour was as you want it would not make it safe to call close() on a
socket used by another thread.

> on the assumption that this is something i need to work around in
> userspace, what's my best choice? i can pthread_kill the stuck
> threads, but that means they need to be somewhat aware of this hack.
> 
> if they just TEMP_FAILURE_RETRY, there's a race condition if the fd
> has been reopened as something else between the close(2) and their
> retry. it also means i'm out of luck for code i don't control, such as
> openssl: that code is always going to be open to the race.

I don't see why you as the platform provider cannot modify your version
of OpenSSL.

> alternatively, i could have a pipe per thread, select(2) on both the
> pipe and the socket rather than read(2) directly, and then examine my
> fd_sets to see whether it's time to read or time to give up, but that
> seems unnecessarily resource-intensive, and also doesn't address the
> openssl case.
> 
> alternatively, there's shutdown(2), but i'm not sure that really does
> what i want either.

I think this may be the way to go.

> for one thing, it's not clear what the interaction
> between shutdown(2) and SO_LINGER is (i'm thinking of write(2) here).
> i also find my unblocked read(2) returns 0 rather than -1 and some
> recognizable value of errno -- which isn't unreasonable in general,
> just for this particular use  -- so i'd need to do some bookkeeping to
> check what that 0 really means.

You already need to mark the file descriptor in the Socket object as
invalid at the start of the close() method, to prevent any further calls
using it.  Other methods can then check whether the file descriptor is
still valid after the system call if they need to distinguish error
cases.

> any comments on these ideas, or other ideas i haven't thought of?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

