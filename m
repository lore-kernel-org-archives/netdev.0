From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH 2/2] af_packet: pass checksum validation status to the user
Date: Thu, 19 Mar 2015 14:50:03 -0400
Message-ID: <CA+FuTSeJH22uVJcZ6eAxau_ng4LdqLfVSRGYna_pi4pxr1Oz_A@mail.gmail.com>
References: <1426752102-12786-1-git-send-email-al.drozdov@gmail.com>
 <1426752102-12786-2-git-send-email-al.drozdov@gmail.com> <CA+FuTSe1+_VjxwT3Zj=ZWb6HVS=Ww98egSR8s9usuOT3QZpbFA@mail.gmail.com>
 <550B10A4.60500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, tom@herbertland.com
To: Alexander Drozdov <al.drozdov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <550B10A4.60500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 19, 2015 at 2:08 PM, Alexander Drozdov <al.drozdov@gmail.com> wrote:
> On Thu, 19 Mar 2015 11:29:32 -0400, Willem de Bruijn <willemb@google.com>
> wrote:
>>
>> On Thu, Mar 19, 2015 at 4:01 AM, Alexander Drozdov <al.drozdov@gmail.com>
>> wrote:
>>>
>>> Introduce TP_STATUS_CSUM_VALID tp_status flag to tell the
>>> af_packet user that at least the transport header checksum
>>> has been already validated.
>>
>> This changes the interface slightly. Processes should be treating
>> this previously unused bit as reserved and other flags have
>> been added to the bitmap in this manner as well, so this should
>> then be safe here, too.
>>
>>> For now, the flag may be set for incoming packets only.
>>
>> Why?
>
> I can't figure out how af_packet could get that the outgoing
> packet's checksum has been validated. "Checksumming on
> output" from skbuff.h tells that skb->ip_summed should
> equal to CHECKSUM_NONE in that case,

CHECKSUM_UNNECESSARY is a valid flag on the outgoing
path according to that documentation. And, indeed, I also see
no checksum scrubbing on forwarding paths in practice (but I
may be wrong there, only took a quick glance).

> but that is not true for me (in my tests, skb->ip_summed ==
> CHECKSUM_UNNECESSARY for forwarded packets in some
> cases).

When you disable hardware checksum offload and generate
packets locally, you do see the expected CHECKSUM_NONE
value?

>> You cannot change the semantics of the flag afterwards.
>
>
> I think the semantics of the flag won't be changed if one set the flag
> for outgoing packets. If the flag is not set (for any directions)
> then that is not mean that the packet checksum is invalid. The user just can
> then
> checksum the packet by itself. So, the user may check the flag for any
> packet
> right now.

I see. So it is a hint. Okay. It would be nice if it behaves as
expected in as many cases as possible from the outset. This
would include PACKET_OUTGOING and CHECKSUM_NONE.

Please also note the flag and semantics in
Documentation/networking/packet_mmap.txt
>
>
>> Better to support both directions from the start.
>>
>>> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
>>> ---
>>>   include/uapi/linux/if_packet.h | 1 +
>>>   net/packet/af_packet.c         | 9 +++++++++
>>>   2 files changed, 10 insertions(+)
>>>
>>> diff --git a/include/uapi/linux/if_packet.h
>>> b/include/uapi/linux/if_packet.h
>>> index da2d668..053bd10 100644
>>> --- a/include/uapi/linux/if_packet.h
>>> +++ b/include/uapi/linux/if_packet.h
>>> @@ -99,6 +99,7 @@ struct tpacket_auxdata {
>>>   #define TP_STATUS_VLAN_VALID           (1 << 4) /* auxdata has valid
>>> tp_vlan_tci */
>>>   #define TP_STATUS_BLK_TMO              (1 << 5)
>>>   #define TP_STATUS_VLAN_TPID_VALID      (1 << 6) /* auxdata has valid
>>> tp_vlan_tpid */
>>> +#define TP_STATUS_CSUM_VALID           (1 << 7)
>>>
>>>   /* Tx ring - header status */
>>>   #define TP_STATUS_AVAILABLE          0
>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>> index 6ecf8dd..3f09dda 100644
>>> --- a/net/packet/af_packet.c
>>> +++ b/net/packet/af_packet.c
>>> @@ -1918,6 +1918,10 @@ static int tpacket_rcv(struct sk_buff *skb, struct
>>> net_device *dev,
>>>
>>>          if (skb->ip_summed == CHECKSUM_PARTIAL)
>>>                  status |= TP_STATUS_CSUMNOTREADY;
>>> +       else if (skb->pkt_type != PACKET_OUTGOING &&
>>> +                (skb->ip_summed == CHECKSUM_COMPLETE ||
>>> +                 skb_csum_unnecessary(skb)))
>>> +               status |= TP_STATUS_CSUM_VALID;
>>>
>>>          if (snaplen > res)
>>>                  snaplen = res;
>>> @@ -3015,6 +3019,11 @@ static int packet_recvmsg(struct kiocb *iocb,
>>> struct socket *sock,
>>>                  aux.tp_status = TP_STATUS_USER;
>>>                  if (skb->ip_summed == CHECKSUM_PARTIAL)
>>>                          aux.tp_status |= TP_STATUS_CSUMNOTREADY;
>>> +               else if (skb->pkt_type != PACKET_OUTGOING &&
>>> +                        (skb->ip_summed == CHECKSUM_COMPLETE ||
>>> +                         skb_csum_unnecessary(skb)))
>>> +                       aux.tp_status |= TP_STATUS_CSUM_VALID;
>>> +
>>
>> These two sections are near duplicates. I'd move the entire status
>> initialization, including existing TP_STATUS_USER and
>> TP_STATUS_CSUMNOTREADY fields to a helper function.
>>
>> It's a bit unfortunately that we have to use an extra bit to add a signal
>> that is a near inverse of the existing TP_STATUS_CSUMNOTREADY
>> (bar CHECKSUM_NONE). I do not immediately see a better way,
>> either, though. And tp_status has plenty room at 32 bits.
>>
>>>                  aux.tp_len = PACKET_SKB_CB(skb)->origlen;
>>>                  aux.tp_snaplen = skb->len;
>>>                  aux.tp_mac = 0;
>>> --
>>> 1.9.1
>>>
>
>
