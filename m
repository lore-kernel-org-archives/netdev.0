From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Sun, 11 Jan 2004 14:39:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4001A667.2020904@pobox.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com> <200401111628.07930.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com, hadi@cyberus.ca,
        Ben Greear <greearb@candelatech.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: <200401111628.07930.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Amir Noam wrote:
> The new SIOCBONDING ioctl handles commands aimed for the bonding 
> module (and not to any specific bonding interface). This is done via 
> an ioctl hook that captures these commands at the socket level 
> (before dev_ioctl()) and passes it to the bonding code. Such commands 
> do not require opening a bonding interface at all, just a valid 
> socket to send the ioctl.

Right.  And this last requirement is spurious.  The operation is 
essentially "open a socket unrelated to X, to perform actions on X".

bonding (and it sounds like VLAN too) needs a specific, well-known 
control point, for controlling module-level data such as the creation 
and deletion of interfaces.

One such well-known control point would be a /dev node.  Jamal's 
suggestion is also an excellent one:  let userspace use netlink to 
communicate with a well known "address" inside the kernel, which would 
work as the central (and thus bonding-module-wide) bonding control 
interface.


> I was trying to follow the example of several other network modules 
> (e.g. vlan, dlci, bridge) that use a socket level ioctl hook to 
> handle such deviceless commands.
> 
> Do you think that a char device is preferrable, given that other 
> similar modules use a socket ioctl hook?

If vlan/dlci/bridge has similar requirements to described above ("open 
socket unrelated to X, to perform actions on X") then they need to be 
fixed up too.

Opening a random socket to use an ioctl(2) to produce some magic 
behavior is just ugly, and we need to avoid that.  Maybe bgreear would 
be open to updating VLAN's interface to netlink at the same time, for 
example?  That would allow us (us==netdev) to understand all angles and 
implications of a good interface design.  VLAN AFAICS has a similar 
requirement:  need an interface _unrelated_ to specific VLAN interfaces, 
to control VLAN interfaces.  And netlink certainly works as a control 
protocol :)

	Jeff
