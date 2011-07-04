From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Mon, 4 Jul 2011 15:37:17 +0300
Message-ID: <CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	<1309777908.26180.1.camel@mojatatu>
	<CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:40746 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab1GDMhS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 08:37:18 -0400
Received: by iwn6 with SMTP id 6so4410945iwn.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 05:37:17 -0700 (PDT)
In-Reply-To: <CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here's a more concrete example:

An example configuration:

	sudo tc qdisc add dev eth1 root handle 1: prio priomap 2 2 2 2 2 2 2
2 2 2 2 2 2 2 2 2
	sudo tc qdisc add dev eth1 parent 1:1 handle 10: pfifo =09
	sudo tc qdisc add dev eth1 parent 1:2 handle 20: pfifo
	sudo tc qdisc add dev eth1 parent 1:3 handle 30: pfifo

	sudo tc filter add dev eth1 protocol ip parent 1: prio 1 u32 match ip
dport 22 0xffff flowid 1:1
	sudo tc filter add dev eth1 protocol ip parent 1: prio 1 u32 match ip
sport 22 0xffff flowid 1:1
	sudo tc filter add dev eth1 protocol ip parent 1: prio 2 u32 match ip
dport 80 0xffff flowid 1:2
	sudo tc filter add dev eth1 protocol ip parent 1: prio 2 u32 match ip
sport 80 0xffff flowid 1:2

I then used scp to copy a small file between computers while capturing
with wireshark:

http://dl.dropbox.com/u/3237005/port22example.pcap

and later I replayed the same capture using tcpreplay.
When using scp, the packets once again ended up where they should be
(1:1 in this configuration). With tcpreplay they ended up in the
default 1:3

On Mon, Jul 4, 2011 at 3:06 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2011-07-04 at 15:00 +0300, Adam Katz wrote:
>> Ok, I just tried this:
>>
>> I've opened www.example.com using a browser while capturing with
>> wireshark. TC placed all port 80 packets into the 1:1 as required. I
>> then physically plugged the nic to a different socket, one that isn'=
t
>> connected to the internet (i did this so I wont get any server
>> responses to the packets i'm sending) and then I replayed the captur=
e
>> of me opening www.example.com
>>
>> The second time, none of the packets ended up in 1:1 - they all went
>> to the default class despite being the EXACT same traffic.
>>
>
> Please post a small sample of the tcpdumps and the tc rules you used.
>
> cheers,
> jamal
>
>



On Mon, Jul 4, 2011 at 3:01 PM, Adam Katz <adamkatz0@gmail.com> wrote:
> Ok, I just tried this:
>
> I've opened www.example.com using a browser while capturing with
> wireshark. TC placed all port 80 packets into the 1:1 as required. I
> then physically plugged the nic to a different socket, one that isn't
> connected to the internet (i did this so I wont get any server
> responses to the packets i'm sending) and then I replayed the capture
> of me opening www.example.com
>
> The second time, none of the packets ended up in 1:1 - they all went
> to the default class despite being the EXACT same traffic.
>
> On Mon, Jul 4, 2011 at 2:11 PM, jamal <hadi@cyberus.ca> wrote:
>>
>> Capture tcpdump for both scenario that works and one
>> that doesnt.
>> Make sure the filters match your failing scenario.
>>
>> cheers,
>> jamal
>>
>> On Mon, 2011-07-04 at 10:38 +0300, Adam Katz wrote:
>>> Hi Everyone
>>>
>>> I'm sorry for littering the mailing list with this question, but no
>>> other place could help me..
>>>
>>> I'm attempting to use tc to shape traffic sent using libpcap, I'm
>>> doing this for a research project. I have a classful scheduler with
>>> several classes, to this scheduler I attach a few filters based on
>>> destination tcp ports.
>>>
>>> My problem is this: When sending packets using a normal userland
>>> socket, the filters work and I see the appropriate traffic entering
>>> the right class. BUT when sending packets with libpcap, all packets
>>> end up in the scheduler's default band as if the filters simply ref=
use
>>> to work.
>>>
>>> Can anyone suggest a solution?
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>
>>
>>
>
