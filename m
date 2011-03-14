From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Mon, 14 Mar 2011 11:06:19 +0100
Message-ID: <201103141106.19679.carsten@wolffcarsten.de>
References: <1299894051-13820-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:40856 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab1CNKY4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 06:24:56 -0400
In-Reply-To: <1299894051-13820-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Saturday 12 March 2011, Yuchung Cheng wrote:
> In the current undo logic, cwnd is moderated after it was restored
> to the value prior entering fast-recovery. It was moderated first
> in tcp_try_undo_recovery then again in tcp_complete_cwr.
>=20
> Since the undo indicates recovery was false, these moderations
> are not necessary. If the undo is triggered when most of the
> outstanding data have been acknowledged, the (restored) cwnd is
> falsely pulled down to a small value.
>=20
> This patch removes these cwnd moderations if cwnd is undone during
> the fast-recovery.

The moderation is in place to avoid gigantic segment bursts, which coul=
d cause=20
unnecessary pressure on buffers. In my eyes it's already suboptimal tha=
t the=20
moderation is weakened in the presence of (detected) reordering, let al=
one=20
removing it completely.

More importantly, the prior ssthresh is restored and not affected by=20
moderation. This means, if moderation reduces cwnd to a small value, th=
en cwnd=20
< ssthresh and TCP will quickly slow-start back to the previous state, =
without=20
sending a big burst of segments.

Also, you intended to remove cwnd moderation only from an undo during=20
recovery, but I think your patch also removes cwnd moderation when the =
undo is=20
caused by D-SACK, i.e. most likely after recovery already ended.

Carsten
--=20
           /\-=C2=B4-/\
          (  @ @  )
________o0O___^___O0o________
