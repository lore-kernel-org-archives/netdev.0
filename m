From: John Gardiner Myers <jgmyers@proofpoint.com>
Subject: Re: [PATCH] ipv6: fix incorrect unregistration of sysctl when last
 ip deleted
Date: Fri, 29 Apr 2011 14:58:24 -0700
Message-ID: <4DBB3480.9020708@proofpoint.com>
References: <201104272312.p3RNCcl6002068@jgmyers-vm1.eng.proofpoint.com> <20110429.134524.116375005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110429.134524.116375005.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/29/2011 1:45 PM, David Miller wrote:
> First of all, when the machine boots up, you already have the problem
> that you cannot set the accept_ra and addrconf sysctl settings before
> the first ipv6 address is added to the interface.
What do you mean? I see no problem.

One does not need to set the accept_ra and addrconf sysctl settings 
before the first ipv6 address is added to the interface, one needs to 
set them before the interface is brought up. DAD (and thus router 
solicitation) does not happen on down interfaces.

When the machine boots up and the interface is discovered, it starts in 
the down state but with the sysctls registered. There is no problem 
adjusting the settings before bringing the interface up.

> So by definition you already cannot make the settings before it is
> "too late" and the device is already engaging in ipv6 activity.
>
> Giving you the capability to handle this across full ipv6 address
> deletions on the device later on doesn't add anything, and at best it
> gives people a false sense of security about being able to preserve
> these settings across an ipv6 disable on the device.
>
> If people are going to use this new behavior to do some trick like:
>
> 1) Let device come up and assign ipv6 addresses so that sysctls appear
> 2) Set ipv6 sysctls how actually desired
> 3) Delete all ipv6 addresses
> 4) Add them all back
>
> Then I doubly do not want to set a precedent for this kind of usage
> by applying this patch.  Fix the real problem.
This is all nonsense.
> This behavior has been here, and intentionally so, since Alexey added
> the "how" parameter to addrconf_ifdown() back in 1997.
The "how" parameter indicates the device is being deleted. In this case, 
the device is not being deleted.

This does bring up the issue that the call to addrconf_ifdown() when the 
MTU goes below IPV6_MIN_MTU probably also needs to be fixed.
Furthermore, there are other side effects to changing the 'how' parameter
> to zero in this case and I haven't seen any analysis that those won't
> cause any other undesirable side effects either.
If the device isn't going away, then the ip6_ptr shouldn't be zeroed, 
the /proc/net/dev_snmp6 entry shouldn't be deregistered, the stateless 
addrconf flags should be cleared, the regen timer shouldn't be deleted, 
ipv6 multicast shouldn't mark the device down instead of being 
destroyed, and the nd_parms shouldn't be freed.
