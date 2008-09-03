From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change
	feature-negotiation options
Date: Wed, 3 Sep 2008 10:24:09 +0200
Message-ID: <20080903082409.GB9001@gerrit.erg.abdn.ac.uk>
References: <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-4-git-send-email-gerrit@erg.abdn.ac.uk> <20080823105647.GA15928@gerrit.erg.abdn.ac.uk> <48BCE45E.1080709@cn.fujitsu.com> <20080903042709.GB4105@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:56106 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751212AbYICIYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 04:24:24 -0400
Content-Disposition: inline
In-Reply-To: <20080903042709.GB4105@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >> +static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
| >> +				u8 feat, u8 *val, u8 len, const bool server)
<snip>
| >> +	if (type == FEAT_NN) {
| >> +		if (local)
| >> +			goto not_valid_or_not_known;
| >>   
| > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| >
| >  Here should be "goto unknown_feature_or_value"?
| >
| > Change R is invalid, and RFC4340 6.6.8
| >
| > An endpoint receiving an invalid Change option MUST respond with the
| > corresponding empty Confirm option.
| >
| > Is this right?
| I am not sure.
| Section 6.3.2 says that Change R options must not be sent for NN options. A
| Change R is different from an invalid value - it is an option which is out
| of place in such a context. A sender using such an option for NN features
| has a clear bug.
| 
| Hence my interpretation of this situation was to flag this bug to the peer:
|  * the peer gets sent an Option Error rather than an empty Confirm,
|  * if it was a Mandatory option, both interpretations are equivalent.
| 
| But there is also the robustness principle (3.6), so thank you, I will
| change it to the `unknown_feature_or_value'.
| 
I have serious doubts whether the above is the right thing. Jumping to
unknown_feature_or_value means the following

unknown_feature_or_value:
        if (!is_mandatory)
		return dccp_push_empty_confirm(fn, feat, local);

not_valid_or_not_known:
        return is_mandatory ? DCCP_RESET_CODE_MANDATORY_ERROR
	                    : DCCP_RESET_CODE_OPTION_ERROR;

==> Hence the host is asked to send an invalid option type, a Confirm L,
    in response to the invalid Change R.
    A Confirm L in the context of negotiating NN features is never a valid
    option, so this jump is paradox. I think this was the reason why it
    was originally a Reset. 

    Are there any objections reverting this to the original state, i.e.
    sending a Reset instead of a Confirm L for an out-of-place Change R?

Gerrit
