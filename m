From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 08:09:35 -0700
Message-ID: <20071002150935.GC17418@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>, torvalds@linux-foundation.org,
	davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43295 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752223AbXJBPJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 11:09:36 -0400
Content-Disposition: inline
In-Reply-To: <E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 06:52:54PM +0800, Herbert Xu wrote:
> > One of my clients also has gigabit so I played around with just that
> > one and it (itanium running hpux w/ broadcom gigabit) can push the load
> > as well.  One weird thing is that it is dependent on the direction the
> > data is flowing.  If the hp is sending then I get 46MB/sec, if linux is
> > sending then I get 18MB/sec.  Weird.  Linux is debian, running 
> 
> First of all check the CPU load on both sides to see if either
> of them is saturating.  If the CPU's fine then look at the tcpdump
> output to see if both receivers are using the same window settings.

tcpdump is a good idea, take a look at this.  The window starts out
at 46 and never opens up in my test case, but in the rsh case it 
starts out the same but does open up.  Ideas?

08:08:06.033305 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: S 2756874880:2756874880(0) win 32768 <mss 1460,wscale 0,nop>
08:08:06.033335 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: S 3360532803:3360532803(0) ack 2756874881 win 5840 <mss 1460,nop,wscale 7>
08:08:06.047924 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 1 win 32768
08:08:06.048218 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 1:2921(2920) ack 1 win 46
08:08:06.048426 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 1461 win 32768
08:08:06.048446 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 2921:5841(2920) ack 1 win 46
08:08:06.048673 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 4381 win 32768
08:08:06.048684 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 5841:10221(4380) ack 1 win 46
08:08:06.049047 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 8761 win 32768
08:08:06.049057 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 10221:16061(5840) ack 1 win 46
08:08:06.049422 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 14601 win 32768
08:08:06.049429 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 16061:18981(2920) ack 1 win 46
08:08:06.049462 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 18981:20441(1460) ack 1 win 46
08:08:06.049484 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 20441:23361(2920) ack 1 win 46
08:08:06.049924 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 21901 win 32768
08:08:06.049943 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 23361:32121(8760) ack 1 win 46
08:08:06.050549 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 30661 win 32768
08:08:06.050559 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 32121:39421(7300) ack 1 win 46
08:08:06.050592 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 39421:40881(1460) ack 1 win 46
08:08:06.050614 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 40881:42341(1460) ack 1 win 46
08:08:06.051170 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 40881 win 32768
08:08:06.051188 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 42341:54021(11680) ack 1 win 46
08:08:06.051923 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 52561 win 32768
08:08:06.051932 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 54021:58401(4380) ack 1 win 46
08:08:06.051942 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 58401:67161(8760) ack 1 win 46
08:08:06.052671 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 65701 win 32768
08:08:06.052680 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 67161:74461(7300) ack 1 win 46
08:08:06.052719 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 74461:77381(2920) ack 1 win 46
08:08:06.052752 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 77381:81761(4380) ack 1 win 46
08:08:06.053549 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 80301 win 32768
08:08:06.053566 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 81761:97821(16060) ack 1 win 46
08:08:06.054423 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 96361 win 32768
08:08:06.054433 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 97821:113881(16060) ack 1 win 46
08:08:06.054476 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 113881:115341(1460) ack 1 win 46
08:08:06.055422 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 113881 win 32768
08:08:06.055438 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 115341:131401(16060) ack 1 win 46
08:08:06.056421 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 131401 win 32768
08:08:06.056432 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 131401:147461(16060) ack 1 win 46
08:08:06.117889 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 147461 win 32768
08:08:06.117897 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 147461:163521(16060) ack 1 win 46
08:08:06.118392 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 148921 win 32768
08:08:06.118405 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 163521:173741(10220) ack 1 win 46
08:08:06.118640 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 151841 win 32768
08:08:06.118768 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 156221 win 32768
08:08:06.118775 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 173741:179581(5840) ack 1 win 46
08:08:06.118783 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 162061 win 32768
08:08:06.118793 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 179581:191261(11680) ack 1 win 46
08:08:06.119388 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 169361 win 32768
08:08:06.119644 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 178121 win 32768
08:08:06.119654 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 191261:195641(4380) ack 1 win 46
08:08:06.119665 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 195641:210241(14600) ack 1 win 46
08:08:06.120265 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 188341 win 32768
08:08:06.120274 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 210241:211701(1460) ack 1 win 46
08:08:06.121137 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 200021 win 32768
08:08:06.121148 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 211701:227761(16060) ack 1 win 46
08:08:06.121763 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 213161 win 32768
08:08:06.121772 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 227761:243821(16060) ack 1 win 46
08:08:06.122385 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 227761 win 32768
08:08:06.122396 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 243821:259881(16060) ack 1 win 46
08:08:06.123260 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 243821 win 32768
08:08:06.123269 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 259881:275941(16060) ack 1 win 46
08:08:06.124008 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 259881 win 32768
08:08:06.124021 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 275941:292001(16060) ack 1 win 46
08:08:06.124884 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 275941 win 32768
08:08:06.124894 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 292001:308061(16060) ack 1 win 46
08:08:06.125637 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 292001 win 32768
08:08:06.125647 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 308061:324121(16060) ack 1 win 46
08:08:06.126512 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 308061 win 32768
08:08:06.126522 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 324121:340181(16060) ack 1 win 46
08:08:06.127383 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 324121 win 32768
08:08:06.127393 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 340181:356241(16060) ack 1 win 46
08:08:06.128135 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 340181 win 32768
08:08:06.128146 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 356241:372301(16060) ack 1 win 46
08:08:06.129010 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 356241 win 32768
08:08:06.129020 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 372301:388361(16060) ack 1 win 46
08:08:06.129761 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 372301 win 32768
08:08:06.129770 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 388361:404421(16060) ack 1 win 46
08:08:06.130636 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 388361 win 32768
08:08:06.130645 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 404421:420481(16060) ack 1 win 46
08:08:06.131510 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 404421 win 32768
08:08:06.131521 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 420481:436541(16060) ack 1 win 46
08:08:06.132130 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 420481 win 32768
08:08:06.132140 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 436541:452601(16060) ack 1 win 46
08:08:06.132886 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 436541 win 32768
08:08:06.132895 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 452601:468661(16060) ack 1 win 46
08:08:06.133754 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 452601 win 32768
08:08:06.133765 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 468661:484721(16060) ack 1 win 46
08:08:06.134630 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 468661 win 32768
08:08:06.134640 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 484721:500781(16060) ack 1 win 46
08:08:06.135384 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 484721 win 32768
08:08:06.135395 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 500781:516841(16060) ack 1 win 46
08:08:06.136258 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 500781 win 32768
08:08:06.136272 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 516841:532901(16060) ack 1 win 46
08:08:06.137006 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 516841 win 32768
08:08:06.137016 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 532901:548961(16060) ack 1 win 46
08:08:06.137880 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 532901 win 32768
08:08:06.137891 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 548961:565021(16060) ack 1 win 46
08:08:06.138756 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 548961 win 32768
08:08:06.138768 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 565021:581081(16060) ack 1 win 46
08:08:06.139505 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 565021 win 32768

