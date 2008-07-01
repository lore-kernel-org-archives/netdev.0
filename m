From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 01 Jul 2008 14:35:19 +0200
Message-ID: <486A2487.2010303@trash.net>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35307 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbYGAMfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 08:35:21 -0400
In-Reply-To: <20080701120320.GA9412@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> On Tue, Jul 01, 2008 at 01:53:43PM +0200, Patrick McHardy (kaber@trash.net) wrote:
>> My two main objections are that this only works for TCP and
>> can be trivially evaded. What use cases does it have?
> 
> Yes, it is TCP specific module.

What about the use cases? I certainly like the idea you suggest in
your blog ("Ever dreamt to block all Linux users in your network
from accessing internet and allow full bandwidth to Windows worm?")
:) But something this easy to evade doesn't seem to provide a real
benefit for a firewall.

I can see that something like "Block IE6 running on Windows version X"
might be useful (NUFW can do this I think), but that needs support
from the host.

>> I'm also wondering whether this couldn't be implemented
>> using the u32 match.
> 
> I'm not sure it is that simple. OSF uses common rules database
> shared with OpenBSD (and other *BSDs as well), so converting it into u32
> match would require noticeble efforts. But in theory it is probably
> doable.

This would be preferrable in my opinion since they both allow
programmable filters, but u32 appears to be more flexible. I'm
very reluctant to add new iptables modules that don't increase
expressiveness or provide other clear benefits since we already
have an insane amount of modules.

 From the fingerprint file:

# Fingerprint entry format:
#
# wwww:ttt:D:ss:OOO...:OS:Version:Subtype:Details
#
# wwww     - window size (can be *, %nnn, Snn or Tnn).  The special values
#            "S" and "T" which are a multiple of MSS or a multiple of MTU
#            respectively.
# ttt      - initial TTL
# D        - don't fragment bit (0 - not set, 1 - set)
# ss       - overall SYN packet size
# OOO      - option value and order specification (see below)
# OS       - OS genre (Linux, Solaris, Windows)
# Version  - OS Version (2.0.27 on x86, etc)
# Subtype  - OS subtype or patchlevel (SP3, lo0)
# details  - Generic OS details

MSS can be matched using the tcpmss match, options (but not order)
using the tcp match, TTL using the ttl match, DF using the IP flags
match, packet size using the length match. That leaves WS for u32
(or adding support to the tcp match).

The conversion looks pretty easy actually.

>>> # iptables -I INPUT -j DROP -p tcp -m osf --genre Linux --log 2 \
>>> --ttl 2 --connector
>> And I don't think it should be using connector. AFAIK we
>> only have a single user in the tree currently and new
>> stuff usually uses genetlink (which is pretty similar),
>> so we might be able to remove connection in the future
>> unless we add new users. But netfilter modules should
>> use nfnetlink anyway.
>  
> This module was created way before genetlink was ever designed (on
> behalf of connector btw :)

Yes, I know.

> Also I do not know why we want to remove connector in favour of
> genetlink, since the former is much simpler to work with. Connector
> logging is optional in OSF.

I'm not sure if we want to, but they appear to provide similar
functionality and connector only has a single user in the tree
so far. But thats a different discussion, for netfilter related
things nfnetlink should be used.
