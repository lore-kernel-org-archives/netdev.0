From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Mon, 18 Mar 2013 13:36:21 -0700
Message-ID: <CAHo-Ooz2W_jcbbOFLvihf+N-6fVSNoj0jGKTT8AXoOSC3_3DRg@mail.gmail.com>
References: <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
	<CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
	<1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130318.131318.138158829629301794.davem@davemloft.net>
	<CAHo-OoxaaLLXtAZcx99m7p5=Hez3gpUWxvoQAgksyG3PRZH-Ng@mail.gmail.com>
	<CAHo-OowoWD_BT2W8ok32pcSmcshXttpErna-X92Ojz_A8es8iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eilong@broadcom.com, eric.dumazet@gmail.com, dmitry@broadcom.com,
	netdev@vger.kernel.org, yuvalmin@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f182.google.com ([209.85.128.182]:39896 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3CRUgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 16:36:23 -0400
Received: by mail-ve0-f182.google.com with SMTP id ox1so4750470veb.41
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 13:36:21 -0700 (PDT)
In-Reply-To: <CAHo-OowoWD_BT2W8ok32pcSmcshXttpErna-X92Ojz_A8es8iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not quite the right call sequence above.
  UPDATE_FSTAT_QSTAT(total_bytes_received); --> SUB_64 --> DIFF_64
is probably more relevant.

Regardless:

/* difference = minuend - subtrahend */
#define DIFF_64(d_hi, m_hi, s_hi, d_lo, m_lo, s_lo) \
<------>do { \
<------><------>if (m_lo < s_lo) { \
<------><------><------>/* underflow */ \
<------><------><------>d_hi = m_hi - s_hi; \
<------><------><------>if (d_hi > 0) { \
<------><------><------><------>/* we can 'loan' 1 */ \
<------><------><------><------>d_hi--; \
<------><------><------><------>d_lo = m_lo + (UINT_MAX - s_lo) + 1; \
<------><------><------>} else { \
<------><------><------><------>/* m_hi <= s_hi */ \
<------><------><------><------>d_hi = 0; \
<------><------><------><------>d_lo = 0; \
<------><------><------>} \
<------><------>} else { \
...
I believe this fails.  All parameters are most likely going to be u32,
since that's used for stats pretty much everywhere.
As such after d_hi = m_hi - s_hi;  d_hi will be >= 0 since it's u32.

As such if "m_hi == s_hi" && "m_lo < s_lo" we will return (0,0)
however if "m_hi < s_hi" && "m_lo < s_lo" we will not return (0,0)

I'm not sure which behaviour is desired, but either way this is obviously wrong.

0 - 1 returns 0
0 - (4GB+1) returns -4GB-1
