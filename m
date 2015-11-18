From: Erik Kline <ek@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 12:36:33 +0900
Message-ID: <CAAedzxoc0+e2CEXux2vFwR0aVdLMvrUfuh0nwCWj_SWUc+T=zw@mail.gmail.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
 <20151117192738.365145d7@samsung9> <CAAedzxqiXnKzCyevNipNnXEc_+TEjnVphLfseTo4ykZ8SAVt_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	dtor@google.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:32960 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbbKRDgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 22:36:54 -0500
Received: by wmec201 with SMTP id c201so258449396wme.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 19:36:53 -0800 (PST)
In-Reply-To: <CAAedzxqiXnKzCyevNipNnXEc_+TEjnVphLfseTo4ykZ8SAVt_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 November 2015 at 12:34, Erik Kline <ek@google.com> wrote:
>
>
> On 18 November 2015 at 12:27, Stephen Hemminger <stephen@networkplumber.org>
> wrote:
>>
>> On Wed, 18 Nov 2015 10:43:40 +0900
>> Lorenzo Colitti <lorenzo@google.com> wrote:
>>
>> > This patch series adds the ability for a privileged process to
>> > destroy sockets belonging to other userspace processes via the
>> > sock_diag interface, and implements that for TCP sockets.
>> >
>> > This functionality is needed on laptops and mobile hosts to
>> > ensure that network switches / disconnects do not result in
>> > applications being blocked for long periods of time (minutes) in
>> > read or connect calls on TCP sockets that will never succeed
>> > because the IP address they are bound to is gone. Closing the
>> > sockets in the protocol layer causes these calls to fail fast and
>> > allows applications to reconnect on another network.
>> >
>> > For many years Android kernels have done this via an out-of-tree
>> > SIOCKILLADDR ioctl that is called when networks disconnect, but
>> > this solution is cleaner, more robust and more flexible. The
>> > system can iterate over all connections on the deleted IP address
>> > and close all of them. But it can also close all sockets opened
>> > by a given process on a given network, for example if the user
>> > has restricted that process from using that network, or if a
>> > secure network such as a VPN is now being applied to the
>> > application and thus previously-established connections are
>> > blackholed.
>> >
>> > The patch series only implements SOCK_DESTROY for TCP sockets,
>> > but the mechanism can be extended to any protocol family that
>> > supports the sock_diag interface.
>> >
>>
>> I understand why you might want this, but it smells like the same
>> kind of problems that the "forced unmount" patch had which eventually
>> led to it not being accepted in mainline.  Lots of corner
>> cases and race conditions waiting to blow up.
>>
>> Look at the issues that the multi-thread socket close has.
>> This looks worse.
>
>
> I'm unsure of the specific issue to which you refer with "multi-thread
> socket close".  This is basically just a user-space forced tcp_close(),
> leaving the file descriptor still valid in the user context for the
> application to manage (alternatively: it aims to be the same as if a
> correctly crafted TCP RST had arrived).
