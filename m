From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] sfc: Own header for nic-specific sriov
 functions, single instance of netdev_ops and sriov removed from Falcon code
Date: Wed, 08 Apr 2015 12:57:05 -0700
Message-ID: <1428523025.25985.224.camel@edumazet-glaptop2.roam.corp.google.com>
References: <552539BA.6070707@solarflare.com>
	 <55253A2D.8090901@solarflare.com>
	 <1428522763.25985.222.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34192 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbbDHT5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 15:57:07 -0400
Received: by iget9 with SMTP id t9so35997461ige.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 12:57:06 -0700 (PDT)
In-Reply-To: <1428522763.25985.222.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-08 at 12:52 -0700, Eric Dumazet wrote:
> On Wed, 2015-04-08 at 15:24 +0100, Shradha Shah wrote:
> > By putting all the efx_{siena,ef10}_sriov_* declarations in
> > {siena,ef10}_sriov.h, ensure they cannot be called from nic-generic code.
> > Also fixes up an instance of this, where mcdi.c was calling
> > efx_siena_sriov_flr.
> > 
> > The single instance of netdev_ops should call general high level
> > functions that can then call something adapter specific in efx_nic_type.
> > We should only do adapter specialisation via efx_nic_type.
> > 
> > Removal of sriov functionality from the Falcon code means that tests
> > are needed for the presence of some callbacks.
> > 
> > Signed-off-by: Shradha Shah <sshah@solarflare.com>
> > ---
> >  drivers/net/ethernet/sfc/Makefile      |   2 +-
> >  drivers/net/ethernet/sfc/ef10.c        |   6 ++
> >  drivers/net/ethernet/sfc/ef10_sriov.h  |  56 +++++++++++++++++
> >  drivers/net/ethernet/sfc/efx.c         |  95 ++++++++++++----------------
> >  drivers/net/ethernet/sfc/efx.h         |   7 +++
> >  drivers/net/ethernet/sfc/falcon.c      |  10 ---
> >  drivers/net/ethernet/sfc/farch.c       |  48 +++++++-------
> >  drivers/net/ethernet/sfc/mcdi.c        |   4 +-
> >  drivers/net/ethernet/sfc/net_driver.h  |   8 +++
> >  drivers/net/ethernet/sfc/nic.h         | 111 ---------------------------------
> >  drivers/net/ethernet/sfc/siena.c       |   6 ++
> >  drivers/net/ethernet/sfc/siena_sriov.c |  53 +++++++++++++---
> >  drivers/net/ethernet/sfc/siena_sriov.h |  78 +++++++++++++++++++++++
> >  drivers/net/ethernet/sfc/sriov.c       |  64 +++++++++++++++++++
> >  drivers/net/ethernet/sfc/sriov.h       |  27 ++++++++
> >  15 files changed, 368 insertions(+), 207 deletions(-)
> >  create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.h
> >  create mode 100644 drivers/net/ethernet/sfc/siena_sriov.h
> >  create mode 100644 drivers/net/ethernet/sfc/sriov.c
> >  create mode 100644 drivers/net/ethernet/sfc/sriov.h
> > 
> > diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
> > index 3a83c0d..a08a789 100644
> > --- a/drivers/net/ethernet/sfc/Makefile
> > +++ b/drivers/net/ethernet/sfc/Makefile
> > @@ -3,6 +3,6 @@ sfc-y			+= efx.o nic.o farch.o falcon.o siena.o ef10.o tx.o \
> >  			   tenxpress.o txc43128_phy.o falcon_boards.o \
> >  			   mcdi.o mcdi_port.o mcdi_mon.o ptp.o
> >  sfc-$(CONFIG_SFC_MTD)	+= mtd.o
> > -sfc-$(CONFIG_SFC_SRIOV)	+= siena_sriov.o
> > +sfc-$(CONFIG_SFC_SRIOV)	+= sriov.o siena_sriov.o
> >  
> >  obj-$(CONFIG_SFC)	+= sfc.o
> > diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
> > index fbb6cfa..4dab1b9 100644
> > --- a/drivers/net/ethernet/sfc/ef10.c
> > +++ b/drivers/net/ethernet/sfc/ef10.c
> > @@ -15,6 +15,7 @@
> >  #include "nic.h"
> >  #include "workarounds.h"
> >  #include "selftest.h"
> > +#include "ef10_sriov.h"
> >  #include <linux/in.h>
> >  #include <linux/jhash.h>
> >  #include <linux/wait.h>
> > @@ -3694,6 +3695,11 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
> >  	.sriov_mac_address_changed = efx_ef10_sriov_mac_address_changed,
> >  	.sriov_wanted = efx_ef10_sriov_wanted,
> >  	.sriov_reset = efx_ef10_sriov_reset,
> > +	.sriov_flr = efx_ef10_sriov_flr,
> > +	.sriov_set_vf_mac = efx_ef10_sriov_set_vf_mac,
> > +	.sriov_set_vf_vlan = efx_ef10_sriov_set_vf_vlan,
> > +	.sriov_set_vf_spoofchk = efx_ef10_sriov_set_vf_spoofchk,
> > +	.sriov_get_vf_config = efx_ef10_sriov_get_vf_config,
> >  
> 
> Hmm...
> 
>   CC [M]  drivers/net/ethernet/sfc/qt202x_phy.o
> drivers/net/ethernet/sfc/siena.c:1008:22: error: 'efx_siena_sriov_set_vf_mac' undeclared here (not in a function)
> drivers/net/ethernet/sfc/siena.c:1009:23: error: 'efx_siena_sriov_set_vf_vlan' undeclared here (not in a function)
> drivers/net/ethernet/sfc/siena.c:1010:27: error: 'efx_siena_sriov_set_vf_spoofchk' undeclared here (not in a function)
> drivers/net/ethernet/sfc/siena.c:1011:25: error: 'efx_siena_sriov_get_vf_config' undeclared here (not in a function)
>   CC [M]  drivers/net/ethernet/sfc/mdio_10g.o
> make[5]: *** [drivers/net/ethernet/sfc/siena.o] Error 1
> make[5]: *** Waiting for unfinished jobs....
> drivers/net/ethernet/sfc/ef10.c:3700:22: error: 'efx_ef10_sriov_set_vf_mac' undeclared here (not in a function)
> drivers/net/ethernet/sfc/ef10.c:3701:23: error: 'efx_ef10_sriov_set_vf_vlan' undeclared here (not in a function)
> drivers/net/ethernet/sfc/ef10.c:3702:27: error: 'efx_ef10_sriov_set_vf_spoofchk' undeclared here (not in a function)
> drivers/net/ethernet/sfc/ef10.c:3703:25: error: 'efx_ef10_sriov_get_vf_config' undeclared here (not in a function)
> make[5]: *** [drivers/net/ethernet/sfc/ef10.o] Error 1
> 

Please test your driver with :

$ grep PCI_IOV .config
# CONFIG_PCI_IOV is not set
$ grep SFC_SRIOV .config
$ 
