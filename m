From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Mon, 9 Jan 2017 08:32:36 +0100
Message-ID: <20170109073236.GA1862@nanopsycho>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Jan 09, 2017 at 12:15:52AM CET, vivien.didelot@savoirfairelinux.com wrote:
>In the new DTS bindings for DSA (dsa2), the "ethernet" and "link"
>phandles are respectively mandatory and exclusive to CPU port and DSA
>link device tree nodes.
>
>Simplify dsa2.c a bit by checking the presence of such phandle instead
>of checking the redundant "label" property.
>
>Then the Linux philosophy for Ethernet switch ports is to expose them to
>userspace as standard NICs by default. Thus use the standard enumerated
>"eth%d" device name if no "label" property is provided for a user port.
>This allows to save DTS files from subjective net device names.
>
>Here's an example on a ZII Dev Rev B board without "label" properties:
>
>    # ip link | grep ': ' | cut -d: -f2
>     lo
>     eth0
>     eth1
>     eth2@eth1
>     eth3@eth1
>     eth4@eth1
>     eth5@eth1
>     eth6@eth1
>     eth7@eth1
>     eth8@eth1
>     eth9@eth1
>     eth10@eth1
>     eth11@eth1
>     eth12@eth1
>
>If one wants to rename an interface, udev rules can be used as usual, as
>suggested in the switchdev documentation:
>
>    # cat /etc/udev/rules.d/90-net-dsa.rules
>    SUBSYSTEM=="net", ACTION=="add", ENV{DEVTYPE}=="dsa", NAME="sw$attr{phys_switch_id}p$attr{phys_port_id}"
>
>    # ip link | awk '/@eth/ { split($2,a,"@"); print a[1]; }'
>    sw00000000p00
>    sw00000000p01
>    sw00000000p02
>    sw01000000p00
>    sw01000000p01
>    sw01000000p02
>    sw02000000p00
>    sw02000000p01
>    sw02000000p02
>    sw02000000p03
>    sw02000000p04
>
>Until the printing of netdev_phys_item_id structures is fixed in
>net/core/net-sysfs.c, an external helper can be used like this:
>
>    # cat /etc/udev/rules.d/90-net-dsa.rules
>    SUBSYSTEM=="net", ACTION=="add", ENV{DEVTYPE}=="dsa", PROGRAM="/lib/udev/dsanitizer $attr{phys_switch_id} $attr{phys_port_id}", NAME="$result"

I know this is kind of confusing, but phys_port_id is to be used to
indicate same physical port that is shared by multiple netdevices- for
example sr-iov usecase. For switchdev usecase, you should use
phys_port_name.

