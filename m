From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH v4 1/2] NetLabel: secid reconciliation support
Date: Wed, 04 Oct 2006 15:52:40 -0400
Message-ID: <45241108.5040303@hp.com>
References: <36282A1733C57546BE392885C0618592015CF961@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:58300 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1750968AbWJDTwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 15:52:42 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF961@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>>>* XFRM present
>>>>
>>>>  xfrm_sid = <full context from xfrm>
>>>>  loc_sid = SECINITSID_NETMSG
>>>>  nlbl_sid = SECSID_NULL/0
>>>>  ext_sid = xfrm_sid
>>>>  final skb->secmark = avc_ok : ext_sid ? unchanged
> 
> Actually, I meant to cite the following instead of the above:
> 
>  * Nothing
> 
>    xfrm_sid = SECSID_NULL/0
>    loc_sid = SECSID_NULL/0
>    nlbl_sid = SECSID_NULL/0
>    ext_sid = xfrm_sid
>    final skb->secmark = avc_ok : ext_sid ? unchanged

Okay, thanks, I think I understand your point now.  Let me try to
restate just to make sure.

Take two cases: the first being no labeling at all, the second being
only NetLabel ...

 * Nothing

   xfrm_sid = SECSID_NULL/0
   loc_sid = SECSID_NULL/0
   nlbl_sid = SECSID_NULL/0
   ext_sid = xfrm_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

 * NetLabel

  xfrm_sid = SECSID_NULL/0
  loc_sid = SECSID_NULL/0
  nlbl_sid = <SECINITSID_NETMSG te ctx, netlabel mls ctx>
  ext_sid = nlbl_sid
  final skb->secmark = avc_ok : ext_sid ? unchanged

In the "Nothing" case the final skb->secmark is set to SECSID_NULL/0;
getpeercon() should return an error. In the "NetLabel" case the final
skb->secmark is set using the TE portions of SECINITSID_NETMSG and the
MLS label of the NetLabel packet; getpeercon() will succeed.

I understand in the "NetLabel" case above you think the TE portion of
the final skb->secmark value should come from
SECSID_NULL/SECINITSID_UNLABELED/0, but do you also want getpeercon() to
return an error in the "NetLabel" case?  I think that's a bad idea as it
will made it *extremely* difficult for applications to determine the MLS
label of a connection using NetLabel.

>>>>* NetLabel present
>>>>
>>>>  xfrm_sid = SECSID_NULL/0
>>>>  loc_sid = SECSID_NULL/0
>>>>  nlbl_sid = <SECINITSID_NETMSG te ctx, netlabel mls ctx>
>>>>  ext_sid = nlbl_sid
>>>>  final skb->secmark = avc_ok : ext_sid ? unchanged
>>>
>>>I was referring to the differences in what getpeercon would
>>>return in the above 2 scenarios.
>>>
>>>In the xfrm case:     final skb->secmark would be 0 
>>
>>resulting in getpeercon
>>
>>>to return EPROTONOOPT
>>
>>In the "XFRM present" case above if the access is allowed (avc_ok is
>>true) then the final skb->secmark value is going to be set to 
>>the value
>>of ext_sid which is the xfrm_sid.  Any calls made to 
>>getpeercon() would
>>return success with the context matching xfrm_sid.
> 
> 
> You are right, but I was actually referring to the "Nothing"
> case above.
> 
> 
>>I have a hunch we are still on different pages here ...
>>
>>
>>>In the NetLabel case: final skb->secmark would be network_t 
>>
>>resulting in
>>
>>>getpeercon to return network_t
>>
>>Yep, and I understand you would like to see it as 
>>unlabeled_t.  I think
>>we both have valid arguments for either case and we are just 
>>waiting to
>>hear from others.
>>
>>-- 
>>paul moore
>>linux security @ hp
>>


-- 
paul moore
linux security @ hp
