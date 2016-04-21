From: Patrick Schaaf <netdev@bof.de>
Subject: Re: bridge not learning from locally sent gratuitous ARP?
Date: Thu, 21 Apr 2016 13:32:16 +0200
Message-ID: <CAJ26g5T65eXWBQBZzRb=hzr+29dUUnWxfN=GUu=ouQJVKZiVGQ@mail.gmail.com>
References: <CAJ26g5SKzs=+0MmanfC4Hfuti_jLo5R=e6T6imNc98rXVsA1ug@mail.gmail.com>
	<5718AC0A.8090009@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:41372 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbcDULcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 07:32:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by mars.intermailgate.com (Postfix) with ESMTP id C72144043D
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 13:32:18 +0200 (CEST)
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by mars.intermailgate.com (Postfix) with ESMTPSA id 18E974030E
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 13:32:18 +0200 (CEST)
Received: by mail-io0-f182.google.com with SMTP id u185so82588407iod.3
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 04:32:18 -0700 (PDT)
In-Reply-To: <5718AC0A.8090009@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 12:31 PM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> On 2016/04/21 15:37, Patrick Schaaf wrote:
> (I understand the problem happens only if you use macvlan on the bridge device. If wrong, correct me.)

That is my understanding, yes. That macvlan device is created by
keepalived, which I use for VRRP, via its use_vmac + vmac_xmit_base
settings.

> Please use "bridge fdb show" instead of "brctl showmacs". brctl is an
> old tool and has limitation in showing fdb entries.

Learn a new thing every day! Thanks, that's good to know.

> I guess your bridge doesn't have the mac address of the macvlan device
> in its fdb. If you can confirm that by bridge command, then add an entry
> by hand.
>
> # bridge fdb add <addr of macvlan> dev <brport> master
> <brport> can be any device that belongs to the bridge.
> This command (without "temp" option) installs an fdb entry that forwards
> frames to the bridge device.

The "bridge" command operates solely on bridge ports (not on the
bridge itself), as far as I can see. Checking the member interfaces,
indeed I cannot find an entry for the macvlan interface VMAC.

The macvlan interface itself is NOT a brport.

So I add that permanent entry to the underlying ethernet link of that bridge.

Seems to work - I can still ping the virtual IP address behind that
VMAC, so the macvlan interface continues to do what it should - and
running tcpdump on the tap brport to openvpn, I see these test pings
when the fdb entry has not been set, but I no longer see them after
the bridge fdb add.

So, assuming that proives stable, I have a workaround - but one that
needs knowlege of A) the unterlying interface (brport) to fondle, and
B) the macvlan MAC address that needs adding. keepalived couldn't
easily do that "in code" because it does not know what sits under the
bridge.

Naive question: shouldn't that work automatically, i.e. macvlan when
sitting on to of a bridge, doing that internally?

Anyway, thanks for the pointers to the workaround, much appreciated!

best regards
  Patrick
