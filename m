From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v3 2/2] netlink: specify netlink packet direction
 for nlmon
Date: Mon, 23 Dec 2013 18:54:31 +0100
Message-ID: <52B878D7.4020308@redhat.com>
References: <1387805756-21121-1-git-send-email-dborkman@redhat.com> <1387805756-21121-3-git-send-email-dborkman@redhat.com> <52B8770B.60009@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756494Ab3LWRyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 12:54:40 -0500
In-Reply-To: <52B8770B.60009@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2013 06:46 PM, Nicolas Dichtel wrote:
> Le 23/12/2013 14:35, Daniel Borkmann a =C3=A9crit :
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
>> and not supported anywhere, and packets of such type were never
>> exposed to user space, so there are no overlapping users of such
>> kind. Thus, as wished, that seems the only way to make both
>> PACKET_* values non-overlapping and therefore device agnostic.
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
>>    - let PACKET_* values not overlap as requested by Dave
>>   v2->v3:
>>    - fixed typo in comment spotted by Nicolas, thanks
>>
>>   include/uapi/linux/if_packet.h | 4 +++-
>>   net/netlink/af_netlink.c       | 2 ++
>>   2 files changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_=
packet.h
>> index e9d844c..06e2a28 100644
>> --- a/include/uapi/linux/if_packet.h
>> +++ b/include/uapi/linux/if_packet.h
>> @@ -26,8 +26,10 @@ struct sockaddr_ll {
>>   #define PACKET_MULTICAST    2        /* To group        */
>>   #define PACKET_OTHERHOST    3        /* To someone else     */
>>   #define PACKET_OUTGOING        4        /* Outgoing of any type */
>> -/* These ones are invisible by user level */
>>   #define PACKET_LOOPBACK        5        /* MC/BRD frame looped bac=
k */
>> +#define PACKET_USER        6        /* To user space    */
>> +#define PACKET_KERNEL        7        /* To kernel space    */
>> +/* Unused, PACKET_FASTROUTE and PACKET_LOOPBACK are invisible to us=
er space */
>>   #define PACKET_FASTROUTE    6        /* Fastrouted frame    */
> Sorry to insist, I just try to understand. Why not removing the defin=
ition of
> PACKET_FASTROUTE?
> Or have a name like PACKET_NL_USER to document the difference between=
 both
> cases?

It's now used by nl, but as we have purely generic names, I simply want=
ed
to comply with that.

We could entirely remove it as it was e.g. proposed in 2008 [1] already=
 if
you see any value in that. Eventually it's up to Dave and if he likes, =
I'll
be happy to send a patch that removes this define.

Best,

Daniel

  [1] http://lists.openwall.net/netdev/2008/05/07/19
