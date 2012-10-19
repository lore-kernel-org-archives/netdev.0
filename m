From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH net-next] packet mmap : allow the user to choose tx data
 offset.
Date: Fri, 19 Oct 2012 15:43:36 +0200
Message-ID: <50815908.1050308@onera.fr>
References: <1350631302-16280-1-git-send-email-paul.chavent@onera.fr> <CAD6jFURov5oB+ck33JzCYQoBo9mYsEM9c0rHz9gmcgdMKgmwCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:40791 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030356Ab2JSNqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 09:46:36 -0400
In-Reply-To: <CAD6jFURov5oB+ck33JzCYQoBo9mYsEM9c0rHz9gmcgdMKgmwCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for your review Daniel. My replies are hereunder.

On 10/19/2012 01:36 PM, Daniel Borkmann wrote:
> On Fri, Oct 19, 2012 at 9:21 AM, Paul Chavent <Paul.Chavent@onera.fr> wrote:
>> The tx data offset of packet mmap tx ring used to be :
>> (TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))
>>
>> The problem is that, with SOCK_RAW socket, the payload
>> (14 bytes after the begening of the user data) is misaligned.
>>
>> This patch allow to let the user give an offset for it's tx
>> data if he desires.
>>
>> Set sock option PACKET_TX_HAS_OFF to 1, then specify in each
>> frame of your tx ring tp_net for SOCK_DGRAM, or tp_mac for
>> SOCK_RAW.
>>
>> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
>> ---
>>   Documentation/networking/packet_mmap.txt | 13 +++++++++
>>   include/uapi/linux/if_packet.h           |  1 +
>>   net/packet/af_packet.c                   | 48 +++++++++++++++++++++++++++++++-
>>   net/packet/internal.h                    |  1 +
>>   4 files changed, 62 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
>> index 1c08a4b..c805e5f 100644
>> --- a/Documentation/networking/packet_mmap.txt
>> +++ b/Documentation/networking/packet_mmap.txt
>> @@ -163,6 +163,19 @@ As capture, each frame contains two parts:
>>
>>    A complete tutorial is available at: http://wiki.gnu-log.net/
>>
>> +By default, the user should put data at :
>> + frame base + TPACKET_HDRLEN - sizeof(struct sockaddr_ll)
>
> TPACKET_HDRLEN is only for tpacket, version 1. Maybe you should mention that.

The difference isn't done farther in the doc (line 393) too.

Beside that, "struct tpacket_hdr" is given as an example without 
recalling that the user could also use "struct tpacket2_hdr" or "struct 
tpacket3_hdr".
So I've supposed that "struct tpacket_hdr" and "TPACKET_HDRLEN" are used 
as general example.

If the PACKET_VERSION socket options was documented, we could add a 
warning that advertise the user that, depending on the version he uses, 
he will have to deal with different structures/macros.

>
>> +So, whatever you choose for the socket mode (SOCK_DGRAM or SOCK_RAW),
>> +the begening of the user data will be at :
>
> Typo in "begening".

Taken into account.

>
>> + frame base + TPACKET_ALIGN(sizeof(struct tpacket_hdr))
>
> See above, tpacket, version 1.

Same justification as above.

>
>> +If you whish to put user data at a custom offset from the begenning of
>
> Typo in "whish" and "begenning".

Taken into account.

