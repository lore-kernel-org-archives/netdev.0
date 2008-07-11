From: Johannes Berg <johannes@sipsolutions.net>
Subject: TXQ real_num_tx_queues comments/questions
Date: Fri, 11 Jul 2008 11:47:06 +0200
Message-ID: <1215769627.3483.107.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XA0/UjgKCbP/Aei4EwmC"
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33583 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbYGKKhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 06:37:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XA0/UjgKCbP/Aei4EwmC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Sorry for not replying in a proper thread, I didn't have a copy at hand
and didn't want to bump the old version. Apologies also for the long
mail, I'm staring at the code at the moment and it may not be the most
cohesive I've ever written.

One thing I just noticed that caused me to think about it a bit more is
that you didn't change netif_tx_{start,stop,wake}_all_queues to use
real_num_tx_queues instead of num_tx_queues. However, since those queues
don't actually get used, it doesn't actually matter whether they're
started or not.

Also related to real_num_tx_queues, you mentioned in the email (if that
restriction is kept it should be explained in a comment somewhere I
think) that it must not be changed while the device is operating. While
that restriction makes it obviously safe, mac80211 is already
effectively violating it, although it isn't setting real_num_tx_queues
at all. That makes me question that restriction a bit.

However, since real_num_tx_queues is only used by the TX hashing, it
would be completely safe to change real_num_tx_queues in an RCU-like
fashion if dev_pick_tx() was under the RCU lock in dev_queue_xmit(),
i.e. just a few lines later.

Back to mac80211. There, we are clearly not using real_num_tx_queues at
all, but we are using select_queue which has the same effect. Our
select_queue, however, isn't static, and it can decide to fill a
different number of queues depending on the aggregation states.

The only interesting situation is when we need to remove a queue since
for adding it we can prepare for that before we make select_queue use
it. Removing it is however, I think, still buggy. You removed most of
the queue locking and now just lock the single txq in ieee80211_requeue,
which seems fine, but when you look at ieee80211_ht_agg_queue_remove it
seems still racy:

select_queue uses the queue_pool bit, which is only cleared in
ieee80211_ht_agg_queue_remove right before ieee80211_requeue.
ieee80211_requeue then proceeds to take all packets out of the queue and
for that of course locks the queue.

But, as far as I can tell, it would be possible for another CPU to be in
select_queue at the same time, after having tested the queue_pool bit to
be set, but not having returned yet. Now, this CPU proceeds to enqueue
the packet to the stopped queue and tries to lock the queue lock for
that, having to wait because the first CPU is in ieee80211_requeue
already holding it. mac80211 finishes requeuing and finally assumes
nothing will come in on that queue any more, but the other CPU, now
getting the lock, will enqueue a frame to that queue.

I'm not entirely sure that my analsysis is correct because the mac80211
code is running in a tasklet, but =EF=BB=BFdev_queue_xmit() only disables b=
hs
after using select_queue, and even that is only local bhs.

To fix it, I think we should move the queue selection under the rcu
lock. Then we can, in mac80211, instead of deferring the requeuing to
the tasklet, defer it to a work struct (i.e. process context) and
synchronize_rcu() between making select_queue no longer choose the queue
and requeuing from it.

Or we can do more complicated things with the queue_pool bits or an
extra spinlock for select_queue.

I like the RCU variant better, as it means we don't need a "central"
lock that is taken for all tx queues, and it also allows other drivers
to actually change real_num_tx_queues in a similar fashion, should that
ever be required.

johannes

--=-XA0/UjgKCbP/Aei4EwmC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIdywXAAoJEKVg1VMiehFYVIYP/jmzrsfsAw/ri/kEyNawG1mt
N6Q3Ub4EPlaffgo/Lfv110JYYF7Vsx/Ti35EAwFb0oDw20l47N5F2NknEAHhCvB/
v26yX9H+rttwDAH+rle/ezw7ciPzKOGXJ/HknpjE4yxVemqiJlqK3jMPyRjJowLr
Djw0A1RGWMhLodKz66b6+ZWS+XgBMtuFgMmSWITRs+lb27TySq11qwaF5wu35jAK
1zIDyoijy/+vYFPdfeH1U9W9sHsWkuJWXXjkTh7idkzvOOwjXvIC60/EP1ek2yZf
YryGdLFTBc7LCba+8fVSWjH+ExeDh1hy9wTDEYOXwbv6c1V+zM8+mCYkgMY5+EZP
86IPYy7jultdUZ1vZm59Is58eyENLA2NjUg4fbUCqau6MpDtdmfnWMqcYps24UBC
ZBMgOvyvqMcokR9upV8hqVpbyPIDIjz+3Bzvh7Qsf1onIMfjfNcKRUQg1NigFWBV
3Y/xz4f+8kF1L+w6oSKw96lNBtul6RSDVtJDRbgS1YY8GhY54lbLNOc4Zrz/ZX9o
rjrCGOiaVIxxpnhsGW2ylDjcv0Z+A6lJAtrsf4em88q1Ukqb8rJ06csWYcSgrcP5
kr7QG4N5IFqu3izLoBokdVcHWKb5uK3MLDSDg48yVeLeEKv8CTIRqT8Q2477A8xe
6MYXe7r6tI0HJ+JnLH8M
=0+Kx
-----END PGP SIGNATURE-----

--=-XA0/UjgKCbP/Aei4EwmC--

