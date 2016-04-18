From: David Miller <davem@davemloft.net>
Subject: Re: switchdev fib offload issues
Date: Mon, 18 Apr 2016 13:52:27 -0400 (EDT)
Message-ID: <20160418.135227.1430871435945779629.davem@davemloft.net>
References: <20160418154757.GA2059@nanopsycho.amit.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com, dsa@cumulusnetworks.com, f.fainelli@gmail.com,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com, tgraf@suug.ch,
	aduyck@mirantis.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbcDRRwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 13:52:31 -0400
In-Reply-To: <20160418154757.GA2059@nanopsycho.amit.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 18 Apr 2016 17:47:57 +0200

> However, if for any reason the switchdev add operation fails, there is an
> abort function called (switchdev_fib_ipv4_abort). This function does two
> things which are both unfortunate in many usecases:
> 1) evicts all fib entries from HW leaving all processing done in kernel
>     - For Spectrum ASIC this means that all traffic running at 100G between
>       all ports is immediately downgraded to ~1-3Gbits
>     - Also this happens silently, user knows nothing about anything went wrong,
>       only forwarding performance suddenly sucks.
> 
> 2) sets net->ipv4.fib_offload_disabled = true
>     - That results in no other fib entry being offloaded, forever,
>       until net is removed and added again, machine reboot is required
>       in case if init_ns
> 
> These 2 issues makes fib offload completely unusable. So I propose
> to start thinking about fixing this.
> 
> I believe that although the current behaviour might be good for default,
> user should be able to change it by setting a different policy. This
> policy will allow to propagate offload error to user.

There were many length discussions about this.

It is extremely hard to load a partial table into the chip and
have it work correctly.  This is because with longest matching
prefix you have to pull out the least specific routing entires
and process them in software.

Also, there is no communication about what makes an entry not be
insertable or not.  So it may be the case that the shorter prefixes
all fit into the table, because those can be compressed and take
up less table space in the chip.

So it's extremely hard to know when "room" is available again.  Room
for what?  One 16-bit prefixed route?  Or room for one arbitrarily
prefixed route?  Which is it?

The user shouldn't need to know anything about this, and I will
be strongly against any design which puts the onus on the user
to configure a table that will fit into the chip.
