From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Sun, 20 Jun 2010 23:57:44 +0200
Message-ID: <20100620215743.GA4036@nuttenaction>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net>
 <20100619221611.784f7dbc@nehalam>
 <20100620095019.GA32223@nuttenaction>
 <20100620.150928.245399526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:33354 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754491Ab0FTW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 18:57:47 -0400
Content-Disposition: inline
In-Reply-To: <20100620.150928.245399526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2010-06-20 15:09:28 [-0700]:

>I think from this perspective, the change is fine too, nothing visible
>to the user is being changed here.

Fine! I have a fundamental question: can we start to use a C language
extension, known as "Labels as Values" in the kernel? I checked this and at
least gcc, llvm and icc support this extension (btw: c1x[1] don't mention
this):

static int sk_run_filter(struct sock_filter *filter) {
  static const void *codetable[] =
      { &&BPF_S_RET_K, &&BPF_S_ALU_ADD_X, &&BPF_S_ALU_SUB_X, &&BPF_S_ALU_MUL_X };
  int pc = 0;

  goto *codetable[*(filter[pc++].code)];

  BPF_S_RET_K:
   return k;

  BPF_S_ALU_ADD_X:
   A += X;
   goto *codetable[*(filter[pc++].code)];

  BPF_S_ALU_SUB_X:
   A -= X;
   goto *codetable[*(filter[pc++].code)];

  BPF_S_ALU_MUL_X:
	 A *= X
   goto *codetable[*(filter[pc++].code)];
}


At least for gcc and llvm the results are quite impressive: http://llvm.org/bugs/show_bug.cgi?id=3120 

arch/m68k/amiga/config.c:amiga_reset() seems to be the only user in the kernel
who use this extension (and nobody complains? ;-)


Cheers, Hagen

[1] http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1425.pdf

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://blog.jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
