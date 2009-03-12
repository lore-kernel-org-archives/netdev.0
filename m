From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
	submit to upper layer
Date: Thu, 12 Mar 2009 16:16:32 +0800
Message-ID: <1236845792.2567.484.camel@ymzhang>
References: <1236761624.2567.442.camel@ymzhang>
	 <877i2wfh1l.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:57804 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752271AbZCLIRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 04:17:03 -0400
In-Reply-To: <877i2wfh1l.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-03-11 at 12:13 +0100, Andi Kleen wrote:
> "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> writes:
>=20
> > I got some comments. Special thanks to =C3=AF=C2=BB=C2=BFStephen He=
mminger for teaching me on
> > what reorder is and some other comments. Also thank other guys who =
raised comments.
>=20
>=20
> >
> > v2 has some improvements.
> > 1) Add new sysfs interface /sys/class/net/ethXXX/rx_queueXXX/proces=
sing_cpu. Admin
> > could use it to configure the binding between RX and cpu number. So=
 it's convenient
> > for drivers to use the new capability.
>=20

> Seems very inconvenient to have to configure this by hand.
A little, but not too much, especially when we consider there is interr=
upt binding.

>  How about
> auto selecting one that shares the same LLC or somesuch?
There are 2 kinds of LLC sharing here.
1) RX/TX share the LLC;
2) All RX share the LLC of some cpus and TX share the LLC of other cpus=
=2E

Item 1) is important, but sometimes item 2) is also important when the =
sending speed is
very high and huge data is on flight which flushes cpu cache quickly.
It's hard to distinguish the 2 different scenarioes automatically.

>  Passing
> data to anything with the same LLC should be cheap enough.
Yes, when the data isn't huge. My forwarding testing currently could re=
ach at 270M bytes per
second on Nehalem and I wish higher if I could get the latest NICs.


> BTW the standard idea to balance processing over multiple CPUs was to
> use MSI-X to multiple CPUs.
Yes. My method still depends on MSI-X and multi-queue. One difference i=
s I just need less than
CPU_NUM interrupt numbers as there are only some cpus working on packet=
 receiving.

>  and just use the hash function on the
> NIC.
Sorry. I can't understand what the hash function of NIC is. Perhaps NIC=
 hardware has something
like hash function to decide the RX queue number based on SRC/DST?

>  Have you considered this for forwarding too?
Yes. originally, I plan to add a tx_num under the same sysfs directory,=
 so admin could
define that all packets received from a RX queue should be sent out fro=
m a specific TX queue.
So struct sk_buff->queue_mapping would be a union of 2 sub-members, rx_=
num and tx_num. But
=EF=BB=BFsk_buff->queue_mapping is just a u16 which is a small type. We=
 might use the most-significant
bit of =EF=BB=BFsk_buff->queue_mapping as a flag as rx_num and tx_num w=
ouldn't exist at the
same time.

>  The trick here would
> be to try to avoid reordering inside streams as far as possible,
It's not to solve reorder issue. The start point is 10G NIC is very fas=
t. We need some cpu
work on packet receiving dedicately. If they work on other things, NIC =
might drop packets
quickly.

The sysfs interface is just to facilitate NIC drivers. If there is no t=
he sysfs interface,
driver developers need implement it with parameters which are painful.

>  but
> since the NIC hash should work on flow basis that should be ok.
Yes, hardware is good at preventing reorder. My method doesn't change t=
he order in software
layer.

Thanks Andi.


