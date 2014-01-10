From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [RFC net-next 2/3] bonding: convert mode setting to use the new option API
Date: Fri, 10 Jan 2014 12:04:54 -0800
Message-ID: <5430CE37-65C0-4F51-B6D3-C24CC860024B@cumulusnetworks.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com> <1389359495-9700-3-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:46496 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757857AbaAJUFO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:05:14 -0500
In-Reply-To: <1389359495-9700-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 10, 2014, at 5:11 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> This patch makes the bond's mode setting use the new option API and
> adds support for dependency printing which relies on having an entry for
> the mode option in the bond_opts[] array.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

> -int bond_option_mode_set(struct bonding *bond, int mode)
> +int bond_option_mode_set(struct bonding *bond, void *newval)
> {
> -	if (bond_parm_tbl_lookup(mode, bond_mode_tbl) < 0) {
> -		pr_err("%s: Ignoring invalid mode value %d.\n",
> -		       bond->dev->name, mode);
> -		return -EINVAL;
> -	}
> -
> -	if (bond->dev->flags & IFF_UP) {
> -		pr_err("%s: unable to update mode because interface is up.\n",
> -		       bond->dev->name);
> -		return -EPERM;
> -	}
> -
> -	if (bond_has_slaves(bond)) {
> -		pr_err("%s: unable to update mode because bond has slaves.\n",
> -			bond->dev->name);
> -		return -EPERM;
> -	}
> +	int mode = *(int *)newval;
> +	struct bond_option *opt;
> 
> 	if (BOND_NO_USES_ARP(mode) && bond->params.arp_interval) {
> +		opt = bond_opt_get(BOND_OPT_MODE);
> 		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
> -			bond->dev->name, bond_mode_tbl[mode].modename);
> +			bond->dev->name, opt->values[mode].name);

Can this be a name accessor func?          ^^^^^^^^^^^^^^^^^^^^^^

> static ssize_t bonding_store_mode(struct device *d,
> 				  struct device_attribute *attr,
> 				  const char *buf, size_t count)
> {
> -	int new_value, ret;
> 	struct bonding *bond = to_bond(d);
> +	int ret;
> 
> -	new_value = bond_parse_parm(buf, bond_mode_tbl);
> -	if (new_value < 0)  {
> -		pr_err("%s: Ignoring invalid mode value %.*s.\n",
> -		       bond->dev->name, (int)strlen(buf) - 1, buf);
> -		return -EINVAL;
> -	}
> -	if (!rtnl_trylock())
> +	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MODE, (char *)buf);
> +	if (ret == -EAGAIN)
> 		return restart_syscall();

I wonder if the restart_syscall() should be kept close to rtnl_trylock() in bond_opt_tryset_rtnl?
