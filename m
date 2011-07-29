From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 16:36:24 +0200
Message-ID: <1311950184.2843.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E32B33C.2020103@hippy.csoma.elte.hu>
	 <1311946421.2843.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32C302.8050304@hippy.csoma.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: synapse <synapse@hippy.csoma.elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56117 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab1G2Og1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:36:27 -0400
Received: by wyg8 with SMTP id 8so221868wyg.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 07:36:26 -0700 (PDT)
In-Reply-To: <4E32C302.8050304@hippy.csoma.elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 16:26 +0200, synapse a =C3=A9crit :
> On 07/29/11 15:33, Eric Dumazet wrote:
> > Le vendredi 29 juillet 2011 =C3=A0 15:18 +0200, synapse a =C3=A9cri=
t :
> >> Hello guys,
> >>
> >> I have a problem that I hope you can help me resolv. This is my fi=
rst
> >> real bug report, so please be
> >> patient :)
> >>
> >> ### Description:
> >> 3.0.0-rc4 routinely locks up with BUG: unable to handle kernel NUL=
L
> >> pointer dereference at 000000000000002c
> >> I have an intel sr2600 machine with a 10Gbit interface, it periodi=
cally
> >> locks up after a few days.
> >> It serves a lot of traffic. The trace is at the end of the mail.
> >> ###
> >>
> >> ### My efforts:
> >> I've traced the error back from atomic_dec_and_test() to:
> >>
> >> ipv4_dst_check()
> >> check_peer_redir()
> >> neigh_release()
> >> atomic_dec_and_test()
> >>
> >> The parameter to atomic_dec_and_test() is NULL (&neigh->refcnt in
> >> neigh_release), so atomic_dec_and_test()
> >> at /arch/x86/include/asm/atomic.h dies at offset 0xffffffff8140f56=
f.
> >>
> >> ffffffff8140f560:       48 8b 15 19 47 2f 00    mov
> >> 0x2f4719(%rip),%rdx        # 0xffffffff81703c80
> >> ffffffff8140f567:       48 89 50 18             mov    %rdx,0x18(%=
rax)
> >> ffffffff8140f56b:       48 8b 7b 40             mov    0x40(%rbx),=
%rdi
> >> ffffffff8140f56f:       f0 ff 4f 2c             lock decl 0x2c(%rd=
i)
> >> ffffffff8140f573:       0f 94 c0                sete   %al
> >> ffffffff8140f576:       84 c0                   test   %al,%al
> >> ffffffff8140f578:       0f 85 ab 00 00 00       jne    0xffffffff8=
140f629
> >>
> >>   From what I've seen is that this code is responsible for pmtu re=
lated
> >> things. The refcount member of struct neighbour
> >> is NULL and the neigh pointer (struct neighbour *) in neigh_releas=
e() is
> >> not. I have no clue how this might happen,
> >> though I suspect somebody releases the data structure somehow. Not=
e that
> >> this code is invoked when redirect_learned.a4
> >> is set and is different from rt_gateway in ipv4_dst_check().
> >>
> >> Is it possible that two packets go to two different cores for proc=
essing
> >> and one core invalidates the rt entry
> >> the other is currently working on (meaning the second will try to
> >> dereference a NULL ptr)?
> >> ###
> >>
> >>
> >> This is just my clumsy attempt at tracking this down, I'm not a ke=
rnel
> >> expert unfortunately. I'm happy to provide
> >> further info on the matter. If I'm completely on the wrong track p=
lease
> >> let me know.
> >>
> >> Thank you for any help,
> >> Gergely Kalman
> >>
> > This bug was probably already fixed.
> >
> > Please try current linux tree
> >
> >
> found no relevant things in the diffs, except for a check against=20
> DST_NOCOUNT
> when calling dst_entries_add(opc, 1). Will try with the new kernel, b=
ut=20
> unfortunately
> it might take days to reproduce.

Hmm, I'll take a look, but check_peer_redir() seems suspicious at first
glance.



