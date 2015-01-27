From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: Fw: [Bug 92081] New: skb->len=0 and getting "EOF on netlink"
 with "ip monitor all" (of iproute) when adding a vlan with "bridge vlan add"
Date: Tue, 27 Jan 2015 18:38:18 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F91890AE59@HASMSX110.ger.corp.intel.com>
References: <20150127120123.4550d9ca@uryu.home.lan>
 <54C7BEA4.9000406@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:55442 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758285AbbA0SiY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 13:38:24 -0500
In-Reply-To: <54C7BEA4.9000406@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Roopa,

> I think my below commit fixed one case of such error:
I am well aware of your commit (in fact I even sent cleanup patch on top of it, removing the oflags,  which was applied).

It seems to me that this commit of yours does not avoid the specific problem of getting EOF with "ip monitor all" which is described in the BUG I opened; it 
could be that it avoid problem with other scenarios, and with wrong message size when both SELF and MASTER flags are set.

> The reason for the zero length message in this case is that the user is sending
>  the setlink request to the bridge with self flag set.
> And since the getlink on the bridge device only returns bytes when its a  bridge port, there are no bytes in the skb.

> I will reconfirm that the above is true and submit a patch (I can update the bugzilla link below as well).

This is exactly so, I am fully confident about it, I checked it in depth with debug , and I had printed the skb->len before calling rtnl_notify() in 
rtnl_bridge_notify() in net/core/rtnetlink.c under such scenario described in the BUG mentioned in the bugzilla link and it was indeed 0.

For the sake of those who are interested in more implementation details and in the code walkthrough under such scenario, what happens when "bridge vlan add vid 1 dev br0 self" , you should follow this path:

Look at rtnl_bridge_setlink() method, it is invoked in this case.
http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2782

If the SELF flag is set it calls dev->netdev_ops->ndo_bridge_setlink()
See:
http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2840

and then it calls rtnl_bridge_notify()
See:
http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2850

Now, rtnl_bridge_notify() calls  dev->netdev_ops->ndo_bridge_getlink()
when the self flag is set.
See:
http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2767

Now, when running the "bridge vlan add" on a bridge device like we do (and **not on a bridge port**)
then the dev variable is an instance of a software bridge. So this calls the ndo_bridge_getlink() callback of the software bridge, which is br_getlink():
See:
http://lxr.free-electrons.com/source/net/bridge/br_netlink.c#L205

Now, br_getlink() first checks if the device is a bridge port:
struct net_bridge_port *port = br_port_get_rtnl(dev);

And it returns 0 if not.
So as a result, the skb->len is 0 and an empty notification is sent.

And when the rtneltnlink socket, which is opened by "ip monitor all" and listens to netlink messages, receives an
empty notification it terminates with the "EOF" message (as mentioned in the bugzilla link).

Sending a patch for resolving it and updating the bugzilla will be really great!

Regards,
Rami Rosen
Intel Corporation



-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of roopa
Sent: Tuesday, January 27, 2015 18:37
To: Stephen Hemminger
Cc: netdev@vger.kernel.org
Subject: Re: Fw: [Bug 92081] New: skb->len=0 and getting "EOF on netlink" with "ip monitor all" (of iproute) when adding a vlan with "bridge vlan add"

I noticed this during my  recent cleanup of rtnl_bridge_setlink/rtnl_bridge_dellink.

I think my below commit fixed one case of such error:

commit 02dba4388d1691a087f40fe8acd2e1ffd577a07f
Author: Roopa Prabhu <roopa@cumulusnetworks.com>
Date:   Wed Jan 14 20:02:25 2015 -0800

     bridge: fix setlink/dellink notifications



The reason for the zero length message in this case is that the user is sending
  the setlink request to the bridge with self flag set.
And since the getlink on the bridge device only returns bytes when its a  bridge port, there are no bytes in the skb.

I will reconfirm that the above is true and submit a patch (I can update the bugzilla link below as well).

Thanks,
Roopa



On 1/27/15, 4:01 AM, Stephen Hemminger wrote:
>
> Begin forwarded message:
>
> Date: Mon, 26 Jan 2015 10:15:12 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" 
> <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 92081] New: skb->len=0 and getting "EOF on netlink" with "ip monitor all" (of iproute) when adding a vlan with "bridge vlan add"
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=92081
>
>              Bug ID: 92081
>             Summary: skb->len=0 and getting "EOF on netlink" with "ip
>                      monitor all" (of iproute) when adding a vlan with
>                      "bridge vlan add"
>             Product: Networking
>             Version: 2.5
>      Kernel Version: 3.17.6-300
>            Hardware: All
>                  OS: Linux
>                Tree: Fedora
>              Status: NEW
>            Severity: high
>            Priority: P1
>           Component: Other
>            Assignee: shemminger@linux-foundation.org
>            Reporter: ramirose@gmail.com
>          Regression: No
>
> On Fedora 21, with 3.17.6-300.fc21.x86_64, with iproute-3.16.0-3 
> (installed from rpm), ip -V:
> ip utility, iproute2-ss140804
>
> Running in one terminal:
> ip monitor all
>
> And then running in a second terminal this sequence:
> ip link add br0 type bridge
> bridge vlan add vid 10 dev br0 self
>
> causes the "ip monitor all" to terminate, with "EOF on netlink".
>
> This happens also on older distros of Fedora (Fedora 20 and downward) 
> with older kernels.
>
> It seems that the reason is that an skb->len is 0 for the netlink 
> notification which is sent from with rtnl_notify() which is invoked 
> from  rtnl_bridge_notify(), which in turn is invoked from  
> rtnl_bridge_setlink().
>
> See:
> http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2773
>
> Rami Rosen
>

--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
