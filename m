From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [udplite] [Patch 1/1] [BUG-FIX]: Avoid u16 checksum coverage
	wrap-around
Date: Mon, 7 Jul 2008 09:59:36 +0100
Message-ID: <20080707085936.GA4270@gerrit.erg.abdn.ac.uk>
References: <20080703113141.GA8223@gerrit.erg.abdn.ac.uk> <20080705.233641.190712838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54261 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751691AbYGGI7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 04:59:43 -0400
Content-Disposition: inline
In-Reply-To: <20080705.233641.190712838.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > udplite: Protection against coverage value wrap-around
| > 
| > This protects UDP-Lite against illegal checksum coverage values and
| > against illegal checksum coverage values caused by the `int' argument
| > wrapping around at 0xffff.
| > 
| > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
| 
| Please preserve the current of using the default value of "8" when an
| illegal value is specified.  This behavior might be important and
| specified somewhere, such as the BSD socket API for udplite used on
| other systems.  The fact that it's even explicitly mentioned in the
| documentation file is a strong indication that it might be that way
| for a good reason.
| 
Can I just clarify illegal checksum values, as there are two different cases:

 (a) Values between 1..7 
     The specification marks these as illegal in RFC 3828, sec. 3.1.
     The Linux UDP-Lite API allowed the user to get away with these illegal 
     coverage values and documented this fact in udplite.txt. Since I am guilty
     of having written this file, I can add that I am not aware that the same 
     behaviour is specified in another place -- other than RFC 3828.

 (b) Values greater than 0xFFFF
     The UDP-Lite checksum coverage field has the same u16 size as the
     UDP Length field but, in contrast, IPv6 jumbograms are not supported
     (RFC 3828, 3.5). This means that checksum coverage values greater than
     65535 are undefined. 
     Since the internal field is u16 and since the setsockopt() argument
     is `int', there is a need to protect against this range, not only 
     since the wrap-around can again cause values in the range 1..7.
       
Can you and/or other people please provide input what to do API-wise in
the two above cases, since this information is needed for the manpage also?

These options come to mind:

  (1) Keep behaviour for (a), return EINVAL for (b).
  (2) Keep behaviour for (a) and silently ignore values > 0xffff by
      replacing these with "full coverage" (0) - problematic if 
      negative values were supplied.
  (3) Return EINVAL in both cases (as sketched by the patch).
  (4) Other alternative?
  
| Gerrit, you like to mix up multiple things at the same time and it
| makes your stuff harder to review.  It also, as a result, makes it
| take longer to integrate your work.
You have a point here. I think I will have to work more with asking how
things should best be done rather than by sending patches.

However, as other people who I work with will be able to confirm, there
is in general a lot of effort being put in to make cooperative work easy.

-- 
