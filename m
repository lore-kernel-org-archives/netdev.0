From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Tue, 10 Nov 2009 16:30:31 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911101605050.20637@melkinpaasi.cs.helsinki.fi>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <alpine.DEB.2.00.0911100659470.7059@melkinpaasi.cs.helsinki.fi> <4AF96D71.8000905@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1868741136-1257862144=:20637"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54002 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391AbZKJOa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 09:30:26 -0500
In-Reply-To: <4AF96D71.8000905@gmail.com>
Content-ID: <alpine.DEB.2.00.0911101630280.20637@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1868741136-1257862144=:20637
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911101609111.20637@melkinpaasi.cs.helsinki.fi>

On Tue, 10 Nov 2009, William Allen Simpson wrote:

> Ilpo Järvinen wrote:
> > On Mon, 9 Nov 2009, William Allen Simpson wrote:
> > > ...
> > > Data structures are carefully composed to require minimal additions.
> > > For example, the struct tcp_options_received cookie_plus variable fits
> > > between existing 16-bit and 8-bit variables, requiring no additional
> > > space (taking alignment into consideration).  There are no additions to
> > > tcp_request_sock, and only 1 pointer in tcp_sock.
> > > ...
> > 
> > One general comment. ...This particular patch still has lots of noise which
> > does not belong to the context of this change. ...Please try to minimize.
> > Eg., if you don't like sizeof(struct tcphdr) but prefer sizeof(*th), you
> > certainly don't have to do it in this particular patch!

After some time I returned to it. My apologies for my previous harsh 
response. My point was to say that you must separate such changes because 
they add to noise which makes it rather annoying to review. At least my 
brains are rather limited still in keeping track of different things.

> This *is* actually in CodingStyle (line 679), and I'm trying to conform:

Sure, fell free to but not in some random places like you now do in this 
patch. If you are not touching a line because of a real change and want do 
a syntax cleanup, please do it in another patch. Especially when your 
actual change is as complicated as this is.

> > ...Also some comment changes which certainly are not mandatory nor even
> > related.
> > 
> Hmmm....
> 
> 1) The first is a hole left by the removal of the data fields some time
> ago, but they left the old (now incorrect) comment:
> 
> -/*	SACKs data	*/
> +	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
> +		cookie_out_never:1,
> +		cookie_in_always:1;
>  	u8	num_sacks;	/* Number of SACK blocks		*/
> 
> Although it's not evident from the diff -u, I'm *filling* that hole,
> putting everything on a nice 32-bit boundary, thus taking *NO* space
> (already mentioned in my patch description above):
> 
> 	u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
> 		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
> 		dsack : 1,	/* D-SACK is scheduled			*/
> 		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
> 		sack_ok : 4,	/* SACK seen on SYN packet		*/
> 		snd_wscale : 4,	/* Window scaling received from sender	*/
> 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
> 	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
> 		cookie_out_never:1,
> 		cookie_in_always:1;
> 	u8	num_sacks;	/* Number of SACK blocks		*/
> 	u16	user_mss;	/* mss requested by user in ioctl	*/
> 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup
> */
> 
> The only reason that it's done this way was Miller's imperative that
> required cramming this into as small a space as possible.
> 
>   "Store the data either somewhere else or in an extremely compact form."
> 
>   "Make your state take up less space in tcp_sock without making it cost
>   more in some other form."
> 
> Of course, it costs more, and I have to keep copying it from place to place,
> adding to the code complexity.  But I was feeling rather clever to have
> found that hole!

I'm sorry but this response tells me that you don't seem to know even 
yourself what you were submitting. Does this ring a bell:

-       if (th->doff == sizeof(struct tcphdr) >> 2) {
+       /* In the spirit of fast parsing, compare doff directly to shifted
+        * constant values.  Because equality is used, short doff can be
+        * ignored here, and checked later.
+        */
+       if (th->doff == (sizeof(*th) >> 2)) {

Besides, I don't understand even what you're trying to say. ...I think we 
already checked the length in tcp_v[46]_rcv against underflow. Why you add 
such a non-sense comment here (plus the sizeof change I covered 
elsewhere)? This is just a noise to annoy reviewer, nothing else.

> 2) The second is a spelling error that I noticed in passing.  It's within
> the same diff -u area (close to other insertions both before and after), so
> fixing it was trivial:
> 
> - * to increse this, although since:
> + * to increase this, although since:
> 
> Are we not supposed to fix spelling errors in comments?

How many extra lines a reviewer has to read because of that? Why not do it 
in a separate patch. git add -i / git stash would help you there. ...To be 
honest, I'd rather have typos in comments which like this are not 
trouble for the reader than clutter feature patches with all this random 
junk.

...I really wish that next time when you submit you get rid of all these 
showstoppers and annoyances (ie., at least honestly try to do your best)
that we could finally concentrate to the actual change and reviewing
that :-). My recommendation is that before hitting the send button you 
review (read through) your own patches, and if you find something to 
correct instead of submitting, postpone that until the problem is solved. 
Like DaveM once noted somebody, you'll not be timed :-). ...I usually do 
that (read my own patches) and end up rather often to not submit (and find 
even real bugs that way quite often).

-- 
 i.
---696230645-1868741136-1257862144=:20637--
