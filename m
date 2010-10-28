From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Thu, 28 Oct 2010 11:33:56 -0700
Message-ID: <AANLkTinq5iYU3A41vLHLLWVpoS-A4mB-RYrrWYCGKk+-@mail.gmail.com>
References: <20101028.112231.232747062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59362 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761242Ab0J1SfJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 14:35:09 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9SIYJl4024377
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 11:34:19 -0700
Received: by iwn10 with SMTP id 10so2656894iwn.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 11:34:19 -0700 (PDT)
In-Reply-To: <20101028.112231.232747062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 11:22 AM, David Miller <davem@davemloft.net> wr=
ote:
>
> - =A0 =A0 =A0 int tot_len =3D 0;
> + =A0 =A0 =A0 size_t tot_len =3D 0;

I would actually keep "tot_len" as an "int".

The whole point of this:

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len > INT_MAX - tot_len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D INT_MAX - tot_l=
en;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tot_len +=3D len;

Is that "tot_len" can _never_ become larger than INT_MAX, because we
never add a "len" that would make it bigger than that.

So "len" itself should be the correct unsigned size_t (so that the
"len > INT_MAX - tot_len" thing is done as an unsigned comparison),
but "tot_len" itself is very much designed to fit in "int".

> +int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockadd=
r *address, int mode)
> =A0{
> =A0 =A0 =A0 =A0int size, ct;
> - =A0 =A0 =A0 long err;
> + =A0 =A0 =A0 size_t err;

Same thing here. Making "err" be an "int" is actually the right thing
to do, because then it matches the return type (iow, if it was any
other type, there would be an implicit cast, and if it didn't fit in
"int", that would be a bug anyway).

                     Linus
