From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Requeues
Date: Fri, 9 Mar 2012 17:54:48 +0000
Message-ID: <CAA93jw4eCG19v5Pt_2o-W7OBQ=66O126xi-Gb8gObakhQabMTw@mail.gmail.com>
References: <1330753728.4671.190.camel@denise.theartistscloset.com>
	<4F51C01C.3040208@intel.com>
	<1330769637.4671.193.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55695 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441Ab2CISBF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 13:01:05 -0500
Received: by wibhj6 with SMTP id hj6so742875wib.1
        for <netdev@vger.kernel.org>; Fri, 09 Mar 2012 10:01:03 -0800 (PST)
In-Reply-To: <1330769637.4671.193.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 3, 2012 at 10:13 AM, John A. Sullivan III
<jsullivan@opensourcedevel.com> wrote:
> On Fri, 2012-03-02 at 22:54 -0800, John Fastabend wrote:
>> On 3/2/2012 9:48 PM, John A. Sullivan III wrote:
>> > Hello, all. =A0I am seeing a small but significant number of reque=
ues on
>> > our pfifo_fast qdiscs. =A0I've not been able to find much on what =
this
>> > means but the little I have implies it may be a problem with the
>> > physical interfaces. =A0However, these are fairly high end systems=
 with
>> > Intel e1000 quad port cards.


=46rom what you describe it sounds like this is not a 'problem', but a
sign that your environment is capable of saturating e1000 quad port
cards.

Adding a little active queue management (red or sfqred) will reduce
the impact of the extra buffering and lead to more responsive streams
with more accurate estimates of the BDP.

if you are already running bql, you will generally see more requeues.

>> >
>> > We thought it might have something to do with the bonded interface=
s so
>> > we checked some other high end systems without bonded interfaces b=
ut the
>> > same quad port cards and, lo and behold, the same small but signif=
icant
>> > number of requeues.
>> >
>> > Is this normal or does it indicate a problem somewhere? Thanks - J=
ohn
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>>
>> One of two things can happen to cause the requeue counter to increme=
nt.
>>
>> When the qdisc dequeues a packet it then gets enqueued in yet anothe=
r
>> queue in the e1000 driver. If the qdisc is dequeueing packets faster
>> than the hardware can consume them the driver will return a
>> NETDEV_TX_BUSY error. This causes the qdisc to 'requeue' the packet =
and
>> in the process increments this counter.
>>
>> The gist is pfifo_fast dequeued a packet tried to give it to e1000 w=
hich
>> pushed back so pfifo_fast put the packet back on the queue.
>>
>> By the way you can tune the size of the e1000 queues manually by pla=
ying
>> with:
>>
>> =A0 =A0 =A0 /sys/class/net/ethx/tx_queue_len
>>
>> But you likely don't want to make them any larger else you'll hit th=
e
>> buffer bloat problem. I'm guessing we should add byte queue limit su=
pport
>> here.
>>
>> The second way to trigger this is multiple cpus contending for a loc=
k.
>>
>> In short requeue counts as long as its not excessive are just part
>> of normal operation. So shouldn't be a problem.
> <snip>
> Thank you very much. =A0I was not aware of CPU contention being a cau=
se.
> We did notice the problem primarily on systems with 8 to 16 cores - J=
ohn
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
