From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: TX timestamping for ICMP (sfc and core)?
Date: Sun, 9 Mar 2014 10:33:29 -0700
Message-ID: <CALCETrV_Zk6GWROQK8hEDwFzUDCtW_HX_xC5QhAFVXPzwgurXQ@mail.gmail.com>
References: <CALCETrXpaD4i9V2Qv_0xfouGRb_y27-R6fOQ5v4Q97jNwgecFA@mail.gmail.com>
 <1394384857.2861.159.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:35527 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbaCIRdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 13:33:50 -0400
Received: by mail-vc0-f175.google.com with SMTP id lh14so4126960vcb.34
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 10:33:49 -0700 (PDT)
In-Reply-To: <1394384857.2861.159.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 9, 2014 at 10:07 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Tue, 2014-03-04 at 12:43 -0800, Andy Lutomirski wrote:
>> I'm trying to get tx timestamping working on ping sockets.  My program
>> works fine (with hardware TX timestamps) if I send my "pings" on the
>> PTP UDP ports.  I want to send real ICMP pings, though.
>>
>> It looks like there are two problems:
>>
>>  - Something in the core code seems to eat SKBTX_HW_STAMP on ping
>> sockets.  At least, this code in efx_hard_start_xmit triggers for
>> IPPROTO_UDP on PTP ports but not for IPPROTO_ICMP:
>>
>>         if (unlikely(efx_xmit_with_hwtstamp(skb)))
>>                 printk(KERN_DEBUG "sfc: trying to do a TX timestamp\n");
>>
>>  - The sfc driver refuses to timestamp non-PTP packets.  There's a
>> check in efx_hard_start_xmit and another in ptp.c.  I suspect that the
>> hardware can support timestamping any outgoing packet, but I'm not
>> really sure.  (I'm using an SFN7322F.)
>
> I think that the SFC9100 family can do TX timestamping for arbitrary
> packets, but they still have to be sent via the MC and that will greatly
> limit the packet rate.
>
> (It may or may not be possible on the SFN[56]322F, as the addition of
> timestamping in a peripheral to the SFC9020 is quite a delicate
> arrangement.  The MCDI transport there also limits TX timestamped
> packets to 252 bytes.)
>
> If you want to send more than a very low rate of packets with TX
> timestamping, the driver should probably tell the kernel to allocate an
> extra TX queue for them and should implement ndo_select_queue.

All of these packets should be flagged with SKBTX_HW_TSTAMP, so the
driver will know that they need special treatment.  Is the issue that,
if they end up on a queue with other packets, that they will block the
other packets?

In any case, doing this on older hardware is probably useless, at
least for me.  I want to implement fully hardware-timestamped ping (to
be open-sourced once it works), and TX timestamps on echo requests
aren't terribly useful without RX timestamps on echo replies / TTL
exceeded messages, and the latter is impossible on older hardware, I
think.

--Andy
