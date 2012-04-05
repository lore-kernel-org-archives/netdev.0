From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: net: kernel BUG() in net/netns/generic.h:45
Date: Thu, 05 Apr 2012 16:53:18 -0700
Message-ID: <m1aa2pwxap.fsf@fess.ebiederm.org>
References: <1333664446.3538.12.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Dave Jones <davej@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46160 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab2DEXtd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 19:49:33 -0400
In-Reply-To: <1333664446.3538.12.camel@lappy> (Sasha Levin's message of "Thu,
	05 Apr 2012 18:20:46 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sasha Levin <levinsasha928@gmail.com> writes:

> Hi all,
>
> When an initialization of a network namespace in setup_net() fails, w=
e
> try to undo everything by executing each of the exit callbacks of eve=
ry
> namespace in the network.
>
> The problem is, it might be possible that the net_generic array wasn'=
t
> initialized before we fail and try to undo everything. At that point,
> some of the networks assume that since we're already calling the exit
> callback, the net_generic structure is initialized and we hit the BUG=
()
> in net/netns/generic.h:45 .
>
> I'm not quite sure whether the right fix from the following three
> options is, and would be happy to figure it out before fixing it:
>
>  1. Don't assume net_generic was initialized in the exit callback, wh=
ich
> is a bit problematic since we can't query that nicely anyway (a
> sub-option here would be adding an API to query whether the net_gener=
ic
> structure is initialized.
>
>  2. Remove the BUG(), switch it to a WARN() and let each subsystem
> handle the case of NULL on it's own. While it sounds a bit wrong, it'=
s
> worth mentioning that that BUG() was initially added in an attempt to
> fix an issue in CAIF, which was fixed in a completely different way
> afterwards, so it's not strictly necessary here.
>
>  3. Only call the exit callback for subsystems we have called the ini=
t
> callback for.

Your option 3 only calling the exit callbacks for subsystems we have
initialized should be what is implemented.  Certainly it looks like we
are attempting to only call the exit callbacks for code whose init
callback has succeeded.

What problem are you seeing?

This smells suspiciously like a problem we had a little while ago caif
was registering as a pernet device instead of a pernet subsystem,
and because of that we had packets flying around after it had been
unregistered and was trying access it's net_generic data.

commit 8a8ee9aff6c3077dd9c2c7a77478e8ed362b96c6
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Thu Jan 26 14:04:53 2012 +0000

    net caif: Register properly as a pernet subsystem.
   =20
    caif is a subsystem and as such it needs to register with
    register_pernet_subsys instead of register_pernet_device.
   =20
    Among other problems using register_pernet_device was resulting in
    net_generic being called before the caif_net structure was allocate=
d.
    Which has been causing net_generic to fail with either BUG_ON's or =
by
    return NULL pointers.
   =20
    A more ugly problem that could be caused is packets in flight why t=
he
    subsystem is shutting down.
   =20
    To remove confusion also remove the cruft cause by inappropriately
    trying to fix this bug.
   =20
    With the aid of the previous patch I have tested this patch and
    confirmed that using register_pernet_subsys makes the failure go aw=
ay as
    it should.
   =20
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
    Acked-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
    Tested-by: Sasha Levin <levinsasha928@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Eric
