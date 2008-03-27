From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: SCTP control socket question
Date: Thu, 27 Mar 2008 16:43:25 +0300
Message-ID: <1206625405.2109.7.camel@iris.sw.ru>
References: <1206619433.32459.9.camel@iris.sw.ru>  <47EB9794.7010407@hp.com>
	 <1206623398.32459.19.camel@iris.sw.ru>  <47EB9E0B.2030400@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-PiqFrGLA90ONyR1iEhMr"
Cc: Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30055 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbYC0NnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 09:43:03 -0400
In-Reply-To: <47EB9E0B.2030400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PiqFrGLA90ONyR1iEhMr
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2008-03-27 at 09:15 -0400, Vlad Yasevich wrote:
> Denis V. Lunev wrote:
> > On Thu, 2008-03-27 at 08:48 -0400, Vlad Yasevich wrote:
> >> Denis V. Lunev wrote:
> >>> Hello, Vlad!
> >>>
> >>> I have read SCTP sources and found that SCTP control socket
> >>> (sctp_ctl_socket) remains hashed unlike similar staff in UDP/TCP etc.
> >>>
> >>> Am I wrong, that it should not be hashed or not?
> >> Why do you believe that the socket is hashed?  That socket is only
> >> allocated and referenced.  It's should not be in any hash tables
> >> since we hold a global reference on it.
> > 
> > sctp_ctl_sock_init
> >   __sock_create
> >     inet(6)_create
> >         sk->sk_prot->hash(sk);
> > 
> > For this purpose sk->sk_prot->unhash is explicitly called for ICMP/TCP
> > etc cases.
> > 
> > Regards,
> > 	Den
> > 
> 
> Ahhh...  ;-)
> 
> struct proto sctp_prot = {
> ...
> 	.hash        =  sctp_hash,
> ...
> }
> 
> static void sctp_hash(struct sock *sk)
> {
>         /* STUB */
> }
> 
> 
> SCTP currently does't do any hashing on the sockets.  It hashes SCTP structures
> that live under the socket.

will you mind against this?

--=-PiqFrGLA90ONyR1iEhMr
Content-Disposition: attachment; filename=1.txt
Content-Type: text/x-patch; name=1.txt; charset=KOI8-R
Content-Transfer-Encoding: 7bit

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5aea911..8d1b2bc 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -680,16 +680,13 @@ static int sctp_ctl_sock_init(void)
 	else
 		family = PF_INET;
 
-	err = sock_create_kern(family, SOCK_SEQPACKET, IPPROTO_SCTP,
-			       &sctp_ctl_socket);
+	err = inet_csk_ctl_sock_create(&sctp_ctl_socket, 
+				       family, SOCK_SEQPACKET, IPPROTO_SCTP);
 	if (err < 0) {
 		printk(KERN_ERR
 		       "SCTP: Failed to create the SCTP control socket.\n");
 		return err;
 	}
-	sctp_ctl_socket->sk->sk_allocation = GFP_ATOMIC;
-	inet_sk(sctp_ctl_socket->sk)->uc_ttl = -1;
-
 	return 0;
 }
 

--=-PiqFrGLA90ONyR1iEhMr--

