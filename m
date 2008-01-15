From: slavon@bigtelecom.ru
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 00:46:02 +0300
Message-ID: <20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net>
	<478D226E.1050209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: Patrick McHardy <kaber@trash.net>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:46325 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbYAOVqG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 16:46:06 -0500
In-Reply-To: <478D226E.1050209@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Jarek Poplawski <jarkao2@gmail.com>:

> Patrick McHardy wrote, On 01/15/2008 05:05 PM:
>
>> Badalian Vyacheslav wrote:
>
> ...
>
>> Yes, packets in the old qdisc are lost.
>>
>>> Maybe if tc do changes - need create second queue (hash of rules or how
>>> you named it?) and do changes at it. Then replace old queue rules by
>>> created new.
>>> Logic -
>>> 1. Do snapshot
>>> 2. Do changes in shapshot
>>> 3. All new packets go to snapshot
>>> 4. If old queue not have packets - delete it.
>>> 5. Snapshot its default.
>>
>>
>> That doesn't really work since qdiscs keep internal state that
>> in large parts depends on the packets queued. Take the qlen as
>> a simple example, the new qdisc doesn't know about the packets
>> in the old one and will exceed the limit.
>
> But, some similar alternative to killing packets 'to death' could
> be imagined, I suppose (in the future, of course!). So, e.g. doing
> the switch automatically after last packet has been dequeued (maybe
> even with some 'special' function/mode for this). After all even
> with accuracy lost, it could be less visible for clients than
> current way?
>
> Regards,
> Jarek P.

Hmmm... i found way to fix this for me... but its not look good

Scheme look like:
Root - prio bands 3 priomap 0 0 0 0 ....
--- Class 1
--- Class 2
-------- Copy of all table (Last this qdisc be root)
--- Class 3
-------- Copy of all table (Last this qdisc be root)

2. Add filter to root - flowid all packets to class 2
3. Delete qdisc at class 3
4. Create all table on class 3 (~20k qdiscs and 20k classes)
5. Replace filter on root - flowid all packets to class 3
6. If need update go to step 3, but use class 2

All work good... and packets not dropeed =)
But i have above 45 k classes and qdiscs.... After some time i will  
need patch to up max qdisc and classes more then 65k (> 0xfffe) =)))
Also i have very bad TC commands performance then i have more then 10k rules.

Thanks =)

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

