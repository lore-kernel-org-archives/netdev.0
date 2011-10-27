From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Wed, 26 Oct 2011 22:35:17 -0700
Message-ID: <CALCETrUFyJPO9O8zZ9ZFY5fOuAjn1Nuxy0oxNh40ihyVeJQtog@mail.gmail.com>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
	<4EA849E7.5030503@hp.com>
	<CALCETrVcG=F6FrcQ3PhGz27t9+6jGh0TGACfVQ6CeUX=EjNsAw@mail.gmail.com>
	<4EA86837.60003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:34013 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870Ab1J0FfS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 01:35:18 -0400
Received: by ggnb1 with SMTP id b1so2305981ggn.19
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 22:35:17 -0700 (PDT)
In-Reply-To: <4EA86837.60003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 1:06 PM, Rick Jones <rick.jones2@hp.com> wrote:
>>> If the networks where this happens are indeed truly private, can th=
ey run
>>> a
>>> private kernel? =A0Or use an LD_PRELOAD hack to wedge-in a
>>> setsockopt(TCP_NODELAY) call into the application? =A0Or set someth=
ing like
>>> tcp_naglim_def on the application system(s)? =A0Or have the server
>>> application
>>> make a setsockopt(TCP_MAXSEG) call before listen() to a value one b=
yte
>>> below
>>> that of what the application is sending?
>>
>> We control our server. =A0We don't control the server at the other e=
nd.
>> We've tried to get them to do any of the above, but they seem
>> unwilling or unable to do it. =A0I suspect that they're using variou=
s
>> pieces from various third-party vendors that just don't care.
>
> Making the setsockopt(TCP_MAXSEG) would be at your end :) =A0Presumab=
ly based
> on the minimum message size. =A0That would cause the connection to ha=
ve an MSS
> =3D=3D the request size so every request send should take the "is thi=
s send plus
> any queued unsent data >=3D MSS" path.

That's cute.  The messages are variable-size (but they don't vary
much), so doing this would probably be worse for the network than
having them set TCP_NODELAY or having us turn off delayed acks, but we
don't really care about the network, and it might work well.

>
> Another "at your end" possibility would be setting a rather small SO_=
RCVBUF
> size at your end before calling listen(), in hopes of triggering the =
window
> update.

That scares me.  If they every start sending in bursts (it happens on
occasion), then we lose if they would want to exceed an artificially
small window.

>
>>> Is the application actually "virtuous" in sending logically associa=
ted
>>> data
>>> in one "send" call, and simply running afoul of Nagle+DelayedACK in
>>> having
>>> multiple distinct requests outstanding at once, or is it actually q=
uite
>>> evil
>>> in that it is sending logically associated data in separate send ca=
lls?
>>>
>>
>> The remote application generates messages meant for us, and they
>> appear to send each message in its own segment. =A0I don't have the
>> source, so I don't know whether they're really using one send call p=
er
>> message or whether they're using MSG_MORE, TCP_CORK, so some other
>> mechanism. =A0Each message is time-sensitive and should be received =
as
>> soon as possible afterq its sent (i.e. one-half rtt). =A0Unfortunate=
ly,
>> when they send two messages and we don't ack the first one, the seco=
nd
>> gets delayed. =A0Turning off delayed acks helps but does not complet=
ely
>> solve the problem.
>
> If it is write,write,read =A0(multiple sends per logical message) in =
a packet
> trace you should see a partial request in the first segment, followed=
 by the
> rest of the request =A0(and perhaps the second through Nth) in the se=
cond
> segment. =A0Or, I suppose your server application would have a receiv=
e
> complete with the first part of the first request, getting the second=
 part
> of the request in a subsequent receive call.
>
> If it is multiple requests at a time each sent in one send call, you =
should
> see a first segment arriving with a complete request within it, follo=
wed by
> a second segment with the next request(s).

These are asynchronous messages and we don't reply to the vast
majority of them.  We see one request arriving per segment.

I'll play with TCP_MAXSEG.  But I'll probably leave TCP_NO_DELAYED_ACK
patched in to my kernel for the time being.  I'm not thrilled about
forcing the other side to split their messages across multiple
segments.

--Andy
