From: enh <enh@google.com>
Subject: why doesn't close() wake a blocked read() --- and what should i do
	about it?
Date: Fri, 9 Jul 2010 16:38:43 -0700
Message-ID: <AANLkTin4ugMqekRX389XxPx_R8Nu2cWYCLYtpU5rSrsU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:56445 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527Ab0GIXir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 19:38:47 -0400
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o69NcjRS029011
	for <netdev@vger.kernel.org>; Fri, 9 Jul 2010 16:38:45 -0700
Received: from gwb17 (gwb17.prod.google.com [10.200.2.17])
	by wpaz5.hot.corp.google.com with ESMTP id o69Nch3k009340
	for <netdev@vger.kernel.org>; Fri, 9 Jul 2010 16:38:44 -0700
Received: by gwb17 with SMTP id 17so99366gwb.39
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 16:38:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

on Android (Linux 2.6.32), if one thread is in accept(2) and another
thread calls close(2) on that socket, the first thread returns with an
error. likewise if the first thread is in recv(2) waiting for a
datagram packet. but if the first thread is just doing a regular
read(2), it's not woken. (similarly for write(2).) this is unfortunate
for me, because that's not how Java is supposed to work
(http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=4344135); calling
Socket.close from another thread is the way you're supposed to unblock
such things. apps need this so they can free up threads. (and i'm
trying to fix the VM so apps can do this.)

it's well documented on the web that this is how linux behaves, though
i didn't find any explanation of why, or why there's the discrepancy
between read(2) and other similar operations. or is this just a bug?

on the assumption that this is something i need to work around in
userspace, what's my best choice? i can pthread_kill the stuck
threads, but that means they need to be somewhat aware of this hack.
if they just TEMP_FAILURE_RETRY, there's a race condition if the fd
has been reopened as something else between the close(2) and their
retry. it also means i'm out of luck for code i don't control, such as
openssl: that code is always going to be open to the race.

alternatively, i could have a pipe per thread, select(2) on both the
pipe and the socket rather than read(2) directly, and then examine my
fd_sets to see whether it's time to read or time to give up, but that
seems unnecessarily resource-intensive, and also doesn't address the
openssl case.

alternatively, there's shutdown(2), but i'm not sure that really does
what i want either. for one thing, it's not clear what the interaction
between shutdown(2) and SO_LINGER is (i'm thinking of write(2) here).
i also find my unblocked read(2) returns 0 rather than -1 and some
recognizable value of errno -- which isn't unreasonable in general,
just for this particular use  -- so i'd need to do some bookkeeping to
check what that 0 really means.

any comments on these ideas, or other ideas i haven't thought of?

thanks,
 --elliott
