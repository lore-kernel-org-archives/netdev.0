From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Tue, 29 Apr 2014 04:01:05 +0900
Message-ID: <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
 <535BB149.3090901@davidnewall.com> <CAKD1Yr0J3JXu9__LH6uKGsPYq+0jxiP1qhS2NTwT9gHitZ16_Q@mail.gmail.com>
 <20140428.125807.409036177577836732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davidn@davidnewall.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	JP Abgrall <jpa@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34316 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaD1TI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:08:56 -0400
Received: by mail-ig0-f182.google.com with SMTP id uy17so5196461igb.3
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 12:08:55 -0700 (PDT)
In-Reply-To: <20140428.125807.409036177577836732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 1:58 AM, David Miller <davem@davemloft.net> wrote:
> There is absolutely no such thing as the UID of a socket.

Sorry - perhaps I should have said "socket creator" or "socket owner".
Basically, what this patch calls "UID" is what the xt_owner module and
xt_LOG iptables modules consider to be the "owner" of a socket, what
nfqueue presents as the user ID, what shows up in
/proc/net/{udp,tcp,raw} in the "uid" column, etc. In most cases this
is the effective UID that made the call to socket() or accept().

This patch allows using that concept in routing. This can be done
today with "iptables -m owner --uid-owner 12345 -j MARK --set-mark
0xbeef; ip rule from fwmark 0xbeef lookup 100", but that has the
limitations I set out in my original message (e.g., incorrect source
address).

> And in software interrupt context, sending TCP ACKs for example, at
> best you have just the socket.  There is no appropriate UID to choose
> in such situations.

For as long as a kernel socket has a corresponding userspace socket,
the kernel socket has a pointer to the userspace socket object
(sk->sk_socket), which has the owner UID, right? So that information
is still accessible even outside process context. It's true that when
the userspace socket is closed that information goes away, but in
theory, it could be written back to the kernel socket in sock_orphan.

> I absolutely do not want to see a feature like this added to the tree,
> as it exemplifies a rather deep misunderstanding of how the hierarchy
> of networking stack objects are arranged and relate to eachother.

The examples I cite above are all in the tree. Do you consider them to
be misguided? In particular, the semantics of the iptables owner match
module seem quite similar to me - it allows making decisions
(including routing decisions) on a packet based on the socket owner.
