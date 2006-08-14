From: Johannes Berg <johannes@sipsolutions.net>
Subject: sysfs vs. d80211 configuration
Date: Mon, 14 Aug 2006 15:10:58 +0200
Message-ID: <44E07662.8070506@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:21377 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750817AbWHNNLJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 09:11:09 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

In my seemingly never-ending quest to actually use the d80211 stack for 
something useful I just wanted to write a small setuid tool that:
 * creates and opens a new monitor interface
 * drops priviledges
 * ... does things with received frames ... (not interesting for this 
discussion)
 * removes new monitor interface

So I figured I'd just keep an fd open to 
/sys/class/net/mymonitorinterface/remove_iface to which I could write 
the interfaces name after I was done with it. However, when writing to 
that fd I got -EACCESS because it checks for CAP_NET_ADMIN.

That seems to make sense. However, it also means that I can simply not 
write the tool that way, it can't drop priviledges. Of course it could 
re-exec itself with a special parameter to tell it to remove the 
interface, but that'd allow anyone to use it to remove any interface. 
Not good either.

Hence, it seems that in order to properly solve this I should simply add 
a new  sysfs "remove" property for each d80211 virtual interface that 
triggers a removal whenever anything is written to it. And it should not 
have a check for CAP_NET_ADMIN so I can use it after dropping 
priviledges. Sounds great, right? So why isn't there a patch attached to 
this mail?

Well, it isn't too great. See, if you think about it again, removing an 
interface *should* require CAP_NET_ADMIN. But if I want to enable above 
use-case, then I have to check for CAP_NET_ADMIN when *opening* the 
sysfs attribute file, not writing to it. But that doesn't seem possible 
to do. Hence, I lose capability granularity. But it seems that sysfs 
doesn't allow me to do that. [Nor does a configuration system via 
netlink. hmm]

Do I lose? Or put from my kernel developer perspective: should we even 
be enabling such a use?

johannes
