From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: SO_MARK and IPv6 and ip rule fwmark: broken
Date: Sat, 26 Sep 2009 04:03:41 -0700
Message-ID: <55a4f86e0909260403k1da86294tca3f60534da24db7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:45237 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbZIZLDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 07:03:39 -0400
Received: by fxm18 with SMTP id 18so2735207fxm.17
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2009 04:03:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AFAICT the following can happen:

* userspace creates an IPv6 socket
* userspace calls setsockopt SO_MARK with a non-zero value
[sk->sk_mark = something] (requires CAP_NET_ADMIN)
* userspace attempts to connect or send a datagram in some other way
* flow struct gets initialized
* fl.mark isn't initialized and defaults to memset'ed 0 <-- *bug*
* routing decision (and potentially src ip selection, etc) gets made
based on flow with missing mark
* skb->mark = sk->sk_mark [which is non-zero] <-- *kind of correct*
* if ip6tables mangle is enabled:
  - temp_mark = skb->mark  <-- *correct, although leads to weird behaviour*
  - rules get called, potentially matching and/or modifying the mark
(ip6tables -m mark, -j MARK)
  - once all rules in the mangle table complete, we do:
  - if (skb->mark != temp_mark) || (other special mangles happened)
re-examine [redo] previous routing decision.

This means, that:
   ip rule (add) fwmark [non-zero] ...
will not work for a fwmark set with SO_MARK, unless you somehow cause
the mangle table to trigger the re-examination of the routing
decision.

For example (tested for v6 TCP, cursory code examination leads me to
believe this is broken for UDP/DCCP/SCTP/etc over v6 as well) while:
   ip rule add fwmark 1234 lookup 200
combined with a
   setsockopt(SO_MARK, 1234)
is ignored,

changing the setsockopt to
   setsockopt(SO_MARK, 12345)
and adding in
   ip6tables -t mangle -A OUTPUT -m mark --mark 12345 -j MARK --set-mark 1234
suddenly results in the ip rule fwmark being obeyed.

I believe that
    setsockopt(SO_MARK, 1234)
combined with
    ip6tables -t mangle -A OUTPUT -j HL --hl-dec 1
would also work (since a changed hoplimit triggers routing
re-examination [exactly why is unclear to me...]).

Figuring out exactly where fl.mark needs to be initialized seems not
quite trivial... (because of questions of what to do with non-tcp
protocols, or syn-ack syncookies, RST packets, etc)

Alternatively temp_mark = skb->mark in the v6 mangle code, could be
changed to temp_mark = 0, in which case just loading the mangle table
would cause it to work, of course this would be unoptimal performance
wise and it would still be broken without ip6tables mangle table being
loaded, which isn't particularly desirable behaviour.

Not quite sure what to do with this...

- Maciej
