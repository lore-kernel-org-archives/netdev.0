From: pravin <pravin.shelar@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] ip_gre: allow CSUM capable devices to
 handle packets
Date: Thu, 21 Feb 2013 23:19:05 -0800
Message-ID: <CANvJab3_ZMiMtCns2TtVxjM8GjVtqtk=+WYzsoj3t2b2958AVg@mail.gmail.com>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
	<CANvJab2uOKaGG6SrJCjvhe39oPqQbLBuc44j_nkShz_NW8G98w@mail.gmail.com>
	<504C9EFCA2D0054393414C9CB605C37F1C019A30@SJEXCHMB06.corp.ad.broadcom.com>
	<CANvJab0xqZhj9TDZOQKtqvDjLu4ez7MrocWY3FaBw28Nxc-Qdg@mail.gmail.com>
	<1361485562.21950.3.camel@lb-tlvb-dmitry>
	<CANvJab2S07fUPT3kJKM=NsCPuO-moJhtxhNExiWnxS-kFOkQ2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33841 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972Ab3BVHTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 02:19:06 -0500
Received: by mail-wi0-f182.google.com with SMTP id hi18so341649wib.9
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 23:19:05 -0800 (PST)
In-Reply-To: <CANvJab2S07fUPT3kJKM=NsCPuO-moJhtxhNExiWnxS-kFOkQ2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 3:46 PM, pravin <pravin.shelar@gmail.com> wrote:
> On Thu, Feb 21, 2013 at 2:26 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>> On Tue, 2013-02-19 at 15:03 -0800, pravin wrote:
>>> On Tue, Feb 19, 2013 at 11:20 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>>> >
>>> >> -----Original Message-----
>>> >> From: pravin [mailto:pravin.shelar@gmail.com]
>>> >> Sent: Tuesday, February 19, 2013 8:28 PM
>>> >> To: Dmitry Kravkov
>>> >> Cc: davem@davemloft.net; netdev@vger.kernel.org
>>> >> Subject: Re: [PATCH net-next v2 1/2] ip_gre: allow CSUM capable devices to
>>> >> handle packets
>>> >>
>>> >> On Mon, Feb 18, 2013 at 11:50 AM, Dmitry Kravkov <dmitry@broadcom.com>
>>> >> wrote:
>>> >> > If device is not able to handle checksumming it will
>>> >> > be handled in dev_xmit
>>> >> >
>>> >> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>>> >> > ---
>>> >> > Changes from v1: fixed email address
>>> >> >
>>> >> >  net/ipv4/ip_gre.c |    7 ++-----
>>> >> >  1 files changed, 2 insertions(+), 5 deletions(-)
>>> >> >
>>> >> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>>> >> > index a56f118..cdc31ac 100644
>>> >> > --- a/net/ipv4/ip_gre.c
>>> >> > +++ b/net/ipv4/ip_gre.c
>>> >> > @@ -745,12 +745,9 @@ static struct sk_buff *handle_offloads(struct sk_buff
>>> >> *skb)
>>> >> >                         goto error;
>>> >> >                 skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
>>> >> >                 return skb;
>>> >> > -       } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
>>> >> > -               err = skb_checksum_help(skb);
>>> >> > -               if (unlikely(err))
>>> >> > -                       goto error;
>>> >> >         }
>>> >> > -       skb->ip_summed = CHECKSUM_NONE;
>>> >> > +       if (skb->ip_summed != CHECKSUM_PARTIAL)
>>> >> > +               skb->ip_summed = CHECKSUM_NONE;
>>> >> >
>>> >> >         return skb;
>>> >> >
>>> >> > --
>>> >> > 1.7.7.2
>>> >> >
>>> >> >
>>> >>
>>> >> This patch breaks GRE tunnel with GRE_CSUM. since GRE_CSUM need
>>> >> complete IP packet to checksum entire GRE payload.
>>> >
>>> > Testing for o_flags&GRE_CSUM does not look too hurt here, since it will be used in ipgre_tunnel_xmit() later on
>>> > This is the only problematic case, right?
>>> >
>>>
>>> It does not work for me. I have GRE device with csum on. Ping works
>>> fine but Netperf is not working.
>>> Looking at code, I am not sure how tcp will work if inner packet TCP
>>> checksum is calculated after GRE_CSUM calculation.
>>
>>
>> Fixes handling when CSUM or SEQ flags are set - via skb_checksum_help()
>> ---
>> Tested with each mode (separately)
>>
>>  net/ipv4/ip_gre.c |   14 +++++++++++---
>>  1 files changed, 11 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> index 5ef4da7..0de54cd 100644
>> --- a/net/ipv4/ip_gre.c
>> +++ b/net/ipv4/ip_gre.c
>> @@ -735,7 +735,8 @@ drop:
>>         return 0;
>>  }
>>
>> -static struct sk_buff *handle_offloads(struct sk_buff *skb)
>> +static struct sk_buff *handle_offloads(struct ip_tunnel *tunnel,
>> +                                      struct sk_buff *skb)
>>  {
>>         int err;
>>
>> @@ -745,8 +746,15 @@ static struct sk_buff *handle_offloads(struct
>> sk_buff *skb)
>>                         goto error;
>>                 skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
>>                 return skb;
>> +       } else if (tunnel->parms.o_flags&(GRE_SEQ|GRE_CSUM) &&
>> +                  skb->ip_summed == CHECKSUM_PARTIAL) {
>> +               err = skb_checksum_help(skb);
>> +               if (unlikely(err))
>> +                       goto error;
>>         }

one more thing, there is no need to do csum for GRE_SEQ case.

>> -       if (skb->ip_summed != CHECKSUM_PARTIAL)
>> +
>> +       if (skb->ip_summed != CHECKSUM_PARTIAL ||
>> +           tunnel->parms.o_flags&(GRE_SEQ|GRE_CSUM))
>>                 skb->ip_summed = CHECKSUM_NONE;
>>
> We can simplify this by dropping check of o_flags.
>
>>         return skb;
>> @@ -776,7 +784,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff
>> *skb, struct net_device *dev
>>         int    err;
>>         int    pkt_len;
>>
>> -       skb = handle_offloads(skb);
>> +       skb = handle_offloads(tunnel, skb);
>>         if (IS_ERR(skb)) {
>>                 dev->stats.tx_dropped++;
>>                 return NETDEV_TX_OK;
>> --
>> 1.7.7.2
>>
>>
>>> Thanks,
>>> Pravin.
>>>
>>
>>
>>
