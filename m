From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] macvlan: add tap device backend
Date: Mon, 10 Aug 2009 08:47:27 +0200
Message-ID: <4A7FC27F.1090904@trash.net>
References: <1249595428-21594-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"" <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55873 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbZHJGrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 02:47:32 -0400
In-Reply-To: <1249595428-21594-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> new file mode 100644
> index 0000000..d99bfc0
> --- /dev/null
> +++ b/drivers/net/macvtap.c
> +static int macvtap_open(struct inode *inode, struct file *file)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	int ifindex = iminor(inode);
> +	struct net_device *dev = dev_get_by_index(net, ifindex);
> +	int err;
> +
> +	err = -ENODEV;
> +	if (!dev)
> +		goto out1;
> +
> +	file->private_data = netdev_priv(dev);
> +	err = 0;
> +out1:
> +	return err;
> +}

macvlan will remove all macvlan/vtap devices when the underlying
device in unregistered, at which time you need to release the
device references you're holding. I'd suggest to change the
macvlan_device_event() handler to use

vlan->dev->rtnl_link_ops->dellink(vlan->dev)

instead of macvlan_dellink() so the macvtap_dellink callback
is invoked.
