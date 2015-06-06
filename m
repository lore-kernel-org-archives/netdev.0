From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next] inet: add IP_BIND_ADDRESS_NO_PORT to overcome
 bind(0) limitations
Date: Sat, 6 Jun 2015 18:38:24 +0200
Message-ID: <CAHo-OowXiXLEc-7TJKUfK2gZespVPN1S8ZN+h4JBHL_8wRw-4g@mail.gmail.com>
References: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35055 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728AbbFFQiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 12:38:25 -0400
Received: by labko7 with SMTP id ko7so71934233lab.2
        for <netdev@vger.kernel.org>; Sat, 06 Jun 2015 09:38:24 -0700 (PDT)
In-Reply-To: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm, I certainly like this.

So IMHO this is indeed much better than a sysctl to select a magic
port to ignore during a bind call (previous internal patchset),
although it does use up one more bit per socket (and one more syscall
per connect).

---

Thinking about this some more, I think it might be possible to make
this behaviour automatic in certain cases.

The new socket bit has 2 different meanings, depending on whether a
port is already allocated or not.
  if a port is not yet allocated, it governs whether bind(port=0) will
allocate a port.
  if a port is already allocated, it flags whether it was autoallocated
(obviously could also just use 2 bits instead of 1)

bind(with port=0)
  if the flag is set, doesn't select a port [ie. this patch]
  if the flag wasn't set, selects a port, sets the flag

getsockname()
  if a port has been selected and the flag is set, clears the flag
  [we've now revealed the port to userspace so can no longer change it]

connect()
  if a port has already been selected and the flag is (still) set,
release the port
  [side note: in order to prevent spurious failures it's possible you
would have to release the port after allocating the new 4-tuple, so
that if that fails, you can still use the pre-allocated port]

[perhaps after successful connect() or listen() the flag should always
be clear(ed)]

End result:
  bind(port=0) connect() without an interleaved getsockname() gets
this ephemeral-port-saving behaviour without userspace changes.

Obviously this is a fair bit of jumping through hoops - but it does
have the benefit of improving ephemeral port use even for unmodified
applications.

---

Less well thought out musings, maybe untenable:

Or perhaps the already existing SOCK_BINDPORT_LOCK could be abused somehow...
The setsockopt could set (and clear) that flag instead of the new bit?
Obviously the setsockopt would only allow changing the flag if port is
still unallocated.
And in bind() that flag being set would prevent automatic allocation
of a port if port=0 was asked for?

Not sure if saving a bit in the socket is worth these additional extra hoops.
