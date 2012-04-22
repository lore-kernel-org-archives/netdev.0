From: David Miller <davem@davemloft.net>
Subject: Re: use-after-free in usbnet
Date: Sat, 21 Apr 2012 22:05:14 -0400 (EDT)
Message-ID: <20120421.220514.2239176260944047457.davem@davemloft.net>
References: <CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
	<20120421.152345.290988116097275353.davem@davemloft.net>
	<CA+v9cxbdQW1idnxes95vHMS+j2XPFw4fDfaDLbJa7enMnyq6LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tom.leiming@gmail.com, oneukum@suse.de, stern@rowland.harvard.edu,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, kernel-team@fedoraproject.org
To: huajun.li.lee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45051 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab2DVCFe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 22:05:34 -0400
In-Reply-To: <CA+v9cxbdQW1idnxes95vHMS+j2XPFw4fDfaDLbJa7enMnyq6LQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Huajun Li <huajun.li.lee@gmail.com>
Date: Sun, 22 Apr 2012 09:45:55 +0800

> On Sun, Apr 22, 2012 at 3:23 AM, David Miller <davem@davemloft.net> w=
rote:
>> From: Ming Lei <tom.leiming@gmail.com>
>> Date: Sat, 21 Apr 2012 09:49:51 +0800
>>
>>> I see the problem, so looks skb_queue_walk_safe is not safe.
>>> I don' know why the 2nd ' tmp =3D skb->next' in =A0skb_queue_walk_s=
afe
>>> is needed and it may become unsafe if skb is freed during current l=
oop.
>>
>> I can't see what the problem is, skb_queue_walk_safe() is perfect
>> and does exactly what it advertises to do.
>>
>> If 'skb' is unlinked inside of an skb_queue_walk_safe() loop, that's
>> fine, because we won't touch 'skb' in the loop iteration tail code.
>>
>> Instead, before the loop contents, we pre-fetch skb->next into 'tmp'
>> and then at the end we move 'skb' forward by simply assigning 'tmp'.
>=20
> In this case, the problem is, 'tmp =3D skb->next' can be moved out of
> rxq/txq, and even be freed. Then in next loop cycle, 'skb =3D tmp' wi=
ll
> refer to a freed skb.  You know, in current code stack, unlink_urbs()
> releases q->lock in each loop, this gives chance to urb complete
> handler to call defer_bh() and cause the problem.

Right, just like interfaces such as list_for_each_entry_safe(), this
macro isn't designed to handle cases where you unlink more than one
entry in the list.  Specifically, it's designed only to handle the
case when you unlink the entry being processed in the current loop
iteration.
