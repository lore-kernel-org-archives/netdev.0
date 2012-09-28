From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [net-next PATCH 4/5] be2net: get rid of AMAP_SET/GET macros in
 TX path
Date: Fri, 28 Sep 2012 05:47:25 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C6562EE@CMEXMB1.ad.emulex.com>
References: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
	<92de1988-73db-4864-bf19-10ed11dac557@CMEXHTCAS2.ad.emulex.com>
 <20120927.222900.1633352325278735069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46239 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab2I1Fr1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 01:47:27 -0400
In-Reply-To: <20120927.222900.1633352325278735069.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>
>Now you have endianness bugs.  The previous code worked with 8-bit
>struct members and as such was endian neutral.
>
>Now you're working with words, so you thus have to take endianness
>into consideration.

Dave,
endianness is handled even in this patch. The call to wrb_fill_hdr()
is followed by be_dws_cpu_to_le() to handle this.

The old code did not set the 8-bit members in the amap_eth_wrb_hdr struct.
The TX hdr wrb structure is actually 4 words (32-bit * 4) long. Each word
has some fields with different bit sizes. In the old code a *separate* psuedo
structure -- called the amap_eth_wrb_hdr -- was defined, wherein a field
of size x bits in the actual TX-hrd-wrb was defined as *x bytes* long. This was
done to be able to calculate the mask and shift values of each bit-field without having to define
them manually.

There has been feedback in the community earlier that this method of calculating
bit-field masks and shifts is unusual and to be consistent with other drivers' code we
manually define the mask and shift values for each field.

>
>The readability aspect is also extremely questionable, here's why.
>The old code accessed struct members with _NAMES_ which described what
>the values are and what they do.
>
>This new code puts values into opaque "word" array members.  That's
>about as crappy as it comes wrt. readability.  What in the world
>does word[0] do?  I can't tell from it's name.  Yet with the existing
>"struct amap_eth_hdr_wrb" there is none of that kind of confusion.

The word[2] of TX-hdr-wrb consists for various 1-bit fields.
I could call this word "flags". But, word[3] consists of unrelated fields like
wrb-num (5bits),  lso-mss-len(14 bits) etc . So, I just used dw[3].

I could rename the current definition of TX-hdr-wrb from
struct be_eth_hdr_wrb {
	u32 dw[4];
};

to

struct be_eth_hdr_wrb {
	u32 rsvd0;
	u32 rsvd0;
	/* compl, evt, crc & cksum bits */
	u32 flags;
	/* num-wrb, lso-mss, vlan-tci etc */
	u32 info;
};

Pls let me know if this addresses your concerns...

thanks,
-Sathya
