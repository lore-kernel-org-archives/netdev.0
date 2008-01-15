From: Martin Devera <devik@cdi.cz>
Subject: Re: Not understand some in htb_do_events function
Date: Tue, 15 Jan 2008 14:54:53 +0100
Message-ID: <478CBB2D.8010207@cdi.cz>
References: <478C86E6.3050508@bigtelecom.ru> <478C87D9.1010305@trash.net> <478CA02A.1070308@cdi.cz> <478CBA44.1090909@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www1.cdi.cz ([194.213.194.49]:55384 "EHLO www1.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbYAONzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 08:55:02 -0500
In-Reply-To: <478CBA44.1090909@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Badalian Vyacheslav wrote:
> Martin Devera =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Patrick McHardy wrote:
>>> Badalian Vyacheslav wrote:
>>>> Hello all.
>>>> I have many messages like "htb: too many events !" in dmesg.
>>>>
>>>> Try to see code and find that function try do 500 events at call.
>>>> Hm... may anyone ask why 500? Why its not dynamic value based on=20
>>>> performance of PC?
>>>
>>>
>>> Thats a good question, I wonder why it is limited at all.
>>> Martin, any hints?
>>>
>>>
>>
>> Hi, I recently replied someone to the same question:
>>
>> > it is possible when during one jiffie (1 or 10ms) more than 500 cl=
asses
>> > changed its state. It is meant to protect your system from liveloc=
k.
>> > The constant should be set to something like
>> > bogomips/bogocomplexity_of_state_change but it was not done.
>>
>> the solution I have in my mind is to change
>>    if (net_ratelimit())
>>                  printk(KERN_WARNING "htb: too many events !\n");
>>          return HZ/10;
>>  to
>>    return 1;
>>
>> to drain extra events asap. It the time of writing I was not able to
>> come with better solution and there were more bugs related to this
>> part of code than now.
>> We want way to smooth big burst of events over more dequeue invocati=
ons
>> in order to not slow dequeue too much. Constant 500 is max. allowed
>> "slowdown" of dequeue.
>> Any bright idea how to do it more elegant, Patrick ?
>>
>> brgds, devik
>=20
> Hmm.. i simple see that if i get messages like this in dmesg my PC li=
mit=20
> speed, but i have many free CPU and HTB classes have not full bandwid=
th=20
> load....
> If i delete half rules - i get bandwidth that i wont. I wrong underst=
and=20
> that if we have this limit (constant 500) my PC can't get full perfor=
mance?
>=20
> Look scheme (example in my memory... not real numbers... for idea onl=
y):
> HTB (default 1)
> - Class 1 (rate 250mbs cell 500 prio 1)
> ---- Here 8000 HTB rules (parent 1) (rate 1kbs, cell from 200kbs to 5=
mbs)
> - Class 2 (rate 250mbs cell 500 prio 1)
>=20
> I always go to 2.
> try ttcp.
> current rate in class 1 - above 150mbs
> current rate in class 2 - above 200mbs
> Load avg above 0.10 - 0.25
> Idle - 80%
>=20
> Try delete half rules
> current rate in class 1 - above 100mbs
> current rate in class 2 - above 400mbs
> Load avg above 0.10 - 0.25
> Idle - 80%
>=20
> All traffic in class 2 do i witch ttcp! its not deleted clients from=20
> class 1.
>=20
> Any idea? Thanks.

The change above (returning 1 instead of HZ/10) should help, it was tes=
ted. Also
you CAN increase the 500 to say 2000. I didn't the change as I'm not su=
re it is
good generic fix...
