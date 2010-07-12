From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [REGRESSION,BISECTED] Panic on ifup
Date: Mon, 12 Jul 2010 10:01:23 +0300
Message-ID: <4C3ABDC3.3000408@iki.fi>
References: <20100711170908.5770.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45801 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab0GLHBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 03:01:31 -0400
Received: by ewy23 with SMTP id 23so738785ewy.19
        for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 00:01:28 -0700 (PDT)
In-Reply-To: <20100711170908.5770.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2010 08:09 PM, George Spelvin wrote:
>> On 07/11/2010 03:38 PM, George Spelvin wrote:
>>> No, although /etc/ipec-tools.conf runs setkey.  As I said,
>>> I was mostly running in single-user mode; a ps axf
>>> output is appended.
>>>
>>> Ah!  A discovery!  There are rules for the gateway!
>>>
>>> add <my_ip> <gw_ip> esp 0x200 -E aes-cbc
>>> 	<key>;
>>> add <gw_ip> <my_ip> esp 0x300 -E aes-cbc
>>> 	<key>;
>>> spdadd <gw_ip> <my_ip> any -P in ipsec
>>> 	esp/transport//use;
>>> spdadd <my_ip> <gw_ip> any -P out ipsec
>>> 	esp/transport//use;
> 
>> This means optional encryption. Probably something goes wrong
>> constructing the bundle which results in encryption not being applied.
>> And it would look like xfrm_resolve_and_create_bundle() does not take
>> this into account properly. I need to fix it with optional policies.
>>
>> In the mean while, could confirm if everything works if you change the
>> last line to:
>> 	esp/transport//require;
> 
> Will do.
> 
> This might lead to no traffic if there's something else broken, however
> it should not crash. This change is needed only for the 'out' policy, as
> the bundles are used only on xmit code paths.
> 
>> yup, xfrm_resolve_and_create_bundle looks to be the culprit. I'll try to
>> figure out a patch for testing.

Can you try the patch attached to end?

>> Ok, this is basically what setkey did for you. Looks like it was ran
>> twice and you are missing flush and spdflush from setkey, so you get
>> duplicates here. Otherwise it's ok.
> 
> Um, I am *not* missing flush and spdflush.  The entire file, with comments
> and blank lines stripped, and some details censored, is:
> 
> #!/usr/sbin/setkey -f
> flush;
> spdflush;
> add $LOCALNET.1 $LOCALNET.62 esp 0x200 -E aes-cbc <key redacted>;
> add $LOCALNET.62 $LOCALNET.1 esp 0x300 -E aes-cbc <key redacted>;
> add $LOCALNET.3 $LOCALNET.62 esp 0x400 -E aes-cbc <key redacted>;
> add $LOCALNET.62 $LOCALNET.3 esp 0x500 -E aes-cbc <key redacted>;
> spdadd $LOCALNET.1 $LOCALNET.62 any -P in ipsec esp/transport//use;
> spdadd $LOCALNET.62 $LOCALNET.1 any -P out ipsec esp/transport//use;
> spdadd $LOCALNET.3 $LOCALNET.62 any -P in ipsec esp/transport//use;
> spdadd $LOCALNET.62 $LOCALNET.3 any -P out ipsec esp/transport//use;

Ah, ok. Did not bother to double check the related IPs as I thought it
was full ipsec.conf. Everything is okay then.

And here goes the patch (which I've only compile tested so far).

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index af1c173..200f8d7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1598,7 +1598,8 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy
**pols, int num_pols,
 		if (err != -EAGAIN)
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 		return ERR_PTR(err);
-	}
+	} else if (err == 0)
+		return NULL;

 	dst = xfrm_bundle_create(pols[0], xfrm, err, fl, dst_orig);
 	if (IS_ERR(dst)) {
@@ -1678,6 +1679,13 @@ xfrm_bundle_lookup(struct net *net, struct flowi
*fl, u16 family, u8 dir,
 			goto make_dummy_bundle;
 		dst_hold(&xdst->u.dst);
 		return oldflo;
+	} else if (new_xdst == NULL) {
+		num_xfrms = 0;
+		if (oldflo == NULL)
+			goto make_dummy_bundle;
+		xdst->num_xfrms = 0;
+		dst_hold(&xdst->u.dst);
+		return oldflo;
 	}

 	/* Kill the previous bundle */
@@ -1760,6 +1768,10 @@ restart:
 				xfrm_pols_put(pols, num_pols);
 				err = PTR_ERR(xdst);
 				goto dropdst;
+			} else if (xdst == NULL) {
+				num_xfrms = 0;
+				drop_pols = num_pols;
+				goto no_transform;
 			}

 			spin_lock_bh(&xfrm_policy_sk_bundle_lock);
