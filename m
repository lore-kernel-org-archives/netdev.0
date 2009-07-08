From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 08 Jul 2009 14:16:56 -0400
Message-ID: <4A54E298.4010202@cs.columbia.edu>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>	<1246994776-1882-2-git-send-email-danms@us.ibm.com>	<4A543D82.5080408@cs.columbia.edu>	<87ljmzqjvl.fsf@caffeine.danplanet.com>	<4A54CCDB.1090602@cs.columbia.edu> <8763e3qfl9.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:48977 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757017AbZGHSRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 14:17:04 -0400
In-Reply-To: <8763e3qfl9.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> It will mostly fix the buffer limits, but not entirely: if the
> OL> original socket first raised the limits above defualt, then sent
> OL> data (not read by peer), then you'll still need to adjust the
> OL> limit before restoring the buffers.
> 
> If we cap the buffers in the checkpoint image to the current system
> limit (sysctl) and then set the per-socket buffer limit (after reading
> them in) to the value in the checkpoint image then we get the desired
> result, right?

Hmmm.... still not -- if user has CAP_NET_ADMIN then there is
no upper bound on so_{snd,rcv}buf.


So I guess the right way to do it is: (1) set buf size to the size
of saved data, (2) populate buffer, (3) restore so_{snd,rcv}buf.

#1 and #3 need to be done under the same security restrictions,
of course, as any change to the buffer bounds.

Oren.

> 
> OL> I can't predict the future, but it's been there forever...
> 
> Yeah, after I sent that I remembered that the magic 108 is in the
> sockaddr_un structure which is a userspace API and therefore not
> likely to change.
> 
> OL> But the point is that I would interpret ENOSPC as "storage/space
> OL> is exhausted", while here the error is that this value is simply
> OL> invalid for the particular kernel on which the restart occurs.
> 
> Yep, fair enough.
> 
> OL> In the original system, once the file becomes unreachable it
> OL> cannot be made reachable again by simple (re)mounting, IOW it can
> OL> no longer be connected-to.
> 
> Ah, I thought you meant "was reachable on the source system and not
> reachable on the target system".  I'm with you now :)
> 
