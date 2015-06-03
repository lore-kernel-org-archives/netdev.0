From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Wed, 3 Jun 2015 13:03:01 +0300
Message-ID: <556ED0D5.8010502@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	 <1432647280.28905.107.camel@redhat.com> <55671309.6080303@mellanox.com>
	 <1432822057.114391.26.camel@redhat.com> <55674077.5040707@mellanox.com>
	 <20150528174337.GA10448@obsidianresearch.com>
	 <1432837360.114391.35.camel@redhat.com>
	 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Shachar Raindel" <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432850150.114391.56.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 29/05/2015 00:55, Doug Ledford wrote:
> On Thu, 2015-05-28 at 22:05 +0300, Or Gerlitz wrote:
>> So what's your concrete saying here? where should we go from here?
> 
> This excerpt is from the commit log of patch 3/12:
> 
> The IB device and port, together with the P_Key and the IP address should
> be enough to uniquely identify the ULP net device.
> 
> The problem here is that this is wrong.  If we allow more than one
> device per pkey with the same GUID, then DHCP breaks, which is bad in
> and of itself, but it also breaks ipv6 link local addressing.  Which
> means that this hunk in patch 4/12:
> 
> +#if IS_ENABLED(CONFIG_IPV6)
> +       case AF_INET6:
> +               if (ipv6_chk_addr(net, &addr_in6->sin6_addr, dev, 1))
> +                       return true;
> +
> +               break;
> +#endif
> 
> can now be tricked into returning true for incorrect devices.
> 
> Where do we go from here?
> 
> First, I'm inclined to say we should modify the add_child portion of
> IPoIB to refuse to add links to a PKey if that GUID is already present
> on that PKey.  You could then use different PKeys on the default GUID
> for separate namespaces.  If you need separate namespaces on the same
> PKey, then enable alias GUIDs for use on the local adapter and require
> one GUID per namespace on the same PKey.
I don't think blocking the current add_child implementation is needed. I
agree IPv6 SLAAC and DHCP currently don't work well, and adding alias
GUID for child interfaces is important, but the current implementation
can be used with static IPv4 addresses, so I don't think it must be
disabled.

> Then I'm inclined to say that we should map for namespaces using device,
> port, guid/gid, pkey.  And in this situation, since a unique guid/gid on
> any given pkey maps to a unique dhcp identifier and a unique ipv6
> lladdr, this becomes freely interchangeable with device, port, pkey,
> address mappings that this patchset was built around.

What if we change the namespaces patches to map (device, port, GID,
P_Key, IP) to netdev / namespace? That is, to use both the GID and the
IP address. This would allow people to use namespaces with the current
implementation (provided they have a valid configuration with no
conflicting IP addresses), and once alias GUIDs are added, the GUIDs
will be used to uniquely resolve the namespace even with such
misconfigurations.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
