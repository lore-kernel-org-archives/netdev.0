From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 19/37] dccp: Header option insertion routine for
	feature-negotiation
Date: Wed, 3 Sep 2008 06:40:06 +0200
Message-ID: <20080903044006.GD4105@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-13-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-17-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-18-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-19-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-20-git-send-email-gerrit@erg.abdn.ac.uk> <48BCD393.6020100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40282 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751069AbYICEkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 00:40:14 -0400
Content-Disposition: inline
In-Reply-To: <48BCD393.6020100@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > +/**
| > + * dccp_insert_fn_opt  -  Insert single Feature-Negotiation option into @skb
| > + * @type: %DCCPO_CHANGE_L, %DCCPO_CHANGE_R, %DCCPO_CONFIRM_L, %DCCPO_CONFIRM_R
| > + * @feat: one out of %dccp_feature_numbers
| > + * @val: NN value or SP array (preferred element first) to copy
| > + * @len: true length of @val in bytes (excluding first element repetition)
| > + * @repeat_first: whether to copy the first element of @val twice
| > + * The last argument is used to construct Confirm options, where the preferred
| > + * value and the preference list appear separately (RFC 4340, 6.3.1). Preference
| > + * lists are kept such that the preferred entry is always first, so we only need
| > + * to copy twice, and avoid the overhead of cloning into a bigger array.
| > + */
| > +int dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat,
| > +		       u8 *val, u8 len, bool repeat_first)
| >  {
| > -	u8 *to;
| > +	u8 tot_len, *to;
| >  
| > -	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len + 3 > DCCP_MAX_OPT_LEN) {
| > -		DCCP_WARN("packet too small for feature %d option!\n", feat);
| > +	/* take the `Feature' field and possible repetition into account */
| > +	if (len > (DCCP_SINGLE_OPT_MAXLEN - 2)) {
| > +		DCCP_WARN("length %u for feature %u too large\n", len, feat);
| >  		return -1;
| >  	}
| >   
| 
| Here, should check (len > DCCP_SINGLE_OPT_MAXLEN - 3 - repeat_first)?
| 
| if len == DCCP_SINGLE_OPT_MAXLEN - 2, then
| 
| tot_len = 3 + repeat_first + len == (DCCP_SINGLE_OPT_MAXLEN + 1 +
| repeat_first)
| 
| The total length of this option will larger than DCCP_SINGLE_OPT_MAXLEN.
| 
in linux/dccp.h
/* maximum size of a single TLV-encoded option (sans type/len bytes) */
#define DCCP_SINGLE_OPT_MAXLEN         253

So if we assume that len = DCCP_SINGLE_OPT_MAXLEN - 2 = 251, then
tot_len = 3 + 251 + repeat_first, which is
  * 254 if repeat_first = 0
  * 255 if repeat_first = 1
	
So it is correct. 

But your input is useful, since it relates to another question, one line
below in linux/dccp.h:

#define DCCP_CCID_LIST_MAX_LEN         (DCCP_SINGLE_OPT_MAXLEN - 2)

this value is the same as in the above test, so will revise to use
something like

#define DCCP_FEAT_MAX_SP_VALS	       (DCCP_SINGLE_OPT_MAXLEN - 2)

to limit the maximum number of server-priority values, in feat.h.

Thanks,
Gerrit
