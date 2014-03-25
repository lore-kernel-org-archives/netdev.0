From: Wei Liu <liuw@liuw.name>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: disable rogue vif in kthread context
Date: Tue, 25 Mar 2014 00:44:41 +0000
Message-ID: <CAOsiSVWtsx7XiyF8Z+jN7vPzmXG+aAXq3xQsvW3dDDiZ5Hc24A@mail.gmail.com>
References: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com> <20140324.152945.1082990562317636743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	edwin@etorok.net,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Paul Durrant <paul.durrant@citrix.com>, zoltan.kiss@citrix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:41833 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbaCYApN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 20:45:13 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so110255wiw.12
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 17:45:11 -0700 (PDT)
In-Reply-To: <20140324.152945.1082990562317636743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 7:29 PM, David Miller <davem@davemloft.net> wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Mon, 24 Mar 2014 12:13:34 +0000
>
>> @@ -62,6 +62,13 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>>       struct xenvif *vif = container_of(napi, struct xenvif, napi);
>>       int work_done;
>>
>> +     /* This vif is rogue, we pretend we've used up all budget to
>> +      * deschedule it from NAPI. But this interface will be turned
>> +      * off in thread context later.
>> +      */
>> +     if (unlikely(vif->disabled))
>> +             return budget;
>> +
>
> As mentioned by others, this makes NAPI poll forever.
>
> The following comment was referenced:
>
>                 /* Drivers must not modify the NAPI state if they
>                  * consume the entire weight.  In such cases this code
>                  * still "owns" the NAPI instance and therefore can
>                  * move the instance around on the list at-will.
>                  */
>                 if (unlikely(work == weight)) {
>
> WHICH MEANS, if you return that you used the full budget, the NAPI instance
> is still owned by the core.
>
> Why?  Becuase if you used the entire budget, it's going to put you back onto
> the polling list and invoke you again some time soon.
>
> If the interface is disabled, you should return zero from the poll and do a
> NAPI completion.
>

Yes, you're right. I made a mistake in using the budget the other way around.

Wei.

> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
