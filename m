From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v2 2/2] be2net: csum, tso and rss steering
 offload support for VxLAN
Date: Mon, 24 Mar 2014 07:38:03 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C2A416325@CMEXMB1.ad.emulex.com>
References: <1395640827-23142-1-git-send-email-sathya.perla@emulex.com>
	<1395640827-23142-3-git-send-email-sathya.perla@emulex.com>
 <CAJZOPZJ9zOBwnqH5XpdonYawu_Mu0A+hD0r4-TRMT5DSsHx=zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:37057 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaCXHiE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 03:38:04 -0400
In-Reply-To: <CAJZOPZJ9zOBwnqH5XpdonYawu_Mu0A+hD0r4-TRMT5DSsHx=zQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
> 
> On Mon, Mar 24, 2014 at 8:00 AM, Sathya Perla <sathya.perla@emulex.com> wrote:
> > This patch mainly implements the add/del_vxlan_port() methods by invoking
> > the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.
> 
> [...]
> > +static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
> > +                             __be16 port)
> > +{
> > +       struct be_adapter *adapter = netdev_priv(netdev);
> > +       struct device *dev = &adapter->pdev->dev;
> > +       int status;
> > +
> > +       if (lancer_chip(adapter) || BEx_chip(adapter))
> > +               return;
> > +
> > +       if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
> > +               dev_warn(dev, "Cannot add UDP port %d for VxLAN offloads\n",
> > +                        be16_to_cpu(port));
> > +               dev_info(dev,
> > +                        "Only one UDP port supported for VxLAN offloads\n");
> > +               return;
> > +       }
> > +
> > +       status = be_cmd_manage_iface(adapter, adapter->if_handle,
> > +                                    OP_CONVERT_NORMAL_TO_TUNNEL);
> > +       if (status) {
> > +               dev_warn(dev, "Failed to convert normal interface to tunnel\n");
> > +               goto err;
> > +       }
> > +
> > +       status = be_cmd_set_vxlan_port(adapter, port);
> 
> so the flow be_cmd_set_vxlan_port --> be_cmd_set_profile_config goes
> to sleep, right? well, it's wrong doing it from  here since the ndo is
> called from the vxlan driver under spinlock, you should easily get a
> nice stack trace if you test your code with spinlock/atomic debugging

be_cmd_set_profile_config() does not sleep. 
But, I guess it could be made to sleep() in the future due to a design change...
Just to future-proof this code, I could fix this up with some workqueue processing..

thanks,
-Sathya
