From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/5 (resend)] veth: Allow to create peer link with given
 ifindex
Date: Wed, 08 Aug 2012 13:00:51 +0400
Message-ID: <50222AC3.8090801@parallels.com>
References: <501FD0F2.4040609@parallels.com>  <501FD14F.2040209@parallels.com> <5020F5AB.3090101@parallels.com> <1344364573.2688.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7512 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470Ab2HHJBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2012 05:01:04 -0400
In-Reply-To: <1344364573.2688.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2012 10:36 PM, Ben Hutchings wrote:
> On Tue, 2012-08-07 at 15:02 +0400, Pavel Emelyanov wrote:
>> The ifinfomsg is in there (thanks kaber@ for foreseeing this long time ago),
>> so take the given ifidex and register netdev with it.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>> ---
>>  drivers/net/veth.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>> index 5852361..496c026 100644
>> --- a/drivers/net/veth.c
>> +++ b/drivers/net/veth.c
>> @@ -348,6 +348,9 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
>>  	if (tbp[IFLA_ADDRESS] == NULL)
>>  		eth_hw_addr_random(peer);
>>  
>> +	if (ifmp)
>> +		peer->ifindex = ifmp->ifi_index;
>> +
>>  	err = register_netdevice(peer);
>>  	put_net(net);
>>  	net = NULL;
> 
> Is this safe, given that this code path previously ignored
> ifmp->ifi_index?  Userland could be passing in garbage and may now fail
> occasionally because the value clashes with an existing interface.

You're right, I've missed that fact :( The good news is that we still can
use the ifmp->ifi_index for the peer index configuration. We just need to
assume that if the caller specified the ifindex for the veth master device,
then it's aware of this possibility and should explicitly configure (or set
to 0) the peer's ifindex as well. Like this:

	if (ifmp && (dev->ifindex != 0))
		peer->ifindex = ifmp->ifi_index;

Does this assumption work from you POV?

> Ben.
> 

Thanks,
Pavel
