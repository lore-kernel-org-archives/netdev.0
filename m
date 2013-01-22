From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 14:38:03 -0800
Message-ID: <CAEP_g=_AebncQ6_tHDA0rN=ya4tAqpN2i8FuQ1hqa8mOgj_AJA@mail.gmail.com>
References: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
 <1358892199.12374.139.camel@edumazet-glaptop> <20130122.170826.1481012610894653735.davem@davemloft.net>
 <1358892924.12374.157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, pshelar@nicira.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:48248 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752683Ab3AVWiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 17:38:23 -0500
Received: by mail-oa0-f70.google.com with SMTP id k14so38675096oag.9
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 14:38:23 -0800 (PST)
In-Reply-To: <1358892924.12374.157.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 2:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-01-22 at 17:08 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 22 Jan 2013 14:03:19 -0800
>>
>> > An application changing data provided on a sendfile() or vmsplice() cant
>> > really expect data integrity being respected, even if checksum are done
>> > by the NIC (TSO)
>> >
>> > So if data integrity is not respected, just send a bogus TX checksum.
>>
>> I disagree.
>>
>> As a quality of implementation decision, we should always compute
>> correct checksums, ragardless of whether the page contents can be
>> modified asynchronously during the packet transmit.
>
> The retransmits will compute the correct checksums.
>
> For a very unlikely operation from the user, we want to disable GSO on
> GRE.

We're currently enforcing this assumption in the rest of the network
stack - it's why we mask out scatter/gather capability in the NIC if
it isn't capable of checksumming the packet.

Packets with asynchronous changes may come from VMs, so it isn't
necessarily reasonable to tell people that they need to disable
offloads with certain use cases.

As Pravin said, pushing down the GSO to the lowest layer is the best
way to solve the problem.  However, I would argue that the current
behavior is not correct.
