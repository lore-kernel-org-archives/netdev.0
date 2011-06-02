From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv5] ethtool: Added FW dump support
Date: Thu, 02 Jun 2011 19:40:49 +0100
Message-ID: <1307040049.2812.19.camel@bwh-desktop>
References: <1307039239-15196-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25433 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab1FBSkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 14:40:52 -0400
In-Reply-To: <1307039239-15196-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-02 at 11:27 -0700, Anirban Chakraborty wrote:
> Ben,
> 
> I've updated the patch with your review comments. Please apply.

You haven't included the manual page changes.  Maybe you edited
ethtool.8, which is generated from ethtool.8.in (substituting the
version string)?  You need to edit and commit ethtool.8.in.

[...]
> +static int do_getfwdump(int fd, struct ifreq *ifr)
> +{
> +	int err;
> +	struct ethtool_dump edata;
> +	struct ethtool_dump *data;
> +
> +	edata.cmd = ETHTOOL_GET_DUMP_FLAG;
> +
> +	ifr->ifr_data = (caddr_t) &edata;
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0) {
> +		perror("Can not get dump level\n");
> +		return 1;
> +	}
> +	if (dump_flag != ETHTOOL_GET_DUMP_DATA) {
> +		fprintf(stdout, "flag: %u, version: %u, length: %u\n",
> +			edata.flag, edata.version, edata.len);
> +		return 0;
> +	}
> +	data = calloc(1, offsetof(struct ethtool_dump, data) + edata.len);
> +	if (!data) {
> +		perror("Can not allocate enough memory\n");
> +		return 1;
> +	}
> +	data->cmd = ETHTOOL_GET_DUMP_DATA;
> +	data->len = edata.len;
> +	ifr->ifr_data = (caddr_t) data;
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0) {
> +		perror("Can not get dump data\n");
> +		goto free;
> +	}
> +	err = do_writefwdump(data);
> +free:
> +	free(data);
> +	return err;
> +}
[...]

I think the last statement should be:
	return err ? 1 : 0;
Otherwise we may return -1.

Otherwise, this looks good.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

