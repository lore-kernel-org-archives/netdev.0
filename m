From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [regression?] e1000e breaks IPMI
Date: Mon, 16 Jun 2008 15:30:24 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52056AC3B7@orsmsx418.amr.corp.intel.com>
References: <20080616211636.GA5179@develbox.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nikola.ciprich@linuxbox.cz, e1000-devel@lists.sourceforge.net,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: "Nikola Ciprich" <extmaillist@linuxbox.cz>,
	<linux-kernel@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20080616211636.GA5179@develbox.linuxbox.cz>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Nikola Ciprich wrote:
> Hi,
> it seems that e1000e breaks IPMI support on at least some
> motherboards (ie SuperMicro PDSMi-LN4 with AOC-IPMI20-E+ module, and
> also others).  
> When e1000e module is loaded, IPMI module stops to respond. The
> problem is, that it was working before, so I tried examining further
> and bisect showed that following commit caused it to stop working:  

thank you for bisecting.
also, I added netdev so the network developers are aware of this thread.
 
> commit 5918bd88effd0233a048983570ec5803f5f753dc
> Author: Auke Kok <auke-jan.h.kok@intel.com>
> Date:   Tue Feb 12 15:20:24 2008 -0800
> 
>     e1000e: Fix CRC stripping in hardware context bug
> 
>     CRC stripping was only correctly enabled for packet split recieves
>     which is used when receiving jumbo frames. Correctly enable SECRC
>     also for normal buffer packet receives.

At one point I fixed a similar bug in e1000 on 82546 hardware that was
connected to a BMC.  In that case the packets were being discarded by a
BMC that is apparently unable to understand that the hardware is
stripping the CRC at reception (and then the BMC looks for the CRC and
drops the packet because there isn't one)

Basically this works fine for Intel BMC's that know about the (AFAIK -
I'm not a BMC expert) special fields in the SMBUS header that indicate
whether the packet was CRCd correctly.  Does the BMC have an option to
turn off CRC checking?  The BMC is the real problem here, probably.
 
> I can confirm that reverting the patch makes IPMI work again. So it
> either is a regression, or maybe just trigger for some other bug
> (seems more likely to me). Pity I haven't noticed it sooner, we've
> been using older e1000[e] drivers up to now.   
> 
> Any suggestions on where the problem could be?

I'm pretty sure that if you disable hardware stripping then it will
start working.  The short term solution is change the code to disable
setting the SECRC bit, like you did when you reverted the patch.

There is a possible complex patch that completely implements software
stripping of CRCs, because there are a lot of issues with doing
pskb_trim, etc in receive.  It would be modeled on the same kind of
thing we did for e1000.  

I hate working around this broken BMC (again) when others are known to
work just fine, and CRC stripping in hardware really simplifies our
receive path.

Netdev, any advice?


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