08:08:18.842450 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 3613368208 win 32768
08:08:18.844056 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 16061:32121(16060) ack 0 win 46
08:08:18.843057 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 16061 win 32768
08:08:18.843069 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 32121:48181(16060) ack 0 win 46
08:08:18.843932 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 32121 win 32768
08:08:18.843942 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 48181:64241(16060) ack 0 win 46
08:08:18.844681 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 48181 win 32768
08:08:18.844690 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 64241:80301(16060) ack 0 win 46
08:08:18.845556 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 64241 win 32768
08:08:18.845566 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 80301:96361(16060) ack 0 win 46
08:08:18.846304 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 80301 win 32768
08:08:18.846313 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 96361:112421(16060) ack 0 win 46
08:08:18.847178 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 96361 win 32768
08:08:18.847187 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 112421:128481(16060) ack 0 win 46
08:08:18.848053 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 112421 win 32768
08:08:18.848063 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 128481:144541(16060) ack 0 win 46
08:08:18.848941 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 128481 win 32768
08:08:18.848952 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 144541:160601(16060) ack 0 win 46
08:08:18.849553 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 144541 win 32768
08:08:18.849561 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 160601:176661(16060) ack 0 win 46
08:08:18.850306 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 160601 win 32768
08:08:18.850316 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 176661:192721(16060) ack 0 win 46
08:08:18.851174 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 176661 win 32768
08:08:18.851182 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 192721:208781(16060) ack 0 win 46
08:08:18.852055 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 192721 win 32768
08:08:18.852064 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 208781:224841(16060) ack 0 win 46
08:08:18.852802 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 208781 win 32768
08:08:18.852810 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 224841:240901(16060) ack 0 win 46
08:08:18.853677 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 224841 win 32768
08:08:18.853687 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 240901:256961(16060) ack 0 win 46
08:08:18.854427 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 240901 win 32768
08:08:18.854436 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 256961:273021(16060) ack 0 win 46
08:08:18.855302 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 256961 win 32768
08:08:18.855311 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 273021:289081(16060) ack 0 win 46
08:08:18.856048 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 273021 win 32768
08:08:18.856058 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 289081:305141(16060) ack 0 win 46
08:08:18.856925 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 289081 win 32768
08:08:18.856934 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 305141:321201(16060) ack 0 win 46
08:08:18.857800 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 305141 win 32768
08:08:18.857809 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 321201:337261(16060) ack 0 win 46
08:08:18.858548 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 321201 win 32768
08:08:18.858556 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 337261:353321(16060) ack 0 win 46
08:08:18.859424 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 337261 win 32768
08:08:18.859432 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 353321:369381(16060) ack 0 win 46
08:08:18.860045 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 353321 win 32768
08:08:18.860054 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 369381:385441(16060) ack 0 win 46
08:08:18.860799 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 369381 win 32768
08:08:18.860807 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 385441:401501(16060) ack 0 win 46
08:08:18.861673 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 385441 win 32768
08:08:18.861683 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 401501:417561(16060) ack 0 win 46
