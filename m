From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Sat, 03 Aug 2013 02:21:14 +0200
Message-ID: <51FC4CFA.8010706@redhat.com>
References: <1375461665-4186-1-git-send-email-nikolay@redhat.com>   <20130802.153212.1340051334413929810.davem@davemloft.net>  <1375485466.4457.4.camel@edumazet-glaptop> <51FC40E5.6050809@redhat.com> <1375488223.4457.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net, fubar@us.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28227 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab3HCAVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 20:21:22 -0400
In-Reply-To: <1375488223.4457.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 02:03 AM, Eric Dumazet wrote:
> On Sat, 2013-08-03 at 01:29 +0200, Nikolay Aleksandrov wrote:
> 
>> I knew it was because of the LLTX, but I was wondering about the possible
>> reasons for the xmit_lock_owner check.
>> So basically the arp monitoring (or any dev_trans_start code) won't work
>> with LLTX devices because they don't get their trans_start updated (not the
>> txq trans_start nor the dev->trans_start), is this correct ?
> 
> Nope : LLTX devices are supposed to update their own dev->trans_start
> I added for these case a special comment as in :
> 
> drivers/net/ethernet/atheros/atl1e/atl1e_main.c:1883:   netdev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
> 
Ah, didn't know about that, so there could be an LLTX device with proper
trans_start if it updates it itself. Fair enough.

> trans_start is a txq property, and vlan devices have a single txq.
> 
> Updating the vlandev->trans_start or the vlantxq->trans_start would be a
> performance killer on MQ ethernet.
> 
Yeah, that part I got, that's why I said it explains a lot for me earlier :-)

> And frankly, as this trans_start is really seldom queried, it makes no
> sense to set it on fast path on the vlan device, if its properly done on
> the real device anyway.
> 
>> But what if the txqs get bound to a particular CPU, then the txq
>> trans_start is okay to be updated I suppose.
> 
> Not sure what you are saying. vlan xmit can be called from any cpus.
> 
Never mind, I didn't notice that the 8021q dev has a single txq as you said.

Thanks for taking the time to explain all this.
