From: "Predrag Hodoba" <predrag.hodoba@gmail.com>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Thu, 29 Mar 2007 16:56:22 +0200
Message-ID: <46d726f90703290756k1894b0aal8df85d46d8c2a25e@mail.gmail.com>
References: <20070327214754.GA11677@dag-work>
	 <20070327.153025.45876618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Griego" <dagriego@gmail.com>, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.226]:58491 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbXC2O4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 10:56:23 -0400
Received: by nz-out-0506.google.com with SMTP id s1so168924nze
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 07:56:23 -0700 (PDT)
In-Reply-To: <20070327.153025.45876618.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: dagriego@gmail.com (David Griego)
> Date: Tue, 27 Mar 2007 14:47:54 -0700
>
>> Adds an IOCTL for aborting established TCP connections, and is
>> designed to be an HA performance improvement for cleaning up, failure
>> notification, and application termination.
>>
>> Signed-off-by:  David Griego <dagriego@gmail.com>
>
> SO_LINGER with a zero linger time plus close() isn't working
> properly?
>
> There is no reason for this ioctl at all.  Either existing
> facilities provide what you need or what you want is a
> protocol violation we can't do.
>

An ioctl like that is sorely missed for high-availability clustering on
Linux and things like the Carrier Grade Linux. Other Unices do have
something similar - there is TCP_IOC_ABORT_CONN ioctl on Solaris and on
FreeBSD/OpenBSD there is TCPCTL_DROP ioctl (accompanied by tcpdrop
utility).

Need for such an API is to a degree indicated in the Carrier Grade Linux
requirements by The Linux Foundation (former OSDL). CGL Clustering
requirements document addresses the need to deal with open TCP sessions in
events of node failure. For example, Carrier Grade Linux Clustering
Requirements Definition (at
http://groups.osdl.org/apps/group_public/download.php/1981/cgl-cluster.pdf)
has two such requirements on its roadmap list:

	CAF.2.3 Deliberate TCP Session Takeover
	CAF.2.4 TCP Session Takeover on Node Failure

(There they talk about session takeover, which is in my opinion quite
difficult to implement, and before such a thing is achieved there is a
clear need for ioctl similar to the one proposed - to tell all clients with
TCP sessions towards the IP address of a failed node that their sessions
are broken, and that they should handle that instantly, not wait for
timeouts to expire. And a client might be a general 3rd party software
where one does not set socket options oneself.)

I'll give a possible use case - let's say we have a highly-available cluster
in active/passive configuration. The active node runs some services and
listens on cluster's IP address. Clients use the cluster's services by
establishing TCP sessions to that IP address. When the active node fails,
the other node should as fast as possible take over the same IP address and
offer the same services, with clients not noticing anything or noticing as
little as possible. Ideally, TCP sessions should be taken over (as
indicated in the Carrier Grade Linux requirements), enabling clients to
continue transparently. But, TCP session takeover is a rather tough
requirement, and before something like that exists (if ever) it would be
quite useful with such ioctl to enable clients to discover broken
sessions and recover in matter of seconds instead of minutes. Obviously, if
one envisages failover of any kind of service, then you can't control what
socket options are used by someone.

Cheers,
Predrag Hodoba
