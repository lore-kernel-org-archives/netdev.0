From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory low
Date: Fri, 19 May 2017 15:55:55 +0200
Message-ID: <87pof5rlw4.fsf@miraculix.mork.no>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
        <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
        <063D6719AE5E284EB5DD2968C1650D6DCFFFAA5C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "'Jim Baxter'" <jim_baxter@mentor.com>,
        "linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Oliver Neukum <oliver@neukum.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFFAA5C@AcuExch.aculab.com>
        (David Laight's message of "Fri, 19 May 2017 11:10:40 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> writes:

> From: linux-usb-owner@vger.kernel.org [mailto:linux-usb-owner@vger.kernel=
.org] On Behalf Of Jim Baxter
>> Sent: 16 May 2017 18:41
>>=20
>> The CDC-NCM driver can require large amounts of memory to create
>> skb's and this can be a problem when the memory becomes fragmented.
>>=20
>> This especially affects embedded systems that have constrained
>> resources but wish to maximise the throughput of CDC-NCM with 16KiB
>> NTB's.
>
> Why is this driver copying multiple tx messages into a single skb.

Mostly becasue it already did that when I started messing with it, and I
didn't know how to avoid that.

> Surely there are better ways to do this??

But I have been there thinking this exact thought a couple of times.
Suggestions are appreciated.

> I think it is generating a 'multi-ethernet frame' URB with an
> overall header for each URB and a header for each ethernet frame.

With some negotiated alignment restrictions, and a linked list of frame
pointer arrays.  But yes, that is basically it.

(it's not always ethernet - with MBIM it can be IP or arbitrary as well,
but I don't think that makes any difference)

> Given that the USB stack allows multiple concurrent transmits I'm
> surprised that batching large ethernet frames makes much difference.

Me too.  Actually, I don't think it does.  The protocol was developed
with specific device restrictions in mind. These might be invalid today.
There is no reason to believe that using simple CDC ECM framing
(i.e. one ethernet frame per URB) is any problem.

> Also the USB target can't actually tell when URB that contain
> multiples of the USB packet size end.
> So it is possible to send a single NTB as multiple URB.

Nice idea!  Never thought of that.  Yes, the driver could use a number
smaller buffers regardless of the NTB size, by abusing the fact that the
device will see them as a contigious USB transfer as long as they fall
on USB packet boundaries.

Started thinking about how to do this in practice.  It seemed obviously
simply to jsut fire off the buffers as they fill up until the the max
aggregation size or time has been exceeded.  But the header makes this
harder than necessary.  It contains both a length and a pointer to the
first frame pointer array (NDP).  So we will have to decide the size of
the NTB and where to put the first NDP before sending the first USB
packet. This is possible if we always go for the pad-to-max strategy.
We'll also have to make some assumptions about the size of the NDP(s) as
we add them, but we already do that so I don't think it is a big deal.

Might be the way to go.

Unless someone has a nice way to just collect a list of skbs and have
them converted to proper framing on the fly when transmitting, without
having to care about USB packet boundaries.



Bj=C3=B8rn
