From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: Re: [PATCH] slip: fix NOHZ local_softirq_pending 08 warning
Date: Wed, 10 Aug 2011 11:47:56 +0400
Message-ID: <CAKh5naayzp3ANwnE2Y9U2LEaiWNoZAuT3aOQbRYdoB5uNdrOPw@mail.gmail.com>
References: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>
 <4E416951.4020207@hartkopp.net>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63348 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab1HJHsQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 03:48:16 -0400
Received: by vws1 with SMTP id 1so642023vws.19
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 00:48:16 -0700 (PDT)
In-Reply-To: <4E416951.4020207@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver,

As I see it, there is the following call chain of the netif_rx_ni() in
the slip (or slcan) driver:
[flush_to_ldisc] -> [disc->ops->receive_buf] -> [slip_unesc] ->
[sl_bump] -> [netif_rx_ni]

So flush_to_ldisc() may be called:
  1) From tty_flush_to_ldisc() with flush_work and as it mentioned
must not be called from IRQ context.
  2) From input_available_p() which can be called from n_tty_read() or
n_tty_poll(), so it's the user's context.
  2) From tty_flip_buffer_push() which schedules the flush_to_ldisc to
work or calls it directly if the tty->low_latency set.

So the only thing we must take into account that with tty->low_latency
set we can be in IRQ context when doing with netif_rx_ni(). But if we
are using netif_rx_ni() we can handle both IRQ and softirq contexts
well as if there are any softirq pending netif_rx_ni() calls
do_softirq()  with preemtion disabled. Then do_softirq() checks if
there is an IRQ context and does nothing if so.

So, I think it's correct to change netif_rx() with the netif_rx_ni().

2011/8/9 Oliver Hartkopp <socketcan@hartkopp.net>:
> Hello Ilya,
>
> is the processing of characters in the tty input stream for line disc=
iplines
> *always* done in softirq context???
>
> If so, i would send a patch for drivers/net/can/slcan.c too ...
>
> Thanks,
> Oliver
>
> On 05.08.2011 21:23, Matvejchikov Ilya wrote:
>> When using nanosleep() in an userspace application we get a ratelimi=
t warning:
>>
>> =A0 =A0 =A0 NOHZ: local_softirq_pending 08
>>
>> According to 481a8199142c050b72bff8a1956a49fd0a75bbe0 the problem is=
 caused by
>> netif_rx() function. This patch replaces netif_rx() with netif_rx_ni=
() which
>> has to be used from process/softirq context.
>>
>> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
>> ---
>> =A0drivers/net/slip.c | =A0 =A02 +-
>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/slip.c b/drivers/net/slip.c
>> index f11b3f3..4c61753 100644
>> --- a/drivers/net/slip.c
>> +++ b/drivers/net/slip.c
>> @@ -367,7 +367,7 @@ static void sl_bump(struct slip *sl)
>> =A0 =A0 =A0 memcpy(skb_put(skb, count), sl->rbuff, count);
>> =A0 =A0 =A0 skb_reset_mac_header(skb);
>> =A0 =A0 =A0 skb->protocol =3D htons(ETH_P_IP);
>> - =A0 =A0 netif_rx(skb);
>> + =A0 =A0 netif_rx_ni(skb);
>> =A0 =A0 =A0 dev->stats.rx_packets++;
>> =A0}
>>
>
>
