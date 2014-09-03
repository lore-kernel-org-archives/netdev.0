From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net v2] tg3: prevent ifup/ifdown during PCI error
 recovery
Date: Wed, 3 Sep 2014 16:25:50 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B3174D@avmb3.qlogic.org>
References: <1409574117-19435-1-git-send-email-ivecera@redhat.com>
 <20140902.130234.1386697848957363743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"prashant@broadcom.com" <prashant@broadcom.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>,
	"ivecera@redhat.com" <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60842 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756264AbaICQZz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 12:25:55 -0400
In-Reply-To: <20140902.130234.1386697848957363743.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The patch fixes race conditions between PCI error recovery callbacks
> > and potential ifup/ifdown.
> >
> > First, if ifup (tg3_open) is called between tg3_io_error_detected()
> > and
> > tg3_io_resume() then tp->timer is armed twice before expiry. Once
> > during
> > tg3_open() and again during tg3_io_resume(). This results in BUG at
> > kernel/time/timer.c:945.
> >
> > Second, if ifdown (tg3_close) is called between
> > tg3_io_error_detected() and tg3_io_resume() then tg3_napi_disable() is
> > called twice without a tg3_napi_enable between. Once during
> > tg3_io_error_detected() and again during tg3_close(). The tg3_io_resume()
> then hangs on rtnl_lock().

Hi, sorry for the late response but just seen this patch.
This sounds like a general problem, i.e., one that could affect multiple drivers
[Not exactly the same issue, but a similar one].

PCI error recovery flows are bad enough without the netdevice transitioning
its state in-between the PCI callbacks.
Perhaps we should consider some general solution, e.g., preventing state
transitions during such a flow [i.e., until the PCI error recovery fully completes]?

> >
> > v2: Added logging messages per Prashant's request
> >
> > Cc: Prashant Sreedharan <prashant@broadcom.com>
> > Cc: Michael Chan <mchan@broadcom.com>
> >
> > Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> 
> Applied, thanks.
