From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH] b44: properly use pr_fmt()
Date: Thu, 26 Apr 2012 05:23:13 -0700
Message-ID: <CAB=NE6WBw3aJrch0JvxZ7jGb_rFW5Z4XWvYc1KqsBqBu+G8mjw@mail.gmail.com>
References: <1335235603-32420-1-git-send-email-mcgrof@do-not-panic.com> <20120424.004745.1479792296922367681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:52217 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220Ab2DZMXe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 08:23:34 -0400
In-Reply-To: <20120424.004745.1479792296922367681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 23, 2012 at 9:47 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
> Date: Mon, 23 Apr 2012 19:46:43 -0700
>
>> From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
>>
>> pr_fmt() is either defined or we redefine it. Typically
>> drivers define it prior to including printk.h but this
>> is done under the assumption that no other subsystem
>> it uses has already defined pr_fmt(). In such cases
>> pr_fmt() should be undefined and redefined.
>>
>> Doing this properly shaves down compilation time quite
>> considerably.
>>
>> Signed-off-by: Luis R. Rodriguez <mcgrof@do-not-panic.com>
>
> Every driver defines pr_fmt then includes the headers. =C2=A0I do not
> see any other place which performs the initial undef of pr_fmt
> like you want to start doing here.

One example is, and that is where I got the hint:

drivers/net/wireless/mwifiex/decl.h

> If there is a reason we should start doing this, it would appear
> to be a universal reason, not one specific to this driver.

Sure.

> If that's the case, we should formally agree to this and then work
> on gradually converting all the drivers in reasonably sized chunks.

Understood.

> Either way I can't apply this patch as-is, sorry Luis.

So the issue can occur if any parent header ends up defining this,
this could happen if a subsystem wants to define the pr_fmt in their
own header and a driver for example wants to override this. In theory
this does not occur but in practice this may vary and if we want to
ensure this does not happen perhaps the thing to do is to document
this as such.

I just tested allmodconfig though and checked compilation for V=3D1
against drivers/net/wireless/ and found no issues against linux-next
though so in practice at least for wireless networking it seems we are
squeaky clean in its usage. I'll test across the kernel though next to
see if there are any real violators of the assumption. Unfortunately
I've hit an issue with compiling allmodconfig already with linux-next
that is already reported so my homework will be to find a shiny
linux-next to compile test against allmodconfig.

An area that this does clearly happen but that likely does not merit
and upstream change for is in the backport work compat that defines
this for older kernels and later we have to also backport users of
pr_fmt such as pr_emerg_once. Ultimately drivers will want to actually
then override this and in that case the undef is necessary as
otherwise you get the redefinition warning which incurs in practice a
considerable CPU performance hit at compilation time.

  Luis
