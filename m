From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH V2] ethtool:  Add command to configure IOV features
Date: Sat, 08 Oct 2011 01:41:25 +0100
Message-ID: <1318034485.2771.162.camel@bwh-desktop>
References: <20110922213543.26713.23525.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20656 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1JHAl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 20:41:27 -0400
In-Reply-To: <20110922213543.26713.23525.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-22 at 14:35 -0700, Greg Rose wrote:
> New command to allow configuration of IOV features such as the number of
> Virtual Functions to allocate for a given Physical Function interface,
> the number of semi-independent net devices to allocate from partitioned
> I/O resources in the PF and to set the number of queues per VF.
[...]
> @@ -266,6 +270,8 @@ static struct option {
>      { "-W", "--set-dump", MODE_SET_DUMP,
>  		"Set dump flag of the device",
>  		"		N\n"},
> +    { "-v", "--get-iov", MODE_GET_IOV, "Get IOV parameters", "\n" },
> +    { "-V", "--set_iov", MODE_SET_IOV, "Set IOV parameters", "[ N ]\n" },

Doesn't match the implementation.

[...]
> +static int do_get_iov(int fd, struct ifreq *ifr)
> +{
> +	int err;
> +	struct ethtool_iov_get_cmd iov_cmd;
> +
> +	iov_cmd.cmd = ETHTOOL_IOV_GET_CMD;
> +	ifr->ifr_data = (caddr_t)&iov_cmd;
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0) {
> +		perror("Can not get current IOV mode\n");
> +		return 1;
> +	}
> +
> +	memcpy(&iov_cmd, ifr->ifr_data, sizeof(iov_cmd));

But ifr->ifr_data == &iov_cmd.  So this is both pointless and dangerous
(as memcpy() doesn't handle overlapping source and destination).

[...]
> +static int do_set_iov(int fd, struct ifreq *ifr)
> +{
> +	int err;
> +	struct ethtool_iov_set_cmd iov_cmd;
> +
> +	if (iov_changed) {
> +		iov_cmd.cmd = ETHTOOL_IOV_SET_CMD;
> +		if (iov_numvfs_wanted >= 0) {
> +			iov_cmd.set_cmd = ETHTOOL_IOV_CMD_CONFIGURE_SRIOV;
> +			iov_cmd.cmd_param = iov_numvfs_wanted;
> +		} else if (iov_numnetdevs_wanted >= 0) {
> +			iov_cmd.set_cmd = ETHTOOL_IOV_CMD_CONFIGURE_NETDEVS;
> +			iov_cmd.cmd_param = iov_numnetdevs_wanted;
> +		} else if (iov_numvqueues_wanted >= 0) {
> +			iov_cmd.set_cmd = ETHTOOL_IOV_CMD_CONFIGURE_VF_QUEUES;
> +			iov_cmd.cmd_param = iov_numvqueues_wanted;
> +		} else {
> +			return -EINVAL;
> +		}
[...]

So what if the user specifies multiple keywords?

Also missing an update to the manual page.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
