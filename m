From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] SFQ planned changes
Date: Tue, 03 Jan 2012 11:40:35 +0100
Message-ID: <1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:39733 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752125Ab2ACKkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 05:40:39 -0500
Received: by lahd3 with SMTP id d3so3660030lah.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 02:40:38 -0800 (PST)
In-Reply-To: <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 03 janvier 2012 =C3=A0 10:36 +0100, Dave Taht a =C3=A9crit :

> I note that (as of yesterday) sfq is performing as well as qfq did
> under most workloads, and is considerably simpler than qfq, but
> what I have in mind for shaping in a asymmetric scenario
> *may* involve 'weighting' - rather than strictly prioritizing -
> small acks... and it may not - I'd like to be able to benchmark
> the various AQM approaches against a variety of workloads
> before declaring victory.


A QFQ setup with more than 1024 classes/qdisc is way too slow at init
time, and consume ~384 bytes per class : ~12582912 bytes for 32768
classes.

We also are limited to 65536 qdisc per device, so QFQ setup using hash
is limited to a 32768 divisor.


Now SFQ as implemented in Linux is very limited, with at most 127 flows
and limit of 127 packets. [ So if 127 flows are active, we have one
packet per flow ]

I plan to add to SFQ following features :

- Ability to specify a per flow limit=20
     Its what is called the 'depth',
     currently hardcoded to min(127, limit)

- Ability to have up to 65535 flows (instead of 127)

- Ability to have a head drop (to drop old packets from a flow)

example of use : No more than 20 packets per flow, max 8000 flows, max
20000 packets in SFQ qdisc, hash table of 65536 slots.

tc qdisc add ... sfq \
	flows 8000 \
	depth 20 \
	headdrop \
	limit 20000 divisor 65536

Ram usage : 32 bytes per flow, instead of 384 for QFQ, so much better
cache hit ratio. 2 bytes per hash table slots, instead of 8 for QFQ.

(perturb timer for a huge SFQ setup would be not recommended)
