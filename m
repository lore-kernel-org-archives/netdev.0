From: Erik Grinaker <erik@bengler.no>
Subject: Re: TCP connection issues against Amazon S3
Date: Tue, 6 Jan 2015 19:50:41 +0000
Message-ID: <FB6A6CF4-0E3F-4BA7-90B1-5DC5FDE12DDE@bengler.no>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com> <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no> <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com> <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com> <54AC348B.4030900@hp.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:39455 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756431AbbAFTun convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 14:50:43 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 63F0A208E9
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2015 14:50:43 -0500 (EST)
In-Reply-To: <54AC348B.4030900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06 Jan 2015, at 19:16, Rick Jones <rick.jones2@hp.com> wrote:
>=20
>>>>>>> A packet dump [1] shows repeated ACK retransmits for some of th=
e
>> TCP does not retransmit ACK ... do you mean DUPACKs sent by the rece=
iver?
>>=20
>> I am trying to understand the problem. Could you confirm that it's t=
he
>> HTTP responses sent from Amazon S3 got stalled, or HTTP requests sen=
t
>> from the receiver (your host)?
>>=20
>> btw I suspect some middleboxes are stripping SACKOK options from you=
r
>> SYNs (or Amazon SYN-ACKs) assuming Amazon supports SACK.
>=20
> The TCP Timestamp option too it seems.
>=20
> Speaking of middleboxes...  It is probably a fish that is red, but a =
while back I stepped in a middle box (a load balancer) which decided th=
at if it saw "too many" retransmissions in a given TCP window that some=
thing was seriously wrong and it would toast the connection.  I thought=
 though that was an active reset on the part of the middlebox. (And the=
 client was the active sender not the back-end server)

It=E2=80=99s looking increasingly probable that it=E2=80=99s something =
like that, since the sender (S3) appears to disable SACKs on the failin=
g clients, while it enables SACKs on other functioning clients.

> I'm assuming one incident starts at XX:41:24.748265 in the trace?  Th=
at does look like it is slowly slogging its way through a bunch of lost=
 traffic, which was I think part of the problem I was seeing with the m=
iddlebox I stepped in, but I don't think I see the reset where I would =
have expected it.  Still, it looks like the sender has an increasing TC=
P RTO as it is going through the slog (as it likely must since there ar=
e no TCP timestamps?), to the point it gets larger than I'm guessing cu=
rl was willing to wait, so the FIN at XX:41:53.269534 after a ten secon=
d or so gap.

Yes, there is one incident starting at XX:41:23. All the RSTs are sent =
at the end though, at the 30s Curl timeout. I=E2=80=99ve put up a strip=
ped down pcap of a single request here:

http://abstrakt.bengler.no/tcp-issues-s3-failure.pcap.bz2
