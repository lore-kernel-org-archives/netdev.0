From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 1/6] utils: Implement strlcpy() and strlcat()
Date: Mon, 4 Sep 2017 11:25:25 -0700
Message-ID: <20170904112525.04bc66d5@xeon-e3>
References: <20170901165256.21459-1-phil@nwl.cc>
        <20170901165256.21459-2-phil@nwl.cc>
        <063D6719AE5E284EB5DD2968C1650D6DD006D878@AcuExch.aculab.com>
        <20170904150015.GB30364@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33119 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753932AbdIDSZd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 14:25:33 -0400
Received: by mail-pf0-f169.google.com with SMTP id y68so2504040pfd.0
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2017 11:25:33 -0700 (PDT)
In-Reply-To: <20170904150015.GB30364@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Sep 2017 17:00:15 +0200
Phil Sutter <phil@nwl.cc> wrote:

> On Mon, Sep 04, 2017 at 02:49:20PM +0000, David Laight wrote:
> > From: Phil Sutter  
> > > Sent: 01 September 2017 17:53
> > > By making use of strncpy(), both implementations are really simple so
> > > there is no need to add libbsd as additional dependency.
> > >   
> > ...  
> > > +
> > > +size_t strlcpy(char *dst, const char *src, size_t size)
> > > +{
> > > +	if (size) {
> > > +		strncpy(dst, src, size - 1);
> > > +		dst[size - 1] = '\0';
> > > +	}
> > > +	return strlen(src);
> > > +}  
> > 
> > Except that isn't really strlcpy().
> > Better would be:
> > 	len = strlen(src) + 1;
> > 	if (len <= size)
> > 		memcpy(dst, src, len);
> > 	else if (size) {
> > 		dst[size - 1] = 0;
> > 		memcpy(dst, src, size - 1);
> > 	}
> > 	return len - 1;  
> 
> Please elaborate: Why isn't my version "really" strlcpy()? Why is your
> proposed version better?
> 
> Thanks, Phil

Linux kernel:
size_t strlcpy(char *dest, const char *src, size_t size)
{
	size_t ret = strlen(src);

	if (size) {
		size_t len = (ret >= size) ? size - 1 : ret;
		memcpy(dest, src, len);
		dest[len] = '\0';
	}
	return ret;
}

FreeBSD:
size_t
strlcpy(char * __restrict dst, const char * __restrict src, size_t dsize)
{
	const char *osrc = src;
	size_t nleft = dsize;

	/* Copy as many bytes as will fit. */
	if (nleft != 0) {
		while (--nleft != 0) {
			if ((*dst++ = *src++) == '\0')
				break;
		}
	}

	/* Not enough room in dst, add NUL and traverse rest of src. */
	if (nleft == 0) {
		if (dsize != 0)
			*dst = '\0';		/* NUL-terminate dst */
		while (*src++)
			;
	}

	return(src - osrc - 1);	/* count does not include NUL */
}


They all give the same results for some basic tests.
Test			FreeBSD		Linux		Iproute2
"",0:           	0 "JUNK"      	0 "JUNK"      	0 "JUNK"      
"",1:           	0 ""          	0 ""          	0 ""          
"",8:           	0 ""          	0 ""          	0 ""          
"foo",0:        	3 "JUNK"      	3 "JUNK"      	3 "JUNK"      
"foo",3:        	3 "fo"        	3 "fo"        	3 "fo"        
"foo",4:        	3 "foo"       	3 "foo"       	3 "foo"       
"foo",8:        	3 "foo"       	3 "foo"       	3 "foo"       
"longstring",0: 	10 "JUNK"     	10 "JUNK"     	10 "JUNK"     
"longstring",8: 	10 "longstr"  	10 "longstr"  	10 "longstr"  
