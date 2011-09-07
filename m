From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/11] netlink: implement memory mapped sendmsg()
Date: Wed, 07 Sep 2011 17:22:00 +0200
Message-ID: <4E678C18.1010306@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net> <1315070771-18576-9-git-send-email-kaber@trash.net> <20110904161822.GA8176@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61795 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127Ab1IGQQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 12:16:38 -0400
In-Reply-To: <20110904161822.GA8176@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.09.2011 18:18, Micha=C5=82 Miros=C5=82aw wrote:
> On Sat, Sep 03, 2011 at 07:26:08PM +0200, kaber@trash.net wrote:
>> From: Patrick McHardy <kaber@trash.net>
>>
>> Add support for memory mapped sendmsg() to netlink. Userspace queued=
 to
>> be processed frames into the TX ring and invokes sendmsg with
>> msg.iov.iov_base =3D NULL to trigger processing of all pending messa=
ges.
>>
>> Since the kernel usually performs full message validation before beg=
inning
>> processing, userspace must be prevented from modifying the message
>> contents while the kernel is processing them. In order to do so, the
>> frames contents are copied to an allocated skb in case the the ring =
is
>> mapped more than once or the file descriptor is shared (f.i. through
>> AF_UNIX file descriptor passing).
>>
>> Otherwise an skb without a data area is allocated, the data pointer =
set
>> to point to the data area of the ring frame and the skb is processed=
=2E
>> Once the skb is freed, the destructor releases the frame back to use=
rspace
>> by setting the status to NL_MMAP_STATUS_UNUSED.
>=20
> Is this protected from threads? Like: one thread waits on sendmsg() a=
nd
> another (same process) changes the buffer.

Yes, if the ring is mapped multiple times (or the file descriptor
is changed), the contents are copied to an allocated skb.
