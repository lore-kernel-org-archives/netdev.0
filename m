From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [PATCH] ipv4 : igmp : optimize timer modify logic in
 igmp_mod_timer()
Date: Wed, 23 Nov 2011 23:44:36 +0800
Message-ID: <1322063076.6253.1.camel@barry.pixelworks.com>
References: <1322062004-9742-1-git-send-email-mypopydev@gmail.com>
	 <1322062966.17693.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37764 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab1KWPpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 10:45:25 -0500
Received: by iage36 with SMTP id e36so1736560iag.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 07:45:24 -0800 (PST)
In-Reply-To: <1322062966.17693.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-23 at 16:42 +0100, Eric Dumazet wrote:
> Le mercredi 23 novembre 2011 =C3=A0 23:26 +0800, Jun Zhao a =C3=A9cri=
t :
> > When timer is pending and expires less-than-or-equal-to new delay,
> > we need not used del_timer()/add_timer().
> >=20
> > Signed-off-by: Jun Zhao <mypopydev@gmail.com>
> > ---
> >  net/ipv4/igmp.c |   12 ++++++------
> >  1 files changed, 6 insertions(+), 6 deletions(-)
> >=20
> > diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> > index c7472ef..50d06c5 100644
> > --- a/net/ipv4/igmp.c
> > +++ b/net/ipv4/igmp.c
> > @@ -215,14 +215,14 @@ static void igmp_mod_timer(struct ip_mc_list =
*im, int max_delay)
> >  {
> >  	spin_lock_bh(&im->lock);
> >  	im->unsolicit_count =3D 0;
> > -	if (del_timer(&im->timer)) {
> > -		if ((long)(im->timer.expires-jiffies) < max_delay) {
> > -			add_timer(&im->timer);
> > -			im->tm_running =3D 1;
> > -			spin_unlock_bh(&im->lock);
> > +	if (timer_pending(&im->timer)) {
> > +		if (time_before_eq(im->timer.expires, (jiffies + max_delay))) {
> > +			spin_lock_bh(&im->lock);
>=20
> And you actually tested this patch ?

Sorry for this mistake. :(.  spin_lock_bh -> spin_unlock_bh

>=20
> >  			return;
> > +		} else {
> > +			del_timer(&im->timer);
> > +			atomic_dec(&im->refcnt);
> >  		}
> > -		atomic_dec(&im->refcnt);
> >  	}
> >  	igmp_start_timer(im, max_delay);
> >  	spin_unlock_bh(&im->lock);
>=20
>=20
> Not sure why you want to optimize this very rare function call, riski=
ng
> adding bugs in it.
>=20
>=20
>=20
