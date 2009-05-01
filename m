From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: skb_tx_hash() improvements
Date: Fri, 01 May 2009 11:29:54 +0200
Message-ID: <49FAC112.6090808@cosmosbay.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>	 <20090430.022417.07019547.davem@davemloft.net>	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>	 <20090430.070811.260649067.davem@davemloft.net> <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com> <49FA932B.4030405@cosmosbay.com> <49FAB2D5.60508@cosmosbay.com> <49FAB831.6020700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Dickinson <andrew@whydna.net>, jelaas@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50867 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbZEAJaC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 05:30:02 -0400
In-Reply-To: <49FAB831.6020700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
>> David, here is the followup I promised
>>
>> Thanks
>>
>> [PATCH] net: skb_tx_hash() improvements
>>
>> When skb_rx_queue_recorded() is true, we dont want to use jhash dist=
ribution
>> as the device driver exactly told us which queue was selected at RX =
time.
>> jhash makes a statistical shuffle, but this wont work with only 8 di=
fferent inputs.
>>
>> We also need to implement a true reciprocal division, to not disturb
>> symmetric setups (when number of tx queues matches number of rx queu=
es)
>> and cpu affinities.
>>
>> This patch introduces a new helper, dev_real_num_tx_queues_set()
>> to set both real_num_tx_queues and its reciprocal value,
>> and makes all drivers use this helper.
>=20
> Oh well, this was wrong, I took divide result while we want a modulo =
!
>=20
> Need to think a litle bit more :)
>=20

So no need of a true reciprocal divide, just a refinement of first patc=
h.

(Avoiding the divide if possible)

If incoming device has 4 rx queues, and outgoing device has 8 queues,
only 4 of tx queues are used, I wonder if we need some further improvem=
ent
here to better use all available tx queues ? Probably not in generic co=
de...

[PATCH] net: skb_tx_hash() improvement

When skb_rx_queue_recorded() is true, we dont want to use jhash distrib=
ution
as the device driver exactly told us which queue was selected at RX tim=
e.
jhash makes a statistical shuffle, but this wont work with only 8 diffe=
rent inputs.

Same thing for the 'modulo' operation, that works only if inputs are
enough random (ie use all available 32 bits)

This patch avoids jhash computation (which cost ~50 instructions), but =
might
still need a modulo operation, in case number of tx queues is smaller
than number of rx queues.

Reported-by: Andrew Dickinson <andrew@whydna.net>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 308a7d0..b3acb51 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1737,9 +1737,19 @@ u16 skb_tx_hash(const struct net_device *dev, co=
nst struct sk_buff *skb)
=20
 	if (skb_rx_queue_recorded(skb)) {
 		hash =3D skb_get_rx_queue(skb);
-	} else if (skb->sk && skb->sk->sk_hash) {
+		/*
+		 * Try to avoid an expensive divide, for symmetric setups :
+		 *   number of tx queues of output device =3D=3D
+		 *   number of rx queues of incoming device
+		 */
+		if (hash >=3D dev->real_num_tx_queues)
+			hash %=3D dev->real_num_tx_queues;
+		return hash;
+	}
+
+	if (skb->sk && skb->sk->sk_hash)
 		hash =3D skb->sk->sk_hash;
-	} else
+	else
 		hash =3D skb->protocol;
=20
 	hash =3D jhash_1word(hash, skb_tx_hashrnd);

