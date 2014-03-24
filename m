From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] be2net: csum, tso and rss steering
 offload support for VxLAN
Date: Mon, 24 Mar 2014 08:52:07 +0200
Message-ID: <CAJZOPZJ9zOBwnqH5XpdonYawu_Mu0A+hD0r4-TRMT5DSsHx=zQ@mail.gmail.com>
References: <1395640827-23142-1-git-send-email-sathya.perla@emulex.com>
	<1395640827-23142-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:42138 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbaCXGwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 02:52:07 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so5015210pbc.41
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 23:52:07 -0700 (PDT)
In-Reply-To: <1395640827-23142-3-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 8:00 AM, Sathya Perla <sathya.perla@emulex.com> wrote:
> This patch mainly implements the add/del_vxlan_port() methods by invoking
> the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.

[...]
> +static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
> +                             __be16 port)
> +{
> +       struct be_adapter *adapter = netdev_priv(netdev);
> +       struct device *dev = &adapter->pdev->dev;
> +       int status;
> +
> +       if (lancer_chip(adapter) || BEx_chip(adapter))
> +               return;
> +
> +       if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
> +               dev_warn(dev, "Cannot add UDP port %d for VxLAN offloads\n",
> +                        be16_to_cpu(port));
> +               dev_info(dev,
> +                        "Only one UDP port supported for VxLAN offloads\n");
> +               return;
> +       }
> +
> +       status = be_cmd_manage_iface(adapter, adapter->if_handle,
> +                                    OP_CONVERT_NORMAL_TO_TUNNEL);
> +       if (status) {
> +               dev_warn(dev, "Failed to convert normal interface to tunnel\n");
> +               goto err;
> +       }
> +
> +       status = be_cmd_set_vxlan_port(adapter, port);

so the flow be_cmd_set_vxlan_port --> be_cmd_set_profile_config goes
to sleep, right? well, it's wrong doing it from  here since the ndo is
called from the vxlan driver under spinlock, you should easily get a
nice stack trace if you test your code with spinlock/atomic debugging
