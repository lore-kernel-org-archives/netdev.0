From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 4 Jun 2015 09:24:37 +0300
Message-ID: <556FEF25.80409@mellanox.com>
References: <55674077.5040707@mellanox.com>
 <20150528174337.GA10448@obsidianresearch.com>
 <1432837360.114391.35.camel@redhat.com>
 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com> <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
 <20150603195325.GC7902@obsidianresearch.com>
 <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
 <20150603234811.GA15128@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150603234811.GA15128-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/06/2015 02:48, Jason Gunthorpe wrote:
> On Wed, Jun 03, 2015 at 11:07:37PM +0300, Or Gerlitz wrote:
> 
>>> I'm mostly fine with it as an optional capability, similar to macvlan,
>>> I just don't see how to cleanly integrate it with RDMA CM and
>>> namespaces. And I don't see what RDMA CM is supposed to do when
>>> it hits this case.
>>>
>>> So, any ideas that don't involve the searching for IP hack??
>>>
>>> [And yes, as discussed with Haggie, it is not the worst hack in the
>>>  world, and maybe we can live with it, but lets understand the trade
>>>  offs carefully]
>>
>> As Haggai wrote, if we let the using IP address thing to fly up, we have
>> support for RDMA in containers using the RDMA-CM at IPoIB environments.
>> This will let people test, use, experiment, fix, interact (and even
>> production-it when static IP address assignment scheme is used).
> 
> I just noticed ipvlan got merged a few months ago.. That certainly
> changed my view on this topic. It is basically a software
> version of the same-guid ipoib children scheme. Similar issues: Same MAC
> address as the parent, IPv6 SLAAC is disabled (?),  DHCP has similar
> issue (solved with RFC4361, and broadcasting fallback, it seems)..
> 
> The l2/l3 distinction in ipvlan is also very interesting. The L3 mode
> solves some of the security type issues. What do you think Haggi?
I think some issues ipvlan is trying to solve would also affect us using
the alias GUIDs solution. ipvlan tries to solve among other the problem
of a limited MAC filter table in NICs, and avoid using promiscuous mode.
But the GID table is also limited, and we don't have something like
promiscuous mode for GIDs in InfiniBand. For large scale use of
containers we would need to also allow the current model.

As for L3 mode, it does seem more restrictive, as all routing decisions
are done in the controlling namespace. Our current ipoib child interface
implementation is more like the L2 version of ipvlan.

> 
> Is there any chance standard things like ipvlan and macvlan could be
> used with rdma-cm if their master devices are IPoIB? 
These standard interfaces seem very much connected with Ethernet (both
have an ARPHDR_ETHER-only check for their upper devices). I think
macvlan's functionality would be covered by adding alias GUIDs to ipoib,
and ipvlan L2 is covered by the current behavior. Perhaps it would be
beneficial to try and make ipvlan more generic so that it would work
over ipoib, giving us support for L3 mode.

As for rdma-cm support, the patch I had for ipoib attempts to scan each
child's upper devices in order to support such topologies. We only
tested it with bonding, but I think it would also work with such devices.

> Are we even on
> the right path to do that someday? Is that the plan for roce?
Yes, for RoCE our goal for the start was to support namespaces in RDMA
CM through macvlan devices. As long as we can update the RoCE gid table
correctly for macvlan and ipvlan devices, the RDMA CM implementation
shouldn't care where the details come from.

> Any thoughts on the idea we still need ipoib same-guid children if
> ipvlan is available?
If we port ipvlan to work over IPoIB interfaces and not just Ethernet,
then ipvlan L2 would provide exactly the same functionality. There onyl
difference I can think of is that ipvlan would use a single UD QP for
all devices (and in connected-mode, a single RC QP between a pair of
hosts), while ipoib would use a QP per child device, and multiple RC QPs
for such pairs.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
