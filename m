From: rajeev kumar <rajeevkumar.linux@gmail.com>
Subject: Re: [RFC PATCH 2/3] net/dsa: Allow probing dsa from usbnet
Date: Wed, 22 Apr 2015 12:45:43 +0530
Message-ID: <CAA7nrthL+=ED7N1OMfwaMjgHhgCZeYrooB+Mzqvvz3s+F=mDow@mail.gmail.com>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
	<1429622791-7195-3-git-send-email-kaisrja1@fel.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sojkam1@fel.cvut.cz, tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34552 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011AbbDVHPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:15:44 -0400
In-Reply-To: <1429622791-7195-3-git-send-email-kaisrja1@fel.cvut.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 6:56 PM, Jan Kaisrlik <kaisrja1@fel.cvut.cz> wrote:
> From: Jan Kaisrlik <ja.kaisrlik@gmail.com>
>
> This patch adds a function which helps to connect net device
> to DSA switch based on mii_bus and netdev.
>
> The switch parameters of the switch are configured in fill_platform_data().
> Currently, the configuration data is hardcoded in the code.
> I don't know how to pass the configuration data from
> user space.
>
> It is not possible to determine the configuration data in plug-and-play
> manner in mv88e6060 driver.
>
> I have thought about two possibilities how to do that. First one is to
> load data from the device tree, because loading from device tree is
> already implemented in dsa_of_probe().
>
> Second possibility is to send configuration of switch via sysfs.
>
> In my opinion, the second one is better because I have already used
> sysfs to bind USB to DSA in patch 3/3.
>
> ---
>  include/net/dsa.h |   3 ++
>  net/dsa/dsa.c     | 121 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 124 insertions(+)
>
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index ed3c34b..df7b748 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -290,4 +290,7 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
>  {
>         return dst->rcv != NULL;
>  }
> +
> +int dsa_probe_mii(struct mii_bus *bus, struct net_device * dev);
> +
>  #endif
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index e2c0703..cb5d9c2 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -798,6 +798,127 @@ out:
>         return ret;
>  }
>
> +static int fill_platform_data(struct dsa_platform_data *pd,
> +               struct mii_bus *bus, struct device * parent){
> +       struct dsa_chip_data * cd;
> +       int i;
> +
> +       static struct device_node dn = {
> +               .name = "name",
> +               .type = "type",
> +               .phandle = 0,
> +               .full_name = "fullname",
> +               .fwnode =  {1},
> +               .properties = NULL,
> +               .deadprops = NULL,
> +               .parent = NULL,
> +               .child = NULL,
> +               .sibling = NULL,
> +               .kobj = {NULL},
> +               ._flags = 0,
> +               .data = NULL
> +       };
> +       static struct device_node dnc = {
> +               .name = "name",
> +               .type = "type",
> +               .phandle = 0,
> +               .full_name = "fullname",
> +               .fwnode =  {1},
> +               .properties = NULL,
> +               .deadprops = NULL,
> +               .parent = &dn,
> +               .child = NULL,
> +               .sibling = NULL,
> +               .kobj = {NULL},
> +               ._flags = 0,
> +               .data = NULL
> +       };
> +       static char *port_names[12] = {"0", "1", "2", "3", "4",
> +               "5", "6", "7", "8", "9", "10", "11"};
> +
> +       pd->nr_chips = 1;
> +       pd->netdev = parent;
> +
> +       cd = kzalloc(sizeof(*cd), GFP_KERNEL);
> +       if (cd == NULL)
> +               return -ENOMEM;
> +
> +       pd->chip = cd;
> +
> +       cd->host_dev = parent;
> +       cd->sw_addr = 0x10;
> +       cd->eeprom_len = 256;
> +       cd->of_node = &dn;
> +       cd->rtable = 0;
> +
> +//     cd->of_node = kzalloc(sizeof(*cd->of_node), GFP_KERNEL);
> +//     if(cd->of_node == NULL)
> +//             goto free;
> +
> +       for (i = 0; i < DSA_MAX_PORTS; i++) {
> +               cd->port_names[i] = port_names[i];
> +               cd->port_dn[i] = &dnc;
> +       }
> +
> +       return 0;
> +
> +//free:
> +//     kfree(cd);
> +//     return -ENOMEM;
> +}

Use proper commenting style.
why are you keeping these commented code ?

> +
> +int dsa_probe_mii(struct mii_bus *bus, struct net_device * dev)
> +{
> +       struct dsa_platform_data *pd;
> +       struct dsa_switch_tree *dst;
> +       int ret;
> +
> +       pr_notice_once("Distributed Switch Architecture driver version %s\n",
> +                      dsa_driver_version);
> +
> +       if (dev == NULL || bus == NULL)
> +               return -EINVAL;
> +
> +       pd = kzalloc(sizeof(*pd), GFP_KERNEL);
> +       if (pd == NULL) {
> +               ret = -ENOMEM;
> +               goto freep;
> +       }
> +
> +       ret = fill_platform_data(pd, bus, bus->parent); //TODO fix it!
> +       if (ret)
> +               goto freep;
> +
> +       if (dev->dsa_ptr != NULL) {
> +               dev_put(dev);
> +               ret = -EEXIST;
> +               goto freep;
> +       }
> +
> +       dst = kzalloc(sizeof(*dst), GFP_KERNEL);

Use devm_* variant

~Rajeev
> +       if (dst == NULL) {
> +               dev_put(dev);
> +               ret = -ENOMEM;
> +               goto freed;
> +       }
> +
> +       dev_set_drvdata(bus->parent, dst);
> +
> +       dst->pd = pd;
> +       dst->master_netdev = dev;
> +
> +       dsa_probe_common(dst, bus->parent);
> +
> +       return 0;
> +
> +freed:
> +       kfree(dst);
> +freep:
> +       kfree(pd);
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(dsa_probe_mii);
> +
>  static int dsa_remove(struct platform_device *pdev)
>  {
>         struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
> --
> 2.1.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
