From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-mm2 - oops in cache_alloc_refill()
Date: Sat, 30 Sep 2006 01:33:49 -0700
Message-ID: <20060930013349.1f12e0ee.akpm@osdl.org>
References: <20060928014623.ccc9b885.akpm@osdl.org>
	<200609290319.k8T3JOwS005455@turing-police.cc.vt.edu>
	<20060928202931.dc324339.akpm@osdl.org>
	<200609291519.k8TFJfvw004256@turing-police.cc.vt.edu>
	<20060929124558.33ef6c75.akpm@osdl.org>
	<200609300001.k8U01sPI004389@turing-police.cc.vt.edu>
	<20060929182008.fee2a229.akpm@osdl.org>
	<20060930013348.GA10905@bougret.hpl.hp.com>
	<200609300331.k8U3V71c008874@turing-police.cc.vt.edu>
	<200609300750.k8U7oihQ008628@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, "John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15265 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751149AbWI3Ik1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 04:40:27 -0400
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200609300750.k8U7oihQ008628@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Sep 2006 03:50:43 -0400
Valdis.Kletnieks@vt.edu wrote:

> On Fri, 29 Sep 2006 23:31:07 EDT, Valdis.Kletnieks@vt.edu said:
> > Fair enough,  I'm going to try reverting the 2 commits and see if things
> > behave better.
> 
> OK, it's definitely something in those 2 commits - I reverted them and the
> resulting 2.6.18-mm2 kernel has been up and stable for 4 hours, even with
> the problem gkrellm updating once a second the whole time.
> 
> I'm not *seeing* how those changes can cause trouble - unless it's this:
> 
> diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
> index 1840b69..9e19a96 100644
> --- a/drivers/net/wireless/orinoco.c
> +++ b/drivers/net/wireless/orinoco.c
> @@ -3037,7 +3037,7 @@ static int orinoco_ioctl_getessid(struct
>         }
>  
>         erq->flags = 1;
> -       erq->length = strlen(essidbuf) + 1;
> +       erq->length = strlen(essidbuf);

You know what the next question is ;)

Did reverting just that line fix it?

> Does some other code go batshit if length ==0? My current config doesn't
> try to actually ifup the wireless if I also have connectivity via copper (in
> order to avoid chewing up a DHCP lease in crowded address space if not needed).
> 
> % iwconfig eth5
> eth5      IEEE 802.11b  ESSID:""  Nickname:"HERMES I"
>           Mode:Managed  Frequency:2.457 GHz  Access Point: Not-Associated   
>           Bit Rate:11 Mb/s   Sensitivity:1/3  
>           Retry limit:4   RTS thr:off   Fragment thr:off
>           Power Management:off
>           Link Quality=0/92  Signal level=134/153  Noise level=134/153
>           Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
>           Tx excessive retries:0  Invalid misc:0   Missed beacon:0
> 
> That ESSID the source of the trouble?
> 

Might be.  I can't immediately spot a problem with it, but perhaps
length==0 causes the driver to not allocate a buffer and to then write to
the not-allocated buffer.  Not sure..
