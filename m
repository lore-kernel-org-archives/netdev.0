From: Dan Langlois <daniel.langlois@siemens.com>
Subject: IGMPMSG_WRONGVIF only happens when true VIF is an OIF of correct
 IIF?
Date: Fri, 18 Feb 2011 16:46:56 +0100
Message-ID: <1298044016.2898.12.camel@thor>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from taad0e1a.siemens.dk ([94.101.220.112]:3517 "EHLO
	taad0e1a.siemens.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751758Ab1BRQTX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:19:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I have a question about the IGMPMSG_WRONGVIF message.
I have MRT_ASSERT enabled but do not receive notifications.
However, if I enable MRT_PIM, I do get them.  I'm curious
why MRT_ASSERT alone isn't sufficient.

This if-statement appears in ip_mr_forward() in net/ipv4/ipmr.c

       if (true_vifi >= 0 && net->ipv4.mroute_do_assert &&
            /* pimsm uses asserts, when switching from RPT to SPT, 
               so that we cannot check that packet arrived on an oif. 
               It is bad, but otherwise we would need to move pretty
               large chunk of pimd to kernel. Ough... --ANK
             */      
            (net->ipv4.mroute_do_pim ||
             cache->mfc_un.res.ttls[true_vifi] < 255) && 
            time_after(jiffies,
                       cache->mfc_un.res.last_assert +
MFC_ASSERT_THRESH)) {
                cache->mfc_un.res.last_assert = jiffies;
                ipmr_cache_report(net, skb, true_vifi,
IGMPMSG_WRONGVIF);
        }       


By the time this statement is reached, it is known that the packet
did not arrive on the expected incoming interface (IIF) and thus a
"WRONGVIF" condition.  This if-statement decides whether a PIM-assert
notification needs to be sent to the multicast routing daemon.

The part of this if-statement I'm questioning is:
    (net->ipv4.mroute_do_pim ||
     cache->mfc_un.res.ttls[true_vifi] < 255) &&

I read this as:
"send WRONGVIF if PIM is enabled -OR-
the packet arrived on an outgoing interface OIF of the correct IIF"

So this statement is always true when PIM is enabled.
However, if only ASSERT is enabled, this statement is only true when
a packet is reflected back on an OIF.

Why not always send the assert for any WRONGVIF condition regardless
of the interface it came in on?  I mean, isn't that the point of
enabling MRT_ASSERT in the first place?  If the assertions weren't
wanted, just don't enable that feature, right?

In our system, multicast streams may get rerouted through a different
VIF than what was first installed in the MFC cache.  I would very much
like to get these WRONGVIF assertions in this case, which is NOT the
case that a packet is seen on an OIF.

Of course I can simply enable MRT_PIM to get the messages, but in that
case I don't understand the reason for having two separate toggles
(MRT_ASSERT versus MRT_PIM).

Could someone please explain the reasoning here, as I don't understand
the comment, and I'm tempted to patch out this part of the if-statement.

cheers,
Dan

