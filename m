From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Fri, 24 Jul 2009 15:44:07 -0500
Message-ID: <1248468247.16746.12.camel@merlyn>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	 <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f192.google.com ([209.85.222.192]:35596 "EHLO
	mail-pz0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbZGXUoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 16:44:14 -0400
Received: by pzk30 with SMTP id 30so1215231pzk.33
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 13:44:14 -0700 (PDT)
In-Reply-To: <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-07-07 at 12:26 -0700, Dan Smith wrote:
>  2. I don't do anything to redirect or freeze traffic flowing to or from the
>     remote system (to prevent a RST from breaking things).  I expect that
>     userspace will bring down a veth device or freeze traffic to the remote
>     system to handle this case.

Theoretically, you can drop any packet that's in flight (ingress or
egress), because IP doesn't guarantee delivery.  TCP is able to recover,
and a UDP or raw-socket application should already be designed to.  Of
course, retransmissions will have an impact on application performance
in the migration case, so that's got to be considered in the tradeoff.
Main goal should probably be avoiding anything that shoves either end
into slow-start.

Thinking out loud, have you considered draining TCP buffers rather than
including them in the checkpoint?  You'd stop ingress traffic, and let
the app run until it had read everything in the socket buffer.  On the
egress side, you'd cork the app by telling it that buffers were full,
and then wait until the data already at the socket layer had been
transmitted.  Both are somewhat unbounded re time, and probably not
worth it, but maybe there's some variant of this idea that has value.
TCP transmit buffers on 10GE links can be pretty big...

BTW, if you see RSTs, that probably means you've created a protocol
violation due to a buggy restore.  Just blocking or dropping packets
shouldn't result in an RST unless it's very long.

  --  John

