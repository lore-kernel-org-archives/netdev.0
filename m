From: Edward Cree <ecree@solarflare.com>
Subject: Re: Checksum offload queries
Date: Thu, 10 Dec 2015 20:28:22 +0000
Message-ID: <5669E066.8090703@solarflare.com>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <20151208.120654.2127200076257822677.davem@davemloft.net>
 <56681B18.3030200@solarflare.com>
 <CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
 <566864C0.6020204@solarflare.com>
 <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
 <56699F15.3030202@solarflare.com>
 <CALx6S34bg-iRMcTpGd+yw+CV1T7MxpWx+i_AdxXjsfTTnOGK4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:29355 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752425AbbLJU2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 15:28:31 -0500
In-Reply-To: <CALx6S34bg-iRMcTpGd+yw+CV1T7MxpWx+i_AdxXjsfTTnOGK4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/15 16:26, Tom Herbert wrote:
> It sounds like potentially interesting work. You'll probably want my patches that provider helper functions that allow a driver to verify that it can offload a checksum. We'll have to update those also to allow two checksums. 
I have just realised something startling.  Assuming the inner protocol uses the ones complement checksum in the way IP, UDP and TCP do, the outer checksum can be computed *without looking at the payload*.  Why?  Because the ones complement sum of (say) a correctly checksummed UDP datagram is simply the complement of the ones complement sum of the pseudo header.  Similarly, the ones complement sum of a correctly checksummed IP header is zero.
Therefore, the outer checksum depends _only_ on the inner and outer pseudo headers and the encapsulation headers.  For example, with UDP encapsulated in VXLAN, we have the following packet structure:
ETH IP UDP VXLAN inner-ETH inner-IP inner-UDP PAYLOAD
and the outer checksum equals
~([outer_pseudo] + [UDP] + [VXLAN] + [inner-ETH] + ~[inner_pseudo])
where [] denotes summation, and all addition is ones complement.
This can easily be computed in software, especially as the stack already has ~[inner_pseudo]: it's stored in the inner checksum field to help inner checksum offload.

Have I made a mistake in my ones-complement maths, or is outer checksum offload as unnecessary as IP header checksum offload?
