From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Fri, 02 Aug 2013 16:59:07 -0700
Message-ID: <13712.1375487947@death.nxdomain>
References: <1375461665-4186-1-git-send-email-nikolay@redhat.com> <20130802.153212.1340051334413929810.davem@davemloft.net> <1375485466.4457.4.camel@edumazet-glaptop> <51FC40E5.6050809@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:36406 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab3HBX7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 19:59:13 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 2 Aug 2013 17:59:12 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 7A5561FF0044
	for <netdev@vger.kernel.org>; Fri,  2 Aug 2013 17:53:46 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r72Nx99J201634
	for <netdev@vger.kernel.org>; Fri, 2 Aug 2013 17:59:10 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r72Nx8Xd024569
	for <netdev@vger.kernel.org>; Fri, 2 Aug 2013 17:59:09 -0600
In-reply-to: <51FC40E5.6050809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>On 08/03/2013 01:17 AM, Eric Dumazet wrote:
>> On Fri, 2013-08-02 at 15:32 -0700, David Miller wrote:
>> 
>>> Handling this specially in bonding isn't really ideal.
>>>
>>> Please either hide this detail in dev_trans_start(), or (preferrably)
>>> have vlan_dev_hard_start_xmit() set the trans_start timestamp
>>> properly thus making this just work for everything.
>> 
>> vlan is LLTX, so setting the timestamp would incur false sharing on
>> multiqueue.
>> 
>Yeah, this statement actually explains a lot for me, thanks :-)
>I knew it was because of the LLTX, but I was wondering about the possible
>reasons for the xmit_lock_owner check.
>So basically the arp monitoring (or any dev_trans_start code) won't work
>with LLTX devices because they don't get their trans_start updated (not the
>txq trans_start nor the dev->trans_start), is this correct ?

	I think what Eric means is that it'll be a performance problem,
because the cache line with the trans_start field will be thrashed
between CPUs as updates compete with each other or inspection from
dev_trans_start.  I suspect it will work from a functional point of view
(unless I'm missing something).

	As a practical matter, it looks like bonding is at present the
only caller of dev_trans_start that passes either (a) a VLAN device, or
(b) a device other than itself (most drivers seem to use it for transmit
timeout detection on their own device).

	Having software devices set trans_start seems unnecessary
(bonding doesn't set it, either), since they'll generally have a
hardware device underneath with a real trans_start value.  It might be
hard to hunt down for tun, though.

>But what if the txqs get bound to a particular CPU, then the txq
>trans_start is okay to be updated I suppose.
>
>Nik
>> But it's true we need a helper, because many callers do
>> 
>> if (dev->priv_flags & IFF_802_1Q_VLAN)
>>        dev = vlan_dev_real_dev(dev);
>> 
>> or the slighly better
>> 
>> if (is_vlan_dev(dev))
>>    dev = vlan_dev_real_dev(dev);

	For just the bonding dev_trans_start() for a VLAN case, one of
the above in dev_trans_start() ought to be sufficient.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
