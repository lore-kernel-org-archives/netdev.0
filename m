From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 15:08:55 -0600
Message-ID: <001601c734fb$89ed3b90$cc0a010a@tcssec.com>
References: <20070110204922.GA1652@gondor.apana.org.au>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'James Morris'" <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Paul Moore" <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:17699 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965099AbXAJVJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 16:09:26 -0500
To: "'Herbert Xu'" <herbert.xu@redhat.com>
In-Reply-To: <20070110204922.GA1652@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Only, on a security policy denial (-ESRCH from the LSM hook), a 0
> > is returned by the resolver to signify no applicable policy since
> > a negative result is akin to no policy. And I see the "no policy"
> > case is already cached.
>
> I'm not talking about an xfrm policy lookup failure, that exists
> with or without SELinux. I'm talking about an error returned from
> security_xfrm_policy_lookup(), i.e., whether a policy can be used
> or not.

I was talking about this (the latter) as well. Currently, on a proper
"negative", -ESRCH is returned by security_xfrm_policy_lookup(), and
this comes back up as a 0 from resolver(), correctly indicating NO
applicable
xfrm policy (after taking security into account). But if
security_xfrm_policy_lookup()
were to return anything other than a zero or -ESRCH, such as -ENOMEM,
you will see it come back up as such (as -ENOMEM) from resolver(),
and in this case, it's neither a positive nor a negative, just an error.
Hence a full lookup would be in order, the next time round.

>  For that case, we only cache positive results currently.

Negatives are currently properly cached as NULL. Any errors
returned from resolver() are true errors, not negatives. Hence,
they needn't be cached.

Also, I would fix the other bug you had noted, by something like:

@@ -232,11 +232,7 @@ nocache:
                err = resolver(key, family, dir, &obj, &obj_ref);

                if (fle) {
-                       if (err) {
-                               /* Force security policy check on next
lookup */
-                               *head = fle->next;
-                               flow_entry_kill(cpu, fle);
-                       } else {
+                       if (!err) {
                                fle->genid = atomic_read(&flow_cache_genid);

                                if (fle->object)


I am planning to test and submit a patch to SELinux
to invoke flow_cache_flush() on policy reloads tomorrow.

I believe changes to labels on SPD rules are already
taken care of by checks involving flow_cache_genid.

