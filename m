From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v3 06/17] net-sysfs: expose physical switch id
 for particular device
Date: Tue, 25 Nov 2014 14:27:34 -0800
Message-ID: <54750256.2090700@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:53183 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaKYW1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:27:37 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so1485807pab.2
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:27:37 -0800 (PST)
In-Reply-To: <1416911328-10979-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 02:28, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Reviewed-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

.. only if you also update Documentation/ABI/testing/sysfs-class-net as
well ;)

> ---
> v2->v3:
> -changed "sw" string to "switch" to avoid confusion
> v1->v2:
> -no change
> ---
>  net/core/net-sysfs.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 26c46f4..9993412 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -12,6 +12,7 @@
>  #include <linux/capability.h>
>  #include <linux/kernel.h>
>  #include <linux/netdevice.h>
> +#include <net/switchdev.h>
>  #include <linux/if_arp.h>
>  #include <linux/slab.h>
>  #include <linux/nsproxy.h>
> @@ -416,6 +417,28 @@ static ssize_t phys_port_id_show(struct device *dev,
>  }
>  static DEVICE_ATTR_RO(phys_port_id);
>  
> +static ssize_t phys_switch_id_show(struct device *dev,
> +				   struct device_attribute *attr, char *buf)
> +{
> +	struct net_device *netdev = to_net_dev(dev);
> +	ssize_t ret = -EINVAL;
> +
> +	if (!rtnl_trylock())
> +		return restart_syscall();
> +
> +	if (dev_isalive(netdev)) {
> +		struct netdev_phys_item_id ppid;
> +
> +		ret = netdev_switch_parent_id_get(netdev, &ppid);
> +		if (!ret)
> +			ret = sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
> +	}
> +	rtnl_unlock();
> +
> +	return ret;
> +}
> +static DEVICE_ATTR_RO(phys_switch_id);
> +
>  static struct attribute *net_class_attrs[] = {
>  	&dev_attr_netdev_group.attr,
>  	&dev_attr_type.attr,
> @@ -441,6 +464,7 @@ static struct attribute *net_class_attrs[] = {
>  	&dev_attr_tx_queue_len.attr,
>  	&dev_attr_gro_flush_timeout.attr,
>  	&dev_attr_phys_port_id.attr,
> +	&dev_attr_phys_switch_id.attr,
>  	NULL,
>  };
>  ATTRIBUTE_GROUPS(net_class);
> 
