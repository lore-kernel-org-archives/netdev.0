From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next 05/11] net: Add full IPv6 addresses to flow_keys
Date: Fri, 22 May 2015 08:08:26 -0700
Message-ID: <CALx6S36uh-m3isgMdSNCfRqRPAHm-98Y56r8C0bDHMvzgLw+Lw@mail.gmail.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
	<1432253506-3646977-6-git-send-email-tom@herbertland.com>
	<20150522075738.GE2138@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34495 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756048AbbEVPI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 11:08:27 -0400
Received: by ieczm2 with SMTP id zm2so33389085iec.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 08:08:26 -0700 (PDT)
In-Reply-To: <20150522075738.GE2138@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 12:57 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, May 22, 2015 at 02:11:40AM CEST, tom@herbertland.com wrote:
>>This patch adds full IPv6 addresses into flow_keys and uses them as
>>input to the flow hash function. The implementation supports either
>>IPv4 or IPv6 addresses in a union, and selector is used to determine
>>how may words to input to jhash2.
>>
>>We also add flow_get_u32_dst and flow_get_u32_src functions which are
>>used to get a u32 representation of the source and destination
>>addresses. For IPv6, ipv6_addr_hash is called. These functions retain
>>getting the legacy values of src and dst in flow_keys.
>>
>>With this patch, Ethertype and IP protocol are now included in the
>>flow hash input.
>>
>>Signed-off-by: Tom Herbert <tom@herbertland.com>
>
> ...
>
>>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>>index cba6a10..306d461 100644
>>--- a/include/net/flow_dissector.h
>>+++ b/include/net/flow_dissector.h
>>@@ -12,7 +12,7 @@
>>  */
>> struct flow_dissector_key_control {
>>       u16     thoff;
>>-      u16     padding;
>>+      u16     addr_type;
>
>
> I don't understand why this is needed. I don't like this. You assign enum
> flow_dissector_key_id to this. Why not just continue to use
> key->basic.n_proto?

The reason we need the address type is in the case that the caller
provides a single union space for the addresses. Caller is just
interested in the last address type written to that space. If we
overload n_proto to be both the protocol and address type there is a
loss of information. For instance, with MPLS we should be able to
return the value (e.g. MPLS) but also return Ethernet addresses-- this
can be done if n_proto is set to ETH_P_MPLS_UC and addr_type is set to
FLOW_DISSECTOR_KEY_ETH_ADDRS (need to add latter). Another point is
that not all address types we could conceive will have an Ethertype,
but all would have a FLOW_DISSECTOR_KEY_*_ADDRS definition.
