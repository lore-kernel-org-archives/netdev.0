From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch] d80211: fix WEP on big endian cpus
Date: Sun, 10 Sep 2006 20:11:47 +0200
Message-ID: <200609102011.48115.mb@bu3sch.de>
References: <20060910173649.GA6324@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:25775
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932282AbWIJSNK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 14:13:10 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060910173649.GA6324@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 September 2006 19:36, David Kimdon wrote:
> The ICV is transmitted on the network as a 4 byte little endian
> quantity.  WEP encryption needs to swap the bytes before transmission
> and decryption needs to swap bytes before ICV verification.

Holy shit, this fixes the bug I am hunting for hours at the moment!
I tested this patch and it works. Thanks very much, you saved me hours. ;)

John (Jiri), please apply this one.

Acked-by: Michael Buesch <mb@bu3sch.de>

> Index: wireless-dev/net/d80211/wep.c
> ===================================================================
> --- wireless-dev.orig/net/d80211/wep.c	2006-09-10 14:50:52.073583400 +0000
> +++ wireless-dev/net/d80211/wep.c	2006-09-10 14:51:10.146835848 +0000
> @@ -121,9 +121,11 @@
>  {
>  	struct scatterlist sg;
>  	u32 *icv;
> +	u32 crc;
>  
>  	icv = (u32 *)(data + data_len);
> -	*icv = ~crc32_le(~0, data, data_len);
> +	crc = ~crc32_le(~0, data, data_len);
> +	*icv = cpu_to_le32(crc);
>  
>  	crypto_cipher_setkey(tfm, rc4key, klen);
>  	sg.page = virt_to_page(data);
> @@ -196,6 +198,7 @@
>  	crypto_cipher_decrypt(tfm, &sg, &sg, sg.length);
>  
>  	crc = ~crc32_le(~0, data, data_len);
> +	crc = cpu_to_le32(crc);
>  	if (memcmp(&crc, data + data_len, WEP_ICV_LEN) != 0)
>  		/* ICV mismatch */
>  		return -1;
> 
> --
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Greetings Michael.
