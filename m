From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] netlink: align attributes on 64-bits
Date: Wed, 19 Dec 2012 09:17:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70F6@saturn3.aculab.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <20121218125735.GG27746@casper.infradead.org> <50D09897.8030508@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F5@saturn3.aculab.com> <20121218171103.GI27746@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <nicolas.dichtel@6wind.com>, <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:32850 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750810Ab2LSJZX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:25:23 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21049-02 for <netdev@vger.kernel.org>;
 Wed, 19 Dec 2012 09:25:19 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20121218171103.GI27746@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Consider the structure:
> > 	struct bar {
> > 		__u32 foo1;
> > 		__u64 foo2;
> > 	}
> > On i386 it will have size 12 and foo2 will be at offset 4.
> > On sparc32 (and most 64bit) it will have size 16 with foo2
> > at offset 8 (and 4 bytes of pad after foo1).
> 
> This is a known problem and I can't think of anything
> that can be done about it except for memcpy()ing the
> data before accessing it.

You can't use memcpy() to copy a pointer to a misaligned
structure into an aligned buffer. The compiler assumes
the pointer is aligned and will use instructions that
depend on the alignment.

> If you have ideas, I'm more that willing to listen :)
> ... Netlink has and will be host bound. It also
> uses host byte order for that reason.

I think:
1) Alignment is only needed on systems that have 'strict alignment'
   requirements (maybe disable for testing?)
2) Alignment is only needed for parameters whose size is a
   multiple of the alignment (a structure containing a
   field that needs 8 byte alignment will always be a multiple
   of 8 bytes long).
3) You need to add NA_HDR_LEN to the write pointer before
   determining the size of the pad.

So a structure of three uint32_t will never need aligning.

	David
