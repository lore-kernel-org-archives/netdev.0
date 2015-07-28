From: Sebastian Fett <db_extern@gmx.de>
Subject: Re: ARP response with link local IP, why not broadcast
Date: Tue, 28 Jul 2015 09:12:03 +0200
Message-ID: <55B72B43.9060400@gmx.de>
References: <55B6432E.5070401@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:49942 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbbG1HLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 03:11:09 -0400
Received: from [192.168.11.112] ([94.186.167.49]) by mail.gmx.com (mrgmx102)
 with ESMTPSA (Nemesis) id 0MMHaL-1ZGQ8k1pYT-0083Wp for
 <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:11:07 +0200
In-Reply-To: <55B6432E.5070401@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a quick update on the subject.

Thanks for the input. It's good to see that I am not the only one that
has this problem.

Right now we go with our initial approach and bcast our arp responses.
We have a very local network build only for one purpose. Other devices
in that network use the same approach. And the master controll software
will arp request every address eventually.
It's not ideal and will potentially take a couple minutes to resolve
every conflict. But it's the best compromise between effort and benefit.

I'll let you know about our test results. Maybe somebody is interested.

Btw, I still wonder if I can partially keep the kernel from answering
ARP packets?


> On Wed, Jul 22, 2015 at 9:49 AM, Sebastian Fett <db_extern@gmx.de> wrote:
>
>>> what is your use case?
>>>
>>
>> My problem ist a local network of audio devices. It is a valid possibility
>> that two halfs of the setup are set up individually (Stage left and stage
>> right). Both local networks will auto configure themselves via link local
>> and will be stable. But there always can be two devices with the same IP in
>> both networks.
>> At one point those two networks will be connected. With the current
>> behaviour the conflicting devices will never know of each other and the
>> address conflict.
>
> Ah yes, this is a valid problem (Partition-Join tolerance) and one that is
> being discussed in the Ipv6 context on 6man:
> http://www.ietf.org/mail-archive/web/ipv6/current/msg22712.html
>
> FWIW, when Solaris implemented ACD (rfc 5227) the compromise
> that was made between bcasting *every* ARP response whle solving
> the type or issue that you describe was to use a periodic ARP "announce",
> advertising the IP address (a Grat ARP) with exponential backoff.
> If a duplicate address is triggered (as would happen in the scenario
> that you describe) the system would fall into the aggressive defend mode.
>
> ARP announcemnts were bcast, but the noise is mitigated by tunable
> exponential backoff.
>
> Of course, all of this only helps to *detect* the duplicate- eventually
> some other entity has to jump in and arbitrate on which one should
> "own" the address.
>
>> The devices are controlled by a central PC using avahi/bonjour. It will know
>> of all conflicting devices, but will only be able to talk to the one that
>> happens to be in it's ARP cache. And renewing that cache will not change
>> anything, because it will happen with unicast messages.
>>
>> I looked at a Dante Controller (an audio data streaming device). And here
>> all ARP messages are answered with broadcasts.
>>
>> I think that behaviour is acceptable because it only happens in local
>> networks. Waking up sleeping devices will not be a concern there.
>
> I dont know if a short term solution that makes sense here is to have
> a tunable for this.
>
> But even the "always bcast arp response" will fail if you have a silent
> rejoin of the partitioned network- there is a reliance on the owner
> of an address bcasting their ARP resp at some point right?
>
> (there's also a DoS vector here- I can create a lot of bcast traffic
> by arping for an address..)
>>
>> That brings me to another question. When I react to an ARP packet in a
>> userspace program, can I keep that packet from reaching the kernel as well?
>> I would like to avoid to completely handle ARP in userspace.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
