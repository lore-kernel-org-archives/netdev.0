From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Wed, 1 Oct 2008 15:53:55 +1000
Message-ID: <20081001055355.GA27304@verge.net.au>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com> <48DA71A8.5050900@hp.com> <7958.1222288188@death.nxdomain.ibm.com> <48DAFB92.7040904@hp.com> <17219.1222355242@death.nxdomain.ibm.com> <48DBB181.9050205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38934 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbYJAFx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 01:53:58 -0400
Content-Disposition: inline
In-Reply-To: <48DBB181.9050205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 11:42:57AM -0400, Brian Haley wrote:
> Jay Vosburgh wrote:
>> Brian Haley <brian.haley@hp.com> wrote:
>>
>>> This is an RFC patch to add better IPv6 failover support for bonding
>>> devices, especially when in active-backup mode, as reported by Alex
>>> Sidorenko.
>>>
>>> What this patch does:
>>>
>>> - Creates a new Kconfig option in the IPv6 Networking section to
>>>  compile-in the support in the bonding driver.  This also forces
>>>  IPV6=y since that's required to link everything.
>>
>> 	I think it's probably better to have the IPV6 dependent bits
>> somehow depend on CONFIG_IPV6 rather than having a Kconfig entry.  I
>> doubt that many real-world users will say yes to IPv6 and bonding, but
>> no to the bonding IPv6 support.  I also suspect that the IPV6=y
>> requirement won't fly with distros.
>
> I'm sure there's a way to do this better, for example, SCTP can be built  
> as a module with IPv6 support and have IPV6=m.  I'll try to make it work  
> without the option when IPV6=y or m.

Hi,

I took a bit of a stab at this, and here is what I cam up with.

It should enable IPV6_BONDING if one of the following is true
  * EXPERIMENTAL=y && IPV6=m && BONDING=m
  * EXPERIMENTAL=y && IPV6=y && BONDING=m
  * EXPERIMENTAL=y && IPV6=y && BONDING=y
And disable IPV6_BONDING in all other cases.

Compile tested only.

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 69c81da..60c06f8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -61,6 +61,7 @@ config DUMMY
 config BONDING
 	tristate "Bonding driver support"
 	depends on INET
+	select IPV6_BONDING if (IPV6=y || IPV6=BONDING) && EXPERIMENTAL
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ec99215..49108be 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -217,4 +217,7 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
 
+config IPV6_BONDING
+	bool
+
 endif # IPV6

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

