From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 09:38:47 -0700
Message-ID: <469958e00905210938s371b5dect28c7b1f8bb751ad1@mail.gmail.com>
References: <20090520230652.GB5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:61770 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330AbZEUQir convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 12:38:47 -0400
Received: by yw-out-2324.google.com with SMTP id 5so727110ywb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 09:38:48 -0700 (PDT)
In-Reply-To: <20090520230652.GB5956@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +
> + =C2=A0 =C2=A0 =C2=A0 while (datagrams < vlen) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D __sys_recv=
msg(sock, (struct msghdr __user *)entry, flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (err < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 goto out_put;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D __put_user=
(err, &entry->msg_len);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (err)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 goto out_put;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ++entry;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ++datagrams;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0out_put:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fput_light(sock->file, fput_needed);
> =C2=A0out:
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We may return less entries than reques=
ted (vlen) if the
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* sock is non block and there aren't eno=
ugh datagrams.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (err =3D=3D 0 || (err =3D=3D -EAGAIN && (fl=
ags & MSG_DONTWAIT)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return datagrams;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return err;
> =C2=A0}
>

There is an assumption here that unless MSG_DONTWAIT is set, or there
is an error,
that the caller will be willing to wait indefinitely for N messages to
show up -- and that
it is never worth waking up the caller earlier with less than N message=
s.

I think an application would more typically want to wait at most m
msecs after the first
message is received to see if any other messages can be delivered at
the same time.
A busy server could simply use DONTWAIT in a polling loop every cycle,
but it would be
nice to be able to wait indefinitely for *any* of your clients to send
you a message.

=46urther, with some sockets there are some messages that are more equa=
l
than others.
Although valid messages, with no errors, they should be delivered to
user-mode immediately.
The example that leaps to my mind immediately are SCTP Events,
particularly with one-to-many
sockets. You could be waiting for N messages, knowing that a specific
peer has been asked to
send N messages. The 2nd message could be an SCTP event announcing
that the specific
association has been torn down (and hence the remaining messages will
not be arriving).
Waiting for a different association to send enough messages to
complete the request will
not provide very prompt service.
