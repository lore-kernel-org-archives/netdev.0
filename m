From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 5/6] switchdev: remove FIB offload infrastructure
Date: Thu, 22 Sep 2016 14:49:06 +0200
Message-ID: <20160922124906.GC1830@nanopsycho.orion>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
 <1474458794-5512-6-git-send-email-jiri@resnulli.us>
 <20160922072519.GB13287@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34434 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcIVMtL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 08:49:11 -0400
Received: by mail-wm0-f68.google.com with SMTP id l132so13874766wmf.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 05:49:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160922072519.GB13287@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 22, 2016 at 09:25:19AM CEST, idosch@idosch.org wrote:
>On Wed, Sep 21, 2016 at 01:53:13PM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Since this is now taken care of by FIB notifier, remove the code, with
>> all unused dependencies.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>[...]
>
>> -static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
>> -{
>> -	struct switchdev_attr attr = {
>> -		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
>> -	};
>> -	struct switchdev_attr prev_attr;
>> -	struct net_device *dev = NULL;
>> -	int nhsel;
>> -
>> -	ASSERT_RTNL();
>> -
>> -	/* For this route, all nexthop devs must be on the same switch. */
>> -
>> -	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
>> -		const struct fib_nh *nh = &fi->fib_nh[nhsel];
>> -
>> -		if (!nh->nh_dev)
>> -			return NULL;
>> -
>> -		dev = switchdev_get_lowest_dev(nh->nh_dev);
>> -		if (!dev)
>> -			return NULL;
>> -
>> -		attr.orig_dev = dev;
>> -		if (switchdev_port_attr_get(dev, &attr))
>> -			return NULL;
>> -
>> -		if (nhsel > 0 &&
>> -		    !netdev_phys_item_id_same(&prev_attr.u.ppid, &attr.u.ppid))
>> -				return NULL;
>> -
>> -		prev_attr = attr;
>> -	}
>> -
>> -	return dev;
>> -}
>
>[...]
>
>> -int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>> -			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
>> -{
>> -	struct switchdev_obj_ipv4_fib ipv4_fib = {
>> -		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
>> -		.dst = dst,
>> -		.dst_len = dst_len,
>> -		.fi = fi,
>> -		.tos = tos,
>> -		.type = type,
>> -		.nlflags = nlflags,
>> -		.tb_id = tb_id,
>> -	};
>> -	struct net_device *dev;
>> -	int err = 0;
>> -
>> -	/* Don't offload route if using custom ip rules or if
>> -	 * IPv4 FIB offloading has been disabled completely.
>> -	 */
>> -
>> -#ifdef CONFIG_IP_MULTIPLE_TABLES
>> -	if (fi->fib_net->ipv4.fib_has_custom_rules)
>> -		return 0;
>> -#endif
>> -
>> -	if (fi->fib_net->ipv4.fib_offload_disabled)
>> -		return 0;
>> -
>> -	dev = switchdev_get_dev_by_nhs(fi);
>
>Since this is now removed I believe we should perform this check inside
>the drivers. For mlxsw we can simply iterate over the nexthops and make
>sure each has a RIF.

rocker does not support multiple nexthops. For mlxsw, we can you what
you suggest. Will add it.


>
>> -	if (!dev)
>> -		return 0;
>> -
>> -	ipv4_fib.obj.orig_dev = dev;
>> -	err = switchdev_port_obj_add(dev, &ipv4_fib.obj);
>> -	if (!err)
>> -		fib_info_offload_inc(fi);
>> -
>> -	return err == -EOPNOTSUPP ? 0 : err;
>> -}