>
>> +the frame (for payload alignment with SOCK_RAW mode for instance) you
>> +can set tp_net (with SOCK_DGRAM) or tp_mac (with SOCK_RAW). In order
>> +to make this work it must be enabled previously with setsockopt()
>> +and the PACKET_TX_HAS_OFF option.
>> +
>>   --------------------------------------------------------------------------------
>>   + PACKET_MMAP settings
>>   --------------------------------------------------------------------------------
>> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
>> index f379929..f9a6037 100644
>> --- a/include/uapi/linux/if_packet.h
>> +++ b/include/uapi/linux/if_packet.h
>> @@ -50,6 +50,7 @@ struct sockaddr_ll {
>>   #define PACKET_TX_TIMESTAMP            16
>>   #define PACKET_TIMESTAMP               17
>>   #define PACKET_FANOUT                  18
>> +#define PACKET_TX_HAS_OFF              19
>>
>>   #define PACKET_FANOUT_HASH             0
>>   #define PACKET_FANOUT_LB               1
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 94060ed..b6df577 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1881,7 +1881,37 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>>          skb_reserve(skb, hlen);
>>          skb_reset_network_header(skb);
>>
>> -       data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
>> +       if (po->tp_tx_has_off) {
>> +               int off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
>> +               int off_max = po->tx_ring.frame_size - tp_len;
>
> I think here, the header length is missing as well. Have you tested
> this with min/max offsets?

The old code was :
data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
So i set the off_min at this value.

When i test with SOCK_DGRAM sockets, i set tp_net to "po->tp_hdrlen - 
sizeof(struct sockaddr_ll)", so tp_net is off_min. And it works.
However, i have never tested with a tp_net that would be off_max.

When i test with SOCK_RAW socket, tp_mac is always greater than off_min 
to achieve payload alignment. I have never tester a tp_mac that would be 
off_max.

I will try the off_max case.

>
> Maybe it is more reasonable to put off = off_min at the beginning and
> then add tp_mac to it. Thus, tp_mac can also be 0 with
> PACKET_TX_HAS_OFF.
>
>> +               int off;
>
> For offsets, better use off_t, or here u32. Also, add a newline after
> variable declaration.

Ok, i will rewrite this like that :

u32 off_min, off_max, off;
off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
off_max = po->tx_ring.frame_size - tp_len;

Is it better ?

>
>> +               if (sock->type != SOCK_DGRAM)
>
> Why not test for == SOCK_RAW? This makes it more readable.

That is because i would like to do the same thing that lines 1654-1663 :

if (sk->sk_type == SOCK_DGRAM) {
	...
} else {
	...
}

It seems that we are sure to know what to do when we have SOCK_DGRAM, 
and fall-back to an alternative for every other cases.
So i have reproduced this pattern, even if the "other cases" will 
certainly be SOCK_RAW.

So I've changed my code to be

if (sk->sk_type == SOCK_DGRAM) {
	...
} else {
	...
}


>
>> +                       switch (po->tp_version) {
>> +                       case TPACKET_V2:
>> +                               off = ph.h2->tp_mac;
>> +                               break;
>> +                       default:
>> +                               off = ph.h1->tp_mac;
>
> TPACKET_V1 as default is wrong since there's also TPACKET_V3. What
> about TPACKET_V3 in general in your patch? You simply ignore it.

I have reproduced the pattern found some lines above (1868-1875)

switch (po->tp_version) {
case TPACKET_V2:
	tp_len = ph.h2->tp_len;
	break;
default:
	tp_len = ph.h1->tp_len;
	break;
}

Do you suggest me to add a case TPACKET_V3 and get tp_len from 
ph.h3->tp_len ?
We should do that at several places in the code and modify these :

union {
	struct tpacket_hdr *h1;
	struct tpacket2_hdr *h2;
	void *raw;
} ph;

Perhaps it could be in an other patch ?

>
>> +                               break;
>> +                       }
>> +               else
>> +                       switch (po->tp_version) {
>> +                       case TPACKET_V2:
>> +                               off = ph.h2->tp_net;
>> +                               break;
>> +                       default:
>> +                               off = ph.h1->tp_net;
>> +                               break;
>> +                       }
>
> Same as above. You should also put braces around the if-else
> construct. Sure, it's only one statement after that, but this spans
> across multiple lines and can make it error-prone in future changes.

Taken into account.

>
>> +               if (unlikely((off < off_min) || (off_max < off))) {
>> +                       pr_err("payload offset (%d) out of range [%d;%d]\n",
>> +                               off, off_min, off_max);
>> +                       return -EINVAL;
>> +               }
>
> if you set off initially to off_min, you could drop the check for off < off_min.

No, because if the user asked for an offset, that probably because he 
put data at this offset. We can't just use the min offset and going on. 
The data pointer will be after the user data's beginning and we don't 
want that the kernel send frames without their beginning.

>
>> +               data = ph.raw + off;
>> +       } else {
>> +               data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
>> +       }
>>          to_write = tp_len;
>>
>>          if (sock->type == SOCK_DGRAM) {
>> @@ -3111,6 +3141,19 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
>>
>>                  return fanout_add(sk, val & 0xffff, val >> 16);
>>          }
>> +       case PACKET_TX_HAS_OFF:
>> +       {
>> +               unsigned int val;
>> +
>> +               if (optlen != sizeof(val))
>> +                       return -EINVAL;
>> +               if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)
>> +                       return -EBUSY;
>> +               if (copy_from_user(&val, optval, sizeof(val)))
>> +                       return -EFAULT;
>> +               po->tp_tx_has_off = !!val;
>> +               return 0;
>> +       }
>>          default:
>>                  return -ENOPROTOOPT;
>>          }
>> @@ -3202,6 +3245,9 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
>>                          ((u32)po->fanout->type << 16)) :
>>                         0);
>>                  break;
>> +       case PACKET_TX_HAS_OFF:
>> +               val = po->tp_tx_has_off;
>> +               break;
>>          default:
>>                  return -ENOPROTOOPT;
>>          }
>> diff --git a/net/packet/internal.h b/net/packet/internal.h
>> index 44945f6..169e60d 100644
>> --- a/net/packet/internal.h
>> +++ b/net/packet/internal.h
>> @@ -110,6 +110,7 @@ struct packet_sock {
>>          unsigned int            tp_reserve;
>>          unsigned int            tp_loss:1;
>>          unsigned int            tp_tstamp;
>> +       unsigned int            tp_tx_has_off:1;
>>          struct packet_type      prot_hook ____cacheline_aligned_in_smp;
>>   };
>