I will add some documentation to kernel regarding this. But I see that
net/dsa/slave.c already implements .ndo_get_phys_port_id :(

I recently made changes in udev so it names the switch ports according
to phys_port_name, out of the box, without need for any rules:
https://github.com/systemd/systemd/pull/4506/commits/c960caa0c2a620fc506c6f0f7b6c40eeace48e4d

I guess that it should be enough for you to implement
ndo_get_phys_port_name.





>
>    # cat /lib/udev/dsanitizer
>    #!/bin/sh
>    echo $1 | sed -e 's,^0*,,' -e 's,0*$,,' | xargs printf sw%d
>    echo $2 | sed -e 's,^0*,,' | xargs printf p%d
>
>    # ip link | awk '/@eth/ { split($2,a,"@"); print a[1]; }'
>    sw0p0
>    sw0p1
>    sw0p2
>    sw1p0
>    sw1p1
>    sw1p2
>    sw2p0
>    sw2p1
>    sw2p2
>    sw2p3
>    sw2p4
>
>Of course the current behavior is unchanged, and the optional "label"
>property for user ports has precedence over the enumerated name.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>Acked-by: Uwe Kleine-König <uwe@kleine-koenig.org>
>---
> Documentation/devicetree/bindings/net/dsa/dsa.txt | 20 ++++++++-----------
> net/dsa/dsa2.c                                    | 24 ++++-------------------
> 2 files changed, 12 insertions(+), 32 deletions(-)
>
>diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
>index a4a570fb2494..cfe8f64eca4f 100644
>--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
>+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
>@@ -34,13 +34,9 @@ Required properties:
> 
> Each port children node must have the following mandatory properties:
> - reg			: Describes the port address in the switch
>-- label			: Describes the label associated with this port, which
>-                          will become the netdev name. Special labels are
>-			  "cpu" to indicate a CPU port and "dsa" to
>-			  indicate an uplink/downlink port between switches in
>-			  the cluster.
> 
>-A port labelled "dsa" has the following mandatory property:
>+An uplink/downlink port between switches in the cluster has the following
>+mandatory property:
> 
> - link			: Should be a list of phandles to other switch's DSA
> 			  port. This port is used as the outgoing port
>@@ -48,12 +44,17 @@ A port labelled "dsa" has the following mandatory property:
> 			  information must be given, not just the one hop
> 			  routes to neighbouring switches.
> 
>-A port labelled "cpu" has the following mandatory property:
>+A CPU port has the following mandatory property:
> 
> - ethernet		: Should be a phandle to a valid Ethernet device node.
>                           This host device is what the switch port is
> 			  connected to.
> 
>+A user port has the following optional property:
>+
>+- label			: Describes the label associated with this port, which
>+                          will become the netdev name.
>+
> Port child nodes may also contain the following optional standardised
> properties, described in binding documents:
> 
>@@ -107,7 +108,6 @@ linked into one DSA cluster.
> 
> 			switch0port5: port@5 {
> 				reg = <5>;
>-				label = "dsa";
> 				phy-mode = "rgmii-txid";
> 				link = <&switch1port6
> 					&switch2port9>;
>@@ -119,7 +119,6 @@ linked into one DSA cluster.
> 
> 			port@6 {
> 				reg = <6>;
>-				label = "cpu";
> 				ethernet = <&fec1>;
> 				fixed-link {
> 					speed = <100>;
>@@ -165,7 +164,6 @@ linked into one DSA cluster.
> 
> 			switch1port5: port@5 {
> 				reg = <5>;
>-				label = "dsa";
> 				link = <&switch2port9>;
> 				phy-mode = "rgmii-txid";
> 				fixed-link {
>@@ -176,7 +174,6 @@ linked into one DSA cluster.
> 
> 			switch1port6: port@6 {
> 				reg = <6>;
>-				label = "dsa";
> 				phy-mode = "rgmii-txid";
> 				link = <&switch0port5>;
> 				fixed-link {
>@@ -255,7 +252,6 @@ linked into one DSA cluster.
> 
> 			switch2port9: port@9 {
> 				reg = <9>;
>-				label = "dsa";
> 				phy-mode = "rgmii-txid";
> 				link = <&switch1port5
> 					&switch0port5>;
>diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
>index bad119cee2a3..9526bdf2a34a 100644
>--- a/net/dsa/dsa2.c
>+++ b/net/dsa/dsa2.c
>@@ -81,30 +81,12 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
> 
> static bool dsa_port_is_dsa(struct device_node *port)
> {
>-	const char *name;
>-
>-	name = of_get_property(port, "label", NULL);
>-	if (!name)
>-		return false;
>-
>-	if (!strcmp(name, "dsa"))
>-		return true;
>-
>-	return false;
>+	return !!of_parse_phandle(port, "link", 0);
> }
> 
> static bool dsa_port_is_cpu(struct device_node *port)
> {
>-	const char *name;
>-
>-	name = of_get_property(port, "label", NULL);
>-	if (!name)
>-		return false;
>-
>-	if (!strcmp(name, "cpu"))
>-		return true;
>-
>-	return false;
>+	return !!of_parse_phandle(port, "ethernet", 0);
> }
> 
> static bool dsa_ds_find_port(struct dsa_switch *ds,
>@@ -268,6 +250,8 @@ static int dsa_user_port_apply(struct device_node *port, u32 index,
> 	int err;
> 
> 	name = of_get_property(port, "label", NULL);
>+	if (!name)
>+		name = "eth%d";
> 
> 	err = dsa_slave_create(ds, ds->dev, index, name);
> 	if (err) {
>-- 
>2.11.0
>
