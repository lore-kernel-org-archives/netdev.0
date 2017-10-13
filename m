From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [RFC] Support for UNARP (RFC 1868)
Date: Fri, 13 Oct 2017 11:23:09 -0700
Message-ID: <42d0c1eb-f37d-eb07-0e29-7a97f5522e64@oracle.com>
References: <1507782977-2443-1-git-send-email-girish.moodalbail@oracle.com>
 <1507820236.31614.50.camel@edumazet-glaptop3.roam.corp.google.com>
 <c75c04fe-46d6-8ec3-844d-fe379710496b@oracle.com>
 <CAF2d9jg7A7fJfE-i4aSgYuvAE+_4VfBOMEtsY_urDNhO0qfoYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        linux-netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?UTF-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28303 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751835AbdJMSXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 14:23:30 -0400
In-Reply-To: <CAF2d9jg7A7fJfE-i4aSgYuvAE+_4VfBOMEtsY_urDNhO0qfoYA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/17 5:53 PM, Mahesh Bandewar (महेश बंडेवार) wrote:
> On Thu, Oct 12, 2017 at 4:06 PM, Girish Moodalbail
> <girish.moodalbail@oracle.com> wrote:
>> Hello Eric,
>>
>> The basic idea is to mark the ARP entry either FAILED or STALE as soon as we
>> can so that the subsequent packets that depend on that ARP entry will take
>> the slow path (neigh_resolve_output()).
>>
>> Say, if base_reachable_time is 30 seconds, then an ARP entry will be in
>> reachable state somewhere between 15 to 45 seconds. Assuming the worst case,
>> the ARP entry will be in REACHABLE state for 45 seconds and the packets
>> continue to traverse the network towards the source machine and gets dropped
>> their since the VM has moved to destination machine.
>>
>> Instead, based on the received UNARP packet if we mark the ARP entry
>>
>> (a) FAILED
>>     - we move to INCOMPLETE state and start the address resolution by sending
>>       out ARP packets (up to allowed maximum number) until we get ARP
>> response
>>       back at which point we move the ARP entry state to reachable.
>>
>> (b) STALE
>>     - we move to DELAY state and set the next timer to DELAY_PROBE_TIME
>>       (1 second) and continue to send queued packets in arp_queue.
>>     - After 1 sec we move to PROBE state and start the address resolution
>> like
>>       in the case(a) above.
>>
>> I was leaning towards (a).
> One could arbitrarily increase the stale timeout (by changing no of
> probes). So sender
> will continue sending traffic to something that has already gone away.
> STALE doesn't
> mean bad but here the sender is clearly indicating it's going away so
> FAILED seems to
> be the only logical option.

I agree.

>>
>>> Will TCP flows be terminated, instead
>>> of being smoothly migrated (TCP_REPAIR)
>>
>>
>> The TCP flows will not be terminated. Upon receiving UNARP packet, the ARP
>> entry will be marked FAILED. The subsequent TCP packets from the client
>> (towards that IP) will be queued (the first 3 packets in arp_queue and then
>> other packets get dropped) until the IP address is resolved again through
>> the slow path neigh_resolve_output().
>>
>> The slow path marks the entry as INCOMPLETE and will start sending several
>> ARP requests (ucast_solicit + app_solicit + mcast_solicit) to resolve the
>> IP. If the resolution is successful, then the TCP packets will be sent out.
>> If not, we will invalidate the ARP entry and call arp_error_report() on the
>> queued packets (which will end up sending ICMP_HOST_UNREACH error). This
>> behavior is same as what will occur if TCP server disappears in the middle
>> of a connection.
>>
>>>
>>> What about IPv6 ? Or maybe more abruptly, do we still need to add
>>> features to IPv4 in 2017,  22 years after this RFC came ? ;)
>>
>>
>> Legit question :). Well one thing I have seen in Networking is that an old
>> idea circles back around later and turns out to be useful in new contexts
>> and use cases. Like I enumerated in my initial email there are certain use
>> cases in Cloud that might benefit from UNARP.
>>
> It doesn't make sense to have this implemented only for IPv4. At this time if
> equivalent IPv6 feature is missing, I don't see it being useful / acceptable.

Obviously UNARP is IPv4 only. I am not aware of any standard way of doing the 
same for IPv6. If such a standard doesn't exist, then we will have to go through 
IETF to get one done? If that is the case, can we please do this in a phased 
manner? This will atleast help the Cloud that are IPv4 only.

thanks,
~Girish
