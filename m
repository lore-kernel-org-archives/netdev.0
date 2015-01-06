From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP connection issues against Amazon S3
Date: Tue, 06 Jan 2015 12:13:36 -0800
Message-ID: <1420575216.5947.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no>
	 <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no>
	 <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no>
	 <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
	 <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no>
	 <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com>
	 <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Erik Grinaker <erik@bengler.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:60563 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbbAFUNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 15:13:39 -0500
In-Reply-To: <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-06 at 19:42 +0000, Erik Grinaker wrote:

> The transfer on the functioning Netherlands server does indeed use SA=
CKs, while the Norway servers do not.
>=20
> For what it=E2=80=99s worth, I have made stripped down pcaps for a si=
ngle failing transfer as well as a single functioning transfer in the N=
etherlands:
>=20
> http://abstrakt.bengler.no/tcp-issues-s3-failure.pcap.bz2
> http://abstrakt.bengler.no/tcp-issues-s3-success-netherlands.pcap.bz2
>=20

Although sender seems to be reluctant to retransmit, this 'failure' is
caused by receiver closing the connection too soon.

Are you sure you do not ask curl to setup a very small completion
timer ?

12:41:00.738336 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 767221:768681, ack 154, win 127, length 1460
12:41:00.738346 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [.],=
 ack 736561, win 1877, length 0
12:41:05.227150 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 736561:738021, ack 154, win 127, length 1460
12:41:05.227250 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [.],=
 ack 745321, win 1882, length 0
12:41:05.278287 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 768681:770141, ack 154, win 127, length 1460
12:41:05.278354 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [.],=
 ack 745321, win 1888, length 0
12:41:05.278421 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 770141:771601, ack 154, win 127, length 1460
12:41:05.278429 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [.],=
 ack 745321, win 1894, length 0
12:41:14.257102 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 745321:746781, ack 154, win 127, length 1460
12:41:14.257154 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [.],=
 ack 746781, win 1900, length 0
12:41:14.308117 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 771601:773061, ack 154, win 127, length 1460
12:41:14.308227 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [.],=
 ack 746781, win 1905, length 0
12:41:14.308387 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 773061:774521, ack 154, win 127, length 1460
12:41:14.308397 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [.],=
 ack 746781, win 1911, length 0

-> Here receiver sends a FIN, because application closed the socket (or=
 died)
12:41:23.237156 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [F.]=
, seq 154, ack 746781, win 1911, length 0
12:41:23.289805 IP 54.231.132.98.80 > 195.159.221.106.48837: Flags [.],=
 seq 746781:748241, ack 155, win 127, length 1460
12:41:23.289882 IP 195.159.221.106.48837 > 54.231.132.98.80: Flags [R],=
 seq 505782802, win 0, length 0

Anyway, getting decent speed without SACK is going to be hard.
