From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: BRIDGE_FLAGS_MASTER is used instead of BRIDGE_VLAN_INFO_MASTER
 flag in bridge/vlan.c
Date: Fri, 15 Aug 2014 12:06:32 -0400
Message-ID: <53EE3008.1070109@redhat.com>
References: <CAGXs5wVPS6YdTsiPxj3aaiwHVSgUhiXtUHxFUNTKDUKxRKTD5A@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: Kevin Wilson <wkevils@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbaHOQGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 12:06:37 -0400
In-Reply-To: <CAGXs5wVPS6YdTsiPxj3aaiwHVSgUhiXtUHxFUNTKDUKxRKTD5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2014 03:20 PM, Kevin Wilson wrote:
> Hello,
> 
> The BRIDGE_VLAN_INFO_MASTER flag was added to /include/uapi/linux/if_bridge.h
> by commit 407af3299ef1ac7e87ce3fb530e32a009d1a9efd,
> "Add netlink interface to configure vlans on bridge ports".
> The value of this flag is checked in the kernel only in the br_afspec()
> method, net/bridge/br_netlink.c.
> 
> 
> Can someone please explain how and where is the BRIDGE_VLAN_INFO_MASTER
> flag set in userspace?

It currently is not used by iproute, but there is nothing that precludes it
from being used by any other rtnetlink app.

> I cannot find such a case. The natural place
> for it is bridge/vlan.c ?(of
> proute2), but it is not set there, and  not in any other module of iproute2.
> see:
> http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/tree/bridge/vlan.c
> 
> There is another flag named "BRIDGE_FLAGS_MASTER" which is set in
> bridge/vlan.c of iproute2.
> 
> Both these flags, BRIDGE_FLAGS_MASTER and BRIDGE_VLAN_INFO_MASTER,
> appear in include/linux/if_bridge.h in iproute2, and both have the
> value 1.
> 
> Could it be a mistake, and in fact when setting BRIDGE_FLAGS_MASTER
> in bridge/vlan.c of iproute2, the meaning was to set
> BRIDGE_VLAN_INFO_MASTER (but since both there values are the same,
> it was not noticed since it caused no problem)?

No, these 2 flags have different meanings.  BRIDGE_FLAGS_MASTER is
universal and tells rtnetlink core to perform the operation on
the bridge device using bridge operations instead of the slave device
with slave device operations.

This is what lets do things like
  # Add vid 100 to the vlan filter list for port eth0 on the bridge
  # eth0 belongs to.
  #
  # bridge vlan add dev eth0 vid 100 master

If you would have set 'self' there, the rtnletlink core would have used
the eth0 device operation which would have bypassed the bridge completely.

BRIDGE_VLAN_INFO_MASTER is meant to be short cut that will add the same
vlan information to the bridge device as it would do to the port.  Supporting
it in iproute, however, would have allowed bridge command to configure the same
thing 2 different ways which would be confising.  Initially I did have another
command line flag that set this option allowed you to do things like:
  # bridge vlan add dev eth0 vid 100 master vlan_master

This would add vid 100 to the filter list for both the port and the bridge device
itself, so that packets tagged with the vlan could be forwarded to the port and
the bridge itself.  But it is really a short cut for the following 2 commands:
  # bridge vlan add dev eth0 vid 100 master
  # bridge vlan add dev br0 vid 100 self

The second is much clearer from the configuration point of view.  Thus iproute
got changed, but the kernel still carries the flag.

It would have been much better if BRIDGE_VLAN_INFO_MASTER was not introduced at
all, but at the time I made the mistake of proposing and it got accepted. :(

> It
> seems to me that we do not really mean to set
> a bridge flag (BRIDGE_FLAGS_MASTER) in a vlan module.
> This mistake is the only explanation I can think of for why
> BRIDGE_VLAN_INFO_MASTER
> is not used in bridge/vlan.c of iproute2.
> 
> If this is the case, I volunteer to send a patch to fix this
> by setting BRIDGE_VLAN_INFO_MASTER instead of BRIDGE_FLAGS_MASTER
> in bridge/vlan.c.

As for the patch, it be cleaner to remove BRIDGE_VLAN_INFO_MASTER, but
that might break the ABI...

May be a doc patch explaining when to to use BRIDGE_VLAN_INFO_MASTER would
be better...

Thanks
-vlad

> 
> Regards,
> Kevin
> 
