From: "George Spelvin" <linux@horizon.com>
Subject: Re: [REGRESSION,BISECTED] Panic on ifup
Date: 11 Jul 2010 13:09:08 -0400
Message-ID: <20100711170908.5770.qmail@science.horizon.com>
References: <4C39D834.8080206@iki.fi>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: linux@horizon.com, timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:61515 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751683Ab0GKRPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 13:15:50 -0400
In-Reply-To: <4C39D834.8080206@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 07/11/2010 03:38 PM, George Spelvin wrote:
>> No, although /etc/ipec-tools.conf runs setkey.  As I said,
>> I was mostly running in single-user mode; a ps axf
>> output is appended.
>> 
>> Ah!  A discovery!  There are rules for the gateway!
>> 
>> add <my_ip> <gw_ip> esp 0x200 -E aes-cbc
>> 	<key>;
>> add <gw_ip> <my_ip> esp 0x300 -E aes-cbc
>> 	<key>;
>> spdadd <gw_ip> <my_ip> any -P in ipsec
>> 	esp/transport//use;
>> spdadd <my_ip> <gw_ip> any -P out ipsec
>> 	esp/transport//use;

> This means optional encryption. Probably something goes wrong
> constructing the bundle which results in encryption not being applied.
> And it would look like xfrm_resolve_and_create_bundle() does not take
> this into account properly. I need to fix it with optional policies.
> 
> In the mean while, could confirm if everything works if you change the
> last line to:
> 	esp/transport//require;

Will do.

This might lead to no traffic if there's something else broken, however
it should not crash. This change is needed only for the 'out' policy, as
the bundles are used only on xmit code paths.

> yup, xfrm_resolve_and_create_bundle looks to be the culprit. I'll try to
> figure out a patch for testing.

> Ok, this is basically what setkey did for you. Looks like it was ran
> twice and you are missing flush and spdflush from setkey, so you get
> duplicates here. Otherwise it's ok.

Um, I am *not* missing flush and spdflush.  The entire file, with comments
and blank lines stripped, and some details censored, is:

#!/usr/sbin/setkey -f
flush;
spdflush;
add $LOCALNET.1 $LOCALNET.62 esp 0x200 -E aes-cbc <key redacted>;
add $LOCALNET.62 $LOCALNET.1 esp 0x300 -E aes-cbc <key redacted>;
add $LOCALNET.3 $LOCALNET.62 esp 0x400 -E aes-cbc <key redacted>;
add $LOCALNET.62 $LOCALNET.3 esp 0x500 -E aes-cbc <key redacted>;
spdadd $LOCALNET.1 $LOCALNET.62 any -P in ipsec esp/transport//use;
spdadd $LOCALNET.62 $LOCALNET.1 any -P out ipsec esp/transport//use;
spdadd $LOCALNET.3 $LOCALNET.62 any -P in ipsec esp/transport//use;
spdadd $LOCALNET.62 $LOCALNET.3 any -P out ipsec esp/transport//use;

Anyway, thank you very much!
