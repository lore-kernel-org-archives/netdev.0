From: Erik Grinaker <erik@bengler.no>
Subject: Re: TCP connection issues against Amazon S3
Date: Tue, 6 Jan 2015 19:01:29 +0000
Message-ID: <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com> <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no> <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com> <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 06 Jan 2015, at 18:33, Yuchung Cheng <ycheng@google.com> wrote:
> 
> On Tue, Jan 6, 2015 at 10:17 AM, Erik Grinaker <erik@bengler.no> wrote:
>> 
>>> On 06 Jan 2015, at 17:20, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Tue, 2015-01-06 at 16:11 +0000, Erik Grinaker wrote:
>>>>> On 06 Jan 2015, at 16:04, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>>> On Tue, 2015-01-06 at 15:14 +0000, Erik Grinaker wrote:
>>>>>> (CCing Yuchung, as his name comes up in the relevant commits)
>>>>>> 
>>>>>> After upgrading from Ubuntu 12.04.5 to 14.04.1 we have begun seeing
>>>>>> intermittent TCP connection hangs for HTTP image requests against
>>>>>> Amazon S3. 3-5% of requests will suddenly stall in the middle of the
>>>>>> transfer before timing out. We see this problem across a range of
>>>>>> servers, in several data centres and networks, all located in Norway.
>>>>>> 
>>>>>> A packet dump [1] shows repeated ACK retransmits for some of the
> TCP does not retransmit ACK ... do you mean DUPACKs sent by the receiver?

Ah, sorry, they are indeed DUPACKs; I thought they were the same thing.

> I am trying to understand the problem. Could you confirm that it's the
> HTTP responses sent from Amazon S3 got stalled, or HTTP requests sent
> from the receiver (your host)?

Yes. We run HTTP GET requests against S3 for images (typically a few megs in size). Once in a while, the response transfer stalls about halfway through, until the client (Curl) times out. The packet dump shows loads of DUPACKs early on, then TCP retransmissions until the connection is closed.

> btw I suspect some middleboxes are stripping SACKOK options from your
> SYNs (or Amazon SYN-ACKs) assuming Amazon supports SACK.

That may be. I just tested this on a server in the Netherlands, and I can not reproduce the problem there, while I can reproduce it from multiple locations and ISPs in Norway. Would it be helpful to have a packet dump from the functioning Netherlands server as well?


>>>>>> requests. Using Ubuntu mainline kernels, we found the problem to have
>>>>>> been introduced between 3.11.10 and 3.12.0, possibly in
>>>>>> 0f7cc9a3c2bd89b15720dbf358e9b9e62af27126. The problem is also present
>>>>>> in 3.18.1. Disabling tcp_window_scaling seems to solve it, but has
>>>>>> obvious drawbacks for transfer speeds. Other sysctls do not seem to
>>>>>> affect it.
>>>>>> 
>>>>>> I am not sure if this is fundamentally a kernel bug or a network
>>>>>> issue, but we did not see this problem with older kernels.
>>>>>> 
>>>>>> [1] http://abstrakt.bengler.no/tcp-issues-s3.pcap.bz2
>>>>> 
>>>>> 
>>>>> CC netdev
>>>>> 
>>>>> This looks like the bug we fixed here :
>>>>> 
>>>>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=39bb5e62867de82b269b07df900165029b928359
>>>> 
>>>> Has that patch gone into a release? Because the problem persists with 3.18.1.
>>> 
>>> Patch is in 3.18.1 yes.
>>> 
>>> So thats a separate issue.
>>> 
>>> Can you confirm pcap was taken at receiver (195.159.221.106), not sender
>>> (54.231.136.74) , and on which host is running the 'buggy kernel' ?
>> 
>> Yes, pcap was taken on receiver (195.159.221.106).
>> 
>>> If the sender is broken, changing the kernel on receiver wont help.
>>> 
>>> BTW not using sack (on 54.231.132.98) is terrible for performance in
>>> lossy environments.
>> 
>> It may well be that the sender is broken; however, the sender is Amazon S3, so I do not have any control over it. And in any case, the problem goes away with 3.11.10 on receiver, but persists with 3.12.0 (or later) on receiver, so there must be some change in 3.12.0 which has caused this to trigger.
>> 
>> If you are confident that the problem is with Amazon, I can get in touch with their engineering department.
