From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH 4/7] secid reconciliation-v02: Invoke LSM hook for out
 bound traffic
Date: Wed, 20 Sep 2006 22:16:17 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609202201090.32645@d.namei>
References: <36282A1733C57546BE392885C061859201573239@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:40601 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751005AbWIUCQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 22:16:21 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C061859201573239@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Sep 2006, Venkat Yekkirala wrote:

> > Quite a lot of logic has changed here.
> > 
> > With the original code, we only restored a secmark once for 
> > the lifetime 
> > of a packet or connetcion (to make behavior deterministic and 
> > security 
> > marks immutable in the face of arbitrarily complex iptables rules).
> > 
> > With your patch, secmarks are always writable.
> 
> Hopefully the following thread addressed these concerns.
> http://marc.theaimsgroup.com/?l=selinux&m=115870100405571&w=2

Ok, but can we preserve existing behavior when packet are only being 
labeled internally?

(We should probably settle on the use of 'external' for cipso/xfrm 
labeling and 'internal' for iptables only).


> > Also, we did not restore a 'null' (zero) secmark to the skb 
> > (while this 
> > should never happen with the current SECMARK target, there may be 
> > non-SELinux extensions later which set a null marking).
> 
> How do you envision this (i.e. resoring a null secmark) being useful?
> secmark is anyway zero by default (when no labeling rules exist for the
> connection) right?

Actually, don't worry about this.  The implementation can decide what a 
'null' mark might be and manage it themselves.


> > You've also changed the logic for the dummy case of 
> > security_skb_netfilter_check()
> 
> I am not getting this. This is a new function. Did you mean
> to point to a different function?
> 
> > 
> > 
> > +static inline int security_skb_netfilter_check(struct sk_buff *skb,
> > +                                       u32 nf_secid)
> > +{
> > +       return 1;
> > +}
> > +
> > 
> > This code does not now behave as it did originally.  Keep in 
> > mind that 
> > SELinux is not the only user of SECMARK.

I'm talking about the code as a whole and the way this hook does not 
preserve existing behavior in the default case.

Look at the original code:

static void secmark_restore(struct sk_buff *skb)
{
        if (!skb->secmark) {
                u32 *connsecmark;
                enum ip_conntrack_info ctinfo;

                connsecmark = nf_ct_get_secmark(skb, &ctinfo);
                if (connsecmark && *connsecmark)
                        if (skb->secmark != *connsecmark)
                                skb->secmark = *connsecmark;
        }
}

Now, you have added an LSM hook in here:

+       /* Set secmark on inbound and filter it on outbound */
+       if (hooknum == NF_IP_POST_ROUTING || hooknum == NF_IP6_POST_ROUTING) {
+               if (!security_skb_netfilter_check(skb, secmark))
+                       return NF_DROP;
+       } else
+               if (skb->secmark != secmark)
+                       skb->secmark = secmark;

The dummy hook does not restore the secmark in the way that the original 
code does, now depending on the hooknum.

When LSM is not configured or no LSM module is active, the behavior of the 
code must be identical to the original version.

> > I really don't know if connection tracking is the right place 
> > to be doing 
> > policy enforcment, either.  Perhaps you should just do the 
> > relabeling here 
> > and enforcement later.
> 
> We could have done enforcement, in the SELinux postroute_last
> hook for example, if only there were a place to hold onto the
> "exit point context", separate from the label already associated
> with the skb in the secmark field. postroute_last would need BOTH
> the label of the skb (available in the secmark field) and the
> "exit point context" to do enforcement.

Ok, it's not pretty, but I guess it's much better than adding another 
field to the skb or similar.


- James
-- 
James Morris
<jmorris@namei.org>
