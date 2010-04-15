From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network multiqueue question
Date: Thu, 15 Apr 2010 20:41:50 +0200
Message-ID: <1271356910.16881.2909.camel@edumazet-laptop>
References: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com>
	 <1271353637.16881.2846.camel@edumazet-laptop>
	 <21433.1271354986@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "George B." <georgeb@gmail.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:52636 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755836Ab0DOSl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 14:41:59 -0400
Received: by bwz25 with SMTP id 25so1999402bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 11:41:57 -0700 (PDT)
In-Reply-To: <21433.1271354986@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 11:09 -0700, Jay Vosburgh a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> >Vlan is multiqueue aware, but bonding is not unfortunatly at this
> >moment.
> >
> >We could let it being 'multiqueue' (a patch was submitted by Oleg A.
> >Arkhangelsky a while ago), but bonding xmit routine needs to lock a
> >central lock, shared by all queues, so it wont be very efficient...
>=20
> 	The lock is a read lock, so theoretically it should be possible
> to enter the bonding transmit function on multiple CPUs at the same
> time.  The lock may thrash around, though.
>=20

Yes, and with 10Gb cards, this is a limiting factor, if you want to sen=
d
14 million packets per second ;)

read_lock() is one atomic op, dirtying cacheline
read_unlock() is one atomic op, dirtying cache line again (if contended=
)

in active-passive mode, RCU use should be really easy, given netdevices
are already RCU compatable. This way, each cpu only reads bonding state=
,
without any memory changes.


> >Since this bothers me a bit, I will probably work on this in a near
> >future. (adding real multiqueue capability and RCU to bonding fast
> >paths)
> >
> >Ref: http://permalink.gmane.org/gmane.linux.network/152987
>=20
> 	The question I have about it (and the above patch), is: what
> does multi-queue "awareness" really mean for a bonding device?  How d=
oes
> allocating a bunch of TX queues help, given that the determination of
> the transmitting device hasn't necessarily been made?
>=20

Well, it is a problem that was also taken into account with vlan, you
might take a look at this commit :

commit 669d3e0babb40018dd6e78f4093c13a2eac73866
Author: Vasu Dev <vasu.dev@intel.com>
Date:   Tue Mar 23 14:41:45 2010 +0000

    vlan: adds vlan_dev_select_queue
   =20
    This is required to correctly select vlan tx queue for a driver
    supporting multi tx queue with ndo_select_queue implemented since
    currently selected vlan tx queue is unaligned to selected queue by
    real net_devce ndo_select_queue.
   =20
    Unaligned vlan tx queue selection causes thrash with higher vlan
    tx lock contention for least fcoe traffic and wrong socket tx
    queue_mapping for ixgbe having ndo_select_queue implemented.
   =20
    -v2
   =20
    As per Eric Dumazet<eric.dumazet@gmail.com> comments, mirrored
    vlan net_device_ops to have them with and without
vlan_dev_select_queue
    and then select according to real dev ndo_select_queue present or
not
    for a vlan net_device. This is to completely skip
vlan_dev_select_queue
    calling for real net_device not supporting ndo_select_queue.
   =20
    Signed-off-by: Vasu Dev <vasu.dev@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


> 	I haven't had the chance to acquire some multi-queue network
> cards and check things out with bonding, so I'm not really sure how i=
t
> should work.  Should the bond look, from a multi-queue perspective, l=
ike
> the largest slave, or should it look like the sum of the slaves?  Som=
e
> of this is may be mode-specific, as well.
>=20




