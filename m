From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net-next 1/1] tcp: sysctl: Fix a race to avoid unexpected 0 window from space
Date: Sat, 25 Mar 2017 11:32:12 +0800
Message-ID: <000501d2a518$64719850$2d54c8f0$@foxmail.com>
References: <1490310312-20661-1-git-send-email-gfree.wind@foxmail.com> <20170324133147.55d2ea3a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        "'Gao Feng'" <fgao@ikuai8.com>
To: "'Stephen Hemminger'" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau1.qq.com ([54.206.16.166]:47884 "EHLO smtpbgau1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966014AbdCYDcU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 23:32:20 -0400
In-Reply-To: <20170324133147.55d2ea3a@xeon-e3>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Stephen Hemminger
> Sent: Saturday, March 25, 2017 4:32 AM
> To: gfree.wind@foxmail.com
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Gao Feng
> <fgao@ikuai8.com>
> Subject: Re: [PATCH net-next 1/1] tcp: sysctl: Fix a race to avoid
unexpected 0
> window from space
> 
> On Fri, 24 Mar 2017 07:05:12 +0800
> gfree.wind@foxmail.com wrote:
> 
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > Because sysctl_tcp_adv_win_scale could be changed any time, so there
> > is one race in tcp_win_from_space.
> > For example,
> > 1.sysctl_tcp_adv_win_scale<=0 (sysctl_tcp_adv_win_scale is negative
> > now)
> > 2.space>>(-sysctl_tcp_adv_win_scale) (sysctl_tcp_adv_win_scale is
> > postive now)
> >
> > As a result, tcp_win_from_space returns 0. It is unexpected.
> >
> > Certainly if the compiler put the sysctl_tcp_adv_win_scale into one
> > register firstly, then use the register directly, it would be ok.
> > But we could not depend on the compiler behavior.
> >
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> > ---
> >  include/net/tcp.h | 8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/net/tcp.h b/include/net/tcp.h index
> > 6ec4ea6..119b592 100644
> > --- a/include/net/tcp.h
> > +++ b/include/net/tcp.h
> > @@ -1252,9 +1252,11 @@ void tcp_select_initial_window(int __space,
> > __u32 mss, __u32 *rcv_wnd,
> >
> >  static inline int tcp_win_from_space(int space)  {
> > -	return sysctl_tcp_adv_win_scale<=0 ?
> > -		(space>>(-sysctl_tcp_adv_win_scale)) :
> > -		space - (space>>sysctl_tcp_adv_win_scale);
> > +	int tcp_adv_win_scale = sysctl_tcp_adv_win_scale;
> > +
> > +	return tcp_adv_win_scale <= 0 ?
> > +		(space>>(-tcp_adv_win_scale)) :
> > +		space - (space>>tcp_adv_win_scale);
> >  }
> >
> >  /* Note: caller must be prepared to deal with negative returns */
> 
> You need to use READ_ONCE() to be safe. The compiler is free to optimized
the
> code back to the original unless READ_ONCE() is used.

Thanks your reminder.
I could not figure out why compiler would do the optimization, rollback the
global variable instead of local tmp variable.
It breaks the original logic.

BTW, I think the READ_ONCE is used to avoid reorder. 
Could you give some guides please ?

Best Regards
Feng
