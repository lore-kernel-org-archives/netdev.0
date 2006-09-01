From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] EtherIP tunnel driver (RFC 3387)
Date: Fri, 01 Sep 2006 18:24:56 +0200
Message-ID: <44F85ED8.2000907@trash.net>
References: <20060901151300.GA15422@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39369 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932452AbWIAQ1a
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 12:27:30 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20060901151300.GA15422@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joerg Roedel wrote:
> diff -uprN linux-2.6.17.11-vanilla/net/ipv4/etherip.c linux-2.6.17.11/net/ipv4/etherip.c
> --- linux-2.6.17.11-vanilla/net/ipv4/etherip.c	1970-01-01 01:00:00.000000000 +0100
> +++ linux-2.6.17.11/net/ipv4/etherip.c	2006-09-01 16:22:54.000000000 +0200

> +/* netdevice hard_start_xmit function
> + * it gets an Ethernet packet in skb and encapsulates it in another IP
> + * packet */
> +static int etherip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct etherip_tunnel *tunnel = netdev_priv(dev);
> +	struct rtable *rt;
> +	struct iphdr *iph;
> +	struct flowi fl;
> +	struct net_device *tdev;
> +	int max_headroom;
> +	struct net_device_stats *stats = &tunnel->stats;
> +
> +	if (tunnel->recursion++) {
> +		tunnel->stats.collisions++;
> +		goto tx_error;
> +	}
> +
> +	fl.oif = 0;
> +	fl.nl_u.ip4_u.daddr = tunnel->parms.iph.daddr;
> +	fl.nl_u.ip4_u.saddr = tunnel->parms.iph.saddr;
> +	fl.nl_u.ip4_u.saddr = 0;
> +	fl.proto = IPPROTO_ETHERIP;

This leaves fields like nfmark or iif uninitialized.

> +
> +	if (ip_route_output_key(&rt, &fl)) {
> +		tunnel->stats.tx_carrier_errors++;
> +		goto tx_error_icmp;
> +	}
> +
> +	tdev = rt->u.dst.dev;
> +	if (tdev == dev) {
> +		ip_rt_put(rt);
> +		tunnel->stats.collisions++;
> +		goto tx_error;
> +	}
> +
> +	max_headroom = (LL_RESERVED_SPACE(tdev)+sizeof(struct iphdr)
> +			+ ETHERIP_HLEN);
> +
> +	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)
> +			|| skb_shared(skb)) {
> +		struct sk_buff *n_skb = skb_realloc_headroom(skb,max_headroom);
> +		if (!n_skb) {
> +			ip_rt_put(rt);
> +			dev_kfree_skb(skb);
> +			tunnel->stats.tx_dropped++;
> +			return 0;
> +		}
> +		if (skb->sk)
> +			skb_set_owner_w(n_skb, skb->sk);
> +		dev_kfree_skb(skb);
> +		skb = n_skb;
> +	}
> +
> +	skb->h.raw = skb->nh.raw;
> +	skb->nh.raw = skb_push(skb, sizeof(struct iphdr)+ETHERIP_HLEN);
> +	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> +	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
> +			IPSKB_REROUTED);                         
> +	dst_release(skb->dst);
> +	skb->dst = &rt->u.dst;


The ipip driver updates the dst_entry's pmtu value, looks like a good
idea for this driver too.

