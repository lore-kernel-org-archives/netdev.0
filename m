From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Tue, 09 Oct 2007 15:28:34 +0900 (JST)
Message-ID: <20071009.152834.38612348.takano@axe-inc.co.jp>
References: <Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
	<20071007.145100.00679926.takano@axe-inc.co.jp>
	<Pine.LNX.4.64.0710081258440.31129@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, y-kodama@aist.go.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:49940 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbXJIG2o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 02:28:44 -0400
In-Reply-To: <Pine.LNX.4.64.0710081258440.31129@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Mon, 8 Oct 2007 14:11:55 +0300 (EEST)

> On Sun, 7 Oct 2007, TAKANO Ryousei wrote:
>=20
> > From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
> > Date: Fri, 5 Oct 2007 13:02:07 +0300 (EEST)
> >=20
> > > On Thu, 4 Oct 2007, TAKANO Ryousei wrote:
> > >=20
> > > In case sacktag uses fastpath, this code won't be executed for th=
e skb's=20
> > > that we would like to check (those with SACKED_RETRANS set, that =
are=20
> > > below the fastpath_skb_hint). We will eventually deal with the wh=
ole queue=20
> > > when fastpath_skb_hint gets set to NULL, with the next cumulative=
 ACK that=20
> > > fully ACKs an skb at the latest. Maybe there's a need for a large=
r surgery=20
> > > than this to fix it. I think we need additional field to tcp_sock=
 to avoid=20
> > > doing a full-walk per ACK:
> >
> > I think the problem occurs in slowpath. For example, in case when t=
he receiver
> > detects and sends back a new SACK block, the sender may fail to det=
ect loss
> > of a retransmitted packet.
>=20
> ...No, the slow path is very likely to _correct_ the problem! The pro=
blem=20
> occurs because fastpath _skips_ processing of skbs below fastpath_skb=
_hint=20
> whereas slowpath starts from tcp_write_queue_head. The retransmitted =
skbs=20
> we're interested in reside exactly on that skipped range.
>=20
Sorry, my explanaton is insufficient.
This problem occurs even if we are in the slowpath.

=46or example, consider the case when the state of the retransmission q=
ueue is
as shown in Fig.1 (http://projects.gtrc.aist.go.jp/gnet/meeting/sack-bu=
g.html).
There are 13 packets in the retransmission queue, P(0) and P(7) are=20
retransmitted, and P(1) to P(9) except P(7) are already SACKed.

If only a SACK block "SACK(8,11)" is received, P(0) is re-transmitted,=20
because the ack_seq of P(0) is smaller than the end sequence number (11=
)=20
of the SACK block. However, if the ACK packet has SACK(8,11) and SACK(1=
,3),=20
these SACK blocks are sorted, and SACK(1,3) is process from P(0) to P(2=
)=20
first. In this case, P(0) is not detected as lost because the ack_seq o=
f=20
P(0) is not smaller than the end sequence number (3) of this SACK block=
=2E=20
Next, SACK(8,11) is scanned from P(3) to P(10). P(0) is not checked her=
e,=20
and the loss is not detected.

Is it corrent?

Ryousei Takano
