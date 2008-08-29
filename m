From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 15/37] dccp: Set per-connection CCIDs via socket options
Date: Fri, 29 Aug 2008 09:17:49 +0200
Message-ID: <20080829071749.GI3557@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-11-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-13-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk> <20080828214501.GT9193@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41318 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750709AbYH2HST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 03:18:19 -0400
Content-Disposition: inline
In-Reply-To: <20080828214501.GT9193@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >  /* maximum number of services provided on the same listening port */
| >  #define DCCP_SERVICE_LIST_MAX_LEN      32
| > +/* maximum number of CCID preferences that can be registered at one time */
| > +#define DCCP_CCID_LIST_MAX_LEN	       16
| 
| Since this is an arbitrary lenght up to 253, it could as well be 253,
| no? Or is there any other limit that I'm forgetting? :-) It may well be
| that case, would have to read the RFC about how the encoding is done for
| feat len, which I did some weeks ago, but...
|   
The worst-case consideration is the Confirm option:
max value =  255
          - 2 bytes for type/length
          - 1 byte for feature number 
          - 1 byte for confirmed value (6.2)
	  = max 251 distinct values.

So make it 251 instead?	- we will need some new RFCs :)


| >  #ifdef __KERNEL__
| >  
| > --- a/net/dccp/proto.c
| > +++ b/net/dccp/proto.c
| > @@ -505,6 +505,34 @@ static int dccp_setsockopt_cscov(struct sock *sk, int cscov, bool rx)
| >  	return rc;
| >  }
| >  
| > +static int dccp_setsockopt_ccid(struct sock *sk, int type,
| > +				char __user *optval, int optlen)
| > +{
| > +	u8 *val;
| > +	int rc = 0;
| > +
| > +	if (optlen < 1 || optlen > DCCP_CCID_LIST_MAX_LEN)
| > +		return -EINVAL;
| > +
| > +	val = kmalloc(optlen, GFP_KERNEL);
| > +	if (val == NULL)
| > +		return -ENOMEM;
| > +
| > +	if (copy_from_user(val, optval, optlen))
| > +		rc = -EFAULT;
| > +
| > +	lock_sock(sk);
| > +	if (!rc && (type == DCCP_SOCKOPT_TX_CCID || type == DCCP_SOCKOPT_CCID))
| > +		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 1, val, optlen);
| > +
| 
| This _really_ is confusing! Why not:
| 
| 	rc = -EFAULT;
| 	if (copy_from_user(val, optval, optlen))
| 		goto out;
| 
| 	lock_sock(sk);
| 	rc = 0;
| 	if (type == DCCP_SOCKOPT_TX_CCID || type == DCCP_SOCKOPT_CCID)
| 		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 1, val, optlen);
| 
| 	if (!rc && (type == DCCP_SOCKOPT_RX_CCID || type == DCCP_SOCKOPT_CCID))
| 		rc = dccp_feat_register_sp(sk, DCCPF_CCID, 0, val, optlen);
| 	release_sock(sk);
| out:
| > +	kfree(val);
| > +	return rc;
| > +}
| 
| :-)
| 
| And even then that '0' or '1' requires one to look at what this binary
| number means, we could have something like
| dccp_feat_register_sp_{local,remote} perhaps, IIRC that is the is_local
| parameter, no?
| 
Thanks, I will be revising this with regard to the above. 

If you want, we could consider dropping the DCCP_SOCKOPT_{RX,TX}_CCID 
since mixed-mode is at the moment not well understood and will lead
to bad performance (e.g. CCID-3 on the forward path and CCID-2 on the
reverse path). 

That would make both the above statements and the socket API much
simpler. Would that be ok?

With regard to the dccp_feat_register_sp_local() function, the price to
pay is that either lines will be longer than 80 characters or that we
will end up with more multi-line statements, which does IMO not help
readability.
