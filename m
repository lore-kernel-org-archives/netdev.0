From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Fri, 11 Jul 2008 00:31:42 +0200
Message-ID: <20080710223141.GA2519@orion.carnet.hr>
References: <4863DA40.9050508@broadcom.com> <20080709164619.GA26098@orion.carnet.hr> <1215622625.5532.43.camel@dell> <20080709.164659.157912631.davem@davemloft.net> <1215723617.6901.3.camel@dell> <20080710212324.GA22521@orion.carnet.hr> <1215725921.6901.10.camel@dell> <20080710220030.GA29558@orion.carnet.hr> <1215728763.6901.23.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"billfink@mindspring.com" <billfink@mindspring.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:55278 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbYGJWbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 18:31:46 -0400
Content-Disposition: inline
In-Reply-To: <1215728763.6901.23.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 03:26:03PM -0700, Michael Chan wrote:
> > > This is the same crash that you originally reported.  The driver was
> > > referencing a NULL SKB because the skb_shinfo(skb)->nr_frags was
> > > modified on the previous packet in the TX ring.
> > >
> > > If you had applied my debug patch #1 that I posted several weeks ago, it
> > > should have avoided this because we should have saved away the nr_frags
> > > for every packet on the TX ring.
> > 
> > It was that same patched kernel that crashed nevertheless.
> 
> That's strange.  You also saw lots of "Corrupted SKB..." dmesg as well,
> right?  May be the debug patch is not bullet-proof although I cannot see
> how we can still get a NULL SKB in the TX completion path.

Yes, there were gobs of those, as usual. JFTR, this was the last one
recorded before the crash, though I can't be sure if it was responsible or not:

Jul 10 23:13:20 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 2
Jul 10 23:13:20 arrakis kernel: original skb:
Jul 10 23:13:20 arrakis kernel: 00000000 00000000 00000000 00000000 15c45900 ffff8100 00000000 00000000
Jul 10 23:13:20 arrakis kernel: 15c80000 ffff8100 258d4d00 ffff8102 00000000 00000000 00000000 00000000
Jul 10 23:13:20 arrakis kernel: 00000000 00000000 00000000 00000000 5383c74e 5383d29e 1e3d909e 00000010
Jul 10 23:13:20 arrakis kernel: 00000000 00000000 00000b92 00000b50 01000000 001000e0 00000000 0008d00e
Jul 10 23:13:20 arrakis kernel: 803e3440 ffffffff 00000000 00000000 00000000 00000000 00000000 20000000
Jul 10 23:13:20 arrakis kernel: 6d8b2897 00000000 000000e0 000000cc 00000000 00000100 00000100 0a8ab8a0
Jul 10 23:13:20 arrakis kernel: fbd14000 ffff8101 fbd140be ffff8101 00000d28 00000001
Jul 10 23:13:20 arrakis kernel:
Jul 10 23:13:20 arrakis kernel: 00010002 05a80002 00010002 00000000 00000000 00000000 0097e340 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000823 000007dd 0134e620 ffffe200 00000000 00000373 026e4338 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 008fd160 ffffe200 00000000 00001000 02447898 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 004e5070 ffffe200 00000000 000001ab 00857ff8 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00000d7b 00898ca0 ffffe200 00000000 0000094b 020068b8 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 0000051b 078e1fd0 ffffe200 00000000 00001000 0790b710 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 07907d18 ffffe200 00000000 00001000 05c1f540 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 07924a38 ffffe200 00000000 00001000 078d79c8 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 0782ae18 ffffe200 00000000 00001000 078c8308 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00000169 00000021 00000000 50545448 654d3a3a
Jul 10 23:13:20 arrakis kernel:
Jul 10 23:13:20 arrakis kernel: Corrupted skb:
Jul 10 23:13:20 arrakis kernel: 00000000 00000000 00000000 00000000 15c45900 ffff8100 00000000 00000000
Jul 10 23:13:20 arrakis kernel: 15c80000 ffff8100 258d4d00 ffff8102 00000000 00000000 00000000 00000000
Jul 10 23:13:20 arrakis kernel: 00000000 00000000 00000000 00000000 5383c74e 5383d29e 1e3d909e 00000010
Jul 10 23:13:20 arrakis kernel: 00000000 00000000 00000b92 00000b50 01000000 001000e0 00000000 0008d00e
Jul 10 23:13:20 arrakis kernel: 803e3440 ffffffff 00000000 00000000 00000000 00000000 00000000 20000000
Jul 10 23:13:20 arrakis kernel: 6d8b2897 00000000 000000e0 000000cc 00000000 00000100 00000100 0a8ab8a0
Jul 10 23:13:20 arrakis kernel: fbd14000 ffff8101 fbd140be ffff8101 00000d28 00000001
Jul 10 23:13:20 arrakis kernel:
Jul 10 23:13:20 arrakis kernel: 00010002 00000001 00000001 00000000 00000000 00000000 0097e340 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000823 000005a8 0134e620 ffffe200 00000000 00000373 026e4338 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 008fd160 ffffe200 00000000 00001000 02447898 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 004e5070 ffffe200 00000000 000001ab 00857ff8 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00000d7b 00898ca0 ffffe200 00000000 0000094b 020068b8 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 0000051b 078e1fd0 ffffe200 00000000 00001000 0790b710 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 07907d18 ffffe200 00000000 00001000 05c1f540 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 07924a38 ffffe200 00000000 00001000 078d79c8 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00001000 0782ae18 ffffe200 00000000 00001000 078c8308 ffffe200
Jul 10 23:13:20 arrakis kernel: 00000000 00000169 00000021 00000000 50545448 654d3a3a
Jul 10 23:13:20 arrakis kernel:


> Anyway, please try today's patch as we need to find the source of the
> problem.

It's running with it now, no messages yet. I'll report when if/when they
happen.

-- 
Josip Rodin
mirrors@debian.org
