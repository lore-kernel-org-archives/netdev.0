From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback registration
Date: Tue, 13 Nov 2007 00:00:08 +0300
Message-ID: <4738BED8.4060701@gmail.com>
References: <20071112151953.052335971@mai.toulouse-stg.fr.ibm.com> <20071112152403.273795630@mai.toulouse-stg.fr.ibm.com> <473879C3.5020301@sw.ru> <m1ejev4dap.fsf@ebiederm.dsl.xmission.com> <473886E2.3020703@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	netdev@vger.kernel.org, xemul@openvz.org,
	containers@lists.osdl.org, yoshfuji@linux-ipv6.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:11026 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbXKLU4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 15:56:18 -0500
Received: by ug-out-1314.google.com with SMTP id z38so817967ugc
        for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 12:56:16 -0800 (PST)
In-Reply-To: <473886E2.3020703@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Let me try to clarify:
> 
>  * when the init network namespace is created, the loopback is created
> first, before ipv6, and the notifier call chain for ipv6 is not setup,
> so the protocol does not receive the REGISTER event
> 
>  * when the init network namespace is destroyed during shutdown, the
> loopback is not unregistered, so there is no UNREGISTER event
> 
>  * when we create a new network namespace, a new instance of the
> loopback is created and a NETDEV_REGISTER is sent to ipv6 because the
> notifier call chain has been setup by the init netns (while ipv6
> protocol is not yet configured for the namespace which is being created)
> 
>  * when the network namespace exits, the loopback is unregistered after
> the ipv6 protocol but the NETDEV_UNREGISTER is sent to addrconf_notify
> while the ipv6 protocol has been destroyed.

this should not be a problem :). IPv6 exiting code could remove in_dev6
at the protocol layer. In this case the notifier will be noop. This
approach is completely equivalent to the unloading of IPv6 module with
persistent loopback.

The registration is still the problem. May be we need to separate
registration from initialization and perform it after protocol layer for
all loopback devices? I'd like this right now, but this is tight change...

> 
> 
> The objective of the patch is to discard these events because they were
> never taken into account and they are not expected to be receive by ipv6
> protocol.
> 
