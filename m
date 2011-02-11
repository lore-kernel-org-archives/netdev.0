From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next-2.6 1/4] net: extend netlink interface to handle
 generic slave management
Date: Fri, 11 Feb 2011 16:48:19 +0100
Message-ID: <4D555A43.5000005@trash.net>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63746 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757380Ab1BKPsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 10:48:43 -0500
In-Reply-To: <20110211152125.GA2763@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.02.2011 16:21, Jiri Pirko wrote:
> Drivers like bridge and bonding uses their own way to manipulate with
> underlink devices. This is an attempt to introduce common interface using
> netlink.

Thanks for working on this, this has been on my TODO list for a
long time.

> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -136,6 +136,9 @@ enum {
>  	IFLA_PORT_SELF,
>  	IFLA_AF_SPEC,
>  	IFLA_GROUP,		/* Group the device belongs to */
> +	IFLA_SLAVE_LIST,
> +	IFLA_SLAVE_ADD,
> +	IFLA_SLAVE_DEL,

I don't like this very much though, the attributes usually contain
data, not commands. We already have NEWLINK, DELLINK etc. on the
top level, the combinations of NEWLINK/NLM_F_CREAT and SLAVE_DEL
or DELLINK and SLAVE_ADD and so on simply don't make sense.

We usually also try to keep the interface symetrical in both
directions (a NEWLINK message from the kernel is identical to a
NEWLINK message from userspace, a DELLINK message as well besides
containing additional information), so using different attributes
for dumping slaves than for adding them seems wrong. If we can
dump all slaves in one message, it should also be possible to
enslave multiple devices using the same message.

What I originally had planned to support enslaving devices is to
make use of the IFLA_MASTER attribute. The IFLA_MASTER attribute
would contain the bond or bridge ifindex and the IFLA_IFNAME
attribute or ifindex would specify the slave device. All operations
would be performed on the slave device as usual, if the IFLA_MASTER
attribute is present we'd additionally call a master specific
callback for enslaving or releasing slave devices. Besides allowing
to keep messages symetrical, an additional benefit is that it would
be possible to create and enslave a device in a single step.


