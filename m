From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 net-next-2.6 2/3] qlcnic: Take FW dump via ethtool
Date: Thu, 12 May 2011 18:27:22 +0100
Message-ID: <1305221242.5214.36.camel@bwh-desktop>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1305154448-9687-4-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:22083 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758202Ab1ELR1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 13:27:25 -0400
In-Reply-To: <1305154448-9687-4-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-11 at 15:54 -0700, Anirban Chakraborty wrote:
> Driver checks if the previous dump has been cleared before taking the dump.
> It doesn't take the dump if it is not cleared.
> 
> Changes from v2:
> Added lock to protect dump data structures from being mangled while
> dumping or setting them via ethtool.

Unfortunately it still seems to be possible for the dump length to
change between the ethtool core calling qlcnic_get_dump_flag() and
qlcnic_get_dump_data().

So I think qlcnic_get_dump_data() will need to double-check the length
after taking the internal lock:

[...]
> +static int
> +qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
> +                       void *buffer)
> +{
> +       int i, copy_sz;
> +       u32 *hdr_ptr, *data;
> +       struct qlcnic_adapter *adapter = netdev_priv(netdev);
> +       struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
> +
> +       if (qlcnic_api_lock(adapter))
> +               return -EIO;
[...]

	if (dump->len < fw_dump->tmpl_hdr->size + fw_dump->size) {
		qlcnic_api_unlock(adapter);
		return -EINVAL;
	}

I'm not sure about the error code... and I'm really not happy about the
need to check lengths in both the ethtool core and the driver.

Can't you change the function that actually makes a dump to acquire the
RTNL lock?  (You'll need to do that *before* acquiring the driver's own
lock.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

