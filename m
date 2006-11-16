From: Ray Lee <ray-lk@madrabbit.org>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Thu, 16 Nov 2006 11:36:55 -0800
Message-ID: <455CBDD7.6000507@madrabbit.org>
References: <455B63EC.8070704@madrabbit.org> <455BFC47.3020006@madrabbit.org> <455CAB2F.1060709@lwfinger.net> <200611162016.42095.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tapsys.com ([72.36.178.242]:44217 "EHLO tapsys.com")
	by vger.kernel.org with ESMTP id S1424377AbWKPTg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 14:36:59 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200611162016.42095.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Thursday 16 November 2006 19:17, Larry Finger wrote:
>> Ray Lee wrote:
>>> Larry Finger wrote:
>>>> Ray Lee wrote:
>>>>> Michael Buesch wrote:
>>>>>> On Wednesday 15 November 2006 20:01, Ray Lee wrote:
>>>>>>> Suggestions? Requests for <shudder> even more info?
>>>>>> Yeah, enable bcm43xx debugging.
>>>>> Sigh, didn't even think to look for that. Okay, enabled and compiling
>>>>> a new kernel. This will take a few days to trigger, if the pattern holds, so
>>>>> in the meantime, any *other* thoughts?
>>>> Which chip and revision do you have? Send me your equivalent of the line
>>>> "bcm43xx: Chip ID 0x4306, rev 0x2".
>>> bcm43xx: Chip ID 0x4306, rev 0x3
>>>
>>> Also, another thing I wasn't clear about in my first email was that the netdev
>>> watchdog timeouts are new with rc5:
>>>
>>> $ zgrep 'NETDEV WATCH' /var/log/messages{,.0,.1.gz} | cut -d: -f2| cut -c 1-6
>>> | uniq -c
>>>    1249 Nov 13
>>>       6 Nov  6
>>>       1 Nov  7
>>>       3 Nov  8
>>>       2 Nov  9
>>>    5717 Nov 10
>>>    5652 Nov 11
>>>       5 Oct 29
>>>       3 Oct 30
>>>       3 Oct 31
>>>       4 Nov  1
>>>       1 Nov  2
>>>       1 Nov  3
>>>
>>> I booted into 2.6.19-rc5 on November 10th. Previous to that was 2.6.19-rc3.
>>> There really does seem to be something suspicious with that patch, yes?
>>>
>>> Thanks,
>>>
>>> Ray
>>>
>> It certainly looks as if the "Drain TX status" patch is causing the problem; however, it should do 
>> nothing for core revisions < 5, and yours is a 3.

(Was writing a response to Larry when this came through...)

> You are looking at the wrong revision number.
> You are looking at the chip revision, while this tests for the
> 802.11 core revision. Get the dmesg line which prints info for the
> core with ID 0x812.

Rev 5:

[ 4777.745121] bcm43xx driver
[ 4777.753262] bcm43xx: Chip ID 0x4306, rev 0x3
[ 4777.753364] bcm43xx: Number of cores: 5
[ 4777.753442] bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
[ 4777.753553] bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
[ 4777.753665] bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
[ 4777.753779] bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
[ 4777.753890] bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
[ 4777.755235] bcm43xx: PHY connected
[ 4777.755307] bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
[ 4777.755417] bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
[ 4777.755541] bcm43xx: Radio turned off
[ 4777.755610] bcm43xx: Radio turned off
[ 4777.895476] bcm43xx: PHY connected
[ 4777.970488] bcm43xx: Microcode rev 0x118, pl 0x17 (2004-05-06  21:34:00)
[ 4777.978762] bcm43xx: Radio turned on
[ 4778.155023] bcm43xx: Chip initialized
[ 4778.155214] bcm43xx: 30-bit DMA initialized
[ 4778.155490] bcm43xx: Keys cleared
[ 4778.155563] bcm43xx: Selected 802.11 core (phytype 2)
[ 4779.055872] bcm43xx: set security called, .level = 0, .enabled = 0,
.encrypt = 0
[ 4779.434968] bcm43xx: set security called, .level = 0, .enabled = 0,
.encrypt = 0
[ 4779.435044] bcm43xx: set security called, .level = 0, .enabled = 0,
.encrypt = 0
[ 4779.435051] bcm43xx: set security called, .level = 0, .enabled = 0,
.encrypt = 0
[ 4779.435058] bcm43xx: set security called, .level = 0, .enabled = 0,
.encrypt = 0


>> Could you do me a favor? Please use git to download the current contents of Linus's tree with a "git 
>> clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git new_dir". Using the same 
>> .config as your current kernel and the git bisect command, you should be able to isolate the commit 
>> that is causing the error. I know that it is a lot of work and will take considerable time; however, 
>> that way we will see if some other change is triggering the problem.
> 
> Well, please bisect it anyway. Otherwise it will be very hard to track down.

If I could figure out a way to make it repeatable, I'd happily do a blind
bisect. As it stands, I can't trigger it manually. I've got a while true; do
iwconfig eth1; done running to hit the ioctls (as the trace in my first
message showed one of them in use), but that's might be a red herring. After
this email, I'll be shutting down all my browser and email windows to try to
kill the large network traffic generating apps as well. Also, does the 0x812
core only hit for certain access points? I have a b and 2 b/g's in range.

So, barring me finding a way to reproduce it, there's the good news that
there's only three bcm43xx patches between what worked and what didn't:

ray@phoenix:~/work/kernel/linux-2.6$ hg log -I drivers/net/wireless/bcm43xx -r
v2.6.19-rc3:tip
changeset:   40500:4ef6746b2f06
user:        Al Viro <viro@ftp.linux.org.uk>
date:        Wed Oct 25 12:01:11 2006 +0700
summary:     [PATCH] missing include of dma-mapping.h

changeset:   40964:ca97546422bd
user:        Michael Buesch <mb@bu3sch.de>
date:        Wed Nov 01 08:15:40 2006 +0500
summary:     [PATCH] bcm43xx: Fix low-traffic netdev watchdog TX timeouts

changeset:   40965:f5021f3521c2
user:        Larry Finger <Larry.Finger@lwfinger.net>
date:        Wed Nov 01 08:15:41 2006 +0500
summary:     [PATCH] bcm43xx: fix unexpected LED control values in BCM4303 sprom

I think we can safely rule out a #include addition. The LED control values one
should be harmless too, yes? So I'm at a loss as to how it could be anything
but the middle one.

I'm open to suggestions on how to make the problem trigger more than once
every two days...

Ray
