From: Willem de Bruijn <willemb@google.com>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Sat, 13 Apr 2013 14:33:49 -0400
Message-ID: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
 <20121213132916.GB10703@netboy.at.omicron.at> <50C9FEC4.5050804@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:64052 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab3DMSeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 14:34:21 -0400
Received: by mail-ie0-f180.google.com with SMTP id a11so4439173iee.39
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 11:34:21 -0700 (PDT)
In-Reply-To: <50C9FEC4.5050804@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 11:13 AM, Paul Chavent <Paul.Chavent@onera.fr> wrote:
> Hello.
>
>
> On 12/13/2012 02:29 PM, Richard Cochran wrote:
>>
>> On Wed, Dec 12, 2012 at 04:29:25PM +0100, Paul Chavent wrote:
>>>
>>> This patch allow to generate tx timestamps of packets sent by the packet
>>> mmap interface.
>>>
>>> Actually, you can't get tx timestamps with the sample code below.
>>>
>>> I wonder if my current implementation is good. And if not, how should i
>>> get the timestamps ?
>>
>>
>> In order for time stamps to appear, somebody has to call
>> skb_tx_timestamp() ...
>
> Yes. "Somebody" means "the hardware driver" after completing xmit. That's
> true ?
>
>
>>
>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>> index e639645..948748b 100644
>>> --- a/net/packet/af_packet.c
>>> +++ b/net/packet/af_packet.c
>>> @@ -1857,6 +1857,10 @@ static int tpacket_fill_skb(struct packet_sock
>>> *po, struct sk_buff *skb,
>>>         void *data;
>>>         int err;
>>>
>>> +       err = sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
>
>>
>> and this call is only setting some flags.
>
> Yes, it only sets some flags. I thought that those flags was required by the
> skb_tx_timestamp() in order to make the appropriate timestamping (hardware,
> software, etc).
>
> So in order to have tx timestamp that work, both calls are needed ?

Yes.

> Why sock_tx_timestamp is called in packet_fill_skb and packet_sendmsg_spkt
> and not in tpacket_fill_skb ?

Good point. From what I can tell, if you add it, the existing error
queue mechanism should work fine. At a glance, your code looks fine,
too, although I haven't tested it.

> Why i can retrieve timestamps when i add this call ?

I actually wondered it if would be possible to return the timestamps
in the ring itself. It is, but requires two additional changes:
writing the timestamp to orig_skb->tstamp in skb_tstamp_tx and then
writing it into the ring in tpacket_destruct_skb. The first change is
a bit odd, as the orig_skb is usually freed shortly after
skb_tstamp_tx is called. Still, I verified that it works and the patch
should also make your errorqueue-based code work, as it inserts the
sock_tx_timestamp. Will send it for review following this.

>>
>> HTH,
>> Richard
>>
> Thank for your help.
>
> Paul.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
