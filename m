From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Thu, 13 Dec 2012 11:09:03 -0800
Message-ID: <50CA27CF.7010301@intel.com>
References: <20121212170520.GA3060@minipsycho.orion>  <20121212092700.7ef2607a@nehalam.linuxnetplumber.net>  <20121212181017.GB3060@minipsycho.orion>  <20121212101208.361ccda0@nehalam.linuxnetplumber.net>  <20121212182556.GC3060@minipsycho.orion>  <20121212103632.2020efce@nehalam.linuxnetplumber.net>  <20121212184925.GD3060@minipsycho.orion>  <20121212105448.490aca5c@nehalam.linuxnetplumber.net>  <20121212190613.GE3060@minipsycho.orion>  <20121212113433.21c05614@nehalam.linuxnetplumber.net>  <20121213161750.GA1914@minipsycho.orion> <50CA0D3D.5000503@gmail.com>  <20121213155423.07c47307@obelix.rh>  <20121213100933.6d68a8e5@nehalam.linuxnetplumber.net>  <20121213161733.7bffe897@obelix.rh>  <20121213102051.72ad69aa@nehalam.linuxnetplumber.net> <1355423612.21918.34.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Flavio Leitner <fbl@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4575 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755615Ab2LMTJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 14:09:07 -0500
In-Reply-To: <1355423612.21918.34.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2012 10:33 AM, Dan Williams wrote:
> On Thu, 2012-12-13 at 10:20 -0800, Stephen Hemminger wrote:
>> On Thu, 13 Dec 2012 16:17:33 -0200
>> Flavio Leitner <fbl@redhat.com> wrote:
>>
>>> On Thu, 13 Dec 2012 10:09:33 -0800
>>> Stephen Hemminger <shemminger@vyatta.com> wrote:
>>>
>>>> On Thu, 13 Dec 2012 15:54:23 -0200
>>>> Flavio Leitner <fbl@redhat.com> wrote:
>>>>
>>>>> I am saying this because people are used to and there are scripts out
>>>>> there using something like:
>>>>> # ethtool <iface> | grep 'Link'
>>>>> to react an interface failure.
>>>>
>>>> Then the script is broken. It is asking about hardware state.
>>>
>>> I was talking about the team master interface, so it makes sense
>>> to check its 'hardware' state. Just think on 'bond0' interface
>>> with no slaves. It should report Link detected: no.
>>>
>>> See bond_release(), what happens if bond->slave_cnt == 0, for instance.
>>>
>>
>> I was thinking more that ethtool operation for reporting link on
>> the team device should use the proper check rather than just using netif_carrier_ok(),
>> the team ethtool operation for get_link should be check IFF_RUNNING flag
>> in dev->flags which is controlled by operstate transistions.
>
> That's not entirely sufficient, because not everything uses ethtool to
> deterine whether the link/carrier is active.  eg, anything listenting to
> netlink for IFF_RUNNING won't know anything about this.  I may have
> missed previous conversation, but IFF_RUNNING is AFAIK the sole
> mechanism to indicate to userspace that the link is operational and
> ready for general traffic.  Can the team drivers simply not set
> IFF_RUNNING until the interface is actually ready for general traffic?
>
> I'd just caution people to be careful when it comes to carrier/link
> states, as a lot of stuff relies on it, and people keep trying to
> slightly change the meaning of it.  We need it to be consistent across
> net interfaces and driver implementations, not have specific meanings to
> certain drivers that don't apply to others.
>
> If teamd needs to manage the carrier state of the teamX interface,
> perhaps instead of munging the actual carrier state itself, it can flip
> some team-private value that is one component of determining whether
> IFF_RUNNING gets set or not?
>
> Dan

Assuming the operstate documentation is correct IFF_RUNNING should only
be set if the operstate is up or unknown. Quoting the text again,

  32	ifinfomsg::if_flags & IFF_RUNNING:
  33	 Interface is in RFC2863 operational state UP or UNKNOWN. This is for
  34	 backward compatibility, routing daemons, dhcp clients can use this
  35	 flag to determine whether they should use the interface.

So my guess is having a team ethtool get_link handler AND managing the
operstate from teamd would satisfy the requirement. But maybe I missed
something.

.John
