From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 13:43:27 -0400
Message-ID: <451D5B3F.70206@hp.com>
References: <36282A1733C57546BE392885C0618592015CF2BE@chaos.tcs.tcs-sec.com> <451D4A51.4000603@hp.com> <Pine.LNX.4.64.0609291247170.6007@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:38097 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1161310AbWI2Rnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 13:43:31 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609291247170.6007@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 29 Sep 2006, Paul Moore wrote:
> 
>>>It seems more of a pain to actually
>>>prevent their use at the same time and/or explain strange/unnatural
>>>behavior.
>>
>>Agreed, the solution that we agreed upon is much easier to implement and
>>explain than a lot of the alternatives.
> 
> Ok, can you please explain it further?
> 
> i.e. show me what the policy looks like, exactly what the user is trying 
> to achieve, and explain what happens to each packet exactly in terms of 
> labeling on the input and output paths.

All right, here is my take on it, perhaps Venkat can chime in too.

 * packet labeling, input

Code below is taken from the secid patchset, minus the SID transition
code as it sounds like that is going to be dropped.  Please note that
this is not a patch just something to help explain.

+static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
+{
+	u32 xfrm_sid, trans_sid;
        u32 nlbl_sid;
+	int err;
+
+	if (selinux_compat_net)
+		return 1;
+
+	/* xfrm/cipso inapplicable for loopback traffic */
+	if (skb->dev == &loopback_dev)
+		return 1;
+
+	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
+	BUG_ON(err);
+
+	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
+					PACKET__FLOW_IN, NULL);
+	if (err)
+		goto out;
+
	if (xfrm_sid)
	        skb->secmark = xfrm_sid;

        err = selinux_netlbl_skbuff_getsid(skb,
                                           skb->secmark,
                                           &nlbl_sid);
        if (err)
                goto out;

        if (nlbl_sid != SECINITSID_UNLABELED) {
                /* not sure if we want this avc check above this if
                 * block? */
                err = avc_has_perm(nlbl_sid,
                                   skb->secmark,
                                   SECCLASS_PACKET,
                                   PACKET__FLOW_IN,
                                   NULL);
                if (err)
                        goto out;
                skb->secmark = nlbl_sid;
        }
+
+out:
+	return err ? 0 : 1;
+};

 * packet labeling, output

This is currently being discussed, so take this with a few grains of salt.

+static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
+{
+	u32 trans_sid;
        u32 nlbl_sid;
+	int err;
+
+	if (selinux_compat_net)
+		return 1;
+
+	if (!skb->secmark) {
+		u32 xfrm_sid;
+
+		selinux_skb_xfrm_sid(skb, &xfrm_sid);
+
+		if (xfrm_sid)
+			skb->secmark = xfrm_sid;
+		else if (skb->sk) {
+			struct sk_security_struct *sksec =
+                                           skb->sk->sk_security;
+			skb->secmark = sksec->sid;
+		}

                err = selinux_netlbl_skbuff_getsid(skb,
                                                   skb->secmark,
                                                   &nlbl_sid);
                if (err)
                        goto out;
                if (nlbl_sid != SECINITSID_UNLABELED) {
                        err = avc_has_perm(nlbl_sid,
                                           skb->secmark,
                                           SECCLASS_PACKET,
                                           PACKET__FLOW_OUT,
                                           NULL);
                        if (err)
                                goto out;
                        skb->secmark = nlbl_sid;
                }
+	}
+
+	err = avc_has_perm(skb->secmark, nf_secid, SECCLASS_PACKET,
+				PACKET__FLOW_OUT, NULL);
+
+out:
+	return err ? 0 : 1;
+}

 * pseudo policy

Since NetLabel presently only provides a MLS label I don't believe there
would be any additional SELinux allow rules beyond those needed for
IPsec labeling (maybe in the flow_out, not sure).  The MLS/MCS
constraints would be the only thing affected I believe, and even then
the existing constraints should suffice.

-- 
paul moore
linux security @ hp
