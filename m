From: "Andrew Brampton" <brampton@gmail.com>
Subject: Receive Side Support (RSS) - Adding support into the kernel
Date: Fri, 21 Nov 2008 17:48:22 +0000
Message-ID: <d41814900811210948p2fb2059epbd381a8105ab8959@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:1443 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304AbYKURsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 12:48:23 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1044734rvb.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 09:48:23 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Recently I've been interested in receive side support (RSS)[1], the
ability for a network card to hash certain fields in a incoming
packet's header, and map this hash to a particular core/processor on
the computer. The idea is that each packet, for example, in a TCP
connection will always be processed by the same core.

Now, some drivers have support for RSS, such as the Intel ixgbe
drivers, and a few others, but the drivers either statically setup the
RSS support, or just leave it disabled.

I believe there should be some way for the kernel to configure the RSS
support inside the drivers. I've googled, and not seen people talking
about adding support. Now I feel I could code some patches which will
begin to add support, but before I do this I wanted to ask for
opinions on the subject. I must note I've never submitted a patch to
the linux kernel, but over the past few years I have made a number of
private hacks, which have worked good enough for me :)

There are three RSS settings which can be configured
1) Which fields of the packet get hashed.
2) The key used by the hashing algorithm
3) The indirection table, which is used to map a 7bit hash value to a
particular core.

I also see there are two things which may configure these options, the
user, or the kernel.
The kernel could for example, configure the indirection table based on
some kind of knowledge (such as which cores are free, or which cores
the receiving application is running on). This task may be too complex
for the kernel to normally do, so the second approach is to configure
this stuff from user-land.
The user-land approach, would be similar to the irqbalance daemon[2].
The irqbalance daemon changes which cores interrupts are fired for
different hardware devices (such as network card) to improve either
performance or power management. I can imagine a RSS daemon which
monitors all the current UDP/TCP flows and decide how to balance them
across the cores.

I think creating a userland daemon is the best approach, as such here
are my suggestions for changes to be made to the kernel.

I'm suggesting that firstly each driver exports a set of functions
which allow the RSS settings to be changed. This can be done by adding
another field to the net_device struct, which would be a struct of
function pointers, such as rss_set_key, rss_get_get, rss_set_hash,
rss_get_hash, etc. Then I suggest creating a new netlink namespace,
which would allow a userland application to configure this on each
device. I'm unsure if the rtnetlink can be altered, since that already
supports queues, and other similar assignments.

Ok, that is my general idea for the moment. I'd be interested in
hearing people's responses. If my current approach sounds good, then
I'll start hacking, and send patches for review. If my approach sounds
bad I would love to hear why and refine my ideas. Also if people want
it I can write a more detailed document explaining exactly what
changes I would make.

thanks
Andrew Brampton
PhD Student, Lancaster University

[1] http://www.microsoft.com/whdc/device/network/ndis_rss.mspx
[2] http://www.irqbalance.org/
