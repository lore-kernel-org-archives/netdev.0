From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: Fix inconsistent teardown and release of private
 netdev state.
Date: Fri, 9 Jun 2017 10:21:04 -0700
Message-ID: <20170609102104.34c26568@xeon-e3>
References: <20170607.155411.201795978436906426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35650 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbdFIRVM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 13:21:12 -0400
Received: by mail-pg0-f42.google.com with SMTP id k71so28514422pgd.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 10:21:12 -0700 (PDT)
In-Reply-To: <20170607.155411.201795978436906426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 07 Jun 2017 15:54:11 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> Network devices can allocate reasources and private memory using
> netdev_ops->ndo_init().  However, the release of these resources
> can occur in one of two different places.
> 
> Either netdev_ops->ndo_uninit() or netdev->destructor().
> 
> The decision of which operation frees the resources depends upon
> whether it is necessary for all netdev refs to be released before it
> is safe to perform the freeing.
> 
> netdev_ops->ndo_uninit() presumably can occur right after the
> NETDEV_UNREGISTER notifier completes and the unicast and multicast
> address lists are flushed.
> 
> netdev->destructor(), on the other hand, does not run until the
> netdev references all go away.
> 
> Further complicating the situation is that netdev->destructor()
> almost universally does also a free_netdev().
> 
> This creates a problem for the logic in register_netdevice().
> Because all callers of register_netdevice() manage the freeing
> of the netdev, and invoke free_netdev(dev) if register_netdevice()
> fails.
> 
> If netdev_ops->ndo_init() succeeds, but something else fails inside
> of register_netdevice(), it does call ndo_ops->ndo_uninit().  But
> it is not able to invoke netdev->destructor().
> 
> This is because netdev->destructor() will do a free_netdev() and
> then the caller of register_netdevice() will do the same.
> 
> However, this means that the resources that would normally be released
> by netdev->destructor() will not be.
> 
> Over the years drivers have added local hacks to deal with this, by
> invoking their destructor parts by hand when register_netdevice()
> fails.
> 
> Many drivers do not try to deal with this, and instead we have leaks.
> 
> Let's close this hole by formalizing the distinction between what
> private things need to be freed up by netdev->destructor() and whether
> the driver needs unregister_netdevice() to perform the free_netdev().
> 
> netdev->priv_destructor() performs all actions to free up the private
> resources that used to be freed by netdev->destructor(), except for
> free_netdev().
> 
> netdev->needs_free_netdev is a boolean that indicates whether
> free_netdev() should be done at the end of unregister_netdevice().
> 
> Now, register_netdevice() can sanely release all resources after
> ndo_ops->ndo_init() succeeds, by invoking both ndo_ops->ndo_uninit()
> and netdev->priv_destructor().
> 
> And at the end of unregister_netdevice(), we invoke
> netdev->priv_destructor() and optionally call free_netdev().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> This is from a few weeks ago, pushed to 'net' and queued up for
> -stable.
> 
>  drivers/net/bonding/bond_main.c                             | 6 +++---
>  drivers/net/caif/caif_hsi.c                                 | 2 +-
>  drivers/net/caif/caif_serial.c                              | 2 +-
>  drivers/net/caif/caif_spi.c                                 | 2 +-
>  drivers/net/caif/caif_virtio.c                              | 2 +-
>  drivers/net/can/slcan.c                                     | 7 +++----
>  drivers/net/can/vcan.c                                      | 2 +-
>  drivers/net/can/vxcan.c                                     | 2 +-
>  drivers/net/dummy.c                                         | 4 ++--
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c             | 2 +-
>  drivers/net/geneve.c                                        | 2 +-
>  drivers/net/gtp.c                                           | 2 +-
>  drivers/net/hamradio/6pack.c                                | 2 +-
>  drivers/net/hamradio/bpqether.c                             | 2 +-
>  drivers/net/ifb.c                                           | 4 ++--
>  drivers/net/ipvlan/ipvlan_main.c                            | 2 +-
>  drivers/net/loopback.c                                      | 4 ++--
>  drivers/net/macsec.c                                        | 4 ++--
>  drivers/net/macvlan.c                                       | 2 +-
>  drivers/net/nlmon.c                                         | 2 +-
>  drivers/net/slip/slip.c                                     | 7 +++----
>  drivers/net/team/team.c                                     | 4 ++--
>  drivers/net/tun.c                                           | 4 ++--
>  drivers/net/usb/cdc-phonet.c                                | 2 +-
>  drivers/net/usb/qmi_wwan.c                                  | 2 +-
>  drivers/net/veth.c                                          | 4 ++--
>  drivers/net/vrf.c                                           | 2 +-
>  drivers/net/vsockmon.c                                      | 2 +-
>  drivers/net/vxlan.c                                         | 2 +-
>  drivers/net/wan/dlci.c                                      | 2 +-
>  drivers/net/wan/hdlc_fr.c                                   | 2 +-
>  drivers/net/wan/lapbether.c                                 | 2 +-
>  drivers/net/wireless/ath/ath6kl/main.c                      | 2 +-
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 1 -
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c     | 3 ++-
>  drivers/net/wireless/intersil/hostap/hostap_main.c          | 2 +-
>  drivers/net/wireless/mac80211_hwsim.c                       | 2 +-
>  drivers/net/wireless/marvell/mwifiex/main.c                 | 2 +-
>  drivers/staging/rtl8188eu/os_dep/mon.c                      | 2 +-
>  drivers/usb/gadget/function/f_phonet.c                      | 2 +-
>  include/linux/netdevice.h                                   | 7 ++++---
>  net/8021q/vlan_dev.c                                        | 4 ++--
>  net/batman-adv/soft-interface.c                             | 5 ++---
>  net/bluetooth/6lowpan.c                                     | 2 +-
>  net/bridge/br_device.c                                      | 2 +-
>  net/caif/chnl_net.c                                         | 4 ++--
>  net/core/dev.c                                              | 8 ++++++--
>  net/hsr/hsr_device.c                                        | 4 ++--
>  net/ieee802154/6lowpan/core.c                               | 2 +-
>  net/ipv4/ip_tunnel.c                                        | 4 ++--
>  net/ipv4/ipmr.c                                             | 2 +-
>  net/ipv6/ip6_gre.c                                          | 9 +++++----
>  net/ipv6/ip6_tunnel.c                                       | 8 ++++----
>  net/ipv6/ip6_vti.c                                          | 8 ++++----
>  net/ipv6/ip6mr.c                                            | 2 +-
>  net/ipv6/sit.c                                              | 6 +++---
>  net/irda/irlan/irlan_eth.c                                  | 2 +-
>  net/l2tp/l2tp_eth.c                                         | 2 +-
>  net/mac80211/iface.c                                        | 6 +++---
>  net/mac802154/iface.c                                       | 7 +++----
>  net/openvswitch/vport-internal_dev.c                        | 4 ++--
>  net/phonet/pep-gprs.c                                       | 2 +-
>  62 files changed, 105 insertions(+), 103 deletions(-)

Is there anything in Documentation/networking/netdevices.txt about this to
avoid any future issues?
