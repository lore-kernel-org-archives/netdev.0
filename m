From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e1000e: possible reggresion?
Date: Thu, 20 Aug 2015 13:29:11 -0700
Message-ID: <1440102551.6610.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <665F7BF9-6041-4E7D-8A37-1B87770F9FAA@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tomas Papan <tomas.papan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36756 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbbHTU3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:29:14 -0400
Received: by pawq9 with SMTP id q9so35467410paw.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 13:29:14 -0700 (PDT)
In-Reply-To: <665F7BF9-6041-4E7D-8A37-1B87770F9FAA@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-20 at 21:37 +0200, Tomas Papan wrote:
> Hi there,
>=20
> I=E2=80=99m observing a freeze with the recent kernel (4.2-rc7). Unfo=
rtunately I can=E2=80=99t preserver the full traces.
> There is nothing in the messages after reboot, I was just lucky one t=
ime to see it when tail -f /var/log/messages was running.
> This is the only line which I was able to get:
> 	eth1 (e1000e): transmit queue 0 timed out
>=20
> I=E2=80=99ve got this message in the past, but the ethtool -K eth1 ts=
o off solved that. I=E2=80=99m always running
> this command at the boot time since then. There is no issue with 4.2-=
rc4. It is hard to bisect,
> because this machine is used as headless server and it happens random=
ly (usually within 2 hours).
>=20
> Do you have any idea how to trace it or what can I do?
> Please keep me on CC since I=E2=80=99m not subscribed on this list
>=20
> Regards
> Tomas

I would pull latest tree from Linus and pray the bug was fixed.

My feeling is that you hit the issue fixed with

commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Aug 13 15:44:51 2015 -0700

    inet: fix potential deadlock in reqsk_queue_unlink()
   =20
    When replacing del_timer() with del_timer_sync(), I introduced
    a deadlock condition :
   =20
    reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()
   =20
    inet_csk_reqsk_queue_drop() can be called from many contexts,
    one being the timer handler itself (reqsk_timer_handler()).
   =20
    In this case, del_timer_sync() loops forever.
   =20
    Simple fix is to test if timer is pending.
   =20
    Fixes: 2235f2ac75fd ("inet: fix races with reqsk timers")
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
