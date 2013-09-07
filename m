From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH] bnx2x: avoid atomic allocations during
 initialization
Date: Sat, 7 Sep 2013 01:45:10 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20D90E3D@SJEXCHMB06.corp.ad.broadcom.com>
References: <1378411989-19775-1-git-send-email-mschmidt@redhat.com>
 <20130906.142735.458916282873797040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"mschmidt@redhat.com" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3879 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754Ab3IGBpQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 21:45:16 -0400
In-Reply-To: <20130906.142735.458916282873797040.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: Friday, September 06, 2013 9:28 PM
> To: mschmidt@redhat.com
> Cc: netdev@vger.kernel.org; Ariel Elior; Eilon Greenstein
> Subject: Re: [PATCH] bnx2x: avoid atomic allocations during initialization
> 
> From: Michal Schmidt <mschmidt@redhat.com>
> Date: Thu,  5 Sep 2013 22:13:09 +0200
> 
> > During initialization bnx2x allocates significant amounts of memory
> > (for rx data, rx SGEs, TPA pool) using atomic allocations.
> >
> > I received a report where bnx2x failed to allocate SGEs and it had to
> > fall back to TPA-less operation.
> >
> > Let's use GFP_KERNEL allocations during initialization, which runs in
> > process context. Add gfp_t parameters to functions that are used both
> > in initialization and in the receive path.
> >
> > Use an unlikely branch in bnx2x_frag_alloc() to avoid atomic
> > allocation by netdev_alloc_frag(). The branch is taken several
> > thousands of times during initialization, but then never more. Note
> > that fp->rx_frag_size is never greater than PAGE_SIZE, so
> __get_free_page() can be used here.
> >
> > Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> This change looks good to me, if some Broadcom folks could take a look and
> ACK/NACK that would be great.
>

Michal,

Once you allocated the memory during initialization , you will most probably fail to allocate its replacement during RX handling (on this machine).
This will cause packets to drop continuously (buffers which were allocated at init time will be returned to the ring).

I prefer driver to allow user to receive traffic in non TPA mode, than not receive traffic at all. 

Thanks
Dmitry
 

 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
