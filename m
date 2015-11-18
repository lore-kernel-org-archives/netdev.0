From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Tue, 17 Nov 2015 20:31:10 -0800
Message-ID: <CALx6S36r=sd9LtXH7jEn2yr=aM1_fJvaRWFO_PmX_Db-fy5fmQ@mail.gmail.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
	<CALx6S37kctONYwuud_0QPMf=8pa6g8bfpT9Vq8aR2FF_MO7oYw@mail.gmail.com>
	<CAKD1Yr1Z8BzW-M+agO-b4Lo8PE8OAR3yedtzvwgLoX2tOYHx3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34214 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbbKREbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 23:31:11 -0500
Received: by ioir85 with SMTP id r85so41829310ioi.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 20:31:10 -0800 (PST)
In-Reply-To: <CAKD1Yr1Z8BzW-M+agO-b4Lo8PE8OAR3yedtzvwgLoX2tOYHx3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 17, 2015 at 8:23 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> On Wed, Nov 18, 2015 at 12:56 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> The patch series only implements SOCK_DESTROY for TCP sockets,
>>> but the mechanism can be extended to any protocol family that
>>> supports the sock_diag interface.
>>>
>> I assume that SIOCKILLADDR was restricted to only closing connections
>> related to add addresses going away, but SOCK_DESTROY seems to allow
>> arbitrarily killing connections without publicized cause.
>
> Closing connections on deleted IP addresses is the main use of
> SIOCKILLADDR, but the ioctl also supports closing all connections on a
> userspace-provided IP address.
>
> However, those semantics are not enough in some cases. For example:
> when a VPN client connects, for security reasons (e.g., to make it
> harder for on-link attackers to attack cleartext apps), traffic from
> unprivileged applications is no longer permitted on non-VPN
> interfaces. All unprivileged traffic is routed over the VPN.
> Currently, existing TCP connections just hang, which typically annoys
> the user. It would be better if we had the ability to close those
> connections with SOCK_DESTROY.
>
> SIOCKILLADDR cannot do that because it is inappropriate to
> indiscriminately kill TCP connections that are not on the VPN - if
> nothing else, one of those TCP connections could be the one that is
> providing the VPN itself.
>
>> Minimally, the application should get at
>> least get a clear error that the local host administratively killed
>> the connection, ETIMEDOUT does not provide that.
>
> I don't know why ETIMEDOUT was chosen (we've been running this since
> 2008), but I think it's because:
>
> 1. All Internet applications have to be prepared to receive ETIMEDOUT
> on TCP sockets.
> 2. ETIMEDOUT is the error that those applications would have gotten
> anyway if they had waited a few minutes.
>
> It's certainly possible to use something other than ETIMEDOUT, though
> I don't know what error code would be appropriate. Perhaps we can make
> it configurable by the caller.

How about ENETRESET?

Also, it would be nice if the part about doing the close on the
protocol socket were abstracted out as protoop in itself, maybe
something like admin_close op. We'll have other use cases where the
stack wants to close a socket outside of user request or normal
protocol operations (KCM does this for instance).

Tom
