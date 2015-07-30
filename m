From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()
Date: Fri, 31 Jul 2015 01:15:15 +0200
Message-ID: <CA++eYdsHw0-2rs1JB-VXiRwwGGCYpS5viW9EMb9sEK7nDcQnYQ@mail.gmail.com>
References: <CA++eYdtOendgSVix0aibj_Ykd=7td4ac3z9Zz1c_p67Xy3bWYw@mail.gmail.com>
	<20150730213225.GA11294@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	sbohrer@rgmadvisors.com, netdev <netdev@vger.kernel.org>,
	Yurij.Plotnikov@oktetlabs.ru, David Miller <davem@davemloft.net>,
	=?UTF-8?Q?St=C3=A5le_Kristoffersen?= <stalk@bridgetech.tv>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33644 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbbG3XPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 19:15:18 -0400
Received: by wicmv11 with SMTP id mv11so38208717wic.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 16:15:15 -0700 (PDT)
In-Reply-To: <20150730213225.GA11294@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2015 at 11:32 PM, Shawn Bohrer <shawn.bohrer@gmail.com>=
 wrote:
> On Thu, Jul 30, 2015 at 10:26:08PM +0200, Kenneth Klette Jonassen wro=
te:
>> Commit 6e54030 breaks the IP_MULTICAST_ALL socket option. There is
>> already a check in ip_mc_sf_allow() that should do the filtering you
>> claim to fix. Was it considered?
>>
>> Commit message:
>> 421b3885bf6d56391297844f43fb7154a6396e12 "udp: ipv4: Add udp early
>> demux" introduced a regression that allowed sockets bound to INADDR_=
ANY
>> to receive packets from multicast groups that the socket had not joi=
ned...
>>
>> man ip(7):
>> IP_MULTICAST_ALL (since Linux 2.6.31)
>> This option can be used to modify the delivery policy of
>> multicast messages to sockets bound to the wildcard INADDR_ANY
>> address.  The argument is a boolean integer (defaults to 1).
>> If set to 1, the socket will receive messages from all the
>> groups that have been joined globally on the whole system.
>> Otherwise, it will deliver messages only from the groups that
>> have been explicitly joined=E2=80=A6
>
> Do you have an application or test case that is now broken after this
> commit?  Or is this just a theoretical breakage based off of my commi=
t
> message?  If you have a simple example test case can you share it?
> Also if this breaks your application but you don't have a test case
> can you describe the breakage?  Is IP_MULTICAST_ALL 0 or 1?  Are you
> not receiving packets or receiving packets you don't expect to
> receive?
>
> I admittedly haven't tried to create a test case yet, but looking ove=
r
> the code I'm not sure how this could have broken IP_MULTICAST_ALL.
> Commit 6e54030 added a call to ip_check_mc_rcu() which as far as I ca=
n
> tell checks to see that a received multicast packet was a mc address
> joined on that interface.

Ah, ok. Thanks for the clarification. Feedback was based on your
commit message, as we already had the per-socket check in
ip_mc_sf_allow() when mc_all=3D=3D0. Since ip_check_mc_rcu() is really =
a
per-device check, it should be ok.

> Without this check it is possible to
> receive multicast packets for an address that hasn't been joined on
> that machine at all.  Which was the bug I was fixing.

Agreed. It is really filtering inadvertently received multicast packets=
=2E

Then we should probably move the ip_early_demux code from
ip_rcv_finish() to ip_route_input_noref()? As is, we now call
ip_check_mc_rcu() twice for some workloads, i.e., once for a failed
early_demux(), then again right before ip_route_input_slow().
