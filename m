From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [v3 PATCH 1/2] bonding: sync netpoll code with bridge
Date: Wed, 15 Dec 2010 06:59:55 -0500
Message-ID: <20101215115955.GA12559@hmsreliant.think-freely.org>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain>
 <20101208135746.GD11454@hmsreliant.think-freely.org>
 <4D008643.5040500@redhat.com>
 <4D089DEA.2060803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D089DEA.2060803@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 15, 2010 at 06:52:26PM +0800, Cong Wang wrote:
> =E4=BA=8E 2010=E5=B9=B412=E6=9C=8809=E6=97=A5 15:33, Cong Wang =E5=86=
=99=E9=81=93:
> >On 12/08/10 21:57, Neil Horman wrote:
> >>On Wed, Dec 08, 2010 at 02:52:08AM -0500, Amerigo Wang wrote:
> >>>-    bond_for_each_slave(bond, slave, i) {
> >>>-        if ((slave->dev->priv_flags&  IFF_DISABLE_NETPOLL) ||
> >>>-            !slave->dev->netdev_ops->ndo_poll_controller)
> >>>-            ret =3D false;
> >>>+    np =3D kmalloc(sizeof(*np), GFP_KERNEL);
> >>>+    err =3D -ENOMEM;
> >>>+    if (!np)
> >>>+        goto out;
> >>>+
> >>>+    np->dev =3D slave->dev;
> >>>+    err =3D __netpoll_setup(np);
> >>Setting up our own netpoll instance on each slave worries me a bit.=
  The
> >>implication here is that, by doing so, some frames will get entirel=
y processed
> >>by the slave.  Most notably arp frames.  That means anything that g=
ets queued up
> >>to the arp_tx queue in __netpoll_rx will get processed during that =
poll event,
> >>and responded to with the mac of the slave device, rather than with=
 the mac of
> >>the bond device, which isn't always what you want.  I think if you =
go with this
> >>route, you'll need to add code to netpoll_poll_dev, right before th=
e call to
> >>service_arp_queue, to check if IFF_SLAVE is set in priv_flags, and =
move the list
> >>to the master device, or some such.
> >
> >
> >Good point! Will fix i
>=20
> Hi, Neil,
>=20
> I think we should do that in bond_poll_controller() rather than netpo=
ll_poll_dev(),
> right? Since this is bond-specific. Does moving all arp_tx of slaves =
to their bond
> address your concern?
>=20
Don't think that will work, because, since your using multiple netpoll =
instances
here, the slaves arp_tx queue will get serviced on the return from the =
slaves
netpoll_poll_dev call, prior to returning to the bond_poll_controller c=
all.  In
other words, bond_poll_controller won't ever see any frames on the slav=
es arp_tx
queue to migrate, since they will have already been responded to by the=
 slave
directly.
Neil

> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
