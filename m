From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH 1/1] ppp: Fix one deadlock issue of PPP when send frame
Date: Sat, 20 Aug 2016 00:47:54 +0200
Message-ID: <20160819224754.ddfl2u4edfkctw4f@alphalink.fr>
References: <1471345503-10085-1-git-send-email-fgao@ikuai8.com>
 <CA+6hz4qN-UmSutpCOY1KtrPBakh+2Qa+VUNVid7dq7EPWZE+aw@mail.gmail.com>
 <96f03d73-73f9-23ac-591f-a855169f8dc9@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Feng Gao <gfree.wind@gmail.com>,
        Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>,
        paulus@samba.org, linux-ppp@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Philp Prindeville <philipp@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:37908 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753576AbcHSWr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 18:47:58 -0400
Content-Disposition: inline
In-Reply-To: <96f03d73-73f9-23ac-591f-a855169f8dc9@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 18, 2016 at 08:11:15AM -0600, Philp Prindeville wrote:
> 
> It seems unlikely to me that this sort of locking problem hasn't existed
> elsewhere before and that an entirely new mechanism for handling it is
> needed...  How are similar re-entrancy issues handled elsewhere?
>
Virtual devices like vxlan and geneve drop packets if the ouput device
(after encapsulation) is the same as the encapsulating device.
It's possible to bypass this check by stacking devices. In this case,
recursion occurs until __dev_queue_xmit() triggers the
XMIT_RECURSION_LIMIT. If the qdisc isn't noqueue so that recursion
isn't stopped by __dev_queue_xmit(), then it's possible to fill the
skb's headroom and the packet gets drop after pskb_expand_head() fails.

In any case only the faulty path is affected and the system remains
stable.

It'd be nice to have PPP working this way, but this is made really
difficult by the number of locks used in the xmit path.
Even checking if the output interface is also the encapsulating one
isn't trivial. The L2TP layer doesn't access the upper interface. It
may not even be a PPP device in case of L2TPv3.
