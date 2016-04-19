From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: switchdev fib offload issues
Date: Tue, 19 Apr 2016 09:21:17 +0200
Message-ID: <20160419072117.GC1958@nanopsycho.orion>
References: <20160418154757.GA2059@nanopsycho.amit.cz>
 <20160418.135227.1430871435945779629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com, dsa@cumulusnetworks.com, f.fainelli@gmail.com,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com, tgraf@suug.ch,
	aduyck@mirantis.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34836 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbcDSHVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 03:21:21 -0400
Received: by mail-wm0-f47.google.com with SMTP id e201so2551905wme.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 00:21:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160418.135227.1430871435945779629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 18, 2016 at 07:52:27PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 18 Apr 2016 17:47:57 +0200
>
>> However, if for any reason the switchdev add operation fails, there is an
>> abort function called (switchdev_fib_ipv4_abort). This function does two
>> things which are both unfortunate in many usecases:
>> 1) evicts all fib entries from HW leaving all processing done in kernel
>>     - For Spectrum ASIC this means that all traffic running at 100G between
>>       all ports is immediately downgraded to ~1-3Gbits
>>     - Also this happens silently, user knows nothing about anything went wrong,
>>       only forwarding performance suddenly sucks.
>> 
>> 2) sets net->ipv4.fib_offload_disabled = true
>>     - That results in no other fib entry being offloaded, forever,
>>       until net is removed and added again, machine reboot is required
>>       in case if init_ns
>> 
>> These 2 issues makes fib offload completely unusable. So I propose
>> to start thinking about fixing this.
>> 
>> I believe that although the current behaviour might be good for default,
>> user should be able to change it by setting a different policy. This
>> policy will allow to propagate offload error to user.
>
>There were many length discussions about this.

I know. I wouln't start this one if the 2 issues I described did not exist.


>
>It is extremely hard to load a partial table into the chip and
>have it work correctly.  This is because with longest matching
>prefix you have to pull out the least specific routing entires
>and process them in software.

Agreed. My my policy change did not change this behavious. the tables
would still be in since. Only capacity of kernel table would be limited
by capacity of HW table for that policy.


>
>Also, there is no communication about what makes an entry not be
>insertable or not.  So it may be the case that the shorter prefixes
>all fit into the table, because those can be compressed and take
>up less table space in the chip.
>
>So it's extremely hard to know when "room" is available again.  Room
>for what?  One 16-bit prefixed route?  Or room for one arbitrarily
>prefixed route?  Which is it?
>
>The user shouldn't need to know anything about this, and I will
>be strongly against any design which puts the onus on the user
>to configure a table that will fit into the chip.

I agree. User should not care and should not speculate if some rule fits
and some other does not. He should just try to add *anything* and see if
the operation was successful or not.
