From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 10:02:10 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:33546 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030458AbWD1RC0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 13:02:26 -0400
Content-class: urn:content-classes:message
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Fri, Apr 28, 2006 at 08:59:19AM -0700, Caitlin Bestler
> (caitlinb@broadcom.com) wrote:
>>> Btw, how is it supposed to work without header split capabale
>>> hardware?
>> 
>> Hardware that can classify packets is obviously capable of doing
>> header data separation, but that does not mean that it has to do so.
>> 
>> If the host wants header data separation it's real value is that when
>> packets arrive in order that fewer distinct copies are required to
>> move the data to the user buffer (because separated data can be
>> placed back-to-back in a data-only ring). But that's an
>> optimization, it's not needed to make the idea worth doing, or even
>> necessarily in the first implementation.
> 
> If there is dataflow, not flow of packets or flow of data
> with holes, it could be possible to modify recv() to just
> return the right pointer, so in theory userspace
> modifications would be minimal.
> With copy in place it completely does not differ from current
> design with copy_to_user() being used since memcpy() is just
> slightly faster than copy*user().

If the app is really ready to use a modified interface we might as well
just give them a QP/CQ interface. But I suppose "receive by pointer"
interfaces don't really stretch the sockets interface all that badly.
The key is that you have to decide how the buffer is released,
is it the next call? Or a separate call? Does releasing buffer
N+2 release buffers N and N+1? What you want to avoid 
is having to keep a scoreboard of which buffers have been
released.

But in context, header/data separation would allow in order
packets to have the data be placed back to back, which 
could allow a single recv to report the payload of multiple
successive TCP segments. So the benefit of header/data
separation remains the same, and I still say it's a optimization
that should not be made a requirement. The benefits of vj_channels
exist even without them. When the packet classifier runs on the
host, header/data separation would not be free. I want to enable
hardware offloads, not make the kernel bend over backwards
to emulate how hardware would work. I'm just hoping that we
can agree to let hardware do its work without being forced to
work the same way the kernel does (i.e., running down a long
list of arbitrary packet filter rules on a per packet basis).


