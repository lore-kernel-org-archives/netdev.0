From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2 net] bnx2x: Fix busy_poll vs netpoll
Date: Wed, 15 Apr 2015 04:05:00 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63CF5B1E@AVMB1.qlogic.org>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
	 ,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
	 ,<1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
	 <1429035897.7346.49.camel@edumazet-glaptop2.roam.corp.google.com>,<1429062300.7346.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "bind@enas.net" <bind@enas.net>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"Willem de Bruijn" <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35303 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751232AbbDOEFQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:05:16 -0400
In-Reply-To: <1429062300.7346.64.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  #ifdef CONFIG_NET_RX_BUSY_POLL
> -static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
> +
> +enum bnx2x_fp_state {
> +       BNX2X_STATE_FP_NAPI     = BIT(0), /* NAPI handler owns the queue */
> +
> +       BNX2X_STATE_FP_NAPI_REQ_BIT = 1, /* NAPI would like to own the queue */
> +       BNX2X_STATE_FP_NAPI_REQ = BIT(1),
> +
> +       BNX2X_STATE_FP_POLL_BIT = 2,
> +       BNX2X_STATE_FP_POLL     = BIT(2), /* busy_poll owns the queue */
> +
> +       BNX2X_STATE_FP_DISABLE_BIT = 3, /* queue is dismantled */
> +};

...

> /* called from the device poll routine to get ownership of a FP */
> static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
>  {
> +       unsigned long prev, old = READ_ONCE(fp->busy_poll_state);
> +
> +       while (1) {
> +               switch (old) {
> +               case BNX2X_STATE_FP_POLL:
> +                       /* make sure bnx2x_fp_lock_poll() wont starve us */
> +                       set_bit(BNX2X_STATE_FP_NAPI_REQ_BIT,
> +                               &fp->busy_poll_state);
> +                       /* fallthrough */
> +               case BNX2X_STATE_FP_POLL | BNX2X_STATE_FP_NAPI_REQ:
> +                       return false;
> +               default:
> +                       break;
> +               }
> +               prev = cmpxchg(&fp->busy_poll_state, old, BNX2X_STATE_FP_NAPI);

Wouldn't this override the disabled status? Shouldn't we return 'false'
if BNX2X_STATE_FP_DISABLE_BIT is set?

> +               if (unlikely(prev != old)) {
> +                       old = prev;
> +                       continue;
> +               }
> +               return true;
>       }
>  }

BTW, this looks quite generic - isn't it possible to take it out of the
driver and push it into the networking core, uniforming it in the process?
