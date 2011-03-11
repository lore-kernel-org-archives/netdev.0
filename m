From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
	after receiving the Confirm option
Date: Fri, 11 Mar 2011 12:30:42 +0100
Message-ID: <20110311113042.GB4876@gerrit.erg.abdn.ac.uk>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk> <1299559831.7569.41.camel@jero-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Samuel Jero <sj323707@ohio.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:45304 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752014Ab1CKLat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:30:49 -0500
Content-Disposition: inline
In-Reply-To: <1299559831.7569.41.camel@jero-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| I now had a chance to put this patch through extensive tests. I had to
| modify two things about the patch to get good performance:
| 1) [...] The primary change is adding a function called
|     dccp_feat_get_nn_next_val() to feat.c.
Well done, this looks good. I did some minor editing:
 * whitespace/formatting/comments,
 * simplification/subsumption,
 * function should not be called for non-NN or non-known
   feature, hence turned that into a DCCP_BUG() condition.

| 2)In a situation where the ack ratio has to be reduced because of an
|    RTO, idle period, or loss, CCID-2 now sets the ack ratio to half of the
|    congestion window (or 1 if that's zero) instead of to the congestion
|    window. This should reduce the problems if one ack is lost (we have to
|    lose two acks to not acknowledge an entire congestion window and trigger
|    RTO)
| 
I think this makes for a separate patch, and it would be good to commentify
the above into the code; please also see 3(b) below.

| Below is an improved patch. What are your thoughts on these changes?
| 
I have uploaded your version of the patch to the test tree, 

http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=126ba220483bb990cf2c4b625464c89909583d3c

Some work still remains to be done:

 1) Since ccid2_ack_ratio_next(sk) is just a wrapper around
    dccp_feat_get_nn_next_val(sk, DCCPF_ACK_RATIO), ok to
    use this instead?
 2) Analogously, for the local sequence window feature the
    dccp_feat_get_nn_next_val() is not used, it uses the
    current value:
    if (val != dp->dccps_l_seq_win)
	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
 3) There is room for some refactoring:
    a) dccp_feat_signal_nn_change() always implies also in part
       dccp_feat_get_nn_next_val(): if the latter function returns
       the same value as the supposedly 'new' one, it is not
       necessary to start a new negotiation. So all the repeated
       tests could be folded into that function.
    b) The following pattern appears three times in ccid2.c:
	if (ccid2_ack_ratio_next(sk) > hc->tx_cwnd)
		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
       Perhaps this can, as some other parts of this patch set, be
       refactored (e.g. the CCID-2 part is already a separate patch).

Other than the minor edits I have left your patch as is, i.e. I have
not yet performed changes (1) and (2), awaiting your opinion on that.

Once you are ok with the edits, I will add your Signed-off-by.
