From: Marc Aurele La France <tsi@ualberta.ca>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Thu, 26 Aug 2010 05:40:42 -0600 (Mountain Daylight Time)
Message-ID: <alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca> <20100823080543.319143e3@nehalam> <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca> <1282672647.2302.15.camel@achroite.uk.solarflarecom.com> <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
 <1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.srv.ualberta.ca ([129.128.5.19]:64743 "EHLO
	mail10.srv.ualberta.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752145Ab0HZLlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 07:41:04 -0400
In-Reply-To: <20100824153920.63360072@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Aug 2010, Stephen Hemminger wrote:
> On Tue, 24 Aug 2010 23:20:41 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>> On Tue, 2010-08-24 at 13:49 -0600, Marc Aurele La France wrote:
>>> On Tue, 24 Aug 2010, Ben Hutchings wrote:
>>>> On Tue, 2010-08-24 at 09:14 -0600, Marc Aurele La France wrote:
>>>>> On Mon, 23 Aug 2010, Stephen Hemminger wrote:
>>>>>> On Mon, 23 Aug 2010 08:44:37 -0600 (MDT)
>>>>>> Marc Aurele La France <tsi@ualberta.ca> wrote:
>>>>>>> In regrouping for my next tack at this, I noticed that all stack traces go
>>>>>>> through ip_append_data().  This would be ipv6_append_data() in the IPv6 case.
>>>>>>> A _very_ rough draft that would have ip_append_data() temporarily drop down
>>>>>>> to a smaller fake MTU follows ...

>>>>>> Why doesn't NFS generate page size fragments?  Does Infiniband or your
>>>>>> device not support this?  Any thing that requires higher order allocation
>>>>>> is going to unstable under load.  Let's fix the cause not the apply bandaid
>>>>>> solution to the symptom.

>>>>> From what I can tell, IP fragmentation is done centrally.

>>>> Stephen and I are not talking about IP fragmentation, but about the
>>>> ability to append 'fragments' to an skb rather than putting the entire
>>>> packet payload in a linear buffer.  See
>>>> <http://vger.kernel.org/~davem/skb_data.html>.

>>> Any payload has to either fit in the MTU, or has to be broken up into
>>> MTU-sized (or less) fragments, come hell or high water.  That this is done
>>> centrally is a good thing.

>> Not necessarily.  Offloading it to hardware, where possible, is usually
>> a performance win.

ip_append_data() deals with that already.

>>> It is the "(or less)" part that I am working towards here.

>> The inability to allocate large linear buffers is not a good reason to
>> generate packets smaller than the MTU.

Generating smaller-than-MTU fragments is better than giving up and 
returning an error in my book.

> IF NFS server is smart enough to generate:
>   Header (skb) + one or more pages in fragment list
> then IP fragmentation could do fragmentation by allocating
> new headers skb (small) and assigning the same pages to
> multiple skb's using page ref count.

> It obviously isn't working that way.

Point of clarification:  we're talking about the client here, not the 
server.  But, yes, it doesn't work that way.

> The whole problem is moot because NFS over UDP has known data corruption
> issues in the face of packet loss.  The sequence number of the IP fragment
> can easily wrap around causing old data to be grouped with new data and
> the UDP checksum is so weak that the resulting UDP packet will be consumed by the NFS
> client ans passed to the user application as corrupted disk block.

> DON'T USE NFS OVER UDP!

Steady now.  There's no need to YELL nor be arrogant.  You and I both know 
there's a place for NFS over UDP.  That's not changing any time soon.  While 
I'm aware of the issue you brought up, it is separate from the one at hand in 
this discussion.

I do want to thank you, however, for reminding me of TCP.  It's something 
20/20 hindsight says I should have checked out before starting this thread. 
Logistically, it'll be a few days before I can do so though.  If that allows 
me to increase the MTU all the way up to 65520, then this UDP thing will 
likely remain unresolved.

Thanks.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
