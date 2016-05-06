From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net v3] vlan: Propagate MAC address to VLANs
Date: Fri, 6 May 2016 10:02:55 -0700
Message-ID: <CAKgT0UeOhYkajP7PJo15cvTJsiEo_Z0OD7Kf=z1iXVRWQhkqaQ@mail.gmail.com>
References: <572C99FB.1060905@brocade.com>
	<572C9B9E.1000304@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35497 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704AbcEFRC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 13:02:56 -0400
Received: by mail-ig0-f169.google.com with SMTP id bi2so51418436igb.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 10:02:55 -0700 (PDT)
In-Reply-To: <572C9B9E.1000304@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 6:26 AM, Mike Manning <mmanning@brocade.com> wrote:
> The MAC address of the physical interface is only copied to the VLAN
> when it is first created, resulting in an inconsistency after MAC
> address changes of only newly created VLANs having an up-to-date MAC.
>
> The VLANs should continue inheriting the MAC address of the physical
> interface, unless explicitly changed to be different from this.
> This allows IPv6 EUI64 addresses for the VLAN to reflect any changes
> to the MAC of the physical interface and thus for DAD to behave as
> expected.
>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  include/linux/if_vlan.h |    2 ++
>  net/8021q/vlan.c        |   17 +++++++++++------
>  net/8021q/vlan_dev.c    |   13 ++++++++++---
>  3 files changed, 23 insertions(+), 9 deletions(-)
>
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -138,6 +138,7 @@ struct netpoll;
>   *     @flags: device flags
>   *     @real_dev: underlying netdevice
>   *     @real_dev_addr: address of underlying netdevice
> + *     @addr_assign_type: address assignment type
>   *     @dent: proc dir entry
>   *     @vlan_pcpu_stats: ptr to percpu rx stats
>   */
> @@ -153,6 +154,7 @@ struct vlan_dev_priv {
>
>         struct net_device                       *real_dev;
>         unsigned char                           real_dev_addr[ETH_ALEN];
> +       unsigned char                           addr_assign_type;
>
>         struct proc_dir_entry                   *dent;
>         struct vlan_pcpu_stats __percpu         *vlan_pcpu_stats;

Please don't start adding new members to structures when it already
exists in the net_device.  If anything you should be able to drop
read_dev_addr if you do this correctly because you shouldn't need to
clone the lower dev address to watch for changes.  All you will need
to do is watch NET_ADDR_STOLEN.

> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -291,6 +291,15 @@ static void vlan_sync_address(struct net
>         if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
>                 return;
>
> +       /* vlan continues to inherit address of parent interface */
> +       if (vlan->addr_assign_type == NET_ADDR_STOLEN) {
> +               ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
> +               goto out;
> +       }
> +
> +       if (!(vlandev->flags & IFF_UP))
> +               goto out;
> +
>         /* vlan address was different from the old address and is equal to
>          * the new address */
>         if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
> @@ -303,6 +312,7 @@ static void vlan_sync_address(struct net
>             !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
>                 dev_uc_add(dev, vlandev->dev_addr);
>
> +out:
>         ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
>  }
>
> @@ -389,13 +399,8 @@ static int vlan_device_event(struct noti
>
>         case NETDEV_CHANGEADDR:
>                 /* Adjust unicast filters on underlying device */
> -               vlan_group_for_each_dev(grp, i, vlandev) {
> -                       flgs = vlandev->flags;
> -                       if (!(flgs & IFF_UP))
> -                               continue;
> -
> +               vlan_group_for_each_dev(grp, i, vlandev)
>                         vlan_sync_address(dev, vlandev);
> -               }
>                 break;
>
>         case NETDEV_CHANGEMTU:

So all of this is far more complicated than it needs to be.  If
NET_ADDR_STOLEN is set you have to follow the lower device MAC
address, otherwise you maintain your own address and have to hold a
reference to it on the lower device.

You should also be able to maintain the current logic of not updating
a down interface on an address change.  You don't need to update a
stolen MAC address until the open routine is called for the interface.

> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -315,17 +315,21 @@ static int vlan_dev_stop(struct net_devi
>
>  static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
>  {
> -       struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
> +       struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
> +       struct net_device *real_dev = vlan->real_dev;
>         struct sockaddr *addr = p;
> +       bool is_real_addr;
>         int err;
>
>         if (!is_valid_ether_addr(addr->sa_data))
>                 return -EADDRNOTAVAIL;
>
> +       is_real_addr = ether_addr_equal(addr->sa_data, real_dev->dev_addr);
> +
>         if (!(dev->flags & IFF_UP))
>                 goto out;
>
> -       if (!ether_addr_equal(addr->sa_data, real_dev->dev_addr)) {
> +       if (!is_real_addr) {
>                 err = dev_uc_add(real_dev, addr->sa_data);
>                 if (err < 0)
>                         return err;
> @@ -336,6 +340,7 @@ static int vlan_dev_set_mac_address(stru
>
>  out:
>         ether_addr_copy(dev->dev_addr, addr->sa_data);
> +       vlan->addr_assign_type = is_real_addr ? NET_ADDR_STOLEN : NET_ADDR_SET;
>         return 0;
>  }

Yeah so you probably don't need most of this.  Just take a look at
dev_set_mac_address.  It will already update this to NET_ADDR_SET
which is really what you want if the user specified a MAC address.  At
that point you should stop following the lower dev because the user
may intend to have this MAC address be static while they change the
lower dev address.

> @@ -558,8 +563,10 @@ static int vlan_dev_init(struct net_devi
>         /* ipv6 shared card related stuff */
>         dev->dev_id = real_dev->dev_id;
>
> -       if (is_zero_ether_addr(dev->dev_addr))
> +       if (is_zero_ether_addr(dev->dev_addr)) {
>                 eth_hw_addr_inherit(dev, real_dev);
> +               vlan_dev_priv(dev)->addr_assign_type = NET_ADDR_STOLEN;
> +       }
>         if (is_zero_ether_addr(dev->broadcast))
>                 memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
>

This should be just dev->addr_assign_type = NET_ADDR_STOLEN.  No need
to put this in a private structure member.
