From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Sat, 03 Aug 2013 01:29:41 +0200
Message-ID: <51FC40E5.6050809@redhat.com>
References: <1375461665-4186-1-git-send-email-nikolay@redhat.com>  <20130802.153212.1340051334413929810.davem@davemloft.net> <1375485466.4457.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net, fubar@us.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754289Ab3HBX3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 19:29:48 -0400
In-Reply-To: <1375485466.4457.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 01:17 AM, Eric Dumazet wrote:
> On Fri, 2013-08-02 at 15:32 -0700, David Miller wrote:
> 
>> Handling this specially in bonding isn't really ideal.
>>
>> Please either hide this detail in dev_trans_start(), or (preferrably)
>> have vlan_dev_hard_start_xmit() set the trans_start timestamp
>> properly thus making this just work for everything.
> 
> vlan is LLTX, so setting the timestamp would incur false sharing on
> multiqueue.
> 
Yeah, this statement actually explains a lot for me, thanks :-)
I knew it was because of the LLTX, but I was wondering about the possible
reasons for the xmit_lock_owner check.
So basically the arp monitoring (or any dev_trans_start code) won't work
with LLTX devices because they don't get their trans_start updated (not the
txq trans_start nor the dev->trans_start), is this correct ?
But what if the txqs get bound to a particular CPU, then the txq
trans_start is okay to be updated I suppose.

Nik
> But it's true we need a helper, because many callers do
> 
> if (dev->priv_flags & IFF_802_1Q_VLAN)
>        dev = vlan_dev_real_dev(dev);
> 
> or the slighly better
> 
> if (is_vlan_dev(dev))
>    dev = vlan_dev_real_dev(dev);
> 
> 
> 
