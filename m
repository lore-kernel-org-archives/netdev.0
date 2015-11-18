From: Lorenzo Colitti <lorenzo@google.com>
Subject: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 10:43:40 +0900
Message-ID: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35106 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbbKRBnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 20:43:53 -0500
Received: by pacej9 with SMTP id ej9so26791265pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 17:43:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the ability for a privileged process to
destroy sockets belonging to other userspace processes via the
sock_diag interface, and implements that for TCP sockets.

This functionality is needed on laptops and mobile hosts to
ensure that network switches / disconnects do not result in
applications being blocked for long periods of time (minutes) in
read or connect calls on TCP sockets that will never succeed
because the IP address they are bound to is gone. Closing the
sockets in the protocol layer causes these calls to fail fast and
allows applications to reconnect on another network.

For many years Android kernels have done this via an out-of-tree
SIOCKILLADDR ioctl that is called when networks disconnect, but
this solution is cleaner, more robust and more flexible. The
system can iterate over all connections on the deleted IP address
and close all of them. But it can also close all sockets opened
by a given process on a given network, for example if the user
has restricted that process from using that network, or if a
secure network such as a VPN is now being applied to the
application and thus previously-established connections are
blackholed.

The patch series only implements SOCK_DESTROY for TCP sockets,
but the mechanism can be extended to any protocol family that
supports the sock_diag interface.
