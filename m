From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 0/3] xen-netback: switch to NAPI + kthread 1:1
 model
Date: Wed, 28 Aug 2013 10:01:35 +0100
Message-ID: <20130828090135.GC15729@zion.uk.xensource.com>
References: <1377518379-26503-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <ian.campbell@citrix.com>,
	<msw@amazon.com>, <konrad.wilk@oracle.com>, <annie.li@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24177 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482Ab3H1JBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 05:01:37 -0400
Content-Disposition: inline
In-Reply-To: <1377518379-26503-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, ping.

This series has been acked by maintainer. If there is no objection we
would like to see it in.

Thanks
Wei.

On Mon, Aug 26, 2013 at 12:59:36PM +0100, Wei Liu wrote:
> This series implements NAPI + kthread 1:1 model for Xen netback.
> 
> This model
>  - provides better scheduling fairness among vifs
>  - is prerequisite for implementing multiqueue for Xen network driver
> 
> The second patch has the real meat:
>  - make use of NAPI to mitigate interrupt
>  - kthreads are not bound to CPUs any more, so that we can take
>    advantage of backend scheduler and trust it to do the right thing
> 
> Benchmark is done on a Dell T3400 workstation with 4 cores, running 4
> DomUs. Netserver runs in Dom0. DomUs do netperf to Dom0 with
> following command: /root/netperf -H Dom0 -fm -l120
> 
> IRQs are distributed to 4 cores by hand in the new model, while in the
> old model vifs are automatically distributed to 4 kthreads.
> 
> * New model
> %Cpu0  :  0.5 us, 20.3 sy,  0.0 ni, 28.9 id,  0.0 wa,  0.0 hi, 24.4 si, 25.9 st
> %Cpu1  :  0.5 us, 17.8 sy,  0.0 ni, 28.8 id,  0.0 wa,  0.0 hi, 27.7 si, 25.1 st
> %Cpu2  :  0.5 us, 18.8 sy,  0.0 ni, 30.7 id,  0.0 wa,  0.0 hi, 22.9 si, 27.1 st
> %Cpu3  :  0.0 us, 20.1 sy,  0.0 ni, 30.4 id,  0.0 wa,  0.0 hi, 22.7 si, 26.8 st
> Throughputs: 2027.89 2025.95 2018.57 2016.23 aggregated: 8088.64
> 
> * Old model
> %Cpu0  :  0.5 us, 68.8 sy,  0.0 ni, 16.1 id,  0.5 wa,  0.0 hi,  2.8 si, 11.5 st
> %Cpu1  :  0.4 us, 45.1 sy,  0.0 ni, 31.1 id,  0.4 wa,  0.0 hi,  2.1 si, 20.9 st
> %Cpu2  :  0.9 us, 44.8 sy,  0.0 ni, 30.9 id,  0.0 wa,  0.0 hi,  1.3 si, 22.2 st
> %Cpu3  :  0.8 us, 46.4 sy,  0.0 ni, 28.3 id,  1.3 wa,  0.0 hi,  2.1 si, 21.1 st
> Throughputs: 1899.14 2280.43 1963.33 1893.47 aggregated: 8036.37
> 
> We can see that the impact is mainly on CPU usage. The new model moves
> processing from kthread to NAPI (software interrupt).
> 
> Wei Liu (3):
>   xen-netback: remove page tracking facility
>   xen-netback: switch to NAPI + kthread 1:1 model
>   xen-netback: rename functions
> 
>  drivers/net/xen-netback/common.h    |  150 +++++--
>  drivers/net/xen-netback/interface.c |  135 ++++--
>  drivers/net/xen-netback/netback.c   |  833 +++++++++++------------------------
>  3 files changed, 445 insertions(+), 673 deletions(-)
> 
> -- 
> 1.7.10.4
