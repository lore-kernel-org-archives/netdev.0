From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] netlink: specify netlink packet
 direction for nlmon
Date: Tue, 31 Dec 2013 13:48:20 -0500 (EST)
Message-ID: <20131231.134820.1660434103068706486.davem@davemloft.net>
References: <1387788519-17722-1-git-send-email-dborkman@redhat.com>
	<1387788519-17722-3-git-send-email-dborkman@redhat.com>
	<52B813E8.8010508@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	darkjames-ws@darkjames.pl
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555Ab3LaSsW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 13:48:22 -0500
In-Reply-To: <52B813E8.8010508@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 23 Dec 2013 11:43:52 +0100

> Le 23/12/2013 09:48, Daniel Borkmann a =E9crit :
>> In order to facilitate development for netlink protocol dissector,
>> fill the unused field skb->pkt_type of the cloned skb with a hint
>> of the address space of the new owner (receiver) socket in the
>> notion of "to kernel" resp. "to user".
>>
>> At the time we invoke __netlink_deliver_tap_skb(), we already have
>> set the new skb owner via netlink_skb_set_owner_r(), so we can use
>> that for netlink_is_kernel() probing.
>>
>> In normal PF_PACKET network traffic, this field denotes if the
>> packet is destined for us (PACKET_HOST), if it's broadcast
>> (PACKET_BROADCAST), etc.
>>
>> As we only have 3 bit reserved, we can use the value (=3D 6) of
>> PACKET_FASTROUTE as it's _not used_ anywhere in the whole kernel
>> and packets of such type were never exposed to user space, so
>> there are no overlapping users of such kind. Thus, as wished,
>> that seems the only way to make both PACKET_* values non-overlapping
>> and therefore device agnostic.
>>
>> By using those two flags for netlink skbs on nlmon devices, they
>> can be made available and picked up via sll_pkttype (previously
>> unused in netlink context) in struct sockaddr_ll. We now have
>> these two directions:
>>
>>   - PACKET_USER (=3D 6)    ->  to user space
>>   - PACKET_KERNEL (=3D 7)  ->  to kernel space
>>
>> Partial `ip a` example strace for sa_family=3DAF_NETLINK with
>> detected nl msg direction:
>>
>> syscall:                     direction:
>> sendto(3,  ...) =3D 40         /* to kernel */
>> recvmsg(3, ...) =3D 3404       /* to user */
>> recvmsg(3, ...) =3D 1120       /* to user */
>> recvmsg(3, ...) =3D 20         /* to user */
>> sendto(3,  ...) =3D 40         /* to kernel */
>> recvmsg(3, ...) =3D 168        /* to user */
>> recvmsg(3, ...) =3D 144        /* to user */
>> recvmsg(3, ...) =3D 20         /* to user */
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Signed-off-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
>> ---
>>   v1->v2:
>>    - let PACKET_* values not overlap as wished by Dave
>>
>>   include/uapi/linux/if_packet.h | 4 +++-
>>   net/netlink/af_netlink.c       | 2 ++
>>   2 files changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/uapi/linux/if_packet.h
>> b/include/uapi/linux/if_packet.h
>> index e9d844c..06e2a28 100644
>> --- a/include/uapi/linux/if_packet.h
>> +++ b/include/uapi/linux/if_packet.h
>> @@ -26,8 +26,10 @@ struct sockaddr_ll {
>>   #define PACKET_MULTICAST	2		/* To group		*/
>>   #define PACKET_OTHERHOST	3		/* To someone else 	*/
>>   #define PACKET_OUTGOING 4 /* Outgoing of any type */
>> -/* These ones are invisible by user level */
>>   #define PACKET_LOOPBACK 5 /* MC/BRD frame looped back */
>> +#define PACKET_USER 6 /* To user space */
> Reusing this value is like changing the API. If some userland apps an=
d
> external
> modules rely on it, this patch may break them.

Interpretation of a value is contextual, please stop ignoring this
fact.

And in this context, Daniel's reappropriation of the PACKET_FASTROUTE
value causes no harm to anyone.

Values never used by us at any point in the past, yet nevertheless
were placed in a user visible header file, have to be kept around.  But
that doesn't mean that we can't reuse them for other meanings.

The worst thing that could exist, is that some code out there builds,
for example, string tables using PACKET_* values and whoever did them
decided to be complete enough to build entries even for effectively
unused values such as PACKET_FASTROUTE.

If you actually do searches for code making reference to
PACKET_FASTROUTE or other similarly unused defines, that's what you
find.  There is nothing looking semantically at this value at all.

Any objections to Daniel's changes will fall on deaf ears until
someone can really provide an actual existing way that things can
break.  Because I'm very sure that they cannot.
