From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Fri, 14 May 2010 12:47:59 +0200
Message-ID: <4BED2A5F.3050008@trash.net>
References: <C811BD6D.312C4%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	arnd@arndb.de
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab0ENKsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 06:48:01 -0400
In-Reply-To: <C811BD6D.312C4%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman wrote:
> On 5/13/10 1:40 PM, "Patrick McHardy" <kaber@trash.net> wrote:
> 
>>> +  if (vf_port[IFLA_VF_PORT_VF])
>>> +   vf = nla_get_u32(vf_port[IFLA_VF_PORT_VF]);
>>> +  err = -EOPNOTSUPP;
>>> +  if (ops->ndo_set_vf_port)
>>> +   err = ops->ndo_set_vf_port(dev, vf, vf_port);
>> This appears to be addressing a single VF to issue commands.
>> I already explained this during the last set of VF patches,
>> messages are supposed to by symetrical, since you're dumping
>> state for all existing VFs, you also need to accept configuration
>> for multiple VFs. Basically, the kernel must be able to receive
>> a message it created during a dump and fully recreate the state.
> 
> This was modeled same as existing IFLA_VF_ cmd where single VF is addressed
> on set, but all VFs for PF are dumped on get.

Yes, that one should have been done differently as well,
unfortunately my comments were ignored. So far rtnetlink
had two properties that are now broken:

- messages sent by the kernel could be sent back to the
  kernel to re-create an object in the same state

- the same parsing functions could be used in userspace for
  messages sent by the kernel and netlink error messages,
  which contain the original userspace message

I know at least one program I've written a few years ago which
relies on the second property. Anyways, this is easily fixable
by encapsulating all top-level VF attributes in a list and
invoking the ndo_set_vf_port() callback for each VF configuration.
