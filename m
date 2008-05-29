From: Martin Wilck <martin.wilck@fujitsu-siemens.com>
Subject: Re: [PATCH] [resend] drivers/net: remove network drivers' last few
 uses  of IRQF_SAMPLE_RANDOM
Date: Thu, 29 May 2008 14:41:16 +0200
Message-ID: <483EA46C.7040508@fujitsu-siemens.com>
References: <ayJOq-3EJ-15@gated-at.bofh.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dgate20.fujitsu-siemens.com ([80.70.172.51]:28720 "EHLO
	dgate20.fujitsu-siemens.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751751AbYE2Mu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 08:50:59 -0400
In-Reply-To: <ayJOq-3EJ-15@gated-at.bofh.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Peterson wrote:

> Remove network drivers' last few uses of theoretically-exploitable network 
> entropy. Only 12 net drivers are affected. Headless boxes should use a 
> more secure source of entropy, such as the userspace daemons rngd, clrngd, 
> egd, audio_entropyd, and/or video_entroyd.

I don't think that consensus has been reached on this subject yet. 
Re-reading this thread, it's obvious that there are two camps with 
conflicting opinions all the way through the community. Very little has 
changed since the debate in 2006.

Those who are in favor of this patch argue that random data from 
/dev/random must be absolutely, truly cryptographically reliable. That's 
fine as a concept, but it is not even remotely realistic in many 
real-world systems.

Think about disk randomness in times where more and more disks don't 
have mechanical heads. Think about caching RAID controllers, solid state 
disks, virtual disks, even iSCSI volumes! In general, modern "disks" are 
no more reliable as entropy source than network interfaces.

Either the low-level driver (knowing the actual hardware) must decide 
whether or not a device is a suitable source of randomness, or better 
even, the admin must judge that from his knowledge of the actual situation.

To make /dev/random truly solid, all devices that currently contribute 
entropy must be re-scrutinized. Whether or not they really generate 
entropy should be made configurable for administrators, this is a matter 
of policy, not an a-priory property of a device class. It should be an 
individual device property - some SCSI disks in a system may be 
considered reliable and others not, and the same would hold for network 
devices.

In the meantime, while /dev/random isn't what it's supposed to be, I 
pledge to keep IRQF_SAMPLE_RANDOM for network devices, or at least, make 
at a configurable option for headless systems.

egd, etc. are not an adequate replacement for network-generated 
randomness. They either use /dev/hw_random, which is only available on a 
few machines, or system statistics which can hardly count as "random 
noise". On the contrary, the statistics are 100% deterministic if the 
initial system state is known. The only way such data can become 
non-deterministic is through user or network input. User input is not 
available in the scenario we're talking about, and well - network input 
should't count, should it? It's not a proof if such data passes the FIPE 
or diehard tests. These tests are statistical and would be passed by 
totally deterministic data such as the sequence of digits of Pi.

Whatever comes out of this discussion, it's most important that some 
sort of consensus is reached that user space can rely on. The current 
situation is just inconsistent and confusing. I that sense, Chris' patch 
is good because it at least removes the inconsistency between network 
drivers. But I'd only find it acceptable as the first part of a patch 
series that tackles the complete entropy-generation infrastructure.

Regards
Martin

