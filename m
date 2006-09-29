From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 13:38:45 -0400
Message-ID: <451D5A25.9090803@hp.com>
References: <36282A1733C57546BE392885C0618592015CF2DE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:30150 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751139AbWI2Riy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 13:38:54 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF2DE@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>>+static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
>>>+{
>>>+	u32 trans_sid;
>>>+	int err;
>>>+
>>>+	if (selinux_compat_net)
>>>+		return 1;
>>>+
>>>+	if (!skb->secmark) {
>>>+		u32 xfrm_sid;
>>>+
>>>+		selinux_skb_xfrm_sid(skb, &xfrm_sid);
>>>+
>>>+		if (xfrm_sid)
>>>+			skb->secmark = xfrm_sid;
>>>+		else if (skb->sk) {
>>>+			struct sk_security_struct *sksec = 
>>
>>skb->sk->sk_security;
>>
>>>+			skb->secmark = sksec->sid;
>>>+		}
>>>+	}
>>>+
>>>+	err = avc_has_perm(skb->secmark, nf_secid, SECCLASS_PACKET,
>>>+				PACKET__FLOW_OUT, NULL);
>>
>>While I don't see any explicit mention of it in the documentation or
>>your comments, I assume we would want a flow_out check for 
>>NetLabel here
>>as well?
>  
> I don't believe we do. By this time, the packet is or should already be
> carrying the CIPSO/NetLabel option which should already be the right one
> (derived from the socket or flow as appropriate), but you would want to
> audit the code to make sure. IOW, the label option in the IP header should
> already be reflecting the secmark on the skb. But again, you may want to
> audit the code to make sure.

In the case above I am concerned about the situation where the
skb->secmark == 0 and there is a IPv4 option (i.e. it is NetLabel
labeled) on the packet.  It would seem that the right/consistent thing
to do would be to adjust the secmark accordingly, similar to what we
would do on the flow_in case, yes?

>>>+static int selinux_ip_postroute_last_compat(struct sock 
>>
>>*sk, struct sk_buff *skb,
>>
>>>+					    struct net_device *dev,
>>> 					    struct avc_audit_data *ad,
>>> 					    u16 family, char 
>>
>>*addrp, int len)
>>
>>> {
>>>@@ -3710,6 +3777,9 @@ static int selinux_ip_postroute_last_com
>>> 	struct inode *inode;
>>> 	struct inode_security_struct *isec;
>>> 
>>>+	if (!sk)
>>>+		goto out;
>>>+
>>> 	sock = sk->sk_socket;
>>> 	if (!sock)
>>> 		goto out;
>>>@@ -3768,7 +3838,11 @@ static int selinux_ip_postroute_last_com
>>> 
>>> 		err = avc_has_perm(isec->sid, port_sid, isec->sclass,
>>> 				   send_perm, ad);
>>>+		if (err)
>>>+			goto out;
>>> 	}
>>>+
>>>+	err = selinux_xfrm_postroute_last(isec->sid, skb, ad);
>>> out:
>>> 	return err;
>>> }
>>>@@ -3782,17 +3856,9 @@ static unsigned int selinux_ip_postroute
>>> {
>>> 	char *addrp;
>>> 	int len, err = 0;
>>>-	struct sock *sk;
>>> 	struct sk_buff *skb = *pskb;
>>> 	struct avc_audit_data ad;
>>> 	struct net_device *dev = (struct net_device *)out;
>>>-	struct sk_security_struct *sksec;
>>>-
>>>-	sk = skb->sk;
>>>-	if (!sk)
>>>-		goto out;
>>>-
>>>-	sksec = sk->sk_security;
>>> 
>>> 	AVC_AUDIT_DATA_INIT(&ad, NET);
>>> 	ad.u.net.netif = dev->name;
>>>@@ -3803,16 +3869,25 @@ static unsigned int selinux_ip_postroute
>>> 		goto out;
>>> 
>>> 	if (selinux_compat_net)
>>>-		err = selinux_ip_postroute_last_compat(sk, dev, &ad,
>>>+		err = selinux_ip_postroute_last_compat(skb->sk, 
>>
>>skb, dev, &ad,
>>
>>> 						       family, 
>>
>>addrp, len);
>>
>>>-	else
>>>-		err = avc_has_perm(sksec->sid, skb->secmark, 
>>
>>SECCLASS_PACKET,
>>
>>>-				   PACKET__SEND, &ad);
>>>+	else {
>>>+		if (!skb->secmark) {
>>>+			u32 xfrm_sid;
>>> 
>>>-	if (err)
>>>-		goto out;
>>>+			selinux_skb_xfrm_sid(skb, &xfrm_sid);
>>> 
>>>-	err = selinux_xfrm_postroute_last(sksec->sid, skb, &ad);
>>>+			if (xfrm_sid)
>>>+				skb->secmark = xfrm_sid;
>>>+			else if (skb->sk) {
>>>+				struct sk_security_struct *sksec =
>>>+						skb->sk->sk_security;
>>>+				skb->secmark = sksec->sid;
>>>+			}
>>>+		}
>>>+		err = avc_has_perm(skb->secmark, SECINITSID_UNLABELED,
>>>+				   SECCLASS_PACKET, 
>>
>>PACKET__FLOW_OUT, &ad);
>>
>>>+	}
>>
>>This looks nearly identical to selinux_skb_flow_out() as implemented
>>above, the only real differences being two of the args to the
>>avc_has_perm() call.  Any reason you don't abstract out the 
>>common parts
>>to a separate function?
> 
> May be in the future.
> 
>>Also, the same comment/question about NetLabel support in
>>selinux_skb_flow_out() applies here as well I suspect.
> 
> My comments earlier should apply here as well. 

Mine too :)

-- 
paul moore
linux security @ hp
