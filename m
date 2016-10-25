From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH v2 RESEND] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Tue, 25 Oct 2016 07:52:39 +0000
Message-ID: <8cc49b57d5d64a439ddc99b94c99f9a3@AMSPEX02CL03.citrite.net>
References: <580E40000200007800119234@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Vrabel <david.vrabel@citrix.com>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
        Juergen Gross <JGross@suse.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:20573 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758567AbcJYHwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 03:52:43 -0400
In-Reply-To: <580E40000200007800119234@prv-mh.provo.novell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jan Beulich [mailto:JBeulich@suse.com]
> Sent: 24 October 2016 16:08
> To: Paul Durrant <Paul.Durrant@citrix.com>; Wei Liu <wei.liu2@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>; xen-devel@lists.xenproject.org;
> boris.ostrovsky@oracle.com; Juergen Gross <JGross@suse.com>;
> netdev@vger.kernel.org
> Subject: [PATCH v2 RESEND] xen-netback: prefer xenbus_scanf() over
> xenbus_gather()
> 
> For single items being collected this should be preferred as being more
> typesafe (as the compiler can check format string and to-be-written-to
> variable match) and more efficient (requiring one less parameter to be
> passed).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> ---
> v2: Avoid commit message to continue from subject.
> ---
>  drivers/net/xen-netback/xenbus.c |   14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> --- 4.9-rc2/drivers/net/xen-netback/xenbus.c
> +++ 4.9-rc2-xen-netback-prefer-xenbus_scanf/drivers/net/xen-
> netback/xenbus.c
> @@ -889,16 +889,16 @@ static int connect_ctrl_ring(struct back
>  	unsigned int evtchn;
>  	int err;
> 
> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> -			    "ctrl-ring-ref", "%u", &val, NULL);
> -	if (err)
> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> +			   "ctrl-ring-ref", "%u", &val);
> +	if (err <= 0)

Looking at other uses of xenbus_scanf() in the same code I think the check here should be if (err < 0). It's a nit, since xenbus_scanf() cannot return 0, but it would be better for consistency I think.

>  		goto done; /* The frontend does not have a control ring */
> 
>  	ring_ref = val;
> 
> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> -			    "event-channel-ctrl", "%u", &val, NULL);
> -	if (err) {
> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> +			   "event-channel-ctrl", "%u", &val);
> +	if (err <= 0) {
>  		xenbus_dev_fatal(dev, err,
>  				 "reading %s/event-channel-ctrl",
>  				 dev->otherend);
> @@ -919,7 +919,7 @@ done:
>  	return 0;
> 
>  fail:
> -	return err;
> +	return err ?: -ENODATA;

I don't think you need this.

  Paul

>  }
> 
>  static void connect(struct backend_info *be)
> 
> 
