From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under bond
Date: Mon, 10 Oct 2011 19:43:03 -0700
Message-ID: <CAEP_g=83tCQMVPOTT82GBw6GamodpqU-SAeYyx9noWnzbGfUpg@mail.gmail.com>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
 <20111010223752.GB2373@minipsycho> <4E93A4D2.10301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44942 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab1JKCnY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 22:43:24 -0400
Received: by vws1 with SMTP id 1so5149540vws.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 19:43:23 -0700 (PDT)
In-Reply-To: <4E93A4D2.10301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2011 at 7:07 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 10/10/2011 3:37 PM, Jiri Pirko wrote:
>> Mon, Oct 10, 2011 at 09:16:41PM CEST, john.r.fastabend@intel.com wro=
te:
>>> The following configuration used to work as I expected. At least
>>> we could use the fcoe interfaces to do MPIO and the bond0 iface
>>> to do load balancing or failover.
>>>
>>> =C2=A0 =C2=A0 =C2=A0 ---eth2.228-fcoe
>>> =C2=A0 =C2=A0 =C2=A0 |
>>> eth2 -----|
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|---- bond0
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|
>>> eth3 -----|
>>> =C2=A0 =C2=A0 =C2=A0 |
>>> =C2=A0 =C2=A0 =C2=A0 ---eth3.228-fcoe
>>>
>>> This worked because of a change we added to allow inactive slaves
>>> to rx 'exact' matches. This functionality was kept intact with the
>>> rx_handler mechanism. However now the vlan interface attached to th=
e
>>> active slave never receives traffic because the bonding rx_handler
>>> updates the skb->dev and goto's another_round. Previously, the
>>> vlan_do_receive() logic was called before the bonding rx_handler.
>>>
>>> Now by the time vlan_do_receive calls vlan_find_dev() the
>>> skb->dev is set to bond0 and it is clear no vlan is attached
>>> to this iface. The vlan lookup fails.
>>>
>>> This patch moves the VLAN check above the rx_handler. A VLAN
>>> tagged frame is now routed to the eth2.228-fcoe iface in the
>>> above schematic. Untagged frames continue to the bond0 as
>>> normal. This case also remains intact,
>>>
>>> eth2 --> bond0 --> vlan.228
>>>
>>> Here the skb is VLAN tagged but the vlan lookup fails on eth2
>>> causing the bonding rx_handler to be called. On the second
>>> pass the vlan lookup is on the bond0 iface and completes as
>>> expected.
>>>
>>> Putting a VLAN.228 on both the bond0 and eth2 device will
>>> result in eth2.228 receiving the skb. I don't think this is
>>> completely unexpected and was the result prior to the rx_handler
>>> result.
>>>
>>> Note, the same setup is also used for other storage traffic that
>>> MPIO is used with eg. iSCSI and similar setups can be contrived
>>> without storage protocols.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>> ---
>>>
>>> net/core/dev.c | =C2=A0 22 +++++++++++-----------
>>> 1 files changed, 11 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 70ecb86..8b6118a 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -3231,6 +3231,17 @@ another_round:
>>> ncls:
>>> #endif
>>>
>>> + =C2=A0 =C2=A0if (vlan_tx_tag_present(skb)) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (pt_prev) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0pt_prev =3D NULL;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vlan_do_receive(&skb=
))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0goto another_round;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else if (unlikely(!skb))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0goto out;
>>> + =C2=A0 =C2=A0}
>>> +
>>> =C2=A0 =C2=A0 =C2=A0rx_handler =3D rcu_dereference(skb->dev->rx_han=
dler);
>>> =C2=A0 =C2=A0 =C2=A0if (rx_handler) {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (pt_prev) {
>>> @@ -3251,17 +3262,6 @@ ncls:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>> =C2=A0 =C2=A0 =C2=A0}
>>>
>>> - =C2=A0 =C2=A0if (vlan_tx_tag_present(skb)) {
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (pt_prev) {
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0pt_prev =3D NULL;
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vlan_do_receive(&skb=
))
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0goto another_round;
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else if (unlikely(!skb))
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0goto out;
>>> - =C2=A0 =C2=A0}
>>> -
>>> =C2=A0 =C2=A0 =C2=A0/* deliver only exact match when indicated */
>>> =C2=A0 =C2=A0 =C2=A0null_or_dev =3D deliver_exact ? skb->dev : NULL=
;
>>>
>>>
>>
>> Hmm, I must look at this again tomorrow but I have strong feeling th=
is
>> will break some some scenario including vlan-bridge-macvlan.
>
> Yes please review... I tested cases with vlan, bridge, and macvlan
> components and believe this works unless I missed something.
>
> Maybe Jesse, can comment though on why this commit that moved (and
> cleaned up) the vlan tag handling put the vlan_do_receive below the
> rx_handler rather than above it. Was this intended to fix something?

The original reason was to ensure packets received from NICs that do
stripping behaved the same as those that don't.  At the time, the
packets with inline vlan tags were handled by the same code that
handled upper layer protocols so it was important that code for vlan
stripped tags be immediately before that.  Otherwise, packets might be
taken either by the bridge hook or vlan code depending the the type of
device.

However, that's no longer an issue because we now emulate vlan
acceleration by untagging packets at the beginning of
__netif_receive_skb(), so the code path will always be the same.
=46urthermore, based on feedback received since that patch it seems
pretty clear that people prefer the behavior where vlan devices take
traffic first, so now that we can have both that and consistent
behavior it seems to be the way to go.

This looks correct to me:
Acked-by: Jesse Gross <jesse@nicira.com>
