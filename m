From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Tue, 17 Nov 2015 19:56:08 -0800
Message-ID: <CALx6S37kctONYwuud_0QPMf=8pa6g8bfpT9Vq8aR2FF_MO7oYw@mail.gmail.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	maze@google.com, dtor@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34463 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376AbbKRD4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 22:56:10 -0500
Received: by ioir85 with SMTP id r85so41230097ioi.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 19:56:09 -0800 (PST)
In-Reply-To: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 17, 2015 at 5:43 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> This patch series adds the ability for a privileged process to
> destroy sockets belonging to other userspace processes via the
> sock_diag interface, and implements that for TCP sockets.
>
> This functionality is needed on laptops and mobile hosts to
> ensure that network switches / disconnects do not result in
> applications being blocked for long periods of time (minutes) in
> read or connect calls on TCP sockets that will never succeed
> because the IP address they are bound to is gone. Closing the
> sockets in the protocol layer causes these calls to fail fast and
> allows applications to reconnect on another network.
>
> For many years Android kernels have done this via an out-of-tree
> SIOCKILLADDR ioctl that is called when networks disconnect, but
> this solution is cleaner, more robust and more flexible. The
> system can iterate over all connections on the deleted IP address
> and close all of them. But it can also close all sockets opened
> by a given process on a given network, for example if the user
> has restricted that process from using that network, or if a
> secure network such as a VPN is now being applied to the
> application and thus previously-established connections are
> blackholed.
>
> The patch series only implements SOCK_DESTROY for TCP sockets,
> but the mechanism can be extended to any protocol family that
> supports the sock_diag interface.
>
I assume that SIOCKILLADDR was restricted to only closing connections
related to add addresses going away, but SOCK_DESTROY seems to allow
arbitrarily killing connections without publicized cause. This
interface, even though it is for a privileged user, should be no more
powerful than it needs to be. Minimally, the application should get at
least get a clear error that the local host administratively killed
the connection, ETIMEDOUT does not provide that.

Tom

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
