From: Markus Stenberg <markus.stenberg@iki.fi>
Subject: Wildcard destination address in SAs in SAD?
Date: Wed, 10 Sep 2014 15:26:02 +0300
Message-ID: <4154E3A3-ED5F-4F12-A096-170C40E23ABA@iki.fi>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Markus Stenberg <markus.stenberg@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out1.inet.fi ([62.71.2.197]:48434 "EHLO jenni1.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbaIJMbo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:31:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let us assume I=92m trying to implement RFC4552 (authentication/confide=
ntiality for OSPFv3). What it specifies is basically per-port SA with A=
H and manual keying, of chosen granularity. As I am quite lazy, I would=
 rather specify just one SA for whole set of routers I happen to manage=
, with fixed SPI and key material.

Currently, it simply is not possible to configure in sane way without u=
sing external daemon that would create SA for every destination a route=
r wants to interact with. That is very suboptimal.

The xfrm code has already concept of =91wildcard source=92. I am propos=
ing to extend the logic also to destinations, with which (for example) =
securing of all Babel traffic looks like this:

root@ir1:/# ip xfrm state
src :: dst ::
        proto esp spi 0x00000042 reqid 42 mode transport
        replay-window 0=20
        auth-trunc hmac(md5) 0x666f6f00000000000000000000000000 96
        enc cbc(aes) 0x666f6f00000000000000000000000000
        sel src ::/0 dst ::/0=20
root@ir1:/# ip xfrm policy
src ::/0 dst ff02::/16 proto udp dport 6696=20
        dir out priority 0=20
        tmpl src :: dst ::
                proto esp reqid 42 mode transport
src ::/0 dst fe80::/64 proto udp dport 6696=20
        dir out priority 0=20
        tmpl src :: dst ::
                proto esp reqid 42 mode transport
src ::/0 dst fe80::/64 proto esp=20
        dir in priority 0=20
        tmpl src :: dst ::
                proto 0 reqid 42 mode transport
src ::/0 dst ff02::/16 proto esp=20
        dir in priority 0
        tmpl src :: dst ::
                proto 0 reqid 42 mode transport
root@ir1:/#

I wrote (fairly small) patch for this ( http://www.employees.org/~msten=
ber/x/0001-xfrm-Support-for-any-dst.patch ). But is this a good idea? T=
he changes are just:

- change xfrm_state_addr_check to allow wildcard (any)=20
- xfrm_state_lookup checks for both exact dst match, as well as wildcar=
d dst match
- xfrm_state_find checks for exact, dst + src any, and dst/src any
- XFRM_STATE_WILDRECV caused SA to be ignored in some lookups, I don=92=
t know why (it is helpful at times). so I removed the checks against it=
=2E

Cheers,

-Markus