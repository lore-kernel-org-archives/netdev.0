From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH 1/6] utils: Implement strlcpy() and strlcat()
Date: Wed, 6 Sep 2017 13:59:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD006EC26@AcuExch.aculab.com>
References: <20170901165256.21459-1-phil@nwl.cc>
        <20170901165256.21459-2-phil@nwl.cc>
        <063D6719AE5E284EB5DD2968C1650D6DD006D878@AcuExch.aculab.com>
        <20170904150015.GB30364@orbyte.nwl.cc> <20170904112525.04bc66d5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:64689 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932307AbdIFN7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 09:59:32 -0400
In-Reply-To: <20170904112525.04bc66d5@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: 04 September 2017 19:25
> On Mon, 4 Sep 2017 17:00:15 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > On Mon, Sep 04, 2017 at 02:49:20PM +0000, David Laight wrote:
> > > From: Phil Sutter
> > > > Sent: 01 September 2017 17:53
> > > > By making use of strncpy(), both implementations are really simple so
> > > > there is no need to add libbsd as additional dependency.
> > > >
> > > ...
> > > > +
> > > > +size_t strlcpy(char *dst, const char *src, size_t size)
> > > > +{
> > > > +	if (size) {
> > > > +		strncpy(dst, src, size - 1);
> > > > +		dst[size - 1] = '\0';
> > > > +	}
> > > > +	return strlen(src);
> > > > +}
> > >
> > > Except that isn't really strlcpy().
> > > Better would be:
> > > 	len = strlen(src) + 1;
> > > 	if (len <= size)
> > > 		memcpy(dst, src, len);
> > > 	else if (size) {
> > > 		dst[size - 1] = 0;
> > > 		memcpy(dst, src, size - 1);
> > > 	}
> > > 	return len - 1;
> >
> > Please elaborate: Why isn't my version "really" strlcpy()? Why is your
> > proposed version better?
> >
> > Thanks, Phil
> 
> Linux kernel:
> size_t strlcpy(char *dest, const char *src, size_t size)
> {
> 	size_t ret = strlen(src);
> 
> 	if (size) {
> 		size_t len = (ret >= size) ? size - 1 : ret;
> 		memcpy(dest, src, len);
> 		dest[len] = '\0';
> 	}
> 	return ret;
> }
> 
> FreeBSD:
> size_t
> strlcpy(char * __restrict dst, const char * __restrict src, size_t dsize)
> {
> 	const char *osrc = src;
> 	size_t nleft = dsize;
> 
> 	/* Copy as many bytes as will fit. */
> 	if (nleft != 0) {
> 		while (--nleft != 0) {
> 			if ((*dst++ = *src++) == '\0')
> 				break;
> 		}
> 	}
> 
> 	/* Not enough room in dst, add NUL and traverse rest of src. */
> 	if (nleft == 0) {
> 		if (dsize != 0)
> 			*dst = '\0';		/* NUL-terminate dst */
> 		while (*src++)
> 			;
> 	}
> 
> 	return(src - osrc - 1);	/* count does not include NUL */
> }
> 
> 
> They all give the same results for some basic tests.
> Test			FreeBSD		Linux		Iproute2
> "",0:           	0 "JUNK"      	0 "JUNK"      	0 "JUNK"
> "",1:           	0 ""          	0 ""          	0 ""
> "",8:           	0 ""          	0 ""          	0 ""
> "foo",0:        	3 "JUNK"      	3 "JUNK"      	3 "JUNK"
> "foo",3:        	3 "fo"        	3 "fo"        	3 "fo"
> "foo",4:        	3 "foo"       	3 "foo"       	3 "foo"
> "foo",8:        	3 "foo"       	3 "foo"       	3 "foo"
> "longstring",0: 	10 "JUNK"     	10 "JUNK"     	10 "JUNK"
> "longstring",8: 	10 "longstr"  	10 "longstr"  	10 "longstr"

You need to look at the contents of the destination buffer after the
first '\0'.
strlcpy() shouldn't change it.

	David
