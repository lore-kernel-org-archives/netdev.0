From: Samir Bellabes <sbellabes@mandriva.com>
Subject: Re: [PATCH] Network Events Connector
Date: Mon, 02 Oct 2006 14:57:55 +0200
Message-ID: <m2r6xqg9ik.fsf@cerbere.dyndns.info>
References: <m23ba7gscl.fsf@cerbere.dyndns.info>
	<20061002090222.GA32591@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 188.235.97-84.rev.gaoland.net ([84.97.235.188]:55455 "EHLO
	cerbere.dyndns.info") by vger.kernel.org with ESMTP id S932275AbWJBM66
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 08:58:58 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061002090222.GA32591@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Mon, 2 Oct 2006 13:02:22 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> On Mon, Oct 02, 2006 at 08:11:06AM +0200, Samir Bellabes (sbellabes@mandriva.com) wrote:
>> 
>> This patch adds a connector which reports networking's events to
>> userspace. It's sending events when a sock has its sk_state changed to :
>>   - LISTEN or CLOSE for DCCP and TCP
>>   - BIND or CLOSE for UDP.
>> 
>> With this notification, a userspace tool can ask the user if he want to
>> let the local firewall open for the corresponding sport or not, and if
>> so open the firewall for the application which get the corresponding sport.
>> 
>> For people behind a firewall (non-running in the user box) we can have a
>> authentification between the user box, which have set the port to state
>> TCP_LISTEN for example, and the firewall, in a such way that the
>> firewall's router will forward incoming packet for this port to the user
>> box.
>> 
>> It will avoid adding specific rules to the user's firewall-script, and
>> let the firewall be more interactive for users.
>> 
>> Signed-off-by: Samir Bellabes <sbellabes@mandriva.com>
>
> Interesting... Mybe it even prints the name of the application which is
> trying to change port state?

Yes, of course, the name of the application is a part of the 'trusted
system'. But i think we can look for the application which gets the
inode corresponding to the sock in userspace, using the /proc/<pid>
files. 
Whithout this, we have to lookup all the process in kernel, in order to
find the one which old the sock. It's time consumming, even if the kind
of event involved (listening/close port) doesn't occur so often.
But if you think the kernel can do that, it's not a problem, i have code
to do that.

In fact the '$PATH/apps' is the complete info we need. With it,
we can ask the user, and we can check with the 'distro' tools (urpmi,
apt-get, smart) if the '$PATH/apps' really belongs to the distro and
should be trust.

I'm working also in a option on this, in order to avoid some 'false
positive', because some ports don't need to be 'open' in the firewall,
using conntrack.
As a example, you can take ftp's client, which will own a listening port
when it will received data from server, but the ip/nf_conntrack_ftp will
do the jobs for us, in order to let the data coming in.
This current patch will send the information that the ftp's client is
listening on a port (and a userspace tool will ask the user about what
to do with this) but the ip_conntrack as already did the job.

> I have couple of comments about structures you use, otherwise it looks
> good, although I do not know if it is ok or not ok to include it into
> mainline tree.
> From one point of view it is small and interesting piece of code, from other
> point it is not clear if such functionality is needed...

ok.

> Btw, you could also create netlink/connector based firewall rules
> update, I think people with hundreds of rules in one table will bless
> you after that.

This is the real goal, using ipset - http://ipset.netfilter.org/
With this we can easily create a uniq rule for iptables, and then
add/remove port from the 'set' involve.


>> +#ifndef CN_NET_H
>> +#define CN_NET_H
>> +
>> +#include <linux/time.h>
>> +#include <linux/ipv6.h>
>> +
>> +/*
>> + * Userspace sends this enum to register with the kernel that it is listening
>> + * for events on the connector.
>> + */
>> +enum cn_net_status {
>> +	CN_NET_LISTEN = 1,
>> +	CN_NET_IGNORE = 2
>> +};
>> +
>> +struct net_event {
>> +	enum event {
>> +		NET_EVENT_NONE		= 0x00000000,
>> +		NET_EVENT_TCP_LISTEN	= 0x00000001,
>> +		NET_EVENT_TCP_CLOSE	= 0x00000002,
>> +		NET_EVENT_UDP_BIND	= 0x00000004,
>> +		NET_EVENT_UDP_CLOSE	= 0x00000008,
>> +		NET_EVENT_DCCP_LISTEN	= 0x00000010,
>> +		NET_EVENT_DCCP_CLOSE	= 0x00000020,
>> +		NET_EVENT_MAX		= 0x80000000
>> +	} event;
>> +	struct timespec timestamp;
>
> Doesn't this monster have different size in 64 and 32 bit
> environments?

I see.

>> +	union {
>> +		struct {
>> +			__u32 err;
>> +		} ack;
>> +		
>> +		struct {
>> +			unsigned int family;
>> +			union {
>> +				struct in6_addr ipv6;
>> +				unsigned long ipv4;
>
> Please no longs in code which is supposed to be used simultaneously in
> 32 and 64 bit environments.

Of course.

Thanks for you comments, i will send a new patch later today.
regars.
