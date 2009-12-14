From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] macvlan: add tap device backend
Date: Mon, 14 Dec 2009 13:53:14 +0100
Message-ID: <4B26353A.9020005@trash.net>
References: <1259862720-28432-1-git-send-email-arnd@arndb.de> <1259862720-28432-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"" <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756525AbZLNMxU@vger.kernel.org>
In-Reply-To: <1259862720-28432-3-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> +static int macvtap_newlink(struct net *src_net,
> +			   struct net_device *dev,
> +			   struct nlattr *tb[],
> +			   struct nlattr *data[])
> +{
> +	struct device *classdev;
> +	dev_t devt;
> +	int err;
> +
> +	err = macvlan_common_newlink(src_net, dev, tb, data,
> +				     macvtap_receive, macvtap_forward);
> +	if (err)
> +		goto out;
> +
> +	devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
> +
> +	classdev = device_create(macvtap_class, &dev->dev, devt,
> +				 dev, "tap%d", dev->ifindex);
> +	if (IS_ERR(classdev)) {
> +		err = PTR_ERR(classdev);
> +		macvtap_del_queues(dev);
> +		macvlan_dellink(dev, NULL);

I think this may cause a double free since macvlan_dellink() will
free the device and rtnl_newlink() will free it again on error.

> +	}
> +
> +out:
> +	return err;
> +}
> +
> +static void macvtap_dellink(struct net_device *dev,
> +			    struct list_head *head)
> +{
> +	device_destroy(macvtap_class,
> +		       MKDEV(MAJOR(macvtap_major), dev->ifindex));
> +
> +	macvtap_del_queues(dev);
> +	macvlan_dellink(dev, head);
> +}
> +
> +static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
> +	.kind		= "macvtap",
> +	.newlink	= macvtap_newlink,
> +	.dellink	= macvtap_dellink,
> +};
