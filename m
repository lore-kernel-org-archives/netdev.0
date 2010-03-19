From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dev_getfirstbyhwtype() optimization
Date: Fri, 19 Mar 2010 06:14:02 +0100
Message-ID: <1268975642.2894.218.camel@edumazet-laptop>
References: <1268947645.2894.166.camel@edumazet-laptop>
	 <20100319023256.GD2894@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:41636 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab0CSFOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:14:09 -0400
Received: by bwz1 with SMTP id 1so2677357bwz.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:14:06 -0700 (PDT)
In-Reply-To: <20100319023256.GD2894@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 mars 2010 =C3=A0 19:32 -0700, Paul E. McKenney a =C3=A9crit=
 :
> On Thu, Mar 18, 2010 at 10:27:25PM +0100, Eric Dumazet wrote:
> > Use RCU to avoid RTNL use in dev_getfirstbyhwtype()
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 17b1686..0f2e9fc 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -772,14 +772,17 @@ EXPORT_SYMBOL(__dev_getfirstbyhwtype);
> >=20
> >  struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned =
short type)
> >  {
> > -	struct net_device *dev;
> > +	struct net_device *dev, *ret =3D NULL;
> >=20
> > -	rtnl_lock();
> > -	dev =3D __dev_getfirstbyhwtype(net, type);
> > -	if (dev)
> > -		dev_hold(dev);
> > -	rtnl_unlock();
> > -	return dev;
> > +	rcu_read_lock();
> > +	for_each_netdev_rcu(net, dev)
> > +		if (dev->type =3D=3D type) {
> > +			dev_hold(dev);
> > +			ret =3D dev;
> > +			break;
> > +		}
> > +	rcu_read_unlock();
> > +	return ret;
>=20
> Looks good, but I don't understand how it helps to introduce the
> local variable "ret".
>=20

Thanks for reviewing Paul !

Not only it helps, its necessary :)

for_each_netdev_rcu(net, dev) {
	if (cond) {
	   dev_hold(dev);
	   break;
	}
}
makes no guarantee dev is NULL if we hit the list end :


/**
 * list_for_each_entry_rcu      -       iterate over rcu list of given =
type
 * @pos:        the type * to use as a loop cursor.
 * @head:       the head for your list.
 * @member:     the name of the list_struct within the struct.
 *
 * This list-traversal primitive may safely run concurrently with
 * the _rcu list-mutation primitives such as list_add_rcu()
 * as long as the traversal is guarded by rcu_read_lock().
 */
#define list_for_each_entry_rcu(pos, head, member) \
        for (pos =3D list_entry_rcu((head)->next, typeof(*pos), member)=
; \
                prefetch(pos->member.next), &pos->member !=3D (head); \
                pos =3D list_entry_rcu(pos->member.next, typeof(*pos), =
member))



