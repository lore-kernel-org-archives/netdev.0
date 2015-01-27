From: roopa <roopa@cumulusnetworks.com>
Subject: Re: Fw: [Bug 92081] New: skb->len=0 and getting "EOF on netlink"
 with "ip monitor all" (of iproute) when adding a vlan with "bridge vlan add"
Date: Tue, 27 Jan 2015 08:36:52 -0800
Message-ID: <54C7BEA4.9000406@cumulusnetworks.com>
References: <20150127120123.4550d9ca@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49142 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613AbbA0Qgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 11:36:55 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so19487071pab.3
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 08:36:55 -0800 (PST)
In-Reply-To: <20150127120123.4550d9ca@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed this during my  recent cleanup of 
rtnl_bridge_setlink/rtnl_bridge_dellink.

I think my below commit fixed one case of such error:

commit 02dba4388d1691a087f40fe8acd2e1ffd577a07f
Author: Roopa Prabhu <roopa@cumulusnetworks.com>
Date:   Wed Jan 14 20:02:25 2015 -0800

     bridge: fix setlink/dellink notifications



The reason for the zero length message in this case is that the user is 
sending
  the setlink request to the bridge with self flag set.
And since the getlink on the bridge device only returns bytes when its 
a  bridge port,
there are no bytes in the skb.

I will reconfirm that the above is true and submit a patch (I can update 
the bugzilla link below as well).

Thanks,
Roopa



On 1/27/15, 4:01 AM, Stephen Hemminger wrote:
>
> Begin forwarded message:
>
> Date: Mon, 26 Jan 2015 10:15:12 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
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
> On Fedora 21, with 3.17.6-300.fc21.x86_64, with iproute-3.16.0-3 (installed
> from rpm),
> ip -V:
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
> This happens also on older distros of Fedora (Fedora 20 and downward) with
> older kernels.
>
> It seems that the reason is that an skb->len is 0 for the netlink notification
> which is sent from
> with rtnl_notify() which is invoked from  rtnl_bridge_notify(), which in turn
> is invoked from  rtnl_bridge_setlink().
>
> See:
> http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2773
>
> Rami Rosen
>
