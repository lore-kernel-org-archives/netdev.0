From: Tom Marshall <tdm.code@gmail.com>
Subject: Small problem with tcp_poll and RST
Date: Wed, 15 Sep 2010 13:17:39 -0700
Message-ID: <AANLkTik-FQ7aF0Cp0NicERYLG1vFG4SAe4aeeMHzxNhO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:48828 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab0IOURk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 16:17:40 -0400
Received: by qwh6 with SMTP id 6so439772qwh.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 13:17:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in tcp_poll seems to suffer from a race condition which can
result in POLLIN but not POLLOUT for an outbound socket connection to
a closed peer.

This can happen if, for example, the RST comes in immediately after
checking sk->sk_err.=A0 It is a small window of opportunity and so it
only happens rarely.

Note this code has remained pretty much unchanged in 2.6.x for years,
and the problem readily reproduces on a wide variety of systems (RHEL
5.x, Ubuntu 10.04, etc.)

I suppose it is arguable whether this is a bug or whether it deserves
to be fixed, but it did cause an issue with some (admittedly broken)
userspace code at my company.

I do not fully understand the intricacies of the interactions between
the TCP state machine and the tcp_poll function (which runs unlocked).
 However, I did find that the below appears to fix the issue.=A0 Since
the overhead is minimal when the socket state does not change, it
should have very little performance impact.

=A0=A0=A0=A0=A0=A0=A0 unsigned char oldstate;
again:
=A0=A0=A0=A0=A0=A0=A0 oldstate =3D sk->sk_state;

=A0=A0=A0=A0=A0=A0=A0 /* body of tcp_poll */

=A0=A0=A0=A0=A0=A0=A0 if (sk->sk_state !=3D oldstate)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto again;

Thanks!
