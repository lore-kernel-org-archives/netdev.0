From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2 2/8] Allow tcp_parse_options to consult dst entry
Date: Thu, 22 Oct 2009 12:41:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0910212041300.14082@melkinkari.cs.Helsinki.FI>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-3-git-send-email-gilad@codefidence.com> <alpine.DEB.2.00.0910211559050.5304@wel-95.cs.helsinki.fi> <4ADF15A2.1050804@codefidence.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243445-799101608-1256146957=:14082"
Cc: Netdev <netdev@vger.kernel.org>, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55977 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbZJVJlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 05:41:53 -0400
In-Reply-To: <4ADF15A2.1050804@codefidence.com>
Content-ID: <alpine.DEB.2.00.0910221241130.5304@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-799101608-1256146957=:14082
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0910221234121.5304@wel-95.cs.helsinki.fi>

On Wed, 21 Oct 2009, Gilad Ben-Yossef wrote:

> Hi Ilpo,
> 
> 
> Thanks for the feedback :-)
> 
> 
> Ilpo Järvinen wrote:
> 
> > On Wed, 21 Oct 2009, Gilad Ben-Yossef wrote:
> >
> >   
> > > We need tcp_parse_options to be aware of dst_entry to take into account
> > > per dst_entry TCP options settings
> > >
> > > Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> > > Sigend-off-by: Ori Finkelman <ori@comsleep.com>
> > > Sigend-off-by: Yony Amit <yony@comsleep.com>
> > >
> > > ---
> > >  include/net/tcp.h        |    3 ++-
> > >  net/ipv4/syncookies.c    |   27 ++++++++++++++-------------
> > >  net/ipv4/tcp_input.c     |    9 ++++++---
> > >  net/ipv4/tcp_ipv4.c      |   19 ++++++++++---------
> > >  net/ipv4/tcp_minisocks.c |    7 +++++--
> > >  net/ipv6/syncookies.c    |   28 +++++++++++++++-------------
> > >  net/ipv6/tcp_ipv6.c      |    3 ++-
> > >  7 files changed, 54 insertions(+), 42 deletions(-)
> > >
> > >
> > >     
> <snip>
> > > diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > > index 7cda24b..1cb0ec4 100644
> > > --- a/net/ipv4/tcp_ipv4.c
> > > +++ b/net/ipv4/tcp_ipv4.c
> >> @@ -1256,11 +1256,18 @@ int tcp_v4_conn_request(struct sock *sk, struct
> sk_buff *skb)
> > >  	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
> > >  #endif
> > >  
> > > +	ireq = inet_rsk(req);
> > > +	ireq->loc_addr = daddr;
> > > +	ireq->rmt_addr = saddr;
> > > +	ireq->no_srccheck = inet_sk(sk)->transparent;
> > > +	ireq->opt = tcp_v4_save_options(sk, skb);
> > > +
> > > +	dst = inet_csk_route_req(sk, req);
> > >   tcp_clear_options(&tmp_opt);
> > >   tmp_opt.mss_clamp = 536;
> > >   tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
> > > 
> > > -	tcp_parse_options(skb, &tmp_opt, 0);
> > > +	tcp_parse_options(skb, &tmp_opt, 0, dst);
> > >  
> > >   if (want_cookie && !tmp_opt.saw_tstamp)
> > >    tcp_clear_options(&tmp_opt);
> >> @@ -1269,14 +1276,8 @@ int tcp_v4_conn_request(struct sock *sk, struct
> sk_buff *skb)
> > >  
> > >   tcp_openreq_init(req, &tmp_opt, skb);
> > > 
> > > -	ireq = inet_rsk(req);
> > > -	ireq->loc_addr = daddr;
> > > -	ireq->rmt_addr = saddr;
> > > -	ireq->no_srccheck = inet_sk(sk)->transparent;
> > > -	ireq->opt = tcp_v4_save_options(sk, skb);
> > > -
> > > 	if (security_inet_conn_request(sk, skb, req))
> > > -		goto drop_and_free;
> > > +		goto drop_and_release;
> > >  
> > >   if (!want_cookie)
> > >    TCP_ECN_create_request(req, tcp_hdr(skb));
> >> @@ -1301,7 +1302,7 @@ int tcp_v4_conn_request(struct sock *sk, struct
> sk_buff *skb)
> > >    */
> > >    if (tmp_opt.saw_tstamp &&
> > > 		    tcp_death_row.sysctl_tw_recycle &&
> > > -		    (dst = inet_csk_route_req(sk, req)) != NULL &&
> > > +		    dst != NULL &&
> > >     
> >
> > Why you need this NULL check this here while you trap it with BUG_ON
> > elsewhere? Does your patch perhaps create a remote DoS opportunity?
> >
> >
> >   
> Indeed, I believe you are right. Good catch.
> 
> What about this (I know the patch gets eaten by Thunderbird, sorry about that.
> This is just for explaining what I want to do):
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> 
> index 1cb0ec4..1d611e3 100644
> 
> --- a/net/ipv4/tcp_ipv4.c
> 
> +++ b/net/ipv4/tcp_ipv4.c
> 
> @@ -1263,6 +1263,9 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff
> *skb)
> 
>        ireq->opt = tcp_v4_save_options(sk, skb);
> 
> 
> 
>        dst = inet_csk_route_req(sk, req);
> 
> +       if(!dst)
> 
> +               goto drop_and_free;
> 
> +
> 
>        tcp_clear_options(&tmp_opt);
> 
>        tmp_opt.mss_clamp = 536;
> 
>        tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
> 
> @@ -1302,7 +1305,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff
> *skb)
> 
>                 */
> 
>                if (tmp_opt.saw_tstamp &&
> 
>                    tcp_death_row.sysctl_tw_recycle &&
> 
> -                   dst != NULL &&
> 
>                    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
> 
>                    peer->v4daddr == saddr) {
> 
>                        if (get_seconds() < peer->tcp_ts_stamp + TCP_PAWS_MSL
> &&
> 
> 
> 
> My rational is that since if the connection is formed we will need to send a
> syn/ack ( call to __tcp_v4_send_synack a couple of lines below) and since we
> can't do that  if we don't have a route, this makes sense.
> 
> If this sounds sane, I'll re-spin the patch with this as a fix.

I'd just guard the relevant places with dst && ...? ...But I didn't go 
through that far to find out how many one would then need.

-- 
 i.
---696243445-799101608-1256146957=:14082--
