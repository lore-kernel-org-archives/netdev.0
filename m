From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i	cannot
 navigate
Date: Mon, 20 Oct 2008 12:38:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810201106200.7072@wrl-59.cs.helsinki.fi>
References: <bug-11721-11547@http.bugzilla.kernel.org/>
 <20081018202056.F1933108040@picon.linux-foundation.org>
 <20081018210252.GA6048@ami.dom.local> <20081018215007.GB6048@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Aldo Maggi <sentiniate@tiscali.it>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57954 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbYJTJiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 05:38:55 -0400
In-Reply-To: <20081018215007.GB6048@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Oct 2008, Jarek Poplawski wrote:

> [RESEND] I forgot to add Aldo's email before - sorry!
> 
> On Sat, Oct 18, 2008 at 11:02:52PM +0200, Jarek Poplawski wrote:
> > Nice job Aldo!
> > 
> > I forward this message to netdev and Cc our best tcp expert.
> > Any new replies should be rather "Reply All" (not bugzilla only).
> > 
> > Thanks,
> > Jarek P.
> > 
> > On Sat, Oct 18, 2008 at 01:20:56PM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> > > http://bugzilla.kernel.org/show_bug.cgi?id=11721
> > > 
> > ...
> > > ------- Comment #30 from sentiniate@tiscali.it  2008-10-18 13:20 -------
> > > absolutely i'm not fed up! and actually i thank you for your patience.
> > > 
> > > i set paperino as you wrote and added ifconfig eth0 mtu 1400 as well
> > > i set the same value of mtu in topolino as well, i hope i was not wrong doing
> > > so!
> > > 
> > > i attach the files you ask for, but now i can navigate with 2.6.27-rc1-git1 as
> > > well!
> > > 
> > > afterwards i've run some more tests and have found out that the culprit is
> > > tcp_sack, if using kernel 2.6.27-rc1-gt1 it is set to "1" i cannot navigate if
> > > to "0" i can.
> > > so i enclose, should it be of any help, also the tcpdump on eth0 of topolino
> > > when on paperino tcp_sack is set to "1".

So this ended up into tcp domain after all (I took earlier a brief 
anyway and found out that there are not that many changes 2.6.26..2.6.27 
-- net/ipv4/tcp*.c include/net/tcp.h)...

I compared your packet against a good one from elsewhere.. I couldn't 
compare your latest dumps fully because attachments 18366 and 18367 are 
with different TCP options (you forgot zeros to sysctls in them?)... 
Anyway, only thing that seemed to be different to that case from elsewhere 
were those extra bytes in the beginning (some below ip protocol that 
gets captured by tcpdump?) which are equal in both working and broken case 
of yours and the different ordering of the tcp options as noted by Jarek 
earlier. I tried to go through the fields one by one but nothing seemed to 
be wrong...

...Might be something crazy in the way that is too picky on tcp option 
ordering which wouldn't surprise me that much... :-) Please try if
the patch below does any difference (on paperino is enough, the gw seems 
innocent here).

If that didn't help, can you please restore the sysctls to 1 and redo
2.6.26.6 dump (like in attachment 18366) so that I get a fully comparable 
sample.

-- 
 i.


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 990a584..850a4e9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -376,6 +376,12 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*md5_hash = NULL;
 	}
 
+	if (unlikely(opts->mss)) {
+		*ptr++ = htonl((TCPOPT_MSS << 24) |
+			       (TCPOLEN_MSS << 16) |
+			       opts->mss);
+	}
+
 	if (likely(OPTION_TS & opts->options)) {
 		if (unlikely(OPTION_SACK_ADVERTISE & opts->options)) {
 			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
@@ -392,12 +398,6 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	if (unlikely(opts->mss)) {
-		*ptr++ = htonl((TCPOPT_MSS << 24) |
-			       (TCPOLEN_MSS << 16) |
-			       opts->mss);
-	}
-
 	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
 		     !(OPTION_TS & opts->options))) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
