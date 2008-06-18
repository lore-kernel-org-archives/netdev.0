From: Ben Greear <greearb@candelatech.com>
Subject: ipv6 devconf.c can attempt to kfree non-heap memory
Date: Wed, 18 Jun 2008 13:12:27 -0700
Message-ID: <48596C2B.2060709@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:57197 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbYFRUM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 16:12:29 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m5IKCRIu012951
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 13:12:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying to add a new ipv6 option, I apparently screwed
something up and caused one of the sysctl_register calls
to fail.  Since I'm not using name-spaces, all and dflt
point to something other than heap memory.  The kfree
then panics when it tries to free them.

I'm not sure this can case ever happen in the real world,
but it's probably worth fixing anyway.

This is from kernel 2.6.25.4, net/ipv6/addrconf.c

static int addrconf_init_net(struct net *net)
{
	int err;
	struct ipv6_devconf *all, *dflt;

	err = -ENOMEM;
	all = &ipv6_devconf;
	dflt = &ipv6_devconf_dflt;

	if (net != &init_net) {
		all = kmemdup(all, sizeof(ipv6_devconf), GFP_KERNEL);
		if (all == NULL)
			goto err_alloc_all;

		dflt = kmemdup(dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
		if (dflt == NULL)
			goto err_alloc_dflt;
	}

	net->ipv6.devconf_all = all;
	net->ipv6.devconf_dflt = dflt;

#ifdef CONFIG_SYSCTL
	err = __addrconf_sysctl_register(net, "all", NET_PROTO_CONF_ALL,
			NULL, all);
	if (err < 0)
		goto err_reg_all;

	err = __addrconf_sysctl_register(net, "default", NET_PROTO_CONF_DEFAULT,
			NULL, dflt);
	if (err < 0)
		goto err_reg_dflt;
#endif
	return 0;

#ifdef CONFIG_SYSCTL
err_reg_dflt:
	__addrconf_sysctl_unregister(all);
err_reg_all:
	kfree(dflt);
#endif
err_alloc_dflt:
	kfree(all);
err_alloc_all:
	return err;
}

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

