From: Patrick Simmons <linuxrocks123@netscape.net>
Subject: Re: [PATCH] Experimental new bonding driver mode=batman
Date: Wed, 20 May 2015 18:37:34 -0400
Message-ID: <555D0CAE.1000607@netscape.net>
References: <555AD3A7.7050202@netscape.net> <20150519074941.GB17391@unicorn.suse.cz> <555AF479.7000603@netscape.net> <20150520073221.GA19868@unicorn.suse.cz> <10002.1432143933@nyx>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omr-m5.mx.aol.com ([64.12.232.237]:57974 "EHLO
	omr-m5.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbbETWmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 18:42:53 -0400
In-Reply-To: <10002.1432143933@nyx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 01:45 PM, Jay Vosburgh wrote:
> Michal Kubecek <mkubecek@suse.cz> wrote:
>
>> On Tue, May 19, 2015 at 04:29:45AM -0400, Patrick Simmons wrote:
>>> On 05/19/2015 03:49 AM, Michal Kubecek wrote:
>>>> On Tue, May 19, 2015 at 02:09:43AM -0400, Patrick Simmons wrote:
>>>>>
>>>>> I've written a new mode for the kernel bonding driver.  It's similar to
>>>>> the round-robin mode, but it keeps statistics on TCP resends so as to
>>>>> favor slave devices with more bandwidth when choosing where to send
>>>>> packets.  I've tested it on two laptops using WiFi/Ethernet and it seems
>>>>> to work okay, but it should be considered experimental.
>>>>
>>>> A description of how is the mode supposed to work would be definitely
>>>> helpful.
>>>>
>>>
>>> Rationale: It's helpful for cases where the slave devices have
>>> significantly different or varying bandwidth.  The reason I wrote it
>>> is to bond powerline networking and wireless networking adapters
>>> into a single interface for use with connecting to a MythTV server.
>>> Neither of these systems is particularly reliable with bandwidth,
>>> but mode=batman can adaptively figure out which network has more
>>> available bandwidth at any given moment.  This is better than
>>> mode=round-robin which always balances everything 50/50.
>>
>> Thank you. But I rather meant some basic description of the algorithm
>> used to achieve this goal. Both should be IMHO part of the commit
>> message.
>
> 	Agreed; the concept sounds interesting, but without a detailed
> description of how it works it is difficult to evaluate its value.
>

The basic algorithm is that each device starts out with a single 
"point".  When a packet drop occurs and another device has been selected 
to retransmit the packet, that device gets another point and, if the 
first device has more than one point, the first device (the one that 
failed to successfully get the packet across) loses a point.  At every 
packet send, all the points of all devices are added up, and each device 
has a (num_points)/(sum of all points) chance of being chosen to send 
the packet.

Every 10 seconds, all devices points are halved (unless the device only 
has one point).  If the bonding device is approximately idle for 60 
seconds, all devices' points are reset to 1 and the algorithm starts over.

Additionally, no slave ever retransmits a packet it itself sent unless 
it is the only active slave; but, if the slave WOULD HAVE retransmitted 
its own packet according to the algorithm, it doesn't lose any points 
and the other slave doesn't get any.

>>> Regarding your analysis, I appreciate your comments, and I know it's
>>> rough, but I'm sorry to say I'm not really interested in doing much
>>> to improve its polish past where it is.  If it fails some way when I
>>> try to deploy it, then I'll fix that, and maybe I'll play around
>>> with the balancing heuristics, but the code quality is what it is
>>> unless someone else wants to improve it.  I would fix the
>>> indentation if that would make it acceptable for you to merge it,
>>> but not much more.  My argument for merging it is basically "it
>>> doesn't do anything unless you pass mode=batman, so what's the
>>> harm?".
>>>
>>> So, if you guys decide you don't want to merge it because of the
>>> global spinlock etc., that's cool and I understand, but I thought I
>>> should at least post to this list so you and any other potentially
>>> interested people know it exists.  Oh, and, if you're not going to
>>> merge it, please let me know so I can know post the patch to GitHub
>>> or somewhere.  And, if you could include a note in the comments at
>>> the top of bond_main.c or somewhere pointing people to the patch,
>>> I'd very much appreciate that. I don't want anyone else to have to
>>> endure hours of kernel rebuilds with KASAN enabled if they want this
>>> functionality :)
>>
>> Well, it's not my call, I'm not a bonding maintainer. But I believe at
>> least some of the objections would be shared by them. Of course, it's up
>> to you if you want to dedicate your time to improving the code to be
>> acceptable for mainline or rather maintain it out of tree (which may end
>> up taking even more time in the long term).

It'll probably just bit-rot :(  The next time it gets looked at will 
probably be in 4-5 years when one of the MythTV computers dies and I 
have to replace it and use a newer kernel because it has new hardware 
that isn't supported.

But it is now and will remain indefinitely at

http://moongate.ydns.eu/bond_mode_batman.patch

for anyone who wants it.

>
> 	Well, I am a bonding maintainer, and I can say that the patch in
> its current state is not suitable for inclusion.
>
> 	At a minimum, there are many coding style issues, commented out
> debug statements, etc, along with design issues (e.g., the batman mode
> handling in bond_handle_frame is unconditional and takes place for all
> modes, not just the new batman mode).
>
> 	If you (Patrick) or someone else wishes to contribute this to
> mainline, I'd suggest that the first step is to read and follow the
> instructions in Documentation/SubmittingPatches in the kernel source
> code.
>
> 	It is also not feasible to add pointers in the kernel source
> code to out-of-tree patches; sorry.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
>

Fair enough.  I actually did read SubmittingPatches already, but thank 
you for pointing it out.  I could easily fix the coding style issues (I 
imagine someone's written a "Linux kernel indentation mode" for emacs by 
now), and I could of course put an if statement around the stuff in 
bond_handle_frame (that's a bug).  What I wouldn't be interested in 
doing would be things like getting rid of the mode-specific spinlocks, 
which someone mentioned earlier as a potential issue.

Basically, I'll do bug fixes etc. if that would make it suitable, but 
not anything like design changes that would be likely to make me have to 
debug the thing again.  So, I guess my question is, would design changes 
be necessary, or would it be suitable if I fixed the indentation, 
cleaned up the debug comments, fixed the bug in bond_handle_frame, and 
did something to handle kmalloc failures?

By the way, I do appreciate the time you all have taken to look at this, 
and thank you for CCing me and please continue to do so because I didn't 
realize the list was so heavy traffic, and so I unsubscribed.

--Patrick Simmons

-- 
If I'm not here, I've gone out to find myself.  If I get back before I 
return, please keep me here.
