From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 1/6] gtp: make GTP sockets in gtp_newlink
 optional
Date: Thu, 2 Feb 2017 15:32:54 +0100
Message-ID: <20170202143254.GA19735@salvia>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-2-aschultz@tpip.net>
 <20170202141011.GB23901@salvia>
 <1114368875.730626.1486045851291.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, laforge <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc <openbsc@lists.osmocom.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36978 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750777AbdBBOdD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 09:33:03 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F2F12E04CA
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:33:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E2875A0FCF
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:33:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B9E58A0FD2
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:32:59 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1114368875.730626.1486045851291.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 03:30:51PM +0100, Andreas Schultz wrote:
> 
> 
> ----- On Feb 2, 2017, at 3:10 PM, pablo pablo@netfilter.org wrote:
> 
> > On Mon, Jan 30, 2017 at 05:37:08PM +0100, Andreas Schultz wrote:
> >> Having both GTPv0-U and GTPv1-U is not always desirable.
> >> Fallback from GTPv1-U to GTPv0-U was depreciated from 3GPP
> >> Rel-8 onwards. Post Rel-8 implementation are discuraged
> >> from listening on the v0 port (see 3GPP TS 29.281, Sect. 1).
> >> 
> >> A future change will completely decouple the sockets from the
> >> network device. Till then, at least one of the sockets needs to
> >> be specified (either v0 or v1), the other is optional.
> >> 
> >> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> >> ---
> >>  drivers/net/gtp.c | 142 +++++++++++++++++++++++++++++-------------------------
> >>  1 file changed, 76 insertions(+), 66 deletions(-)
> >> 
> >> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> >> index bda0c64..18944f4 100644
> >> --- a/drivers/net/gtp.c
> >> +++ b/drivers/net/gtp.c
> >> @@ -259,28 +259,30 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp,
> >> struct sk_buff *skb,
> >>  	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
> >>  }
> >>  
> >> -static void gtp_encap_disable(struct gtp_dev *gtp)
> >> -{
> >> -	if (gtp->sock0 && gtp->sock0->sk) {
> >> -		udp_sk(gtp->sock0->sk)->encap_type = 0;
> >> -		rcu_assign_sk_user_data(gtp->sock0->sk, NULL);
> >> -	}
> >> -	if (gtp->sock1u && gtp->sock1u->sk) {
> >> -		udp_sk(gtp->sock1u->sk)->encap_type = 0;
> >> -		rcu_assign_sk_user_data(gtp->sock1u->sk, NULL);
> >> -	}
> >> -
> >> -	gtp->sock0 = NULL;
> >> -	gtp->sock1u = NULL;
> >> -}
> >> -
> >>  static void gtp_encap_destroy(struct sock *sk)
> >>  {
> >>  	struct gtp_dev *gtp;
> >>  
> >>  	gtp = rcu_dereference_sk_user_data(sk);
> >> -	if (gtp)
> >> -		gtp_encap_disable(gtp);
> >> +	if (gtp) {
> >> +		udp_sk(sk)->encap_type = 0;
> >> +		rcu_assign_sk_user_data(sk, NULL);
> >> +	}
> >> +}
> >> +
> >> +static void gtp_encap_disable_sock(struct socket *sock)
> > 
> > Nitpick: Please, use sk for consistency:
> > 
> >        static void gtp_encap_disable_sock(struct socket *sk)
> > 
> 
> Throughout the net subsystem 'struct socket` is always using sock
> for variable names and 'struct sock' is using sk. I have been
> following that convention, but can change to sk if you really want.

Forget this, sorry. I think I read there 'struct sock'. I got confused
by patch context.
