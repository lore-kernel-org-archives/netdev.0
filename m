From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Sun, 17 Mar 2013 16:17:31 -0700
Message-ID: <1363562251.29475.109.camel@edumazet-glaptop>
References: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
	 <1363384577-21287-1-git-send-email-zenczykowski@gmail.com>
	 <504C9EFCA2D0054393414C9CB605C37F20BE6A2B@SJEXCHMB06.corp.ad.broadcom.com>
	 <20130317.142425.1713640249735424829.davem@davemloft.net>
	 <1363549074.4752.3.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1363551952.29475.93.camel@edumazet-glaptop>
	 <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dmitry@broadcom.com,
	zenczykowski@gmail.com, maze@google.com, netdev@vger.kernel.org,
	yuvalmin@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:43676 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529Ab3CQXRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 19:17:34 -0400
Received: by mail-da0-f47.google.com with SMTP id s35so961243dak.34
        for <netdev@vger.kernel.org>; Sun, 17 Mar 2013 16:17:33 -0700 (PDT)
In-Reply-To: <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-17 at 22:53 +0200, Eilon Greenstein wrote:

> This is not such a trivial issue - the HW/FW is guaranteeing the atomic
> read and this is why we can always use 32b variables.
> 

I am glad you qualify the following code as 'trivial'

/* difference = minuend - subtrahend */
#define DIFF_64(d_hi, m_hi, s_hi, d_lo, m_lo, s_lo) \
        do { \
                if (m_lo < s_lo) { \
                        /* underflow */ \
                        d_hi = m_hi - s_hi; \
                        if (d_hi > 0) { \
                                /* we can 'loan' 1 */ \
                                d_hi--; \
                                d_lo = m_lo + (UINT_MAX - s_lo) + 1; \
                        } else { \
                                /* m_hi <= s_hi */ \
                                d_hi = 0; \
                                d_lo = 0; \
                        } \
                } else { \
                        /* m_lo >= s_lo */ \
                        if (m_hi < s_hi) { \
                                d_hi = 0; \
                                d_lo = 0; \
                        } else { \
                                /* m_hi >= s_hi */ \
                                d_hi = m_hi - s_hi; \
                                d_lo = m_lo - s_lo; \
                        } \
                } \
        } while (0)


All the macros and _hi/_ho fields found in
drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
are really badly designed.

It hurts so much the common sense its not even funny.

All you really needed is to have normal host structures containing u64
fields, and you only needed one single helper to convert from hw u32:u32
to host u64.

Because gcc handles u64 operations very well, even on 32bit hosts, and
it knows about the carry flag.
