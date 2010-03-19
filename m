From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: dev_getfirstbyhwtype() optimization
Date: Fri, 19 Mar 2010 04:54:07 -0700
Message-ID: <20100319115407.GG2894@linux.vnet.ibm.com>
References: <1268947645.2894.166.camel@edumazet-laptop>
 <20100319023256.GD2894@linux.vnet.ibm.com>
 <1268975642.2894.218.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:43853 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341Ab0CSLyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 07:54:11 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2JBpKni023361
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 07:51:20 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2JBs9cw1093694
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 07:54:09 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2JBs8ml023272
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 07:54:08 -0400
Content-Disposition: inline
In-Reply-To: <1268975642.2894.218.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 06:14:02AM +0100, Eric Dumazet wrote:
> Le jeudi 18 mars 2010 =E0 19:32 -0700, Paul E. McKenney a =E9crit :
> > On Thu, Mar 18, 2010 at 10:27:25PM +0100, Eric Dumazet wrote:
> > > Use RCU to avoid RTNL use in dev_getfirstbyhwtype()
> > >=20
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > ---
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 17b1686..0f2e9fc 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -772,14 +772,17 @@ EXPORT_SYMBOL(__dev_getfirstbyhwtype);
> > >=20
> > >  struct net_device *dev_getfirstbyhwtype(struct net *net, unsigne=
d short type)
> > >  {
> > > -	struct net_device *dev;
> > > +	struct net_device *dev, *ret =3D NULL;
> > >=20
> > > -	rtnl_lock();
> > > -	dev =3D __dev_getfirstbyhwtype(net, type);
> > > -	if (dev)
> > > -		dev_hold(dev);
> > > -	rtnl_unlock();
> > > -	return dev;
> > > +	rcu_read_lock();
> > > +	for_each_netdev_rcu(net, dev)
> > > +		if (dev->type =3D=3D type) {
> > > +			dev_hold(dev);
> > > +			ret =3D dev;
> > > +			break;
> > > +		}
> > > +	rcu_read_unlock();
> > > +	return ret;
> >=20
> > Looks good, but I don't understand how it helps to introduce the
> > local variable "ret".
> >=20
>=20
> Thanks for reviewing Paul !
>=20
> Not only it helps, its necessary :)
>=20
> for_each_netdev_rcu(net, dev) {
> 	if (cond) {
> 	   dev_hold(dev);
> 	   break;
> 	}
> }
> makes no guarantee dev is NULL if we hit the list end :
>=20
>=20
> /**
>  * list_for_each_entry_rcu      -       iterate over rcu list of give=
n type
>  * @pos:        the type * to use as a loop cursor.
>  * @head:       the head for your list.
>  * @member:     the name of the list_struct within the struct.
>  *
>  * This list-traversal primitive may safely run concurrently with
>  * the _rcu list-mutation primitives such as list_add_rcu()
>  * as long as the traversal is guarded by rcu_read_lock().
>  */
> #define list_for_each_entry_rcu(pos, head, member) \
>         for (pos =3D list_entry_rcu((head)->next, typeof(*pos), membe=
r); \
>                 prefetch(pos->member.next), &pos->member !=3D (head);=
 \
>                 pos =3D list_entry_rcu(pos->member.next, typeof(*pos)=
, member))

Right!  Got it, thank you!

							Thanx, Paul
