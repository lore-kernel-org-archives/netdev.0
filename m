From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Multicast and receive filtering in TUN/TAP
Date: Wed, 09 Jul 2008 15:58:23 -0700
Message-ID: <4875428F.4080704@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Brian Braunstein <linuxkernel@bristyle.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Shaun Jackman <sjackman@gmail.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-fou
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:16921 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbYGIW6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 18:58:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yesterday while fixing xoff stuckiness issue in the TUN/TAP driver I got 
a chance to look into the multicast filtering code in there. And 
immediately realized how terribly broken & confusing it is. The patch 
was originally done by Shaun (CC'ed) and went in without any proper ACK 
from me, Dave or Jeff.
Here is the original ref
	http://marc.info/?l=linux-netdev&m=110490502102308&w=2

I'm not going to dive into too much details on what's wrong with the 
current code. The main issues are that it mixes RX and TX filtering 
which are orthogonal, and it reuses ioctl names and stuff for 
manipulating TX filter state as if it was a normal RX multicast state.
Later on Brian's patch added insult to the injury
	http://git.kernel.org/?p=linux/kernel/git/\
		torvalds/linux-2.6.git;\
		a=commit;h=36226a8ded46b89a94f9de5976f554bb5e02d84c
Brian missed the point of the original patch (not his fault, as I said 
the original patch was not the best) that the separate address 
introduced by the MC patch was used for filtering _TX_ packets. It had 
nothing to do with the HW addr of the local network interface.

The problem is that MC stuff is now even more broken and ioctls that 
were used originally now mean something different. So my first thinking 
was to just rip the MC stuff out because it's broken and probably nobody 
uses it (given that we got no complains after Brian's patch broke it 
completely). But then I realized that if done properly it might be very 
useful for virtualization.

---

So the first question is are there any users out there that ever used 
the original patch. Shaun, any insight ? How did you intend to use it ?

---

The second question is do you guys think that QEMU/KVM/LGUEST/etc would 
benefit if receive filtering was done by the host OS. Here is a specific 
example of what I'm talking about.
We can do what qemu/hw/e1000.c:receive_filter() does in the _host_ 
context (that function currently runs in the guest context). By looking 
at libvirt, typical QEMU based setup is that you have a single bridge 
and all the TAPs from different VMs are hooked up to that bridge. What 
that means is that if one VM is getting MC traffic or when the bridge 
sees MACADDR that is not in its tables the packets get delivered to all 
the VMs. ie We have to wake all of the up only to so that they could 
drop that packet. Instead, we could setup filters in the host's side of 
the TAP device.
Does that sound like something useful for QEMU/KVM ?
If yes we can talk about the API. If not then I'll just nuke it.

Thanx
Max
