From: Eddie Kohler <kohler@cs.ucla.edu>
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change	feature-negotiation
 options
Date: Wed, 03 Sep 2008 05:27:07 -0700
Message-ID: <48BE829B.9000303@cs.ucla.edu>
References: <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-4-git-send-email-gerrit@erg.abdn.ac.uk> <20080823105647.GA15928@gerrit.erg.abdn.ac.uk> <48BCE45E.1080709@cn.fujitsu.com> <20080903042709.GB4105@gerrit.erg.abdn.ac.uk> <20080903082409.GB9001@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out-56.smtp.ucla.edu ([169.232.46.165]:59712 "EHLO
	out-56.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbYICMhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:37:42 -0400
In-Reply-To: <20080903082409.GB9001@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Gerrit Renker wrote:
> | >> +static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
> | >> +				u8 feat, u8 *val, u8 len, const bool server)
> <snip>
> | >> +	if (type == FEAT_NN) {
> | >> +		if (local)
> | >> +			goto not_valid_or_not_known;
> | >>   
> | > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> | >
> | >  Here should be "goto unknown_feature_or_value"?
> | >
> | > Change R is invalid, and RFC4340 6.6.8
> | >
> | > An endpoint receiving an invalid Change option MUST respond with the
> | > corresponding empty Confirm option.
> | >
> | > Is this right?
> | I am not sure.
> | Section 6.3.2 says that Change R options must not be sent for NN options. A
> | Change R is different from an invalid value - it is an option which is out
> | of place in such a context. A sender using such an option for NN features
> | has a clear bug.
> | 
> | Hence my interpretation of this situation was to flag this bug to the peer:
> |  * the peer gets sent an Option Error rather than an empty Confirm,
> |  * if it was a Mandatory option, both interpretations are equivalent.
> | 
> | But there is also the robustness principle (3.6), so thank you, I will
> | change it to the `unknown_feature_or_value'.
> | 
> I have serious doubts whether the above is the right thing. Jumping to
> unknown_feature_or_value means the following
> 
> unknown_feature_or_value:
>         if (!is_mandatory)
> 		return dccp_push_empty_confirm(fn, feat, local);
> 
> not_valid_or_not_known:
>         return is_mandatory ? DCCP_RESET_CODE_MANDATORY_ERROR
> 	                    : DCCP_RESET_CODE_OPTION_ERROR;
> 
> ==> Hence the host is asked to send an invalid option type, a Confirm L,
>     in response to the invalid Change R.
>     A Confirm L in the context of negotiating NN features is never a valid
>     option, so this jump is paradox. I think this was the reason why it
>     was originally a Reset. 
> 
>     Are there any objections reverting this to the original state, i.e.
>     sending a Reset instead of a Confirm L for an out-of-place Change R?

I'd mildly object.  I believe that section 6.6.8 of the RFC requires (MUST) 
that DCCP responds to every invalid Change option with an empty Confirm. 
Section 6.3.2 strongly hints that Change R options for non-negotiable features 
are invalid.  (I think we meant to explicitly SAY that such options were 
invalid, but unfortunately it looks like we did not.)  The right thing to do 
here is:

       if (is_mandatory)
           return DCCP_RESET_CODE_MANDATORY_ERROR;
       else
           return dccp_push_empty_confirm(fn, feat, local);

which is jumping to unknown_feature_or_value.

I don't think this jump is "paradox."  DCCP's partner is asking to negotiate a 
non-negotiable feature, so IT doesn't think the feature is non-negotiable! 
(Otherwise it wouldn't have started the negotiation.)  We send an empty 
Confirm to slap it and tell it to get with the program.  The pseudocode in 
section 6.6.2 indicates that an endpoint receiving an empty Confirm simply 
gives up the negotiation without changing the value.  This is what we want to 
happen.

I agree, Gerrit, that this is not a critical case.

Eddie



> 
> Gerrit
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
