From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] introducing new net device feature NETIF_F_MC_ALL
Date: Fri, 17 Sep 2004 15:46:19 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040917154619.5e384c67.davem@davemloft.net>
References: <OF09580470.88860050-ONC1256F01.006D92A3-C1256F11.007F285D@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: pavlic@de.ibm.com
In-Reply-To: <OF09580470.88860050-ONC1256F01.006D92A3-C1256F11.007F285D@de.ibm.com>
List-Id: netdev.vger.kernel.org


Looks mostly fine Frank.

But why don't we save you some work, we have the IP address
handy therefore it's kind of silly for you to have to look
it up again.

Let's create a new netdev callback, something like:

	void (*mc_change)(struct netdev *dev, void *addr, int family, int add);

Then net/ipv4/igmp.c can do something like:

static void ip_mc_filter_add(struct in_device *in_dev, u32 addr)
{
	char buf[MAX_ADDR_LEN];
	struct net_device *dev = in_dev->dev;

	/* Checking for IFF_MULTICAST here is WRONG-WRONG-WRONG.
	   We will get multicast token leakage, when IFF_MULTICAST
	   is changed. This check should be done in dev->set_multicast_list
	   routine. Something sort of:
	   if (dev->mc_list && dev->flags&IFF_MULTICAST) { do it; }
	   --ANK
	   */
	if (arp_mc_map(addr, buf, dev, 0) == 0) {
		dev_mc_add(dev,buf,dev->addr_len,0);
		if (dev->mc_change)
			dev->mc_change(dev, &addr, AF_INET, 1);
	}
}

static void ip_mc_filter_del(struct in_device *in_dev, u32 addr)
{
	char buf[MAX_ADDR_LEN];
	struct net_device *dev = in_dev->dev;

	if (arp_mc_map(addr, buf, dev, 0) == 0) {
		dev_mc_delete(dev,buf,dev->addr_len,0);
		if (dev->mc_change)
			dev->mc_change(dev, &addr, AF_INET, 0);
	}
}

And similarly for the other dev_mc_{add,delete}() call sites.
