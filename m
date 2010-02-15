From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Mon, 15 Feb 2010 09:32:33 +0200
Message-ID: <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com>
References: <20100214144415.GA8115@x200>
	 <20100215001849.GB15437@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f201.google.com ([209.85.223.201]:53831 "EHLO
	mail-iw0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782Ab0BOHcf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 02:32:35 -0500
Received: by iwn39 with SMTP id 39so1921539iwn.1
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2010 23:32:34 -0800 (PST)
In-Reply-To: <20100215001849.GB15437@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 2:18 AM, Herbert Xu <herbert@gondor.apana.org.a=
u> wrote:
> On Sun, Feb 14, 2010 at 04:44:15PM +0200, Alexey Dobriyan wrote:
>> Consider using ipcomp with tunnel mode:
>>
>> =A0 =A0 =A0 pfkey_add -> xfrm_state_init -> x->type->init_state() =3D=
=3D ipcomp4_init_state
>>
>> 1. If ipcomp_tunnel_attach() fails, xfrm_state private data (x->data=
) are freed
>> =A0 =A0first time (synchronously), but stale pointer is left.
>> 2. xfrm_state_init() failed, all right, we're going to do error unwi=
nd
>> =A0 =A0but this time asynchronously and we're going to double free x=
->data
>> =A0 =A0asynchronously.
>
> Sorry, I don't see the async path, where is it?

pfkey_add
pfkey_msg2xfrm_state
xfrm_init_state         [fails]
xfrm_state_put
__xfrm_state_destroy    [puts xfrm_state into GC list, schedule work]
xfrm_state_gc_task
xfrm_state_gc_destroy
x->type->destructor
