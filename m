From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Tue, 10 Nov 2009 08:41:05 -0500
Message-ID: <4AF96D71.8000905@gmail.com>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <alpine.DEB.2.00.0911100659470.7059@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:61244 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbZKJNlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 08:41:04 -0500
Received: by pzk26 with SMTP id 26so12809pzk.4
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 05:41:09 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.0911100659470.7059@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Mon, 9 Nov 2009, William Allen Simpson wrote:
>>...
>> Data structures are carefully composed to require minimal additions.
>> For example, the struct tcp_options_received cookie_plus variable fi=
ts
>> between existing 16-bit and 8-bit variables, requiring no additional
>> space (taking alignment into consideration).  There are no additions=
 to
>> tcp_request_sock, and only 1 pointer in tcp_sock.
>>...
>=20
> One general comment. ...This particular patch still has lots of noise=
=20
> which does not belong to the context of this change. ...Please try to=
=20
> minimize. Eg., if you don't like sizeof(struct tcphdr) but prefer=20
> sizeof(*th), you certainly don't have to do it in this particular pat=
ch!

This *is* actually in CodingStyle (line 679), and I'm trying to conform=
:

<blockquote>
The preferred form for passing a size of a struct is the following:

	p =3D kmalloc(sizeof(*p), ...);

The alternative form where struct name is spelled out hurts readability=
 and
introduces an opportunity for a bug when the pointer variable type is c=
hanged
but the corresponding sizeof that is passed to a memory allocator is no=
t.
</blockquote>

Maybe some of these anticipate part 2, so I can defer them to later.  I=
've
already coded much of part 2, so things are bleeding back and forth.


> ...Also some comment changes which certainly are not mandatory nor ev=
en=20
> related.
>=20
Hmmm....

1) The first is a hole left by the removal of the data fields some time
ago, but they left the old (now incorrect) comment:

-/*	SACKs data	*/
+	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
+		cookie_out_never:1,
+		cookie_in_always:1;
  	u8	num_sacks;	/* Number of SACK blocks		*/

Although it's not evident from the diff -u, I'm *filling* that hole,
putting everything on a nice 32-bit boundary, thus taking *NO* space
(already mentioned in my patch description above):

	u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
		dsack : 1,	/* D-SACK is scheduled			*/
		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
		sack_ok : 4,	/* SACK seen on SYN packet		*/
		snd_wscale : 4,	/* Window scaling received from sender	*/
		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
		cookie_out_never:1,
		cookie_in_always:1;
	u8	num_sacks;	/* Number of SACK blocks		*/
	u16	user_mss;	/* mss requested by user in ioctl	*/
	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */

The only reason that it's done this way was Miller's imperative that
required cramming this into as small a space as possible.

   "Store the data either somewhere else or in an extremely compact for=
m."

   "Make your state take up less space in tcp_sock without making it co=
st
   more in some other form."

Of course, it costs more, and I have to keep copying it from place to p=
lace,
adding to the code complexity.  But I was feeling rather clever to have
found that hole!


2) The second is a spelling error that I noticed in passing.  It's with=
in
the same diff -u area (close to other insertions both before and after)=
, so
fixing it was trivial:

- * to increse this, although since:
+ * to increase this, although since:

Are we not supposed to fix spelling errors in comments?

