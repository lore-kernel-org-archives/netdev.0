From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 21:07:38 +0100
Message-ID: <4AE8A48A.1060407@trash.net>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE7F859.7020105@gmail.com> <4AE895E8.60308@trash.net> <4AE89927.9090405@candelatech.com> <4AE8A098.8040207@trash.net> <4AE8A3C3.1070003@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64927 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbZJ1UHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 16:07:40 -0400
In-Reply-To: <4AE8A3C3.1070003@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> On 10/28/2009 12:50 PM, Patrick McHardy wrote:
> 
>>> And, even 1MB may not be enough for some scenarios.  So, probably
>>> best to
>>> let users over-ride the initial setting on cmd-line.  If not, then use
>>> a large value to start with.
>>
>> How about this? It uses 1MB as receive buf limit by default (without
>> increasing /proc/sys/net/core/rmem_max it will be limited by less
>> however) and allows to specify the size manually using "-rcvbuf X"
>> (-r is already used, so you need to specify at least -rc).
>>
>> Additionally rtnl_listen() continues on ENOBUFS after printing the
>> error message.
> 
> Looks good..except:
> 
> If rmem_max is smaller than 1M, will that cause setsocktopt to
> fail and thus fail early out of rtnl_open_byproto?

No, the kernel takes the value as a hint and only uses the
maximum allowable value:

	case SO_RCVBUF:
		/* Don't error on this BSD doesn't and if you think
		   about it this is right. Otherwise apps have to
		   play 'guess the biggest size' games. RCVBUF/SNDBUF
		   are treated in BSD as hints */

		if (val > sysctl_rmem_max)
			val = sysctl_rmem_max;

> Maybe we should only print errors but not return in that method
> when setsockopt fails?
> 
> In another project, I ended up trying ever smaller values until one
> worked in order to get near what the user wanted even if rmem_max
> was configured smaller.  Not sure if that is worth doing here or not.

I think it should be fine this way.
