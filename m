From: "Jan Beulich" <JBeulich@suse.com>
Subject: RE: [PATCH v2 RESEND] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Tue, 25 Oct 2016 02:22:31 -0600
Message-ID: <580F32670200007800119584@prv-mh.provo.novell.com>
References: <580E40000200007800119234@prv-mh.provo.novell.com>
 <8cc49b57d5d64a439ddc99b94c99f9a3@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
        "Wei Liu" <wei.liu2@citrix.com>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
        "Juergen Gross" <JGross@suse.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Paul Durrant" <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:52925 "EHLO
        prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbcJYIWf (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:5:1>);
        Tue, 25 Oct 2016 04:22:35 -0400
In-Reply-To: <8cc49b57d5d64a439ddc99b94c99f9a3@AMSPEX02CL03.citrite.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 25.10.16 at 09:52, <Paul.Durrant@citrix.com> wrote:
>> From: Jan Beulich [mailto:JBeulich@suse.com]
>> Sent: 24 October 2016 16:08
>> --- 4.9-rc2/drivers/net/xen-netback/xenbus.c
>> +++ 4.9-rc2-xen-netback-prefer-xenbus_scanf/drivers/net/xen-netback/xenbus.c
>> @@ -889,16 +889,16 @@ static int connect_ctrl_ring(struct back
>>  	unsigned int evtchn;
>>  	int err;
>> 
>> -	err = xenbus_gather(XBT_NIL, dev->otherend,
>> -			    "ctrl-ring-ref", "%u", &val, NULL);
>> -	if (err)
>> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
>> +			   "ctrl-ring-ref", "%u", &val);
>> +	if (err <= 0)
> 
> Looking at other uses of xenbus_scanf() in the same code I think the check 
> here should be if (err < 0). It's a nit, since xenbus_scanf() cannot return 0, 
> but it would be better for consistency I think.

Hmm, this goes back to the discussion following from
https://lists.xenproject.org/archives/html/xen-devel/2016-07/msg00678.html
which in fact you had given your R-b back then. I continue to be
of the opinion that callers should not leverage the fact that
xenbus_scanf() can't return zero. They instead should check for
an explicit success indicator (which only positive values are). But
you're the maintainer of the code, so if you now think the same
way David does, I guess I'll have to make the adjustment.

>>  		goto done; /* The frontend does not have a control ring */
>> 
>>  	ring_ref = val;
>> 
>> -	err = xenbus_gather(XBT_NIL, dev->otherend,
>> -			    "event-channel-ctrl", "%u", &val, NULL);
>> -	if (err) {
>> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
>> +			   "event-channel-ctrl", "%u", &val);
>> +	if (err <= 0) {
>>  		xenbus_dev_fatal(dev, err,
>>  				 "reading %s/event-channel-ctrl",
>>  				 dev->otherend);
>> @@ -919,7 +919,7 @@ done:
>>  	return 0;
>> 
>>  fail:
>> -	return err;
>> +	return err ?: -ENODATA;
> 
> I don't think you need this.

If the other change gets made, then indeed this isn't needed.

Jan
