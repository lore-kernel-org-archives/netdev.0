From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: netlink: filter particular protocols from analyzers
Date: Thu, 05 Sep 2013 21:48:00 +0200
Message-ID: <5228DFF0.7070106@redhat.com>
References: <1378396127-8342-1-git-send-email-dborkman@redhat.com> <20130905.144442.2085221662776542385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752Ab3IETsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 15:48:07 -0400
In-Reply-To: <20130905.144442.2085221662776542385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2013 08:44 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu,  5 Sep 2013 17:48:47 +0200
>
>> From: Daniel Borkmann <dborkmann@redhat.com>
>>
>> Fix finer-grained control and let only a whitelist of allowed netlink
>> protocols pass, in our case related to networking. If later on, other
>> subsystems decide they want to add their protocol as well to the list
>> of allowed protocols they shall simply add it. While at it, we also
>> need to tell what protocol is in use otherwise BPF_S_ANC_PROTOCOL can
>> not pick it up (as it's not filled out).
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

To answer Stephen and Dave in one message ... ;-)

> This takes away functionality that I'd be more interesting in using,
> namely being able to listen to all netlink protocols using one tap.
>
> Seriously, when I first saw this feature, that was the first way I'd
> imagine myself using it, as a tcpdump for netlink traffic, all of
> it.
>
> If I just want to hear all netlink traffic, don't make me be forced to
> know every single NETLINK_* protocol value and have to open that many
> sockets just to do so.
>
> It also makes it so that I can't listen to userlevel custom netlink
> protocols, another minus of filtering.
>
> At the very least, allow an sk_protocol of zero or similar to have this
> meaning of "everything".

I agree with you with all the above and I think with having this in
tcpdump would be great to debug netlink traffic of course ...

With socket(PF_PACKET, ..., htons(ETH_P_ALL)) you will already get all
users from the suggested white-list of the patch, which is the majority
of netlink users I believe. Hence, you do not need to have one socket
per protocol. skbs from there should get dragged into pf_packet via
dev_queue_xmit_nit() which works on ptype_all list.

Plus, with the nskb->protocol addition in this patch, they can then either
take all netlink traffic from that, or filter with BPF e.g. for particular
protocols via BPF_S_ANC_PROTOCOL or more advanced stuff, for example. Also,
they can select particular dissectors with that information that comes in
via sll_protocol which is useful, of course.

I think for out-of-tree modules, we never really cared much, and they
could use generic netlink probably anyway. The thing why I wanted to
do this is to keep security related messages (audit, selinux) generally
under the radar, which is "more or less" what's remaining, so we still get
main users. This patch would accomplish those things, that's why I think
it's useful.
