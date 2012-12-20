From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] netlink: align attributes on 64-bits
Date: Thu, 20 Dec 2012 09:37:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70FA@saturn3.aculab.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <20121218125735.GG27746@casper.infradead.org> <50D09897.8030508@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F5@saturn3.aculab.com> <20121218171103.GI27746@casper.infradead.org> <AE90C24D6B3A694183C094C60CF0A2F6026B70F6@saturn3.aculab.com> <20121219172012.GC6975@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <nicolas.dichtel@6wind.com>, <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53284 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752049Ab2LTJqn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 04:46:43 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14173-05 for <netdev@vger.kernel.org>;
 Thu, 20 Dec 2012 09:46:38 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20121219172012.GC6975@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 12/19/12 at 09:17am, David Laight wrote:
> > You can't use memcpy() to copy a pointer to a misaligned
> > structure into an aligned buffer. The compiler assumes
> > the pointer is aligned and will use instructions that
> > depend on the alignment.
> 
> I am not sure I understand this correctly. Are you saying
> that the following does not work on i386?
> 
> struct foo {
>   uint32_t a;
>   uint64_t b;
> };
> 
> struct foo buf;
> 
> memcpy(&buf, nla_data(attr), nla_len(attr));
> printf([...], buf.b);

That will be fine on all systems.
But if, instead, you have:
	struct foo buf, *bufp;
	bufp = nla_data(attr);
	memcpy(&buf, bufp, sizeof buf);
The compiler is allowed to assume that 'bufp' is aligned,
so the copy will be done using 64bit accesses.

(Basically because all you are allowed to do with 'void *'
is cast a point to 'void *', then back to its original type.
So when you cast back from 'void *' the pointer can be assumed
to be aligned.)

This will fault on systems that require strict alignment
of 64bit items.

	David
