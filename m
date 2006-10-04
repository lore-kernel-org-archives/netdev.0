From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH v4 1/2] NetLabel: secid reconciliation support
Date: Wed, 04 Oct 2006 14:45:49 -0400
Message-ID: <4524015D.3070501@hp.com>
References: <36282A1733C57546BE392885C0618592015CF8A5@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:12986 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1422761AbWJDSpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 14:45:51 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF8A5@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>@@ -3714,19 +3714,34 @@ static int selinux_skb_flow_in(struct sk
>> 	if (skb->dev == &loopback_dev)
>> 		return 1;
>> 
>>+	if (skb->secmark)
>>+		loc_sid = skb->secmark;
>>+	else
>>+		loc_sid = SECINITSID_NETMSG;
>>+
>> 	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
>> 	BUG_ON(err);
>>-
>>-	err = avc_has_perm(xfrm_sid, skb->secmark? : SECINITSID_NETMSG,
>>-					SECCLASS_PACKET,
>>-					PACKET__FLOW_IN, NULL);
>>+	err = selinux_netlbl_skb_sid(skb,
>>+				     xfrm_sid ? xfrm_sid : loc_sid,
>>+				     &nlbl_sid);
>> 	if (err)
>> 		goto out;
>> 
>>-	if (xfrm_sid)
>>-		skb->secmark = xfrm_sid;
>>+	if (nlbl_sid)
>>+		ext_sid = nlbl_sid;
>>+	else
>>+		ext_sid = xfrm_sid;
> 
> 
> There's a problem here in that it would require 2 different policies
> depending on whether one is using netlabel or xfrm. Specifically, in
> the absence of matching iptables contexts (secmark), the skb here
> will get:
> 
> - 0 (xfrm case)
> - network_t (netlabel)

Perhaps I'm reading it the wrong way, but I didn't quite follow your
comment.  In an effort to bring some clarity to all of this here are all
of the possibile combinations that I can see using the code above (feel
free to correct me if I made a mistake):

 * SECMARK, XFRM, NetLabel present

   xfrm_sid = <full context from xfrm>
   loc_sid = <full context from secmark>
   nlbl_sid = <xfrm_sid te ctx, netlabel mls ctx>
   ext_sid = nlbl_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

 * SECMARK, XFRM present

   xfrm_sid = <full context from xfrm>
   loc_sid = <full context from secmark>
   nlbl_sid = SECSID_NULL/0
   ext_sid = xfrm_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

 * SECMARK, NetLabel present

   xfrm_sid = SECSID_NULL/0
   loc_sid = <full context from secmark>
   nlbl_sid = <secmark te ctx, netlabel mls ctx>
   ext_sid = nlbl_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

 * XFRM, NetLabel present

   xfrm_sid = <full context from xfrm>
   loc_sid = SECINITSID_NETMSG
   nlbl_sid = <xfrm_sid te ctx, netlabel mls ctx>
   ext_sid = nlbl_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

 * XFRM present

   xfrm_sid = <full context from xfrm>
   loc_sid = SECINITSID_NETMSG
   nlbl_sid = SECSID_NULL/0
   ext_sid = xfrm_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

 * NetLabel present

   xfrm_sid = SECSID_NULL/0
   loc_sid = SECSID_NULL/0
   nlbl_sid = <SECINITSID_NETMSG te ctx, netlabel mls ctx>
   ext_sid = nlbl_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

 * Nothing

   xfrm_sid = SECSID_NULL/0
   loc_sid = SECSID_NULL/0
   nlbl_sid = SECSID_NULL/0
   ext_sid = xfrm_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

> This has implications for getpeercon() where it would
> 
> - fail with ENOPROTOOPT (xfrm case)
> - returns network_t (netlabel)
> 
> I would still argue that the nature of the domain being carried by
> the packet is still unlabeled_t as implied by the null secmark. While
> I view secmark/point as specifying BOTH a flow control point and a
> default domain (incidentally using the same label more because of
> implementation constrainst), I view network_t as purely a flow control
> point.
> 
> But I also realize there can be equally forceful arguments for what this
> patch does.

I know the two of us have talked about this before on the mail lists,
but I don't believe anyone else has ever made a comment in this regard.
 I tend to feel rather strongly that when using just NetLabel on a
connection you shouldn't see an "unlabeled_t" type as I feel that the
connotation associated with this type is misleading, even though from a
TE point of view there may be an argument made that it is appropriate.

> What does the community think? We need to resolve it one way or the
> other unless the above differences in behavior are desired or somehow
> accounted for in policy and apps.

I agree - I'd like to hear what others (namely Stephen Smalley, James
Morris and all of the Tresys folks <past and present>) have to say on
this issue.

-- 
paul moore
linux security @ hp
