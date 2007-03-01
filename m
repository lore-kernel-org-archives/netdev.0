From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/2] [TCP]: Add two new spurious RTO responses to FRTO
Date: Thu, 1 Mar 2007 13:30:20 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703011312250.19465@kivilampi-30.cs.helsinki.fi>
References: <20070228121302.GA2983@ff.dom.local>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2093170895-1172748620=:19465"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34142 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964968AbXCALaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 06:30:23 -0500
In-Reply-To: <20070228121302.GA2983@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2093170895-1172748620=:19465
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 28 Feb 2007, Jarek Poplawski wrote:

> On 27-02-2007 16:50, Ilpo Järvinen wrote:
> > New sysctl tcp_frto_response is added to select amongst these
> ...
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > @@ -762,15 +763,17 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp,
> >  }
> >  
> >  /* Set slow start threshold and cwnd not falling to slow start */
> > -void tcp_enter_cwr(struct sock *sk)
> > +void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
> >  {
> >  	struct tcp_sock *tp = tcp_sk(sk);
> > +	const struct inet_connection_sock *icsk = inet_csk(sk);
> >  
> >  	tp->prior_ssthresh = 0;
> >  	tp->bytes_acked = 0;
> >  	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
> 
> -	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
> +	if (icsk->icsk_ca_state < TCP_CA_CWR) {
> 
> Probably something for the next "BTW".

These are going to 2.6.22, not to 2.6.21, see:
  http://marc.theaimsgroup.com/?l=linux-netdev&m=117213215924406&w=2
...or do you mean something else?

Since DaveM has already applied this, here is a patch with your correction 
alone on the top of tcp-2.6.

--
[PATCH] [TCP]: Complete icsk-to-local-variable change (in tcp_enter_cwr)

A local variable for icsk was created but this change was
missing. Spotted by Jarek Poplawski.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6e1776..dc221a3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -770,7 +770,7 @@ void tcp_enter_cwr(struct sock *sk, cons
 
 	tp->prior_ssthresh = 0;
 	tp->bytes_acked = 0;
-	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
+	if (icsk->icsk_ca_state < TCP_CA_CWR) {
 		tp->undo_marker = 0;
 		if (set_ssthresh)
 			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
-- 
1.4.2

---696243703-2093170895-1172748620=:19465--
