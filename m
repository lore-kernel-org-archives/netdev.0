From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns identify"
Date: Fri, 18 Jan 2013 09:41:00 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7114@saturn3.aculab.com>
References: <87a9u4q7k9.fsf@xmission.com><1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com><87a9s772zw.fsf@xmission.com><1358470823.15692.156.camel@deadeye.wl.decadent.org.uk> <87mww71drv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42269 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751116Ab3ARJnE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 04:43:04 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06506-03 for <netdev@vger.kernel.org>;
 Fri, 18 Jan 2013 09:43:01 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <87mww71drv.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> >> +		if (!isdigit(ch))
> >> >
> >> > ch must be cast to unsigned char before passing to isdigit().
> >>
> >> isdigit is defined to take an int.  A legacy of the implicit casts in
> >> the K&R C days.  Casting to unsigned char would be pointless and silly.
> > [...]
> >
> > It's not pointless.  This is explained in the very first line of the
> > description in the manual page...
> 
> If it's not pointless it is an implementation bug.  The conversion to of
> char to int happens implicitly whenever you pass a char.  It is
> absolutely broken to have a function that takes a char converted to int
> and reject the automatic conversion of char to int.
> 
> I suspect much more strongly that it is a case of poor documentation.

All of the isxxxx() functions have an input domain of EOF and all the
values of 'char' cast to unsigned (I've forgotten the exact words).
Passing in a value that is outside the domain has an undefined effect
and is very likely to generate a core dump, even if it doesn't
dump, the returned value is likely to be wrong.

This input value matches the values returned by the stdio getc()
functions and getopt().

> If isdigit can't deal with what I have passed it I will be much more
> interested in writing a patch for isdigit.

The traditional/expected implementation of the isxxx() functions is
a macro expansion that indexes an array and checks for some bits.
gcc even has a warning about indexing arrays with 'char' that,
I suspect, is there to detect incorrect uses of the isxxx() functions.

> That said I just dobule checked with the code below.  Negative character
> values work correctly and don't cause any runtime errors.

The fact that one specific piece of code appears to work doesn't mean
that all such code will work - it won't.

In any case the functions have to differentiate between EOF and
the 256 valid values of 'char'. EOF (more or less) has to be -1
so the char bit pattern 0xff must not become -1 (it passes
isprint() in at least some locales).

I've had to do a trawl through a large amount of user code fixing
the buggy calls to the isxxxx() functions. Interestingly I didn't
actually find any code that could pass EOF as an argument!

	David
