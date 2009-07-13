From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 13 Jul 2009 15:04:51 -0700
Message-ID: <65634d660907131504u35154059m5934cca3cb9363e0@mail.gmail.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
	 <20090713.104950.121936768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:59265 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757537AbZGMWE6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 18:04:58 -0400
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n6DM4uxc029639
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2009 15:04:56 -0700
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by spaceape11.eur.corp.google.com with ESMTP id n6DM4qIn007400
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2009 15:04:53 -0700
Received: by pxi15 with SMTP id 15so741781pxi.33
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2009 15:04:52 -0700 (PDT)
In-Reply-To: <20090713.104950.121936768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2009 at 10:49 AM, David Miller <davem@davemloft.net> wr=
ote:
>
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 3 May 2009 21:03:01 -0700
>
> > @@ -758,6 +758,8 @@ struct net_device
> > =A0 =A0 =A0 void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*ax25_ptr; =
=A0 =A0 =A0/* AX.25 specific data */
> > =A0 =A0 =A0 struct wireless_dev =A0 =A0 *ieee80211_ptr; /* IEEE 802=
=2E11 specific data,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0assign before registering */
> > + =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *rps_map;
> > + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_map_len;
> >
> > =A0/*
> > =A0 * Cache line mostly used on receive path (including eth_type_tr=
ans())
>
> So essentially this table is a user defined (via sysctl) group of cpu=
s
> among which to distribute incoming traffic for a device, right?

Yes.=A0 It's a simple static table.

>
> Why not take this to it's logical end point, which is to monitor
> transmits using a tiny flow lookup table, and map receives of the sam=
e
> flow to the same cpu?

Is it better do use transmits, or monitor where recvmsg was called?

>
> You can even "cheat" and not store the whole flow key in the small
> lookup table, just use the resulting hash value as the key. =A0Also,
> if "best effort" is considered OK you can even do away with hash
> chaining as well, further decreasing the space cost of the table.

Right.=A0 In fact, just using the hash as the key is what you want when
device provides the hash (i.e. Toeplitz).=A0 The caveat is that we
should to prevent OOO packets when threads migrate, I think I have a
reasonable solution for that following your earlier suggestion.

I hope to have a new patch soon for steering packets to application
CPU and using device hash, thanks for bugging me on it!

>
> If your goal is to steer traffic to the cpu on which the receiving
> application is operating, that seems to me to be the only way to
> reliably and consistently hit that target.
