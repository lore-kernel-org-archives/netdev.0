From: Edward Cree <ecree@solarflare.com>
Subject: Re: Checksum offload queries
Date: Thu, 10 Dec 2015 15:49:41 +0000
Message-ID: <56699F15.3030202@solarflare.com>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <20151208.120654.2127200076257822677.davem@davemloft.net>
 <56681B18.3030200@solarflare.com>
 <CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
 <566864C0.6020204@solarflare.com>
 <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:28940 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751370AbbLJPuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 10:50:09 -0500
In-Reply-To: <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/15 18:00, Tom Herbert wrote:
> That is not at all true. If the stack has set up VXLAN RCO and the > device decides to set the inner checksum itself then the checksum > will be bad. The checksum interface is very specific please read it > carefully (sk_buff.h), if the driver/device thinks it is smarter > than the stack and tries to do set its own rules on how checksum > offload works then things will eventually break miserably.

Ok, I've passed that on to the guy working on this bit of the driver.

It looks like the best way to support the capabilities of NICs like the
sfc 8000 series (which can fill in two checksums but uses packet parsing
to figure out what to do, rather than using csum start/offset) is:

(core / stack)
* add NETIF_F_HW_2CSUMS (or whatever name)
* squeeze a second csum start/offset pair into the skb (as you mention,
 we can do this without size increase)
* Modify (Tx) CHECKSUM_PARTIAL generation to use both csum pairs.
 Presumably by creating CHECKSUM_PARTIAL_2CSUMS to indicate that the
 second csum pair has been filled in as well.

(sfc driver)
* declare 2CSUMS support
* on getting an skb for xmit, check whether the csum pairs match what our
 eeevil packet parsing hardware will do.  If so, send it with appropriate
 csum offload settings (we can enable/disable inner & outer offload
 independently, with TX Option descriptors).  Any csum pair that doesn't
 match, we call skb_checksum_help to do it in software, and tell the
 hardware not to do that one.

Optionally, we could also create NETIF_F_IP[V6]_2CSUMS in the stack and
have our driver advertise that instead, but since there has to be a
fallback to skb_checksum_help in the driver anyway, there doesn't seem
to be much point.

Does that seem reasonable?
