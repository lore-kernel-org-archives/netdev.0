From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 3/5] [RFC] Infiniband: connection
	abstraction
Date: Sat, 21 Jan 2006 15:37:12 -0800
Message-ID: <ada3bjhrw47.fsf@cisco.com>
References: <ORSMSX4011XvpFVjCRG00000041@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX4011XvpFVjCRG00000041@orsmsx401.amr.corp.intel.com> (Sean
	Hefty's message of "Tue, 17 Jan 2006 15:28:17 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

BTW, it's probably worth highlighting these parts of this patch:

First off, ip_dev_find() is exported again:

 > --- linux-2.6.git/net/ipv4/fib_frontend.c	2006-01-16 10:28:29.000000000 -0800
 > +++ linux-2.6.ib/net/ipv4/fib_frontend.c	2006-01-16 16:14:24.000000000 -0800
 > @@ -666,4 +666,5 @@ void __init ip_fib_init(void)
 >  }
 >  
 >  EXPORT_SYMBOL(inet_addr_type);
 > +EXPORT_SYMBOL(ip_dev_find);
 >  EXPORT_SYMBOL(ip_rt_ioctl);

And then it's used here:

 > +int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr)
 > +{
 > +	struct net_device *dev;
 > +	u32 ip = ((struct sockaddr_in *) addr)->sin_addr.s_addr;
 > +	int ret;
 > +
 > +	dev = ip_dev_find(ip);
 > +	if (!dev)
 > +		return -EADDRNOTAVAIL;
 > +
 > +	ret = copy_addr(dev_addr, dev, NULL);
 > +	dev_put(dev);
 > +	return ret;
 > +}

And also here to find the local device to use when connecting to a
loopback address:

 > +static int addr_resolve_local(struct sockaddr_in *src_in,
 > +			      struct sockaddr_in *dst_in,
 > +			      struct rdma_dev_addr *addr)
 > +{
 > +	struct net_device *dev;
 > +	u32 src_ip = src_in->sin_addr.s_addr;
 > +	u32 dst_ip = dst_in->sin_addr.s_addr;
 > +	int ret;
 > +
 > +	dev = ip_dev_find(dst_ip);
 > +	if (!dev)
 > +		return -EADDRNOTAVAIL;
 > +
 > +	if (!src_ip) {
 > +		src_in->sin_family = dst_in->sin_family;
 > +		src_in->sin_addr.s_addr = dst_ip;
 > +		ret = copy_addr(addr, dev, dev->dev_addr);
 > +	} else {
 > +		ret = rdma_translate_ip((struct sockaddr *)src_in, addr);
 > +		if (!ret)
 > +			memcpy(addr->dst_dev_addr, dev->dev_addr, MAX_ADDR_LEN);
 > +	}
 > +
 > +	dev_put(dev);
 > +	return ret;
 > +}

I don't really have an opinion one way or another about this usage,
but I think it's a good idea to make sure that this stuff doesn't get
lost in all the other code, since it is (re)exporting a function that
is currently private to networking.

 - R.
