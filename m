From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 17:08:07 +0100
Message-ID: <87wqtlommw.fsf@nemi.mork.no>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
	<CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
	<87d2veot6t.fsf@nemi.mork.no>
	<CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
	<871ubtq47a.fsf@nemi.mork.no>
	<CACVXFVMDNtJOp+8jMOuhCBjrqq-L=jicEJBr_=ErG19Vr+7OGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:33803 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792Ab3CEQJr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 11:09:47 -0500
In-Reply-To: <CACVXFVMDNtJOp+8jMOuhCBjrqq-L=jicEJBr_=ErG19Vr+7OGw@mail.gmail.com>
	(Ming Lei's message of "Tue, 5 Mar 2013 23:29:15 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:

> Yes, USB core will flush any outstanding URBs, but the driver still n=
eed
> to deal with suspend failure carefully, for example, suppose usb_resu=
me()
> is called in suspend failure path, and the submitted URBs are killed
> by USB core later. But after the device is wakeup, and the resume() w=
ill
> do nothing since the suspend count is leaked. So it is what the patch=
es
> are fixing, and it is better to not depend on the default flushing UR=
Bs of
> USB core.

I am starting to wonder why the USB core has combined system suspend an=
d
runtime suspend if we are going to end up with every driver testing
PMSG_IS_AUTO(message) and selecting a completely different code path.

You are right that we will end up with problems if usbnet_resume is
called for a device usbnet hasn't suspended.  But I'd still claim that
is a bug in the USB core, which is the one that decided to ignore the
suspend error and still call resume.

I guess proper error handling here require the USB core to see the
interface driver as dead if it fails to suspend on system suspend, and
do forced rebinding on resume.

I am not going to fight this any longer.  The per-driver
PMSG_IS_AUTO(message) testing is an ugly workround for a core problem,
but they are already all over the place...  Still, please make sure the
drivers all return 0 if they are pretending to suspend. No error code
return if the driver ignores the error.


Bj=C3=B8rn
