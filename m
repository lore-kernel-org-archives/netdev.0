From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 28 Jun 2006 12:32:38 -0500
Message-ID: <44A2BD36.3010601@lwfinger.net>
References: <20060626212547.GE30706@tuxdriver.com> <200606281634.24160.mb@bu3sch.de> <44A2A872.3050905@lwfinger.net> <200606281832.01108.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:60579 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751475AbWF1Rcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 13:32:47 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606281832.01108.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Wednesday 28 June 2006 18:04, Larry Finger wrote:
> 
> Oh, well. Forget it all.
> I remembered the code wrong.
> At the moment I looked at the code and it has the opposite semantics.
> It loops to wait for the READY bit to appear.
> 
> Well, I would say your old device simply takes this long
> to disable and there is no bug.
> 
> Oh, well...

So the conclusion is that my card is really slow. As mine is likely to be the worst of the lot, I 
propose the following structure for the loop in question:

                 for (i = 10000; i; i--) {
                         tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
                         if (tmp & BCM43xx_IRQ_READY) {
                                 if (i < 9998)
                                         printkl(KERN_INFO PFX "MAC suspend delay %d usec, IRQ_REASON "
                                                 "0x%08x\n", 10000-i, tmp & ~BCM43xx_IRQ_READY);
                                 goto out;
                         }
                         udelay(1);
                 }
                 printkl(KERN_ERR PFX "MAC suspend failed\n");

My maximum delay (so far) is 796 usec, thus this loop gives me a safety factor of more than 10, but 
it should satisfy Jeff and let this patch in question be accepted. Of course, the 'if (i < 9998)' 
statement with the printkl is optional. BTW, as you suspected, the IRQ_REASON value is still at 
0x580 when the READY bit is set.

Thanks for the help,

Larry
