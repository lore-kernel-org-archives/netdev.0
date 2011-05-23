From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 15:05:54 -0700
Message-ID: <m1y61x2htp.fsf@fess.ebiederm.org>
References: <4DDAB72B.9050101@gmail.com> <4DDAC26C.2070601@candelatech.com>
	<20110523140048.777fb378@nehalam>
	<20110523.172047.1438754754048434316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50632 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757730Ab1EWWGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 18:06:02 -0400
In-Reply-To: <20110523.172047.1438754754048434316.davem@davemloft.net> (David
	Miller's message of "Mon, 23 May 2011 17:20:47 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 23 May 2011 14:00:48 -0700
>
>> IMHO the REORDER_HDR flag was a design mistake. It means supporting
>> two different API's for the application. For a packet capture application
>> it means the format of the packet will be different based on how
>> the VLAN was created. And the vlan was created outside the application.
>> 
>> If there was a requirement to support both formats, then it should
>> be a property of the AF_PACKET socket.  The application can then do
>> an setsockopt() to control the format of the data. The issue is
>> for things like mmap/AF_PACKET the re-inserted form will be slower
>> since data has to be copied.
>
> Indeed, it was a foolish thing to support in the first place.
>
> I guess we couldn't see the hw offloads in the future at that
> point.
>
> I'm all for finding a way to deprecate this over time.


There are two very similar issues here, that affect two
slightly different cases.

Let's assume the configuration is:
eth0 - Talks to the outside world.
vlan2000 - Is the vlan interface of interest.


With REORDER_HDR set when I tcpdump on vlan2000 I don't see the
vlan header, however I continue to see the vlan header when I tcpdump on eth0.

With vlan hardware acceleration.  When I tcpdump on eth0 I don't
see the vlan header.  Nor do I see the vlan header when I tcpdump
on vlan2000.


Right now both cases are problematic in Linus's tree.

For inbound packets We are testing the wrong interface for the to see if
we should play with REORDER_HDR.

Hardware acceleration vlan tagging we are hiding the vlan header from
portable applications that simply dump eth0.  Which is non-intuitive
and apparent to everyone now that this happens on both software and
hardware interfaces.


So we have a couple of questions.
1) Do we revert the software emulation of vlan header tagging to fix
   it's implementation issues in 2.6.40?

   The big issues.
   - vlan_untag is currently reading undefined data.
   - Clearing REORDER_HDR no longer works.

   I expect the issues are small enough that we can address them now.

2) Do we instead move the software implementation of vlan header
   acceleration back into the net-next.

3) What do we do with pf_packet and vlan hardware acceleration when
   dumping not the vlan interface but the interface below the vlan
   interface?

   Do we provide an option to keep the vlan header?  Should that option
   be on by default?

Eric
