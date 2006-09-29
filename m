From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 15:51:22 -0400
Message-ID: <451D793A.4040007@hp.com>
References: <36282A1733C57546BE392885C0618592015CF2BE@chaos.tcs.tcs-sec.com> <451D4A51.4000603@hp.com> <Pine.LNX.4.64.0609291247170.6007@d.namei> <451D5B3F.70206@hp.com> <Pine.LNX.4.64.0609291430130.7553@d.namei> <451D6EB1.3040006@hp.com> <Pine.LNX.4.64.0609291517170.7975@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:40140 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1161869AbWI2Tvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 15:51:46 -0400
To: James Morris <jmorris@namei.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <Pine.LNX.4.64.0609291517170.7975@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 29 Sep 2006, Paul Moore wrote:
> 
> 
>>>Say that the SA is labeled "secret" and you have two FTP clients 
>>>connecting to a server via xinetd on this SA.  Each client additionally 
>>>labels their packets via CIPSO as secret:c1 and secret:c2 respectively.  
>>>xinetd launches an FTP server for each at the correct level.
>>
>>I believe Venkat can address this.
> 
> Ok, I'd still really like to see a worked example of just Netlabel + 
> secmark/connseckmark, to see what happens to the connection marks.

Fair enough.

> It 
> seems that the connection mark should always be correct, and restored to 
> the packet.  In which case, what happens when a CIPSO label on an 
> established {connection} ...

The following would happen, in order, in selinux_skb_flow_in() (I'm
ommitting the IPsec relevant portions of this function for clarity):

1. A NetLabel SID would be generated using the secmark as the
"base_sid"; this means that the NetLabel would be the concatenation of
the secmark's TE context and the NetLabel's MLS label.  The secmark is
not yet modified.

2. The NetLabel SID would be avc checked against the secmark:
    avc_has_perm(nlbl_sid,
                 skb->secmark,
                 SECCLASS_PACKET,
		 PACKET__FLOW_IN,
                 NULL)
   Note that in practice this is basically just a MLS label check.

3. If the NetLabel SID != 0 the secmark would be replaced with the
NetLabel SID.

I am trying to make NetLabel behave in a similar fashion as to how
labeled IPsec works in the secid patches; I believe the above steps
acomplish this.  If not please let me know and I'll make the necessary
changes.

> ... or related packet doesn't match ...

Not sure what you mean by "related packet", but if the check in step #2
fails then the packet would be dropped.  The only case where I can see
this happening is that if the MLS/MCS constraints did not allow the
flow_in permission.  This allows administrators to set specific MLS
labels for any iptables "object".

> ... or you get no CIPSO label (e.g. ICMP from intermediate router) ...

If there is no packet label that NetLabel recognizes and NetLabel is
configured to allow unlabeled traffic then the NetLabel SID generated in
step #1 above would be 0.

> Or, is would you be always 
> overwriting secmark/connsecmark labeling, and if so, how/why are you using 
> them?

I think I addressed that above.

FYI: in between emails I'm working on a patch against Venkat's secid
patches which implements this, hopefully Venkat can roll this patch into
his secid patchset so this is all committed/rejected at once.

-- 
paul moore
linux security @ hp
