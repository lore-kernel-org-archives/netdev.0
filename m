From: "Benjamin Li" <benli@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Mon, 1 Mar 2010 17:26:10 -0800
Message-ID: <1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com>
References: <20091229084929.54912c0c@pluto.restena.lu>
 <1262077540.12520.4.camel@localhost>
 <20091229145403.39f82773@pluto.restena.lu>
 <1262149691.2788.63.camel@localhost>
 <20100219091034.5fbb0165@pluto.restena.lu>
 <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
 <20100223131508.4c6cb866@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDEV <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Bruno =?ISO-8859-1?Q?Pr=E9mont?=" <bonbons@linux-vserver.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100223131508.4c6cb866@neptune.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bruno,

On Tue, 2010-02-23 at 04:15 -0800, Bruno Pr=E9mont wrote:
> Hi Benjamin,
>=20
> On Fri, 19 February 2010 "Benjamin Li" <benli@broadcom.com> wrote:
> > >From your logs it looks like the device came up using MSI, but in =
the
> > MSI-X poll routine was being called:
> >=20
> > [    9.836673] bnx2: eth0: using MSI
> > ...
> >=20
> > [  134.643459]  [<ffffffffa004019e>] bnx2_poll_msix+0x3e/0xd0 [bnx2=
]
> > [  134.643465]  [<ffffffff8135bcd1>] netpoll_poll+0xe1/0x3c0
> >=20
> > which is incorrect.  If we are in MSI mode, the bnx2_poll() routine
> > should be used.
> >=20
> > I think what is going on here is that during the bnx2x driver
> > initialization the current bnx2 driver adds all possible NAPI
> > structures that map to all the hardware vectors (BNX2_MAX_MSIX_VEC=3D=
9)
> > to the NAPI list in the net_device structure regardless if they are
> > used or not (Seen in drivers/net/bnx2.c:bnx2_init_napi()).  This ca=
n
> > cause uninitialized NAPI structures to be placed on the napi_list.
> > Because this device is in MSI mode, only 1 vector is initialized.
> > Now, the problem is triggered when net/core/netpoll.c:poll_napi() i=
s
> > called. This is because this routine will run through the entire
> > napi_list calling all the poll routines.  In your particular case, =
it
> > is calling the poll routine on an uninitialized vector causing the
> > kernel panic.
> >=20
> > Please try the patch below to see if it solves your problem.  Note,
> > this only have been compile tested and tested against basic traffic
> > runs. Unfortunately, I could not reproduce the kernel panic with th=
e
> > instructions below to verify the patch.
> >=20
> > Thanks again for all your help in helping us track this down.
>=20
> I applied the patch today and tried to reproduce with my showcases.
>=20
> Seems that it's harder to trigger now but I still end up being able t=
o
> crash the box. Don't know if it's the same cause or not (could also
> be the tcp-retransmit ghost)...
>=20
> This time I had to run a few paralell scp's (8Mb/s each) to the box a=
nd=20
> 'echo t > /proc/sysrq-trigger' multiple times via ssh session for it =
to
> happen. It didn't trigger with by netbomb though I will try some more
> and see)
>=20
> I don't know if it's the same reason or not (hopefully something
> reached disk as serial console is dead and pings are not
> answered anymore.
> It's probably some printk/bug/warn that triggers in network stack and
> deadlocks with netconsole.

Thanks for trying the patch.  I still haven't been able to reproduce
what you are seeing here.  I am able to run scp and 'echo t
> /proc/sysrq-trigger' multiple times.  I was wondering if you had any
success reproducing the problem with a stack trace?

Thanks again.

-Ben

>=20
> Regards,
> Bruno
>=20
