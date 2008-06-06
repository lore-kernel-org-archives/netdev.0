From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [dccp] [RFC/RFT] [Patch 1/2]: Allow to distinguish original
	and retransmitted packets
Date: Fri, 6 Jun 2008 09:51:55 +0100
Message-ID: <20080606085155.GA4343@gerrit.erg.abdn.ac.uk>
References: <4846462F.3020004@cn.fujitsu.com> <20080604132152.GA17595@ghostprotocols.net> <20080604133849.GA5583@gerrit.erg.abdn.ac.uk> <20080604154452.GB4625@ghostprotocols.net> <20080604155540.GA16194@gerrit.erg.abdn.ac.uk> <20080605144435.GA8800@gerrit.erg.abdn.ac.uk> <20080605144529.GB8800@gerrit.erg.abdn.ac.uk> <20080605202716.GA6823@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36762 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753355AbYFFIwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 04:52:38 -0400
Content-Disposition: inline
In-Reply-To: <20080605202716.GA6823@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Arnaldo:
| Em Thu, Jun 05, 2008 at 03:45:29PM +0100, Gerrit Renker escreveu:
| > dccp: Allow to distinguish original and retransmitted packets
| 
| Why not do it the way I suggested? I.e. using
| __dccp_transmit_skb/dccp_transmit_skb? Less changes, same effect, or am
| I missing something?
| 
I had sat down and tried to integrate your solution and had replied in a
separate thread what the difficulties were in doing this. Yes, your
solution solves the problem of not incrementing GSS when sending the
initial Request packet via dccp_connect.

But there are two other problems which it didn't solve
 (a) when GSS is incremented in (__)dccp_transmit_skb() and the
     option-insertion code fails for some reason, there is a hole in the 
     sequence space. I don't know whether this is a big problem, but to
     me it seems cleaner to first assign the incremented value of GSS to
     a temporary variable and update GSS only if option-insertion succeeds;
 (b) in the mainline code updating AWL=GSS is missing, so we additionally
     need to call dccp_update_gss to update AWL. This is a bug which is
     fixed in the test tree. In RFC 4340, 7.5.1 it is defined for DCCP A as
          AWL := max(GSS + 1 - W', ISS).
     where W' is the local value of the Sequence Window. The problem in the
     mainline code is that there is no distinction between local and remote
     Sequence Window, i.e. there is only one variable and no negotiation.
     For this particular problem it  does not need feature negotiation
     since it is the local value and since Sequence Window is a non-negotiable
     feature (RFC 4340, 6.4), i.e. the remote peer has to accept this value
     via Change L(Sequence Window).
     But irrespective of feature negotiation, we need to call dccp_update_gss
     in dccp_transmit_skb, so that the Ack window is kept up-to-date with
     regard to GSS.

So, facing these two problems, I was stuck with how to integrate your
solution with the above and couldn't figure out how to fit that in.

That is because the control flow in dccp_transmit_skb, to solve the above, is
 
	/* assign incremented value to dccp_skb_cb */
	dcb->dccpd_seq = ADD48(dp->dccps_gss, 1);

	switch (dcb->dccpd_type) {
		case DCCP_PKT_REQUEST:
                        set_ack = 0;
                        /* Use ISS on the first (non-retransmitted) Request. */
                        if (icsk->icsk_retransmits == 0)
                                dcb->dccpd_seq = dp->dccps_iss;
			break;
	// ...
	}

	/* if this fails, GSS is not updated */
	if (dccp_insert_options(sk, skb)) {
		kfree_skb(skb);
		return -EPROTO;
	}

	// ...
	dccp_update_gss(sk, dcb->dccpd_seq);	/* this updates GSS, AWH, AWL */
	dccp_hdr_set_seq(dh, dp->dccps_gss);

	// ...
	// transmit the skb via queue_xmit

I have tested my code to work correctly with up to net.dccp.default.retries1=5,
it will also work correctly with higher values.

Gerrit
