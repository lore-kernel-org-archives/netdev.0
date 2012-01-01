From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bonding: fix error handling if slave is busy (v2)
Date: Sat, 31 Dec 2011 16:13:22 -0800
Message-ID: <20111231161322.40b16d69@nehalam.linuxnetplumber.net>
References: <20111230144023.371be015@nehalam.linuxnetplumber.net>
	<4EFF3419.4050504@gmail.com>
	<20111231152646.6f0f98fc@nehalam.linuxnetplumber.net>
	<4EFFA44E.10507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51130 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721Ab2AAANZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2011 19:13:25 -0500
In-Reply-To: <4EFFA44E.10507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 01 Jan 2012 01:09:50 +0100
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 01/01/2012 00:26, Stephen Hemminger a =E9crit :
> > If slave device already has a receive handler registered, then the
> > error unwind of bonding device enslave function is broken.
> >
> > The following will leave a pointer to freed memory in the slave
> > device list, causing a later kernel panic.
> > # modprobe dummy
> > # ip li add dummy0-1 link dummy0 type macvlan
> > # modprobe bonding
> > # echo +dummy0>/sys/class/net/bond0/bonding/slaves
> >
> > The fix is to detach the slave (which removes it from the list)
> > in the unwind path.
> >
> > Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>=20
> Thanks Stephen.
>=20
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

The locking in bond driver is a tangled web.

Would be cleaner to get rid of bond->lock altogether.
Slave add/delete should be protected by RTNL, and the lookup should
be converted to RCU.  The problem is that bonding driver implements
own form of circular list to handle round-robin etc.
