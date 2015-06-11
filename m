From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] bridge: use either ndo VLAN ops or switchdev
 VLAN ops to install MASTER vlans
Date: Thu, 11 Jun 2015 12:39:19 -0700
Message-ID: <5579E3E7.30005@gmail.com>
References: <1434050122-26405-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, makita.toshiaki@lab.ntt.co.jp,
	roopa@cumulusnetworks.com, jhs@mojatatu.com,
	simon.horman@netronome.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33568 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbbFKTk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 15:40:29 -0400
Received: by qkhg32 with SMTP id g32so7600964qkh.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 12:40:28 -0700 (PDT)
In-Reply-To: <1434050122-26405-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/15 12:15, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> To maintain backward compatibility with the existing iproute2 "bridge vlan"
> command, let bridge's setlink/dellink handler call into either the port
> driver's 8021q ndo ops or the port driver's bridge_setlink/dellink ops.
> 
> This allows port driver to choose 8021q ops or the newer
> bridge_setlink/dellink ops when implementing VLAN add/del filtering on the
> device.  The iproute "bridge vlan" command does not need to be modified.
> 
> To summarize using the "bridge vlan" command examples, we have:
> 
> 1) bridge vlan add|del vid VID dev DEV
> 
> Here iproute2 sets MASTER flag.  Bridge's bridge_setlink/dellink is called.
> Vlan is set on bridge for port.  If port driver implements ndo 8021q ops,
> call those to port driver can install vlan filter on device.  Otherwise, if
> port driver implements bridge_setlink/dellink ops, call those to install
> vlan filter to device.  This option only works if port is bridged.
> 
> 2) bridge vlan add|del vid VID dev DEV master
> 
> Same as 1)
> 
> 3) bridge vlan add|del vid VID dev DEV self
> 
> Bridge's bridge_setlink/dellink isn't called.  Port driver's
> bridge_setlink/dellink is called, if implemented.  This option works if
> port is bridged or not.  If port is not bridged, a VLAN can still be
> added/deleted to device filter using this variant.
> 
> 4) bridge vlan add|del vid VID dev DEV master self
> 
> This is a combination of 1) and 3), but will only work if port is bridged.

Woah, I now realize how confused I was with how it is meant to be used,
still am actually.

> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---

[snip]

> +static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
> +			  u16 vid, u16 flags)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +	struct switchdev_obj vlan_obj = {
> +		.id = SWITCHDEV_OBJ_PORT_VLAN,
> +		.u.vlan = {
> +			.flags = flags,
> +			.vid_start = vid,
> +			.vid_end = vid,
> +		},
> +	};
> +	int err;
> +
> +	/* If driver uses VLAN ndo ops, use 8021q to install vid
> +	 * on device, otherwise try switchdev ops to install vid.
> +	 */
> +
> +	if (ops->ndo_vlan_rx_add_vid) {
> +		err = vlan_vid_add(dev, br->vlan_proto, vid);
> +	} else {

Do we need to be more restrictive here and make sure that we did not set
BRIDGE_VLAN_INFO_UNTAGGED or BRIDGE_VLAN_INFO_PVID for this vid since
the legacy 802.1q ndos do not make any distinction and just assume tagged?
-- 
Florian
