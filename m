From: Ben Hutchings <bhutchings@solarflare.com>
Subject: 64-bit net_device_stats
Date: Wed, 02 Jun 2010 22:34:29 +0100
Message-ID: <1275514469.2115.70.camel@achroite.uk.solarflarecom.com>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
	 <20100525.161539.104072714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: junchangwang@gmail.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9477 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654Ab0FBVec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 17:34:32 -0400
In-Reply-To: <20100525.161539.104072714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-25 at 16:15 -0700, David Miller wrote:
[...]
> If the problem is that people want 64-bit counters available for core
> statistics on 32-bit systems, we do not fix that problem by hacking
> every single driver to provide them side-band via ethtool.
> 
> First of all, we now have "struct rtnl_link_stats64" in
> linux/if_link.h, it's there to start combating this problem
> generically, for every device, rather than the way you are trying
> handle it only for one specific driver at a time.
> 
> So that's the area where you should start looking to solve these kinds
> of problem.

My understand of the current situation is as follows; correct me if any
of this is wrong:

The standard counters in struct net_device_stats have type unsigned long
which is the native word size and so can be read and updated
automatically.  Net drivers can update counters from the data path
without any interlocking with their ndo_get_stats implementation or the
networking core code which reads them.

The values returned by ndo_get_stats (by reference) are exposed:
- Through procfs (/proc/net/dev) as columns of numbers
- Through sysfs (/sys/class/net/*/stats/*) as single numeric strings
- Through netlink (IFLA_STATS and IFLA_STATS64) as 32-bit or 64-bit
  values in binary structures

Changing the counter types to u64 for 32-bit architectures would remove
atomicity and expose half-updated counters to userland.  Changing the
driver interface significantly so that atomicity is not needed would
require changes to hundreds of drivers.

Assuming the above is all correct, I think we can only solve this with a
gradual change (as for net_device_ops).  The following might work:

1. a. Define struct net_device_stats64 identically to rtnl_link_stats64.
   b. Add net_device_ops::ndo_get_stats64, the implementation of which
      will return a pointer to such a structure.  The referenced
      structure must only be updated atomically, except within the
      call to ndo_get_stats64.
   (For 64-bit architectures, these could be macro aliases to the
   existing structure and operations.)
   c. On 32-bit architectures, insert unsigned long padding after each
      member of struct net_device_stats.
   d. Add an anonymous union in net_device; move stats into the union
      and add struct net_device_stats64 stats64.
   e. Change dev_get_stats() to return a pointer to struct
      net_device_stats64, and to call ndo_get_stats64 if available in
      preference to ndo_get_stats.  Adjust callers accordingly.
   f. Either change dev_get_stats() to clear the padding members, or
      change drivers to ensure that the padding is cleared.

2. Change drivers to define ndo_get_stats64, following the rule
   stated in 1b.

3. Much later, remove net_device_stats.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

