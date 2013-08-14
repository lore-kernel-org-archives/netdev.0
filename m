From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next ] xfrm: Update xfrm_state lifetime expire after
 clock_was_set
Date: Wed, 14 Aug 2013 13:26:02 +0800
Message-ID: <520B14EA.4080903@windriver.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com> <1375866296-15079-3-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <herbert@gondor.hengli.com.au>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45323 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab3HNFWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 01:22:52 -0400
In-Reply-To: <1375866296-15079-3-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8807=E6=97=A5 17:04, Fan Du wrote:
> After clock_was_set called to set new time or host resume from suspen=
d
> state. Notify IKED with soft timeout for SAs which haven't reach its
> soft timeout limit. For those dying SAs, arrange them to hard expire.
>
> Signed-off-by: Fan Du<fan.du@windriver.com>
> ---
>   net/xfrm/xfrm_state.c |   40 ++++++++++++++++++++++++++++++++++++++=
++
>   1 file changed, 40 insertions(+)
>
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 78f66fa..25e808d 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -2002,6 +2002,44 @@ int xfrm_init_state(struct xfrm_state *x)
>
>   EXPORT_SYMBOL(xfrm_init_state);
>
> +extern struct atomic_notifier_head clock_change_notifier_list;
> +static int clock_change_callback(struct notifier_block *nb,
> +                               unsigned long reason, void *arg)
> +{
> +	struct xfrm_state_walk *walk;
> +	struct xfrm_state *state;
> +	struct net *net;
> +	long next;
> +
> +	rtnl_lock();
> +	for_each_net(net) {
> +		spin_lock_bh(&xfrm_state_lock);
> +		list_for_each_entry(walk,&net->xfrm.state_all, all) {
> +			state =3D container_of(walk, struct xfrm_state, km);
> +			spin_lock(&state->lock);
                              ^^^^^^^^^^^^^
LOCKDEP complaint here about trying acquiring xfrm_state_lock while hol=
ding state->lock.
So fix this with below modifications.


 From bf282199fd172d1bbc6dcd0e38d1b8fc2192e5f5 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Wed, 14 Aug 2013 12:59:11 +0800
Subject: [PATCHv3 net-next ] xfrm: Update xfrm_state lifetime expire af=
ter clock_was_set

After clock_was_set called to set new time or host resume from suspend
state. Notify IKED with soft timeout for SAs which haven't reach its
soft timeout limit. For those dying SAs, arrange them to hard expire.

This modification is characterized by SA is sensible to any degree of
clock changes while as SA lifetime is marked by second.

Another point is clock_was_set is traversing all net name space to
update SA time while holding rtnl_lock, it may not scale very well.

Signed-off-by: Fan Du <fan.du@windriver.com>

v3:
   - Fix lockdep complaint about circular locking with trying to acquir=
e
     state->clock while holding xfrm_state_lock.
v2:
   - Use notifier when clock was set, and then update SA lifetime accor=
dingly.
---
  net/xfrm/xfrm_state.c |   44 ++++++++++++++++++++++++++++++++++++++++=
++++
  1 file changed, 44 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1df4436..50af80c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2002,6 +2002,48 @@ int xfrm_init_state(struct xfrm_state *x)

  EXPORT_SYMBOL(xfrm_init_state);

+static int clock_change_callback(struct notifier_block *nb,
+				unsigned long reason, void *arg)
+{
+	struct xfrm_state_walk *walk;
+	struct xfrm_state *state;
+	struct net *net;
+	long next;
+
+	rtnl_lock();
+	for_each_net(net) {
+		spin_lock_bh(&xfrm_state_lock);
+		list_for_each_entry(walk, &net->xfrm.state_all, all) {
+			state =3D container_of(walk, struct xfrm_state, km);
+			xfrm_state_hold(state);
+			spin_unlock_bh(&xfrm_state_lock);
+
+			spin_lock_bh(&state->lock);
+			if (state->km.dying) {
+				next =3D 0;
+			} else {
+				state->km.dying =3D 1;
+				km_state_expired(state, 0, 0);
+				next =3D state->lft.hard_add_expires_seconds -
+					state->lft.soft_add_expires_seconds;
+			}
+			state->km.state =3D XFRM_STATE_EXPIRED;
+			tasklet_hrtimer_start(&state->mtimer, ktime_set(next, 0), HRTIMER_M=
ODE_REL);
+			spin_unlock_bh(&state->lock);
+			xfrm_state_put(state);
+			spin_lock_bh(&xfrm_state_lock);
+		}
+		spin_unlock_bh(&xfrm_state_lock);
+	}
+	rtnl_unlock();
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block clock_change_notifier =3D {
+	.notifier_call =3D clock_change_callback,
+};
+
  int __net_init xfrm_state_init(struct net *net)
  {
  	unsigned int sz;
@@ -2026,6 +2068,7 @@ int __net_init xfrm_state_init(struct net *net)
  	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
  	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
  	init_waitqueue_head(&net->xfrm.km_waitq);
+	register_clock_change_notifier(&clock_change_notifier);
  	return 0;

  out_byspi:
@@ -2057,6 +2100,7 @@ void xfrm_state_fini(struct net *net)
  	xfrm_hash_free(net->xfrm.state_bysrc, sz);
  	WARN_ON(!hlist_empty(net->xfrm.state_bydst));
  	xfrm_hash_free(net->xfrm.state_bydst, sz);
+	unregister_clock_change_notifier(&clock_change_notifier);
  }

  #ifdef CONFIG_AUDITSYSCALL
--=20
1.7.9.5


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
