From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Wed, 27 Sep 2006 23:09:26 -0500
Message-ID: <451B4AF6.3090203@lwfinger.net>
References: <200609271726.34305.mb@bu3sch.de> <451AA446.7060009@lwfinger.net> <200609271950.47430.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:47561 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S965278AbWI1EJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 00:09:30 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609271950.47430.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Wednesday 27 September 2006 18:18, Larry Finger wrote:
>> Michael Buesch wrote:
>>> This fixes some race conditions in the WirelessExtension
>>> handling and association handling code.
>>>
>>> Signed-off-by: Michael Buesch <mb@bu3sch.de>
>>>
>>> ---
>> This patch doesn't apply.
> 
> Oh, linville merged stuff on the 25th. That's the day I updated
> my tree to do this patch. But seems like I did it just before
> the merge.
> Who could suspect that linville merges something. :D
> *me runs away*
> 
> Anyway. Here's an updated patch.

NACK this version. It applied correctly, but introduced a new problem. My device occasionally gets 
deauthentication messages from my AP.Preciously, it would do a scan or two, and then reauthenticate. 
After your patch was applied, it never stops scanning.

The "normal" sequence is

kernel: SoftMAC: Received deauthentication packet from 00:14:bf:85:49:fa, but that network is unknown.
kernel: SoftMAC: Associate: Scanning for networks first.
kernel: SoftMAC: Start scanning with channel: 1
kernel: SoftMAC: Scanning 14 channels
kernel: bcm43xx: set security called, .enabled = 0, .encrypt = 0
kernel: bcm43xx: set security called, .enabled = 0, .encrypt = 0
kernel: bcm43xx: set security called, .level = 0, .enabled = 0, .encrypt = 0
kernel: bcm43xx: set security called, .level = 0, .enabled = 0, .encrypt = 0
kernel: bcm43xx: set security called, .level = 0, .enabled = 0, .encrypt = 0
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Queueing Authentication Request to 00:14:bf:85:49:fa
kernel: SoftMAC: Cannot associate without being authenticated, requested authentication
kernel: SoftMAC: Sent Authentication Request to 00:14:bf:85:49:fa.
kernel: SoftMAC: Open Authentication completed with 00:14:bf:85:49:fa
kernel: SoftMAC: sent association request!
kernel: SoftMAC: generic IE set to dd160050f20101000050f20201000050f20201000050f202
kernel: SoftMAC: Already associating or associated to 00:14:bf:85:49:fa
kernel: SoftMAC: associated!
kernel: bcm43xx: set security called, .active_key = 0, .level = 2, .enabled = 1,

With your patch:

kernel: SoftMAC: Received deauthentication packet from 00:14:bf:85:49:fa, but that network is unknown.
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Unable to find matching network after scan!
kernel: SoftMAC: Associate: Scanning for networks first.
kernel: SoftMAC: Start scanning with channel: 1
kernel: SoftMAC: Scanning 14 channels
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Associate: Scanning for networks first.
kernel: SoftMAC: Start scanning with channel: 1
kernel: SoftMAC: Scanning 14 channels
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Associate: Scanning for networks first.
kernel: SoftMAC: Start scanning with channel: 1
kernel: SoftMAC: Scanning 14 channels
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Unable to find matching network after scan!
kernel: SoftMAC: generic IE set to dd160050f20101000050f20201000050f20201000050f202
kernel: SoftMAC: Associate: Scanning for networks first.
kernel: SoftMAC: Start scanning with channel: 1
kernel: SoftMAC: Scanning 14 channels
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Associate: Scanning for networks first.
kernel: SoftMAC: Start scanning with channel: 1
kernel: SoftMAC: Scanning 14 channels
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Associate: Scanning for networks first.
kernel: SoftMAC: Start scanning with channel: 1
kernel: SoftMAC: Scanning 14 channels
kernel: SoftMAC: Scanning finished
kernel: SoftMAC: Unable to find matching network after scan!
kernel: SoftMAC: generic IE set to dd160050f20101000050f20201000050f20201000050f202

This pattern repeats until the network is brought down and back up.

Larry

