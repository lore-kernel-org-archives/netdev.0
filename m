From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH v2 net-next] Introduce a sysctl that modifies the value
 of PROT_SOCK.
Date: Fri, 13 Jan 2017 16:13:35 -0800
Message-ID: <20170114001335.GD3094@templeofstupid.com>
References: <20161231125505.7f0c7dff@xeon-e3>
 <20170112065225.GB2345@templeofstupid.com>
 <20170112.092213.864894939381841760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kjlx@templeofstupid.com, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:47143 "EHLO
        homiemail-a43.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750713AbdANANh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:13:37 -0500
Received: from homiemail-a43.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a43.g.dreamhost.com (Postfix) with ESMTP id E5EE86002D19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:13:36 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a43.g.dreamhost.com (Postfix) with ESMTPSA id B4EA16002D17
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:13:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170112.092213.864894939381841760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 09:22:13AM -0500, David Miller wrote:
> From: Krister Johansen <kjlx@templeofstupid.com>
> > The use case for this change is to allow containerized processes to bind
> > to priviliged ports, but prevent them from ever being allowed to modify
> > their container's network configuration.  The latter is accomplished by
> > ensuring that the network namespace is not a child of the user
> > namespace.  This modification was needed to allow the container manager
> > to disable a namespace's priviliged port restrictions without exposing
> > control of the network namespace to processes in the user namespace.
> 
> This is what CAP_NET_BIND_SERVICE is for, and why it is a separate
> network privilege, please use it.

It sounds like I may have done an inadequate job of explaining why I
took this approach instead of going the CAP_NET_BIND_SERVICE route.

In this scenario, the network namespace is created and configured first.
Then the containerized processed get placed into a separate user
namespace.  This is so that the processes in the container, even if they
somehow manage to obtain extra privilege in the userns, can never modify
the network namespace.

The check in ns_capable() is looking at the priviliges of the user
namespace that created the netns and its parents.  Even if I were to
grant a process in the container CAP_NET_BIND_SERVICE, ns_capable()
wouldn't recognize that as being a valid privilige for the netns.

If I were to invert the order of operations and create the userns before
the netns, then the capability would be recognized.  However, that also
allows any potential privilege escalation in the userns to bring with it
the potential that an attacker can modify the container's network
configuration.

I'd much rather run the containers without privs, and without the userns
having rights to the netns, to mitigate the risk of an attacker being
able to alter the container's networking configuration.

-K
