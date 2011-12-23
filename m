From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 20:21:23 +0100
Message-ID: <1324668083.2915.15.camel@edumazet-laptop>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	 <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	 <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	 <1324664907.2915.5.camel@edumazet-laptop>
	 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42777 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab1LWTV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 14:21:27 -0500
Received: by wgbdr13 with SMTP id dr13so17866170wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 11:21:25 -0800 (PST)
In-Reply-To: <20111223110749.7a690685@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 11:07 -0800, Stephen Hemminger=
 a =C3=A9crit :

> skb_cb is the dumping ground of the networking layer.
> The assumption was that the qdisc could use the skb_cb
> for it's own scratchpad. Netem is using it for tagging
> packets in the queue.=20
>=20
> So basically, netem, choke, and sfb are incompatible with
> each other. This is not that bad, why not add a flag to qdisc
> ops to indicate which qdisc are using cb and block user from
> trying to do something bogus.

This is not how I planned to solve the problem.

I think we need an internal tfifo for netem use.

Then be able to add another qdisc on top of netem.


tfifo as a first stage, hardcoded (only limit is tunable)
[ optional 2nd stage, any qdisc ]

netem_queue()
{
	queue packet to tfifo
	(eventually at head, of reordering)
}

netem_dequeue()
{
	if (other_qdisc) {
		for_each_packet_from_tfifo_time_ready() {
			other_qdisc->enqueue(skb);
		}
		try_to_dequeue_one_packet_from(other_qdisc);
	} else {
		dequeue_one_packet_from_tfifo_time_ready();
	}
}
