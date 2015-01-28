From: roopa <roopa@cumulusnetworks.com>
Subject: Re: Fw: [Bug 92081] New: skb->len=0 and getting "EOF on netlink"
 with "ip monitor all" (of iproute) when adding a vlan with "bridge vlan add"
Date: Tue, 27 Jan 2015 21:18:49 -0800
Message-ID: <54C87139.4090805@cumulusnetworks.com>
References: <20150127120123.4550d9ca@uryu.home.lan> <54C7BEA4.9000406@cumulusnetworks.com> <9B0331B6EBBD0E4684FBFAEDA55776F91890AE59@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:54322 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762506AbbA1FSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 00:18:51 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so23151467pab.6
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 21:18:50 -0800 (PST)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F91890AE59@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/15, 10:38 AM, Rosen, Rami wrote:
> Hi, Roopa,
>
>> I think my below commit fixed one case of such error:
> I am well aware of your commit (in fact I even sent cleanup patch on top of it, removing the oflags,  which was applied).
>
> It seems to me that this commit of yours does not avoid the specific problem of getting EOF with "ip monitor all" which is described in the BUG I opened; it
> could be that it avoid problem with other scenarios, and with wrong message size when both SELF and MASTER flags are set.
>
>> The reason for the zero length message in this case is that the user is sending
>>   the setlink request to the bridge with self flag set.
>> And since the getlink on the bridge device only returns bytes when its a  bridge port, there are no bytes in the skb.
>> I will reconfirm that the above is true and submit a patch (I can update the bugzilla link below as well).
> This is exactly so, I am fully confident about it, I checked it in depth with debug , and I had printed the skb->len before calling rtnl_notify() in
> rtnl_bridge_notify() in net/core/rtnetlink.c under such scenario described in the BUG mentioned in the bugzilla link and it was indeed 0.
>
> For the sake of those who are interested in more implementation details and in the code walkthrough under such scenario, what happens when "bridge vlan add vid 1 dev br0 self" , you should follow this path:
>
> Look at rtnl_bridge_setlink() method, it is invoked in this case.
> http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2782
>
> If the SELF flag is set it calls dev->netdev_ops->ndo_bridge_setlink()
> See:
> http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2840
>
> and then it calls rtnl_bridge_notify()
> See:
> http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2850
>
> Now, rtnl_bridge_notify() calls  dev->netdev_ops->ndo_bridge_getlink()
> when the self flag is set.
> See:
> http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2767
>
> Now, when running the "bridge vlan add" on a bridge device like we do (and **not on a bridge port**)
> then the dev variable is an instance of a software bridge. So this calls the ndo_bridge_getlink() callback of the software bridge, which is br_getlink():
> See:
> http://lxr.free-electrons.com/source/net/bridge/br_netlink.c#L205
>
> Now, br_getlink() first checks if the device is a bridge port:
> struct net_bridge_port *port = br_port_get_rtnl(dev);
>
> And it returns 0 if not.
> So as a result, the skb->len is 0 and an empty notification is sent.
>
> And when the rtneltnlink socket, which is opened by "ip monitor all" and listens to netlink messages, receives an
> empty notification it terminates with the "EOF" message (as mentioned in the bugzilla link).
>
> Sending a patch for resolving it and updating the bugzilla will be really great!

Thanks for the details. I have updated the bugzilla with my notes and 
your notes from this email.
Now i have a patch that avoids sending a notification if skb->len == 0. 
But, the real fix is to get bridge driver ndo_bridge_getlink to do the 
right thing and send the updated vlan notification.

I will send the skb->len check  patch shortly. And then look at fixing 
ndo_bridge_getlink
