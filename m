From: David Miller <davem@davemloft.net>
Subject: the mystery that is sock_fasync
Date: Fri, 11 Aug 2006 03:15:16 -0700 (PDT)
Message-ID: <20060811.031516.38316536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50399
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751098AbWHKKPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 06:15:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8816CAE43C4
	for <netdev@vger.kernel.org>; Fri, 11 Aug 2006 03:15:16 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I was studying sock_fasync() and it definitely has a bunch
of questionable issues.

Well firstly, it duplicates fasync_helper() entirely.
The only difference is that sock_fasync() does socket
local locking which is better for performance.  fasync_helper()
uses a global spinlock to protect the fasync list it is given.

Secondly, and I think more importantly, this thing acts as
if it is possible to have more than one file --> socket
mapping.  That is simply impossible.

There can indeed be many file descriptors that point to the
file object that points to the socket inode, but that's
different.

This invariant is maintained by the fact that socket
creations creates and maps one file object to point
to the socket's inode in sock_create.

Furthermore we block any attempt to open sockets by name
via things like /proc/$PID/fds/$sock_fdnum

In fact when sock_close() runs, it calls sock_fasync(-1, file, 0) and
the subsequent sock_release() bug checks that fasync_list is NULL.

If my analysis is correct we can incredibly simplify sock_fasync().

Did I miss some way that multiple file objects can point to the
same socket inode?

