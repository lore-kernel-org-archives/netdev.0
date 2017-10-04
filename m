From: Greg Ungerer <gerg@linux-m68k.org>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: rework in-chip bridging
Date: Wed, 4 Oct 2017 16:20:12 +1000
Message-ID: <ab86ad59-06af-b4ab-0bc6-dace73f04ef0@linux-m68k.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------F90371E04223B075E1B7054B"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out8.external.iinet.net.au ([203.59.1.225]:19205
        "EHLO icp-osb-irony-out8.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750866AbdJDG3q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 02:29:46 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------F90371E04223B075E1B7054B
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi Vivien,

On Wed, Mar 29, 2017 at 04:30:16PM -0400, Vivien Didelot wrote:
> All ports -- internal and external, for chips featuring a PVT -- have a
> mask restricting to which internal ports a frame is allowed to egress.
> 
> Now that DSA exposes the number of ports and their bridge devices, it is
> possible to extract the code generating the VLAN map and make it generic
> so that it can be shared later with the cross-chip bridging code.

This patch changes the behavior of interfaces on startup if they are
not part of a bridge.

I have a board with a Marvell 6350 switch with a device tree that sets
up the 5 ports as lan1, lan2, lan3, lan4, wan. With kernels before
this patch (so linux-4.12 and older) after system startup I could do:

  ifconfig lan1 192.168.0.1

And then ping out that interface with no problems.

After this patch is applied (effects linux-4.13 and newer) then the
ping fails:

  PING 192.168.0.22 (192.168.0.22) 56(84) bytes of data.
  From 192.168.0.1 icmp_seq=1 Destination Host Unreachable
  From 192.168.0.1 icmp_seq=2 Destination Host Unreachable
  From 192.168.0.1 icmp_seq=3 Destination Host Unreachable

If I incorporate an interface into a bridge then it all works ok.
So simply:

  brctl addbr br0
  brctl addif br0 lan1
  ifconfig lan1 up
  ifconfig br0 192.168.0.1

Then pings out work as expected. And if I now remove that lan1
interface from the bridge and use it alone again then it will
now work ok:

  ifconfig br0 down
  brctl delif br0 lan1
  ifconfig lan1 192.168.0.1

And that now pings ok.

I fixed this with the attached patch. It is probably not the correct
approach, but it does restore the older behavior.

What do you think?

Regards
Greg



> Signed-off-by: Vivien Didelot <vivien.dide...@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 53 ++++++++++++++++++++++++++--------------
>  1 file changed, 34 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index b114bf8e6a11..e5165831e8b5 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -1123,27 +1123,42 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int 
> port,
>         return err;
>  }
>  
> +static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
> +{
> +       struct dsa_switch *ds = NULL;
> +       struct net_device *br;
> +       u16 pvlan;
> +       int i;
> +
> +       if (dev < DSA_MAX_SWITCHES)
> +               ds = chip->ds->dst->ds[dev];
> +
> +       /* Prevent frames from unknown switch or port */
> +       if (!ds || port >= ds->num_ports)
> +               return 0;
> +
> +       /* Frames from DSA links and CPU ports can egress any local port */
> +       if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
> +               return mv88e6xxx_port_mask(chip);
> +
> +       br = ds->ports[port].bridge_dev;
> +       pvlan = 0;
> +
> +       /* Frames from user ports can egress any local DSA links and CPU ports,
> +        * as well as any local member of their bridge group.
> +        */
> +       for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
> +               if (dsa_is_cpu_port(chip->ds, i) ||
> +                   dsa_is_dsa_port(chip->ds, i) ||
> +                   (br && chip->ds->ports[i].bridge_dev == br))
> +                       pvlan |= BIT(i);
> +
> +       return pvlan;
> +}
> +
>  static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int 
> port)
>  {
> -       struct dsa_switch *ds = chip->ds;
> -       struct net_device *bridge = ds->ports[port].bridge_dev;
> -       u16 output_ports = 0;
> -       int i;
> -
> -       /* allow CPU port or DSA link(s) to send frames to every port */
> -       if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
> -               output_ports = ~0;
> -       } else {
> -               for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
> -                       /* allow sending frames to every group member */
> -                       if (bridge && ds->ports[i].bridge_dev == bridge)
> -                               output_ports |= BIT(i);
> -
> -                       /* allow sending frames to CPU port and DSA link(s) */
> -                       if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
> -                               output_ports |= BIT(i);
> -               }
> -       }
> +       u16 output_ports = mv88e6xxx_port_vlan(chip, chip->ds->index, port);
>  
>         /* prevent frames from going back out of the port they came in on */
>         output_ports &= ~BIT(port);
> -- 


--------------F90371E04223B075E1B7054B
Content-Type: text/x-patch;
 name="0001-linux-dsa-fix-first-use-port-breakage.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-linux-dsa-fix-first-use-port-breakage.patch"

>From d81c15dda9fd84895caa67e4c187ad0b6b33af1f Mon Sep 17 00:00:00 2001
From: Greg Ungerer <gerg@linux-m68k.org>
Date: Thu, 21 Sep 2017 13:35:35 +1000
Subject: [PATCH] net: dsa: mv88e6xxx: fix first-use port breakage

The very first time you configure a switch port for use - as a stand alone
port - the interface cannot pass packets. If you configure the interface
as part of a bridge it works. If you then remove it from the bridge and
again try to use it as a stand alone port it will now work.

Commit e5887a2a11094 ("net: dsa: mv88e6xxx: rework in-chip bridging")
changes the switch initialization code and introduces the different
behavior.

To fix I changed the initialization behavior to make it similar to the
older code for the case at system startup (before all data structures
associated with this switch device have been fully setup).

Signed-off-by: Greg Ungerer <gerg@linux-m68k.org>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 929b62c..38527e0 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -911,8 +911,11 @@ static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
 	u16 pvlan;
 	int i;
 
-	if (dev < DSA_MAX_SWITCHES)
+	if (dev < DSA_MAX_SWITCHES) {
 		ds = chip->ds->dst->ds[dev];
+		if (ds == NULL)
+			ds = chip->ds;
+	}
 
 	/* Prevent frames from unknown switch or port */
 	if (!ds || port >= ds->num_ports)
-- 
1.9.1


--------------F90371E04223B075E1B7054B--
