From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Sun, 14 Jun 2009 22:54:07 -0700
Message-ID: <65634d660906142254q4afb8f1ta63176817968c43d@mail.gmail.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
	 <20090610.012342.121254416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:36551 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbZFOFyK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 01:54:10 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n5F5sBr0020242
	for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 06:54:12 +0100
Received: from qw-out-1920.google.com (qwj9.prod.google.com [10.241.195.73])
	by zps36.corp.google.com with ESMTP id n5F5s7gh022979
	for <netdev@vger.kernel.org>; Sun, 14 Jun 2009 22:54:07 -0700
Received: by qw-out-1920.google.com with SMTP id 9so1982417qwj.54
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2009 22:54:07 -0700 (PDT)
In-Reply-To: <20090610.012342.121254416.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 1:23 AM, David Miller<davem@davemloft.net> wrot=
e:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 3 May 2009 21:03:01 -0700
>
>> This is an update of the receive packet steering patch (RPS) based o=
n received
>> comments (thanks for all the comments). =A0Improvements are:
>>
>> 1) Removed config option for the feature.
>> 2) Made scheduling of backlog NAPI devices between CPUs lockless and=
 much
>> simpler.
>> 3) Added new softirq to do defer sending IPIs for coalescing.
>> 4) Imported hash from simple_rx_hash. =A0Eliminates modulo operation=
 to convert
>> hash to index.
>> 5) If no cpu is found for packet steering, then netif_receive_skb pr=
ocesses
>> packet inline as before without queueing. =A0In paritcular if RPS is=
 not
>> configured on a device the receive path is unchanged from current fo=
r
>> NAPI devices (one additional conditional).
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> Just to keep this topic alive, I want to mention two things:
>
> 1) Just the other day support for the IXGBE "Flow Director" was
> =A0 added to net-next-2.6, it basically does flow steering in
> =A0 hardware. =A0It remembers where the last TX for a flow was
> =A0 made, and steers RX traffic there.
>
> =A0 It's essentially a HW implementation of what we're proposing
> =A0 here to do in software.
>

That's very cool.  Does it preserve in order delivery?

> 2) I'm steadily still trying to get struct sk_buff to the point
> =A0 where we can replace the list handling implementation with a
> =A0 standard "struct list_head" and thus union that with a
> =A0 "struct call_single_data" so we can use remote cpu soft-irqs
> =A0 for software packet flow steering.
>

I took another look at that an I have to wonder if it might be overly
complicated somehow.  Seems like this use of the call_single_data
structures would be essentially creating another type of skbuff list
than sk_buff_head (but without qlen which I think still may be
important).  I'm not sure that there's any less locking in that method
either.  What is the advantage over using a shared skbuff queue and
making doing a single IPI to schedule the backlog device on the remote
CPU?
