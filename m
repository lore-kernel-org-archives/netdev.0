From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Wed, 22 Sep 2010 19:35:35 +0200
Message-ID: <1285176935.2639.453.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
	 <1285064011.2617.238.camel@edumazet-laptop>
	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
	 <1285144306.2639.90.camel@edumazet-laptop>
	 <1285144471.2639.96.camel@edumazet-laptop>
	 <1285144681.2639.102.camel@edumazet-laptop>
	 <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57965 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795Ab0IVRfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 13:35:40 -0400
In-Reply-To: <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 septembre 2010 =C3=A0 17:58 +0900, Tetsuo Handa a =C3=A9=
crit :=20
> > Updated and booted/tested patch :
>=20
> The warning by test.sh disappeared by your patch.
> But the warning which I encounter upon reboot still appears.

> FYI,
>=20
>   # cat /etc/exports
>   /usr/src/ *(rw,no_root_squash,async)
>=20
>   # grep nfs /proc/mounts
>   127.0.0.1:/usr/src/ /mnt nfs rw,relatime,vers=3D3,rsize=3D32768,wsi=
ze=3D32768,namlen=3D255,hard,proto=3Dudp,port=3D65535,timeo=3D7,retrans=
=3D3,sec=3Dsys,addr=3D127.0.0.1 0 0
>=20
> test.sh does not trigger this warning on 2.6.34.7 and
> triggers this warning on 2.6.35.5 .
>=20

Thanks !

We have for each socket :

One spinlock (sk_slock.slock)
One rwlock (sk_callback_lock)

It is legal to use :

A) (this is used in net/sunrpc/xprtsock.c)
read_lock(&sk->sk_callback_lock) (without blocking BH)
<BH>
spin_lock(&sk->sk_slock.slock);
=2E..
read_lock(&sk->sk_callback_lock);
=2E..

Its also legal to do

B)
write_lock_bh(&sk->sk_callback_lock)
stuff
write_unlock_bh(&sk->sk_callback_lock)


But if we have a path that :

C)
spin_lock_bh(&sk->sk_slock)
=2E..
write_lock_bh(&sk->sk_callback_lock)
stuff
write_unlock_bh(&sk->sk_callback_lock)

Then we can have a deadlock with A)

CPU1 [A]                                CPU2 [C]
read_lock(&sk->sk_callback_lock)
<BH>					spin_lock_bh(&sk->sk_slock)
<wait to spin_lock(slock)>
					<wait to write_lock_bh(callback_lock)>

We have one such path C) in inet_csk_listen_stop() :

local_bh_disable();
bh_lock_sock(child); // spin_lock_bh(&sk->sk_slock)
WARN_ON(sock_owned_by_user(child));
=2E..
sock_orphan(child); // write_lock_bh(&sk->sk_callback_lock)

This is a false positive because its not possible that this particular
deadlock can occur, since inet_csk_listen_stop() manipulates half
sockets (not yet given to a listener)

Give me a moment to think about it and write a fix.



