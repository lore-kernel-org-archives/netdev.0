From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net 8/8] ixgbe: ethtool: stats user buffer overrun
Date: Wed, 8 Feb 2012 15:17:09 +0000
Message-ID: <1328714229.12637.43.camel@deadeye>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328693798-27323-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, John Fastabend <john.r.fastabend@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63694 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754233Ab2BHPRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 10:17:06 -0500
In-Reply-To: <1328693798-27323-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-08 at 01:36 -0800, Jeff Kirsher wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> 
> If the number of tx/rx queues changes the ethtool ioctl
> ETHTOOL_GSTATS may overrun the userspace buffer. This
> occurs because the general practice in user space to
> query stats is to issue a ETHTOOL_GSSET cmd to learn the
> buffer size needed, allocate the buffer, then call
> ETHTOOL_GSTIRNGS and ETHTOOL_GSTATS. If the number of
> real_num_queues is changed or flow control attributes
> are changed after ETHTOOL_GSSET but before the
> ETHTOOL_GSTRINGS/ETHTOOL_GSTATS a user space buffer
> overrun occurs.

This is a problem with several ethtool operations - the user buffer size
is implicit.

> To fix the overrun always return the max buffer size
> needed from get_sset_count() then return all strings
> and stats from get_strings()/get_ethtool_stats().
> 
> This _will_ change the output from the ioctl() call
> which could break applications and script parsing in
> theory. I believe these changes should not break existing
> tools because the only changes will be more {tx|rx}_queues
> and the {tx|rx}_pb_* stats will always be returned.
[...]

Yes, this sounds perfectly reasonable.  And this change is definitely
worth making.

However, even if the number of stats (or other attributes) for a device
never change at run-time, devices can be renamed concurrently so that
the second operation runs on a different device!

Perhaps we could change dev_ioctl so that if ifreq::ifr_name is an empty
string then the socket's bound device is used.  However, setting
SO_BINDTODEVICE currently requires CAP_NET_RAW.  Alternately, there
could be some sort of union between ifr_name and an ifindex.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
