From: Andrew Lutomirski <amluto@gmail.com>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Sat, 11 Apr 2009 11:46:00 -0400
Message-ID: <cb0375e10904110846k53bd5edbvb9fc9f6ff43bc97c@mail.gmail.com>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
	 <20090404.170539.148727646.davem@davemloft.net>
	 <cb0375e10904042100o1a203512l593021ee66cb591d@mail.gmail.com>
	 <alpine.WNT.2.00.0904091128270.6048@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:62984 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbZDKPqC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 11:46:02 -0400
In-Reply-To: <alpine.WNT.2.00.0904091128270.6048@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 9, 2009 at 8:48 PM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
>
> does this patch also fix the issue?

Yes.

2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN qlen 1000

Tested-by: Andy Lutomirski <amluto@gmail.com>

The link operational states are still funny, though:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
3: wmaster0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast state UNKNOWN qlen 1000

It looks like all interfaces that don't call netif_carrier_down after
registration end up in UNKNOWN until something happens.  The case of
carrier_on but UNKNOWN doesn't seem to confuse my userspace, but it's
still odd.

--Andy

>
> =3D=3D=3D=3D=3D begin =3D=3D=3D=3D=3D
>
> e1000e: indicate link down at load
>
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
> same kind of patch as e1000, let driver explicitly push link state
> once link comes up.
>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
>
> =A0drivers/net/e1000e/netdev.c | =A0 =A06 ++----
> =A01 files changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index fb78278..6a0411e 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -3072,6 +3072,8 @@ static int e1000_open(struct net_device *netdev=
)
> =A0 =A0 =A0 =A0if (test_bit(__E1000_TESTING, &adapter->state))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EBUSY;
>
> + =A0 =A0 =A0 netif_carrier_off(netdev);
> +
> =A0 =A0 =A0 =A0/* allocate transmit descriptors */
> =A0 =A0 =A0 =A0err =3D e1000e_setup_tx_resources(adapter);
> =A0 =A0 =A0 =A0if (err)
> @@ -5006,10 +5008,6 @@ static int __devinit e1000_probe(struct pci_de=
v *pdev,
> =A0 =A0 =A0 =A0if (!(adapter->flags & FLAG_HAS_AMT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e1000_get_hw_control(adapter);
>
> - =A0 =A0 =A0 /* tell the stack to leave us alone until e1000_open() =
is called */
> - =A0 =A0 =A0 netif_carrier_off(netdev);
> - =A0 =A0 =A0 netif_tx_stop_all_queues(netdev);
> -
> =A0 =A0 =A0 =A0strcpy(netdev->name, "eth%d");
> =A0 =A0 =A0 =A0err =3D register_netdev(netdev);
> =A0 =A0 =A0 =A0if (err)
>
