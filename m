From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH v4 1/2] NetLabel: secid reconciliation support
Date: Wed, 04 Oct 2006 16:08:05 -0400
Message-ID: <452414A5.8060001@hp.com>
References: <36282A1733C57546BE392885C0618592015CF96F@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, eparis@redhat.com, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:27520 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751019AbWJDUIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 16:08:09 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF96F@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>On Wed, 2006-10-04 at 15:27 -0400, Paul Moore wrote:
>>
>>>Venkat Yekkirala wrote:
>>>
>>>>>* XFRM present
>>>>>
>>>>>  xfrm_sid = <full context from xfrm>
>>>>>  loc_sid = SECINITSID_NETMSG
>>>>>  nlbl_sid = SECSID_NULL/0
>>>>>  ext_sid = xfrm_sid
>>>>>  final skb->secmark = avc_ok : ext_sid ? unchanged
> 
> 
> As noted subsequently, I actually meant to refer to the below
> instead of the XFRM case above:
> 
>  * Nothing
> 
>    xfrm_sid = SECSID_NULL/0
>    loc_sid = SECSID_NULL/0
>    nlbl_sid = SECSID_NULL/0
>    ext_sid = xfrm_sid
>    final skb->secmark = avc_ok : ext_sid ? unchanged
> 
> 
>>>>>* NetLabel present
>>>>>
>>>>>  xfrm_sid = SECSID_NULL/0
>>>>>  loc_sid = SECSID_NULL/0
>>>>>  nlbl_sid = <SECINITSID_NETMSG te ctx, netlabel mls ctx>
>>>>>  ext_sid = nlbl_sid
>>>>>  final skb->secmark = avc_ok : ext_sid ? unchanged
>>>>
>>>>I was referring to the differences in what getpeercon would
>>>>return in the above 2 scenarios.
>>>>
>>>>In the xfrm case:     final skb->secmark would be 0 
>>
>>resulting in getpeercon
>>
>>>>to return EPROTONOOPT
>>>
>>>In the "XFRM present" case above if the access is allowed (avc_ok is
>>>true) then the final skb->secmark value is going to be set 
>>
>>to the value
>>
>>>of ext_sid which is the xfrm_sid.  Any calls made to 
>>
>>getpeercon() would
>>
>>>return success with the context matching xfrm_sid.
>>>
>>>I have a hunch we are still on different pages here ...
>>>
>>>
>>>>In the NetLabel case: final skb->secmark would be 
>>
>>network_t resulting in
>>
>>>>getpeercon to return network_t
>>>
>>>Yep, and I understand you would like to see it as 
>>
>>unlabeled_t.  I think
>>
>>>we both have valid arguments for either case and we are 
>>
>>just waiting to
>>
>>>hear from others.
>>
>>I don't understand the argument for network_t, and it seems to violate
>>our goals of 1) having consistent policy regardless of 
>>network labeling
>>mechanism, and 2) having getpeercon() always return a subject 
>>label that
>>can be used as a basis for avc_has_perm() and setexeccon() calls.
> 
> But in the case where there's no domain info, but a cipso label,
> getpeercon will fail (EPROTONOOPT). Do I rememember that Paul was
> trying to use a special SID to use as a base sid in this case?

[I'm replying to both Stephen and Venkat here as the email is coming in
faster than I can type :)]

In the current non-secid world, if the connection is NetLabel labeled,
the sock_rcv_skb() LSM hook uses SECINITSID_NETMSG as the base_sid and
the recvfrom permission to control access.  Calls to getpeercon() on a
NetLabel connection use the socket's SID as the base_sid and the network
traffic's MLS label.

In the latest secid world, when there is only NetLabel labeling present
on the connection SECINITSID_NETMSG is used as the base_sid for the
final skb->secmark value as determined by the flow_in() LSM hook with
the MLS label being set to match the NetLabel on the packet.  Calls to
getpeercon() will use the secmark value of the packet when the
connection is establishes (in *all* cases) so getpeercon() in the
NetLabel only case will succeed and return the value determined above.

-- 
paul moore
linux security @ hp
