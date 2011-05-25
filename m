From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] af-packet: Save reference to bound network device.
Date: Wed, 25 May 2011 15:05:10 -0700
Message-ID: <4DDD7D16.6030907@candelatech.com>
References: <1306360602-9672-1-git-send-email-greearb@candelatech.com> <20110525.180113.1194226831134092545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49167 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241Ab1EYWFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:05:12 -0400
In-Reply-To: <20110525.180113.1194226831134092545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2011 03:01 PM, David Miller wrote:
> From: greearb@candelatech.com
> Date: Wed, 25 May 2011 14:56:42 -0700
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This saves a network device lookup on each packet transmitted,
>> for sockets that are bound to a network device.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> You can't hold onto devices like this unless you also add a netdev
> event notifier that will release it.  Otherwise we'll hang on net
> driver module unload until the packet socket is closed.
>
> I don't think you really want to walk all pf-packet sockets on netdev
> events just to do this.

Doesn't this piece of code take care of that?
I tested with rmmod..but of course I could have missed something.

@@ -2266,6 +2284,10 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
  				}
  				if (msg == NETDEV_UNREGISTER) {
  					po->ifindex = -1;
+					if (po->bound_dev) {
+						dev_put(po->bound_dev);
+						po->bound_dev = NULL;
+					}
  					po->prot_hook.dev = NULL;
  				}
  				spin_unlock(&po->bind_lock);


>
> dev_get_by_index(,_rcu}() is insanely cheap, I doubt it's showing up
> on your profiles at all.

I admit it was a small change...maybe 5Mbps (from 165 to 170Mbps in
this particular test), but it did seem to improve things a bit.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

