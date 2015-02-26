From: roopa <roopa@cumulusnetworks.com>
Subject: Re: ARP resolving for switch drivers
Date: Wed, 25 Feb 2015 21:56:49 -0800
Message-ID: <54EEB5A1.1000706@cumulusnetworks.com>
References: <20150222.011109.109641758308879034.davem@davemloft.net> <CAE4R7bCV1+oA8i52i8g=+yEwsoApcAQq5-WeTxgN40v-ai7y+A@mail.gmail.com> <CAE4R7bDnrMZSsZeZmYkT8HhkXUpgnedBo8VX5iEtyJmzJ7gV5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38303 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbbBZF4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 00:56:51 -0500
Received: by pdbfp1 with SMTP id fp1so10530428pdb.5
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 21:56:50 -0800 (PST)
In-Reply-To: <CAE4R7bDnrMZSsZeZmYkT8HhkXUpgnedBo8VX5iEtyJmzJ7gV5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/15, 9:08 PM, Scott Feldman wrote:
> On Sat, Feb 21, 2015 at 10:28 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>> On Sat, Feb 21, 2015 at 10:11 PM, David Miller <davem@davemloft.net> wrote:
>>> Scott I looked into the current state of affairs and you should
>>> be able to use generic infrastructure to resolve a neighbour
>>> entry and even trigger the state machine.
>>>
>>> For ipv4:
>>>
>>>          n = __ipv4_neigh_lookup(dev, ip_addr);
>>>          if (!n)
>>>                  n = neigh_create(&arp_tbl, &ip_addr, dev, true);
>>>          if (!n)
>>>                  goto error;
>>>
>>>          if (!(n->nud_state & NUD_VALID))
>>>                  neigh_event_send(n, NULL);
>>>          else
>>>                  memcpy(&hw_entry->mac_addr, n->ha, dev_addr_len);
>>>
>>> If you have to take the neigh_event_send() path, you have to wait for
>>> the notifier to be invoked.  And in the notifier you can fetch the
>>> MAC address.
>> Perfect!  I'll give this a try shortly and test and report back.
>> (Trying to beat down some remaining L2 issues first).
>>
> David,
>
> Just following up on this.  The code above works great, at least for
> the initial nh resolution when route is installed.  I need to do some
> more testing for the cases when the neigh entry goes to !NUD_VALID,
> but I'm still holding a route with nhs looking for that neigh.  I
> guess I need to re-trigger the above code.  Need to play around with
> it.
>
> There are two other items I had on my list for L3 from netconf:
>
> 1) Routes that overlap tables, or how to assign priority.  I'll look
> at the RFC you sent for collapsing local/main tables.  For now, I used
> fib_info->fib_priority for the priority in the rocker L3 table.  Maybe
> that's good enough once local/main are collapsed?  But for other
> tables, I'm not sure if fib_info->fib_priority will be sufficient.  I
> probably need some guidance here.
>
> 2) Marking routes as "external"[1].  I added a RTAX_FEATURE_EXTERNAL
> bit to be set by application (iproute2, quagga, etc) when wanting to
> install route externally, for example to a switchdev switch.  Then if
> application sets bit, it is the applications responsibility to handle
> failure cases and rollback any lesser-prefixed routes than may have
> been pushed earlier, successfully to external.  The problem I'm
> running into is internal kernel routes need to be pushed to external
> and I don't want to mark those as "external", but I also want those to
> be install externally (to the device), if possible.
>
> [1] "external" seems to be the label we're giving kernel objects that
> get mirrored externally to a device, such as the mark we used for FDB
> entries populated into the bridge's FDB by a learning device.
scott,  don't mean to interrupt dave and your conversation here.
But, I am not seeing the hw learnt fdb entries to be same as
the routes from iproute2 or quagga.  In the fdb case, you had to mark it
external to indicate ownership of the entry to age it appropriately in 
the offload model
where both kernel and hw mirror fdb database and both can populate the 
fdb database.

I am not seeing the need to generalize the notion of  'external' used in 
fdb offloads across other sub-systems.
In this case  its the app (iproute2, quagga). What you want here is 
failure policy flags (as discussed @netdev01)
that user-space owns. And these should be optional with kernel having 
its own default policy (And default policy is where I am interested in :).

I guess I am re-iterating your intent but labeling it differently. :)

Thanks,
Roopa
