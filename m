From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [RFC][PATCH net-next] ethtool: Allow drivers to select RX NFC
 rule locations
Date: Fri, 16 Dec 2011 18:44:45 -0800
Message-ID: <4EEC021D.1050804@chelsio.com>
References: <1324084683.2798.45.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4049 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809Ab1LQCou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 21:44:50 -0500
In-Reply-To: <1324084683.2798.45.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2011 05:18 PM, Ben Hutchings wrote:
> Define special location values for RX NFC that request the driver to
> select the actual rule location.  This allows for implementation on
> devices that use hash-based filter lookup, whereas currently the API is
> more suited to devices with TCAM lookup or linear search.
> 
> In ethtool_set_rxnfc() and the compat wrapper ethtool_ioctl(), copy
> the structure back to user-space after insertion so that the actual
> location is returned.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

I like this change.  One concern below.

> -	return dev->ethtool_ops->set_rxnfc(dev, &info);
> +	rc = dev->ethtool_ops->set_rxnfc(dev, &info);
> +	if (rc)
> +		return rc;
> +
> +	if (cmd == ETHTOOL_SRXCLSRLINS &&
> +	    copy_to_user(useraddr, &info, info_size))
> +		return -EFAULT;

Here we return failure but the rule has been added successfully and is in 
effect.  It may be better to return 0 and let user-space tell this last step 
failed by the fact that the location field is still special.
