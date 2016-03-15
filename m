From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] af_unix: closed SOCK_SEQPACKET socketpair must get SIGPIPE
Date: Tue, 15 Mar 2016 17:13:07 +0100
Message-ID: <CAG_fn=Xq_OaQdDSov8vAR-Lq8tDftGo=Pmp0p3q_LzLXDCFVvw@mail.gmail.com>
References: <1458032624-139688-1-git-send-email-glider@google.com>
	<063D6719AE5E284EB5DD2968C1650D6D4111FC91@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "edumazet@google.com" <edumazet@google.com>,
	"rweikusat@mobileactivedefense.com"
	<rweikusat@mobileactivedefense.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35216 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240AbcCOQNI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 12:13:08 -0400
Received: by mail-wm0-f43.google.com with SMTP id l68so157134460wml.0
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 09:13:08 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D4111FC91@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 15, 2016 at 2:46 PM, David Laight <David.Laight@aculab.com>=
 wrote:
> From: Alexander Potapenko
>> Sent: 15 March 2016 09:04
>> According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
>> socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if th=
e
>> socket is no longer connected.
> ...
>> Without the below patch the behavior is as follows:
>>
>> $ ./sock seqpacket
>> sendmsg: Broken pipe
> ...
>> The behavior of the patched kernel complies with POSIX:
>>
>> $  ./sock seqpacket
>> Killed by SIGPIPE
> ...
>
> While POSIX might specify this behaviour, changing the behaviour
> could easily break applications.
> Basically this change (more or less) require every application that
> uses SOCK_SEQPACKED to be audited to ensure that MSG_NOSIGNAL is set
> on ever send/write to the socket.
This is true, but the drawback of maintaining a non-standard behavior
is that people can't write portable code.
I couldn't find the exact place where the bug has been introduced, but
according to http://lxr.free-electrons.com/ SOCK_SEQPACKET sockets did
not respect MSG_NOSIGNAL from the very beginning
(http://lxr.free-electrons.com/source/net/unix/af_unix.c?v=3D3.8#L1723,
there was no such thing as SOCK_SEQPACKET in AF_UNIX in 2.4.37)
Unfortunately I don't know how to estimate the number of existing
users depending on this oddity, as well as the number of people that
have to work around it, so leaving it up to maintainers to decide
whether the fix is needed.

> Personally I think the whole SIGPIPE on sockets should never have bee=
n
> allowed to get into the standard.
> I don't remember MSG_NOSIGNAL being present in SYSV.
I think it was not.

> The only time you want a write into a pipe to generate SIGPIPE is
> for pipes generates by the shell that feed stdout to stdin of the
> next process in the pipeline.
> If pipes are implemented as unix-domain socketpairs (no one does that
> any more) then it would require the SIGPIPE for write().
>
>         David
>
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicl=
e
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