> +
> +	iph = skb->nh.iph;
> +	iph->version = 4;
> +	iph->ihl = sizeof(struct iphdr)>>2;
> +	iph->frag_off = 0;
> +	iph->protocol = IPPROTO_ETHERIP;
> +	iph->tos = 0;
> +	iph->daddr = rt->rt_dst;
> +	iph->saddr = rt->rt_src;
> +	iph->ttl = tunnel->parms.iph.ttl;
> +	if (iph->ttl == 0)
> +		iph->ttl = dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
> +
> +	/* add the 16bit etherip header after the ip header */
> +	*((u16*)(skb->nh.raw + sizeof(struct iphdr))) = ntohs(ETHERIP_HEADER);
> +	nf_reset(skb);
> +	IPTUNNEL_XMIT();
> +	tunnel->dev->trans_start = jiffies;
> +	tunnel->recursion--;
> +
> +	return 0;
> +
> +tx_error_icmp:
> +	dst_link_failure(skb);
> +
> +tx_error:
> +	tunnel->stats.tx_errors++;
> +	dev_kfree_skb(skb);
> +	tunnel->recursion--;
> +	return 0;
> +}
> +
> +/* get statistics callback */
> +static struct net_device_stats *etherip_tunnel_stats(struct net_device *dev)
> +{
> +	struct etherip_tunnel *ethip = netdev_priv(dev);
> +	return &ethip->stats;
> +}
> +
> +/* checks parameters the driver gets from userspace */
> +static int etherip_param_check(struct ip_tunnel_parm *p)
> +{
> +	if ((p->iph.version != 4)
> +			|| (p->iph.protocol != IPPROTO_ETHERIP)
> +			|| (p->iph.ihl != 5)
> +			|| (p->iph.daddr == INADDR_ANY)
> +			|| MULTICAST(p->iph.daddr))


This looks a bit strangely aligned.

> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +/* central ioctl function for all netdevices this driver manages
> + * it allows to create, delete, modify a tunnel and fetch tunnel
> + * information */
> +static int etherip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr,
> +		int cmd)
> +{
> +	int err = 0;
> +	struct ip_tunnel_parm p;
> +	struct net_device *new_dev;
> +	char *dev_name;
> +	struct etherip_tunnel *t;
> +
> +
> +	switch (cmd) {
> +	case SIOCGETTUNNEL:
> +		err = -EINVAL;
> +		if (dev == etherip_tunnel_dev)
> +			goto out;
> +		t = netdev_priv(dev);
> +		if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms,
> +				sizeof(t->parms)))
> +			err = -EFAULT;
> +		err = 0;
> +		break;
> +	case SIOCADDTUNNEL:
> +		err = -EINVAL;
> +		if (dev != etherip_tunnel_dev)
> +			goto out;
> +
> +	case SIOCCHGTUNNEL:
> +		err = -EPERM;
> +		if (!capable(CAP_NET_ADMIN))
> +			goto out;
> +
> +		err = -EFAULT;
> +		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data,
> +					sizeof(p)))
> +			goto out;
> +
> +		if ((err = etherip_param_check(&p)) < 0)
> +			goto out;
> +
> +		t = etherip_tunnel_find(&p);
> +
> +		err = -EEXIST;
> +		if ((t != NULL) && (t->dev != dev))
> +			goto out;
> +
> +		if (cmd == SIOCADDTUNNEL) {
> +
> +			p.name[IFNAMSIZ-1] = 0;
> +			dev_name = p.name;
> +			if (dev_name[0] == 0)
> +				dev_name = "ethip%d";
> +
> +			err = -ENOMEM;
> +			new_dev = alloc_netdev(
> +					sizeof(struct etherip_tunnel),
> +					dev_name,
> +					etherip_tunnel_setup);
> +
> +			if (new_dev == NULL)
> +				goto out;
> +				
> +			if (strchr(new_dev->name, '%')) {
> +				err = dev_alloc_name( new_dev, new_dev->name);
> +				if (err < 0)
> +					goto add_err1;
> +			}
> +			
> +			t = netdev_priv(new_dev);
> +			t->dev = new_dev;
> +			strncpy(p.name, new_dev->name, IFNAMSIZ);
> +			memcpy(&(t->parms), &p, sizeof(p));
> +			
> +			write_lock(&etherip_lock);
> +			etherip_tunnel_add(t);
> +			write_unlock(&etherip_lock);
> +			
> +			err = register_netdevice(new_dev);
> +			if (err < 0)
> +				goto add_err2;
> +			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p,
> +						sizeof(p)))
> +				err = -EFAULT;
> +
> +		} else {
> +			err = -EINVAL;
> +			if ((t = netdev_priv(dev)) == NULL)
> +				goto out;
> +			if (dev == etherip_tunnel_dev)
> +				goto out;
> +			write_lock(&etherip_lock);
> +			memcpy(&(t->parms), &p, sizeof(p));
> +			write_unlock(&etherip_lock);
> +		}
> +
> +		err = 0;
> +		break;
> +add_err2:
> +		write_lock(&etherip_lock);
> +		etherip_tunnel_del(t);
> +		write_unlock(&etherip_lock);


