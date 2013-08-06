From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: Delete hold_timer when destroy policy
Date: Tue, 6 Aug 2013 10:05:06 +0200
Message-ID: <20130806080506.GF25511@secunet.com>
References: <1375351716-3265-1-git-send-email-fan.du@windriver.com>
 <20130801120146.GD25511@secunet.com>
 <51FB09C0.7090807@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39651 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608Ab3HFIFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 04:05:13 -0400
Content-Disposition: inline
In-Reply-To: <51FB09C0.7090807@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 02, 2013 at 09:22:08AM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B408=E6=9C=8801=E6=97=A5 20:01, Steffen Klassert wrote:
> >On Thu, Aug 01, 2013 at 06:08:36PM +0800, Fan Du wrote:
> >>Both policy timer and hold_timer need to be deleted when destroy po=
licy
> >>Bad mood today, maybe I'm wrong about this...
> >>
> >>Signed-off-by: Fan Du<fan.du@windriver.com>
> >>---
> >>  net/xfrm/xfrm_policy.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >>diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> >>index d8da6b8..f7078eb 100644
> >>--- a/net/xfrm/xfrm_policy.c
> >>+++ b/net/xfrm/xfrm_policy.c
> >>@@ -308,7 +308,7 @@ void xfrm_policy_destroy(struct xfrm_policy *po=
licy)
> >>  {
> >>  	BUG_ON(!policy->walk.dead);
> >>
> >>-	if (del_timer(&policy->timer))
> >>+	if (del_timer(&policy->timer) || del_timer(&policy->polq.hold_tim=
er))
> >>  		BUG();
> >>
> >
> >The timers should be already deleted when xfrm_policy_destroy() is
> >called. This is just to check if that really happened and to
> >catch this bug if not. So it's not a bug fix, it just helps to
> >catch a potential bug. I'll consider to take this into ipsec-next
> >after some testing.
> >
>=20
> On the contrary, please take a look at callers of xfrm_policy_destroy=
=2E
> Code flow is as below:
>=20
>   xfrm_policy_alloc() /* setup timer/hold_timer here */ (1)
>=20
>   /* do something with this policy, insert or something else */
>=20
>   goto err; /* bail out if bad things happens */
>=20
>   return ok
>=20
> err:
>   xfrm_policy_destroy() /*So both timers in (1) need to be deleted */
>=20

setup_timer() does not arm the timer, it just initializes the timer.
So the timer is not pending when xfrm_policy_destroy() is called
on error. The del_timer() in xfrm_policy_destroy() is really just
to catch a bug. That's also the reason why we call BUG() if we
delete a pending timer.

Anyway, applied to ipsec-next.

Thanks!
