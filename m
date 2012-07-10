From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Tue, 10 Jul 2012 15:22:20 +0800
Message-ID: <CACVXFVPgqtSN3BrEXRxSv4yxaxCni495SxZNXBmYQpagmxk2tQ@mail.gmail.com>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	<1341474192.2583.3299.camel@edumazet-glaptop>
	<CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	<1341477192.2583.3415.camel@edumazet-glaptop>
	<CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	<1341481760.2583.3579.camel@edumazet-glaptop>
	<CACVXFVNYwNrdWS_EiQ4O0-ou369AQ2tB4qbvmzY1rt5T3QnyUw@mail.gmail.com>
	<1341842043.3265.2914.camel@edumazet-glaptop>
	<CACVXFVNdiwVn1Mo--N4N0HdYrEJizExtd_cppT4tS=mjog2PKw@mail.gmail.com>
	<1341895143.3265.4049.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:60704 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab2GJHWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 03:22:21 -0400
Received: by obbuo13 with SMTP id uo13so21767322obb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 00:22:20 -0700 (PDT)
In-Reply-To: <1341895143.3265.4049.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 10, 2012 at 12:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Please dont send private messages for discussing general linux stuff.
>
> Next time I wont reply.
>
> On Tue, 2012-07-10 at 12:00 +0800, Ming Lei wrote:
>> On Mon, Jul 9, 2012 at 9:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2012-07-09 at 21:23 +0800, Ming Lei wrote:
>> >
>> >> Looks the patch replaces skb_clone with netdev_alloc_skb_ip_align and
>> >> introduces extra copies on incoming data, so would you mind explaining
>> >> it in a bit detail? And why is skb_clone not OK for the purpose?
>> >
>> > Problem with cloning is that some paths will have to make a private copy
>> > of the skb.
>>
>> Looks you convert some private copy into all copy in rx path, :-)
>
> For small speed device, a copy is probably unnoticed.

The copy still has some effect on low speed device, for example, your recent
patch on asix driver can improve tx performance from ~75M to ~92M.

>
> rtl8169 does that (copybreak) for security issues on Gbps link speed,
> and I get Gbps link speed on an old AMD host with no problem.
>
> As you discovered, the slowdown comes from SLAB debug on the 30K huge
> skb. To recover from this we must patch usbnet to not constantly
> allocate/free such big RX skb but recycle them. Once we do that, you'll
> find out that copybreak improves general performance on low ram devices
> by an order of magnitude.

Looks your copybreak patch doesn't improve tx performance on smsc95xx.

>> >
>> > So you dont see the cost here in the driver, but later in upper stacks.
>> >
>> > Since this driver defaults to a huge RX area of more than 16Kbytes,
>> > a copy to a much smaller skb (we call this 'copybreak' in our jargon )
>> > is more than welcome to avoid OOM problems anyway.
>>
>> Looks 'memory compaction' has been implemented already to address
>> the big buffer allocation problem.
>
> Usually its too late (not enough ram to perform the compaction), and
> a collapse having to compact 3MB is very expensive and blows cpu caches.
>
> I noticed that on machines with 1GB or 2GB ram. These machines are
> called ChromeBooks and every lost network frame is analyzed in Google.
> And we had problems because some wifi adapters use 8KB skbs for incoming
> frames.

Kernel stack size is 8KB or more, so could you find process creation failure
in your ChromeBooks machine at the same time?

> (Not even 32KB !!! This is just crazy !!)
>
> Relying on TCP collapsing is just very lazy. What about other
> protocols ?
>
> I guess that on beagle this can happen very fast.

Previously I only found there was usbnet OOMs triggered by
kmalloc(GFP_ATOMIC), but kmalloc(GFP_KERNEL) can succeed.
Some times later, the problem disappeared.

>>
>> Also the allocated huge RX SKB buffer will be freed after all cloned buffers
>> are consumed, so I still don't know what is the real problem with cloned buffer.
>>
>
> IF they are consumed.
>
> But IF they arent because application is not fast enough to drain, you
> end with sockets storing huge amount of data in their receive buffer.
>
> So a single 100 bytes payload holds the 32KB block.
>
> If you allowed your UDP socket to store 130.000 bytes of payload, you
> can consume 13.000 * 32KB = ~40 MB

Looks it is one advantage of copybreak.

>
>
>> >
>> > TCP coalescing (skb_try_coalesce) for example wont work for cloned skbs,
>> > so TCP receive window will close pretty fast, and performance sucks in
>> > lossy environments (like the Internet)
>>
>> I didn't observe the above thing, so could you provide a way to reproduce it?
>>
>
> netstat -s can show you interesting TCP counters. But as driver lies on
> skb->truesize, you can also have unexpected crashes with malicious
> senders. With a 64 ratio, its easy to consume all ram.
>
> TCP coalescing is great as soon as you have Out Of Order queueing
> because of packet losses. You avoid expensive collapses and
> dropping/purge of OFO queue. Sender has to resend previously sent data.
>
>> Suppose the above is true, looks skb_clone is useless, isn't it?
>
> cloning has some uses, for example if you dont need to touch packet
> content, only mess with skb->data, skb->len, skb->tail.
>
> But if you need to change a single bit in the payload, or play with skb
> fragments (struct skb_shared_info), you have to make a full copy of the
> 30KB buffer, even if the skb contained only 10 bytes of payload.

So the netdev_alloc_skb_ip_align() can be replaced with skb_clone()
in asix driver since not bits are touched in asix_rx_fixup? The default MTU is
1500 and rx_urb_size is 2048.

If so, could we use copybreak only for case of rx_urb_size > 4096?
And for ax88172, the dev->rx_urb_size is always 2048, looks the copy
is not needed at all.

> I would just switch off turbo mode by default, I doubt it has any
> advantage.

At least for smsc95xx, I think 32K buffer is not worthy of the feature.

>
> Coalescing up to 16K of incoming frames adds latency for no performance
> gain, once you do it the right way (that is without OOM risks).
> Currently, skb->truesize lie is very bad.
>



Thanks,
-- 
Ming Lei
