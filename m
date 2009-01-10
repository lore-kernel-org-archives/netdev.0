From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 3/4] net: pppol2tp - introduce net-namespace functionality
Date: Sat, 10 Jan 2009 21:51:40 +0300
Message-ID: <20090110185140.GE29349@localhost>
References: <20090109195154.320495476@gmail.com>> <4967accc.0c58560a.2ee6.3de4@mx.google.com> <49688120.9000507@katalix.com> <20090110111359.GA29349@localhost> <20090110125444.GB29349@localhost> <4968B929.10801@katalix.com> <20090110151958.GC29349@localhost> <20090110161257.GD29349@localhost> <4968E589.2020904@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:39467 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZAJSvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 13:51:46 -0500
Content-Disposition: inline
In-Reply-To: <4968E589.2020904@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[James Chapman - Sat, Jan 10, 2009 at 06:14:33PM +0000]
| Cyrill Gorcunov wrote:
| > [Cyrill Gorcunov - Sat, Jan 10, 2009 at 06:19:58PM +0300]
| > | [James Chapman - Sat, Jan 10, 2009 at 03:05:13PM +0000]
| > | | Cyrill Gorcunov wrote:
| > | | > [Cyrill Gorcunov - Sat, Jan 10, 2009 at 02:13:59PM +0300]
| > | | > | [James Chapman - Sat, Jan 10, 2009 at 11:06:08AM +0000]
| > | | > | | Cyrill Gorcunov wrote:
| > | | > | | > - Each tunnel and appropriate lock are inside own namespace now.
| > | | > | | > - pppox code allows to create per-namespace sockets for
| > | | > | | >   both PX_PROTO_OE and PX_PROTO_OL2TP protocols. Actually since
| > | | > | | >   now pppox_create support net-namespaces new PPPo... protocols
| > | | > | | >   (if they ever will be) should support net-namespace too otherwise
| > | | > | | >   explicit check for &init_net would be needed.
| > | | 
| > | | Ok, I tested this in my L2TP setup. The first ppp session setup fails
| > | | because the PPPIOCNEWUNIT ioctl returns -EEXIST. I think the problem is
| > | |  the logic in ppp_create_interface(), which does the following to create
| > | | a new ppp interface:
| > | | 
| > | |         /* Initialize the new ppp unit */
| > | |         ppp->file.index = unit;
| > | |         sprintf(dev->name, "ppp%d", unit);
| > | | 
| > | |         ret = register_netdev(dev);
| > | | 
| > | | Looks like there is more work to do in the ppp changes.
| > | | 
| > | |
| > ...
| > 
| > Btw James did connection work without these patches? On
| > pure net-next-2.6 tree? I've some bad feeling that this
| > fail is related to different patch. Just to be sure.
| 
| If you mean, does pppol2tp work with the patches applied when no
| namespace is configured, yes it does.
| 

James I just found that my previous commits in net-next-2.6 could
be breaking the user side apps. I mean when cardmap was here
ppp_create_interface does not fail if user-side application
has asked not for'new' (ie -1) unit but some predefined number not
being used before so any PPPIOCNEWUNIT ioctl call with new unit number was
serviced by ppp module successfully. As only I've introduced idr
technique I missed such a case and now any PPPIOCNEWUNIT call
will not mark unit as 'reserved'. That is why I asked if l2tp
does work without these 'namespace' related patches.

I'm investigating this issue now. It seems idr can't guarantee
to allocate predefined id number (it could be 'equal' or 'above').
Maybe we would have to revert these commits
(commits 7a95d267fb62cd6b80ef73be0592bbbe1dbd5df7 and 
 ab5024ab23b78c86a0a1425defcdde48710fe449).
But this issue is not related to what you have now.

|
| But to test this patch, I ran two l2tp daemons (in different namespaces
| on the same box) and used the veth device to connect them. The failure
| happened on the first l2tp session create because each side tried to
| create a ppp interface called ppp0.
| 
| Should all interface names be unique across the system even when netns
| is used? If so, then ppp_generic needs to assign system-wide unique ppp
| unit numbers.
| 

I don't think it should be like that since net_device is 'net-namespace'
bound. At least register_netdevice() retrieve *net from device being
registered so I suppose devices with same names but in different
namespace could take place. I'll recheck.

Thanks for testing James!

| 
| -- 
| James Chapman
| Katalix Systems Ltd
| http://www.katalix.com
| Catalysts for your Embedded Linux software development
| 

		- Cyrill -