It there a reason for adding the tunnel before register_netdevice
succeeds? It seems like the tunnel can be found on the list before
it is fully initialized.

> +add_err1:
> +		free_netdev(new_dev);
> +		goto out;
> +
> +	case SIOCDELTUNNEL:
> +		err = -EPERM;
> +		if (!capable(CAP_NET_ADMIN))
> +			goto out;
> +
> +		err = -EINVAL;
> +		if (dev == etherip_tunnel_dev)
> +			goto out;
> +
> +		t = netdev_priv(dev);
> +			
> +		write_lock(&etherip_lock);
> +		etherip_tunnel_del(t);
> +		write_unlock(&etherip_lock);
> +
> +		unregister_netdevice(t->dev);
> +		err = 0;
> +
> +		break;
> +	default:
> +		err = -EINVAL;
> +	}
> +
> +out:
> +	return err;
> +}
> +
> +/* device init function - called via register_netdevice
> + * The tunnel is registered as an Ethernet device. This allows
> + * the tunnel to be added to a bridge */
> +static void etherip_tunnel_setup(struct net_device *dev)
> +{
> +	SET_MODULE_OWNER(dev);
> +	dev->open = etherip_tunnel_open;
> +	dev->hard_start_xmit = etherip_tunnel_xmit;
> +	dev->stop = etherip_tunnel_stop;
> +	dev->get_stats = etherip_tunnel_stats;
> +	dev->do_ioctl = etherip_tunnel_ioctl;
> +	dev->destructor = free_netdev;
> +
> +	ether_setup(dev);


Maybe you should set tx_queue_len to zero after this, I guess
you don't want a queue len of 1000 for a software device.

> +	random_ether_addr(dev->dev_addr);
> +}
> +
> +/* receive function for EtherIP packets
> + * Does some basic checks on the MAC addresses and
> + * interface modes */
> +static int etherip_rcv(struct sk_buff *skb)
> +{
> +	struct iphdr *iph;
> +	struct ethhdr *ehdr;
> +	struct etherip_tunnel *tunnel;
> +	struct net_device *dev;
> +
> +	iph = skb->nh.iph;
> +
> +	read_lock(&etherip_lock);
> +	tunnel = etherip_tunnel_locate(iph->saddr);
> +	if (tunnel == NULL)
> +		goto drop;
> +
> +	dev = tunnel->dev;
> +	secpath_reset(skb);
> +	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
> +	skb_pull(skb, (skb->nh.raw - skb->data)
> +			+ sizeof(struct iphdr) + ETHERIP_HLEN);
> +	ehdr = (struct ethhdr*)skb->data;
> +	skb->dev = dev;
> +	skb->pkt_type = PACKET_HOST;
> +	skb->protocol = eth_type_trans(skb, tunnel->dev);
> +	skb->ip_summed = CHECKSUM_UNNECESSARY;
> +	dst_release(skb->dst);
> +	skb->dst = NULL;
> +
> +
> +	/* do some checks */
> +	if ((skb->pkt_type == PACKET_HOST)
> +			|| (skb->pkt_type == PACKET_BROADCAST))
> +		goto accept;
> +
> +	if ((skb->pkt_type == PACKET_MULTICAST) && ((dev->mc_count > 0)
> +				|| (dev->flags & IFF_ALLMULTI)))


Strangely aligned and unnecessary parens around comparisons.

> +		goto accept;
> +	
> +	if ((skb->pkt_type == PACKET_OTHERHOST) && (dev->flags & IFF_PROMISC))
> +		goto accept;


Why would you want to receive packets for other hosts picked up in
promiscous mode?

> +
> +	goto drop;
> +
> +accept:
> +	tunnel->dev->last_rx = jiffies;
> +	tunnel->stats.rx_packets++;
> +	tunnel->stats.rx_bytes += skb->len;
> +	dst_release(skb->dst);
> +	skb->dst = NULL;


Already done above, nf_reset is missing.

> +	netif_rx(skb);
> +	read_unlock(&etherip_lock);
> +	return 0;
> +
> +drop:
> +	read_unlock(&etherip_lock);
> +	kfree_skb(skb);
> +	return 0;
> +}
> +
> +static void etherip_err(struct sk_buff *skb, u32 info)
> +{


You could propagte errors from destination unreachable messages
similar to what the IPIP driver does.

> +}
> +
> +static struct net_protocol etherip_protocol = {
> +	.handler      = etherip_rcv,
> +	.err_handler  = 0,//etherip_err,
> +	.no_policy    = 1,
> +};
> +
> +/* module init function
> + * initializes the EtherIP protocol (97) and registers the initial
> + * device */
> +static int __init etherip_init(void)
> +{
> +	int err, i;
> +	struct etherip_tunnel *p;
> +
> +	printk(KERN_INFO BANNER1);
> +	printk(KERN_INFO BANNER2);
> +
> +	if (inet_add_protocol(&etherip_protocol, IPPROTO_ETHERIP)) {
> +		printk(KERN_ERR "etherip: can't add protocol\n");
> +		return -EAGAIN;
> +	}
> +
> +	etherip_tunnel_dev = alloc_netdev(sizeof(struct etherip_tunnel),
> +			"ethip0",
> +			etherip_tunnel_setup);
> +	
> +	if (!etherip_tunnel_dev) {
> +		err = -ENOMEM;
> +		goto err2;
> +	}
> +
> +	p = netdev_priv(etherip_tunnel_dev);
> +	p->dev = etherip_tunnel_dev;
> +
> +	if ((err = register_netdev(etherip_tunnel_dev)))
> +		goto err1;
> +
> +	for (i=0;i<HASH_SIZE;++i)
> +		INIT_LIST_HEAD(&tunnels[i]);


This needs to be done before register_netdev since as soon as it
returns the ioctl handler can be called.

> +
> +out:
> +	return err;
> +err1:
> +	free_netdev(etherip_tunnel_dev);
> +err2:
> +	inet_del_protocol(&etherip_protocol, IPPROTO_ETHERIP);
> +	goto out;
> +}
> +
> +/* destroy all tunnels */
> +static void __exit etherip_destroy_tunnels(void)
> +{
> +	int i;
> +	struct list_head *ptr;
> +	struct etherip_tunnel *ret;
> +	
> +	for (i=0;i<HASH_SIZE;++i) {
> +		ptr = tunnels[i].next;
> +		while (ptr != &(tunnels[i])) {
> +			ret = list_entry(ptr, struct etherip_tunnel, list);


list_for_each_entry

> +			ptr = ptr->next;
> +			unregister_netdevice(ret->dev);
> +		}
> +	}
> +}
> +
> +/* module cleanup function */
> +static void __exit etherip_exit(void)
> +{
> +	rtnl_lock();
> +	etherip_destroy_tunnels();
> +	unregister_netdevice(etherip_tunnel_dev);
> +	rtnl_unlock();
> +	if (inet_del_protocol(&etherip_protocol, IPPROTO_ETHERIP))
> +		printk(KERN_ERR "etherip: can't remove protocol\n");
> +}
> +
> +module_init(etherip_init);
> +module_exit(etherip_exit);
