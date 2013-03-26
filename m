From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Tue, 26 Mar 2013 18:02:34 +0000
Message-ID: <5151E2BA.6070703@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20640 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932113Ab3CZSCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 14:02:37 -0400
In-Reply-To: <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 11:08, Wei Liu wrote:
> This patch tries to coalesce tx requests when constructing grant copy
> structures. It enables netback to deal with situation when frontend's
> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> 
> It defines max_skb_slots, which is a estimation of the maximum number of slots
> a guest can send, anything bigger than that is considered malicious. Now it is
> set to 20, which should be enough to accommodate Linux (16 to 19).
> 
> Also change variable name from "frags" to "slots" in netbk_count_requests.

It it worth summarizing an (off-line) discussion I had with Wei on this
patch.

There are two regression that need to be addressed here.

1. The reduction of the number of supported ring entries (slots) per
packet (from 18 to 17).

2. The XSA-39 security fix turning "too many frags" errors from just
dropping the packet to a fatal error and disabling the VIF.

The key root cause of the problem is that the protocol is poorly
specified using a property external to the netback/netfront drivers
(i.e., MAX_SKB_FRAGS).

A secondary problem is some frontends have used a max slots per packet
value that is larger than netback as supported. e.g., the Windows GPLPV
drivers use up to 19.  These packets have always been dropped.

The first step is to properly specify the maximum slots per-packet as
part of the interface.  This should be specified as 18 (the historical
value).

The second step is to define a threshold for slots per packet, above
which the guest is considered to be malicious and the error is fatal.
20 seems a sensible value here.

The behavior of netback for packet is thus:

    1-18 slots: valid
   19-20 slots: drop and respond with an error
   21+   slots: fatal error

Note that we do not make 19-20 valid as this is a change to the protocol
and guests may end up relying on this which would then break the guests
if they migrate or start on host with a limit of 18.

A third (and future) step would be to investigate whether increasing the
slots per-packet limit is sensible.  There would then need to be a
mechanism to negotiate this limit between the front and back ends.

David
