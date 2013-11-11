From: Chris J Arges <chris.j.arges@canonical.com>
Subject: Re: iproute2: potential upgrade regression with 58a3e827
Date: Mon, 11 Nov 2013 15:26:32 -0600
Message-ID: <52814B88.1050708@canonical.com>
References: <527D2768.1030403@canonical.com> <527E6A32.5020808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Brian Haley <brian.haley@hp.com>, shemminger@osdl.org,
	ebiederm@xmission.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:57010 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab3KKV0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 16:26:21 -0500
In-Reply-To: <527E6A32.5020808@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2013 11:00 AM, Brian Haley wrote:
> On 11/09/2013 02:03 AM, Chris J Arges wrote:
>> Hi,
>> The commit
>> https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=58a3e8270fe72f8ed92687d3a3132c2a708582dd
>>
>> could be potentially introducing a regression on an upgrade.
>>
>> I've noticed that upgrading iproute while there are active namespaces
>> could cause the following error:
>> seting the network namespace failed: Invalid argument
>>
>> Here's a test case:
>> Build and install iproute2 with 4395d48c78a77a99c5a8618403211032356fe552
>>
>> In one terminal run:
>> ip netns add netns_old
>> ip link add name if_old type veth peer name if_old_peer
>> ip link set dev if_old_peer netns netns_old
>> ip netns exec netns_old bash
>>
>> Build and install iproute2 with yypyye72f8ed92687d3a3132c2a708582dd
>>
>> In the same terminal as you typed the original commands run:
>> ip netns add netns_one
>> ip link add name if_one type veth peer name if_one_peer
>> ip link set dev if_one_peer netns netns_one
>> ip netns exec netns_one bash
>> ip netns exec netns_old bash
>>
>> You'll get:
>> seting the network namespace failed: Invalid argument
>>
>> If you just run the above without transitioning to the code in 58a3e827,
>> then it works.
> 
> I've seen this error recently as well, and when it does happen if you go
> look in /var/run/netns you'll see that the permissions on your
> namespace(s) are most likely 000.  The only solution I found was to
> reboot, and then only use the newer iproute.
> 
> Maybe that info can help track down the cause?
> 
> -Brian
> 

Good suggestion,
So I'll use a more simple example now:

1)
ip netns add first
ip netns exec first bash

2)
ip netns add second
ip netns exec second bash

3)
ip netns exec first bash

If we do not upgrade the package, after we execute (2) we have:
# ls -l /var/run/netns
total 0
-r-------- 1 root root 0 Nov 11 20:38 first
-r-------- 1 root root 0 Nov 11 20:38 second

If we upgrade after (1), then run (2) we have:
# ls -l /var/run/netns
total 0
---------- 1 root root 0 Nov 11 20:56 first
-r-------- 1 root root 0 Nov 11 20:57 second

So looks like netns add is doing something different from 58a3e827 and on.

I'll have to spend more time to do further analysis.
--chris
