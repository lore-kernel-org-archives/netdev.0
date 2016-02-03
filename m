From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Wed, 03 Feb 2016 11:34:43 -0800
Message-ID: <1454528083.7627.284.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
	 <1454440995-18457-3-git-send-email-bro.devel+kernel@gmail.com>
	 <1454445306.7627.204.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAF8eE=XxUeoe7pC8C6wgOi=GUR4daRNvFq8ZTrUCifZVa5zn+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?ISO-8859-1?Q?P=E5l?= Halvorsen <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad
	<bro.devel+kernel@gmail.com>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34077 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbcBCTep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 14:34:45 -0500
Received: by mail-pf0-f178.google.com with SMTP id o185so18776767pfb.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 11:34:44 -0800 (PST)
In-Reply-To: <CAF8eE=XxUeoe7pC8C6wgOi=GUR4daRNvFq8ZTrUCifZVa5zn+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-02-03 at 19:17 +0100, Bendik R=C3=B8nning Opstad wrote:
> On Tue, Feb 2, 2016 at 9:35 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > On Tue, 2016-02-02 at 20:23 +0100, Bendik R=C3=B8nning Opstad wrote=
:
> >>
> >>   o When packets are scheduled for transmission, RDB replaces the =
SKB to
> >>     be sent with a modified SKB containing the redundant data of
> >>     previously sent data segments from the TCP output queue.
> >
> > Really this looks very complicated.
>=20
> Can you be more specific?

A lot of code added, needing maintenance cost for years to come.

>=20
> > Why not simply append the new skb content to prior one ?
>=20
> It's not clear to me what you mean. At what stage in the output engin=
e
> do you refer to?
>=20
> We want to avoid modifying the data of the SKBs in the output queue,

Why ? We already do that, as I pointed out.

> therefore we allocate a new SKB (This SKB is named rdb_skb in the cod=
e).
> The header and payload of the first SKB containing data we want to
> redundantly transmit is then copied. Then the payload of the SKBs fol=
lowing
> next in the output queue is appended onto the rdb_skb. The last paylo=
ad
> that is appended is from the first SKB with unsent data, i.e. the
> sk_send_head.
>=20
> Would you suggest a different approach?
>=20
> > skb_still_in_host_queue(sk, prior_skb) would also tell you if the s=
kb is
> > really available (ie its clone not sitting/waiting in a qdisc on th=
e
> > host)
>=20
> Where do you suggest this should be used?

To detect if appending data to prior skb is possible.

If the prior packet is still in qdisc, no change is allowed,
and it is fine : DRB should not trigger anyway.

>=20
> > Note : select_size() always allocate skb with SKB_WITH_OVERHEAD(204=
8 -
> > MAX_TCP_HEADER) available bytes in skb->data.
>=20
> Sure, rdb_build_skb() could use this instead of the calculated
> bytes_in_rdb_skb.

Point is : small packets already have tail room in skb->head

When RDB decides a packet should be merged into the prior one, you can
simply copy payload into the tailroom, then free the skb.

No skb allocations are needed, only freeing.

RDB could be implemented in a more concise way.
