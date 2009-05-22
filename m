From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Fri, 22 May 2009 09:39:28 -0700
Message-ID: <469958e00905220939w69b401aeq47903d48977166c7@mail.gmail.com>
References: <20090520230652.GB5956@ghostprotocols.net>
	 <200905221022.48790.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: =?UTF-8?Q?R=C3=A9mi_Denis=2DCourmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:5510 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbZEVQj2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 12:39:28 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1084169ywb.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2009 09:39:29 -0700 (PDT)
In-Reply-To: <200905221022.48790.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/5/22 R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>:
> On Thursday 21 May 2009 02:06:52 ext Arnaldo Carvalho de Melo wrote:
>> + =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We may return less entries than reque=
sted (vlen) if the
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* sock is non block and there aren't en=
ough datagrams.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 if (err =3D=3D 0 || (err =3D=3D -EAGAIN && (f=
lags & MSG_DONTWAIT)))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return datagrams;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return err;
>> =C2=A0}
>
> Could there be a situation whereby we receive one or more datagrams, =
then get
> an error? How does userland get the datagrams then?
>

This is exactly how a server using SOCK_DGRAM or SOCK_SEQPACKET would
want to work -- give me up to N messages received over time X (waiting =
at most
time Y after the first message is received).

The server application then:
+ wakes up with at most Y delay on delivery of any single message.
+ but wakes up only once during that period (unless N or more messages
are received)
+ wakes up at least every X to deal with idle processing.

It could simply wake up every y msecs, then use recvmmsg to receive
everything that is there,
but that would mean a lot of idle wake-ups when the number of clients i=
s low.

These are all less relevant for SOCK_STREAM since statistical
averaging of incoming
messages is rarely feasible for a single connection.

As commented earlier, however, it would make sense for each transport
to be able to
declare a given message to be "urgent" (by whatever means appropriate
to that transport)
and thereby trigger an earlier delivery. RDMA interfaces use a
"solicited event" bit for
these purposes.
