From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Wed, 17 Aug 2016 00:21:40 +0900
Message-ID: <CAKD1Yr3J8NMZkVXdUGZNeA=nRdWWKcq+0JRM57B_Q7WsCkTgGw@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <20160808.143500.473355495580691289.davem@davemloft.net> <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
 <20160808.222030.1314134961786852070.davem@davemloft.net> <CAAedzxq-XYTVgZ7=VX-OWHYNSRjDuf==si-my=Jy3YEo7atcWQ@mail.gmail.com>
 <04a393c9-39f8-8d73-3476-928732e5b193@cumulusnetworks.com>
 <ed271d49-e796-ebaa-2e71-35711710fd49@miraclelinux.com> <CAKD1Yr3LNv+hDm0HfxYiGvotiTYab9W-+5R0OUjinF-tdwKy1g@mail.gmail.com>
 <642d0eef-4f62-f63c-9db5-3d890bb942df@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>, Erik Kline <ek@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34332 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbcHPPWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:22:07 -0400
Received: by mail-io0-f181.google.com with SMTP id q83so110349359iod.1
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 08:22:02 -0700 (PDT)
In-Reply-To: <642d0eef-4f62-f63c-9db5-3d890bb942df@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 4:39 PM, YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com> wrote:
>
> > and then in the various sendmsg functions:
> >
> >         if (!inet_check_bound_oif(sk, oif))
> >                 return -EINVAL;
> >
>
> Yes, something like that.

There's another complication. inet6_bind and raw_bind take
sin6_scope_id and assign it to sk_bound_dev_if:

        if (addr_len >= sizeof(struct sockaddr_in6) &&
            addr->sin6_scope_id) {
                if (addr->sin6_scope_id != sk
                        /* Override any existing binding, if another
                         * one is supplied by user.
                         */
                         sk->sk_bound_dev_if = addr->sin6_scope_id;
                }

The reason they do this is that the only place in the socket to
score the scope ID is sk_bound_dev_if. The scope ID has to be stored
in the socket, because it's the only way to ensure the semantics of
scoped addresses, where the address without the scope ID is not
unique, and thus the scope ID is effectively part of the address. For
example:

1.  A socket bound to fe80::1%eth0 and a socket bound to fe80::1%wlan0
    must never see each other's packets. This means that things like
    udp6_lib_lookup must take the scope ID into account.
2. Calling getpeername() on a socket that's bound to fe80::1%eth0 must
    return eth0's ifindex in sin6_scope_id.

Unless we add a scope ID field to the socket, changing this behaviour
would cause substantial breakage. It's perfectly legal to bind a
socket to fe80::1%eth0 and then fe80::2%wlan0, for example. So we
can't just say that sk_bound_dev_if must always take precedence on
sin6_scope_id.

I also don't see how the VRF behaviour where sk_bound_dev_if sets the
master interface and pktinto selects the slave interface" can be made
to work at all in the presence of scoped addresses. I don't see any
way to support a socket bound to fe80::1%eth0 and a socket bound to
fe80::1%wlan0 in the same VRF.
