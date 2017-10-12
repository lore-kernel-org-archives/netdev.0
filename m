From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] veth: tweak creation of veth device
Date: Thu, 12 Oct 2017 12:49:37 -0400
Message-ID: <85tvz4wbtq.fsf@mojatatu.com>
References: <1507666124-8780-1-git-send-email-mrv@mojatatu.com>
        <20171011.151706.1844884518098480593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:48100 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752973AbdJLQtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 12:49:41 -0400
Received: by mail-io0-f194.google.com with SMTP id h70so6157678ioi.4
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 09:49:41 -0700 (PDT)
In-Reply-To: <20171011.151706.1844884518098480593.davem@davemloft.net> (David
        Miller's message of "Wed, 11 Oct 2017 15:17:06 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

>> When creating veth pair, at first rtnl_new_link() creates veth_dev, i.e.
>> one end of the veth pipe, but not registers it; then veth_newlink() gets
>> invoked, where peer dev is created _and_ registered, followed by veth_dev
>> registration, which may fail if peer information, that is VETH_INFO_PEER
>> attribute, has not been provided and the kernel will allocate unique veth
>> name.
>> 
>> So, we should ask the kernel to allocate unique name for veth_dev only
>> when peer info is not available.
>> 
>> Example:
>> 
>> % ip link dev veth0 type veth
>> RTNETLINK answers: File exists
>> 
>> After fix:
>> % ip link dev veth0 type veth
>> % ip link show dev veth0
>> 5: veth0@veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>>     link/ether f6:ef:8b:96:f4:ec brd ff:ff:ff:ff:ff:ff
>> %
>> 
>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>
> I'm not so sure about this.
>
> If we specify an explicit tb[IFLA_NAME], we shouldn't completely ignore that
> request from the user just because they didn't give any peer information.
>
> I see what happens in this case, the peer gets 'veth0' and then since
> the user asked for 'veth0' for the non-peer it conflicts.

So, the only way is to require user space to _always_ pass in
VETH_INFO_PEER, which may break existing code (fixing iproute2 is easiest).

Otherwise ignore netlink messages lacking of VETH_INFO_PEER and return
error.

IMO, neither of these solutions seem reasonable.

Also, there are valid use cases where a user does not care about veth
name sitting in container, but assigns a name following certain
pattern to a host-side veth.

> Well, too bad.  The user must work to orchestrate things such that
> this doesn't happen.  That means either providing the IFLA_NAME for
> both the peer and the non-peer, or specifying neither.
>
> I'm not applying this, sorry.
