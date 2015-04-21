From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 02/11] IB/addr: Pass network namespace as a parameter
Date: Tue, 21 Apr 2015 13:34:58 +0300
Message-ID: <553627D2.7050607@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
	 <1429520622-10303-3-git-send-email-haggaie@mellanox.com>
 <1429567530.45956.31.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429567530.45956.31.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 21/04/2015 01:05, Doug Ledford wrote:
> On Mon, 2015-04-20 at 12:03 +0300, Haggai Eran wrote:
>> From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>
>> Add network namespace support to the ib_addr module. For that, all the address
>> resolution and matching should be done using the appropriate namespace instead
>> of init_net.
>>
>> This is achieved by:
>>
>> 1. Adding an explicit network namespace argument to exported function that
>>    require a namespace.
>> 2. Saving the namespace in the rdma_addr_client structure.
>> 3. Using it when calling networking functions.
>>
>> In order to preserve the behavior of calling modules, &init_net is
>> passed as the parameter in calls from other modules. This is modified as
>> namespace support is added on more levels.
>>
>> Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> ---
>>  drivers/infiniband/core/addr.c           | 31 ++++++++++++----------
>>  drivers/infiniband/core/cma.c            |  4 ++-
>>  drivers/infiniband/core/verbs.c          | 14 +++++++---
>>  drivers/infiniband/hw/ocrdma/ocrdma_ah.c |  3 ++-
>>  include/rdma/ib_addr.h                   | 44 ++++++++++++++++++++++++++++----
>>  5 files changed, 72 insertions(+), 24 deletions(-)
>>
>> diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
>> index f80da50d84a5..95beaef6b66d 100644
>> --- a/drivers/infiniband/core/addr.c
>> +++ b/drivers/infiniband/core/addr.c
>> @@ -128,7 +128,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
>>  	int ret = -EADDRNOTAVAIL;
>>  
>>  	if (dev_addr->bound_dev_if) {
>> -		dev = dev_get_by_index(&init_net, dev_addr->bound_dev_if);
>> +		dev = dev_get_by_index(dev_addr->net, dev_addr->bound_dev_if);
>>  		if (!dev)
>>  			return -ENODEV;
>>  		ret = rdma_copy_addr(dev_addr, dev, NULL);
>> @@ -137,9 +137,10 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
>>  	}
>>  
>>  	switch (addr->sa_family) {
>> -	case AF_INET:
>> -		dev = ip_dev_find(&init_net,
>> -			((struct sockaddr_in *) addr)->sin_addr.s_addr);
>> +	case AF_INET: {
>                        ^ Please don't add brackets just so you can
> convert a cast into a variable declaration that's unnecessary
> 
>> +		struct sockaddr_in *addr_in = (struct sockaddr_in *)addr;
>> +
>> +		dev = ip_dev_find(dev_addr->net, addr_in->sin_addr.s_addr);
>>  
>>  		if (!dev)
>>  			return ret;
>> @@ -149,12 +150,12 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
>>  			*vlan_id = rdma_vlan_dev_vlan_id(dev);
>>  		dev_put(dev);
>>  		break;
>> -
>> +	}
>>  #if IS_ENABLED(CONFIG_IPV6)
>>  	case AF_INET6:
>>  		rcu_read_lock();
>> -		for_each_netdev_rcu(&init_net, dev) {
>> -			if (ipv6_chk_addr(&init_net,
>> +		for_each_netdev_rcu(dev_addr->net, dev) {
>> +			if (ipv6_chk_addr(dev_addr->net,
>>  					  &((struct sockaddr_in6 *) addr)->sin6_addr,
>>  					  dev, 1)) {
>>  				ret = rdma_copy_addr(dev_addr, dev, NULL);
>> @@ -236,7 +237,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
>>  	fl4.daddr = dst_ip;
>>  	fl4.saddr = src_ip;
>>  	fl4.flowi4_oif = addr->bound_dev_if;
>> -	rt = ip_route_output_key(&init_net, &fl4);
>> +	rt = ip_route_output_key(addr->net, &fl4);
>>  	if (IS_ERR(rt)) {
>>  		ret = PTR_ERR(rt);
>>  		goto out;
>> @@ -278,12 +279,13 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
>>  	fl6.saddr = src_in->sin6_addr;
>>  	fl6.flowi6_oif = addr->bound_dev_if;
>>  
>> -	dst = ip6_route_output(&init_net, NULL, &fl6);
>> +	dst = ip6_route_output(addr->net, NULL, &fl6);
>>  	if ((ret = dst->error))
>>  		goto put;
>>  
>>  	if (ipv6_addr_any(&fl6.saddr)) {
>> -		ret = ipv6_dev_get_saddr(&init_net, ip6_dst_idev(dst)->dev,
>> +		ret = ipv6_dev_get_saddr(addr->net,
>> +					 ip6_dst_idev(dst)->dev,
>>  					 &fl6.daddr, 0, &fl6.saddr);
>>  		if (ret)
>>  			goto put;
>> @@ -458,7 +460,7 @@ static void resolve_cb(int status, struct sockaddr *src_addr,
>>  }
>>  
>>  int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *dmac,
>> -			       u16 *vlan_id)
>> +			       u16 *vlan_id, struct net *net)
> 
> In the core networking code, the net namespace is always first.  Please
> stick with that paradigm.
> 

I'll fix these comments in the next revision.

Thanks,
Haggai

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
