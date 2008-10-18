From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Sat, 18 Oct 2008 09:38:46 +0200
Message-ID: <48F99286.9050706@hartkopp.net>
References: <1224253423.17450.211.camel@ecld0pohly> <48F96DD6.5060904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:26420 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbYJRHiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 03:38:54 -0400
In-Reply-To: <48F96DD6.5060904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
>
> Interesting stuff :)
>

Indeed.

> 1) You want hardware TX stamping on all frames sent behalf a given socket
>  Mark a WANT_HARDWARE_TX_STAMP flag at socket level
>   Copy this flag when generating skb for this socket.
>     When transmitting WANT_HARDWARE_TX_STAMP tagged frame to device,
>     dont feed it to dev_queue_xmit_nit() in dev_hard_start_xmit()
>     In NIC driver tx completion, test skb WANT_HARDWARE_TX_STAMP flag.
>     If set, get tstamp from hardware and copy it to skb tstamp,     
> and call dev_queue_xmit_nit() (we might avoid cloning skb there, since
>     nic driver doesnt need it anymore)
>
>  This flag could also be set at device level, for all sent frames. 
> (tcpdump new option)
>
> 2) You want hardware RX stamping on a particular device, yet being 
> able to
>   deliver system time to legacy apps, unaware of hardware tstamps.
>
>   Set a global flag on device, telling linux stack this device feeds 
> hardware stamp.
>   In driver RX completion, set skb tstamp with hardware stamps.
>
>   Mark a WANT_HARDWARE_RX_STAMP flag at socket level, for PTP 
> applications.
>
>   In recv(), if current socket is not marked WANT_HARDWARE_RX_STAMP 
> and device has
>   the global flag set, copy system time in tstamp, overrinding 
> hardware tstamp.
>
>

Looks good to me. Just one question regarding
'copy system time in tstamp, overrinding hardware tstamp':

When recv() delivers to several sockets there would be probably 
*different* system time values copied and delivered for the *same* skb, 
right?

If so i would tend to fill both (system time and hw timestamp) on driver 
level into the skb and then decide on socket level what to push into 
user space as you suggested above.

Regards,
Oliver

