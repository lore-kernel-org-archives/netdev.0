From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 11:31:43 +0200
Message-ID: <1271064703.16881.16.camel@edumazet-laptop>
References: <201004112338.47019.nuclearcat@nuclearcat.com>
	 <1271025353.2078.155.camel@edumazet-laptop>
	 <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com>
	 <1271052111.2078.168.camel@edumazet-laptop>
	 <OF802D1BE7.C2709B61-ON65257703.00235EF5-65257703.002B5F38@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Denys Fedorysychenko <nuclearcat@nuclearcat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:42539 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab0DLJbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 05:31:50 -0400
Received: by bwz19 with SMTP id 19so22031bwz.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 02:31:48 -0700 (PDT)
In-Reply-To: <OF802D1BE7.C2709B61-ON65257703.00235EF5-65257703.002B5F38@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 13:24 +0530, Krishna Kumar2 a =C3=A9crit =
:

> If the dst got changed between call to vlan_dev_hwaccel_hard_start_xm=
it
> and it's call to dev_queue_xmit, that change to dst should have reset
> sk_tx_queue_mapping to -1 by calling sk_tx_queue_clear (assuming that=
 I
> have changed in all paths, eg __sk_dst_reset), and thus result in a n=
ew
> mapping in dev_pick_tx. Would the patch hide the actual bug where we =
do
> not clear sk_tx_queue_mapping, eg __sk_dst_set does it? I agree the
> patch will fix the panic, but this check could be removed if the code
> which changes the dst is fixed to clear the mapping. I could check th=
at
> if you think this assumption is correct.
>=20

I believe you focus on another problem. I am not saying we dont have
another bug (forgetting to reset sk_dst_cache somewhere).

I am only saying that when we want to cache the queue number on a given
socket, we have to make sure current packet routing decision was taken
on same dst_entries than current and future ones. Denys hit the problem
because of long delays caused by traffic shaping.

So the cache renew must be safe, which I tried to fix.

You are saying that cache invalidation might be missing from some paths=
=2E
I dont think so because I took an extensive look at these spots when
working on yet another RCU conversion two days ago (sk_dst_lock becomes
a spinlock). This was fresh in my mind, this is why I probably found
Denys problem origin so quickly ;)



