From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Wed, 26 Oct 2011 12:35:22 -0700
Message-ID: <CALCETrVcG=F6FrcQ3PhGz27t9+6jGh0TGACfVQ6CeUX=EjNsAw@mail.gmail.com>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
	<4EA849E7.5030503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51216 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab1JZTfW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 15:35:22 -0400
Received: by ywm3 with SMTP id 3so1883126ywm.19
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 12:35:22 -0700 (PDT)
In-Reply-To: <4EA849E7.5030503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 10:56 AM, Rick Jones <rick.jones2@hp.com> wrote=
:
> On 10/25/2011 07:25 PM, Andy Lutomirski wrote:
>>
>> When talking to an unfixable interactive peer that fails to set
>> TCP_NODELAY, disabling delayed ACKs can help mitigate the problem.
>> This is an evil thing to do, but if the entire network is private,
>> it's not that evil.
>>
>> This works around a problem with the remote *application*, so make
>> it a socket option instead of a sysctl or a per-route option.
>>
>> Signed-off-by: Andy Lutomirski<luto@amacapital.net>
>> ---
>>
>> This patch is a bit embarrassing. =A0We talk to remote applications =
over
>> TCP that are very much interactive but don't set TCP_NODELAY. =A0The=
se
>> applications apparently cannot be fixed. =A0As a partial workaround,=
 if we
>> ACK every incoming segment, then as long as they don't transmit two
>> segments per rtt, we do pretty well.
>
> Embarrassing/evil indeed - is it really something to go into the kern=
el?

That's a good question.  It's in our kernel -- I don't know whether it
should go upstream.

>
> If the networks where this happens are indeed truly private, can they=
 run a
> private kernel? =A0Or use an LD_PRELOAD hack to wedge-in a
> setsockopt(TCP_NODELAY) call into the application? =A0Or set somethin=
g like
> tcp_naglim_def on the application system(s)? =A0Or have the server ap=
plication
> make a setsockopt(TCP_MAXSEG) call before listen() to a value one byt=
e below
> that of what the application is sending?

We control our server.  We don't control the server at the other end.
We've tried to get them to do any of the above, but they seem
unwilling or unable to do it.  I suspect that they're using various
pieces from various third-party vendors that just don't care.

>
> Is the application actually "virtuous" in sending logically associate=
d data
> in one "send" call, and simply running afoul of Nagle+DelayedACK in h=
aving
> multiple distinct requests outstanding at once, or is it actually qui=
te evil
> in that it is sending logically associated data in separate send call=
s?
>

The remote application generates messages meant for us, and they
appear to send each message in its own segment.  I don't have the
source, so I don't know whether they're really using one send call per
message or whether they're using MSG_MORE, TCP_CORK, so some other
mechanism.  Each message is time-sensitive and should be received as
soon as possible afterq its sent (i.e. one-half rtt).  Unfortunately,
when they send two messages and we don't ack the first one, the second
gets delayed.  Turning off delayed acks helps but does not completely
solve the problem.

> rick jones
>
> choir preaching follows:

:)  I agree.  Unfortunately I didn't write all this stuff.
