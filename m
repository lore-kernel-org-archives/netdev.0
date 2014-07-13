From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 1/1] net: ppp: don't call sk_chk_filter twice
Date: Sun, 13 Jul 2014 19:07:32 +0200
Message-ID: <CAADnVQJ8cBaROGee3osvK5maEmVjfU0ubv8-MXRAKqWQPcKRjA@mail.gmail.com>
References: <53C28335.9090902@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Christoph Schulz <develop@kristov.de>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <53C28335.9090902@kristov.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 13, 2014 at 3:01 PM, Christoph Schulz <develop@kristov.de> wrote:
> From: Christoph Schulz <develop@kristov.de>
>
> Commit 568f194e8bd16c353ad50f9ab95d98b20578a39d ("net: ppp: use
> sk_unattached_filter api") causes sk_chk_filter() to be called twice when
> setting a PPP pass or active filter. This applies to both the generic PPP
> subsystem implemented by drivers/net/ppp/ppp_generic.c and the ISDN PPP
> subsystem implemented by drivers/isdn/i4l/isdn_ppp.c. The first call is from
> within get_filter(). The second one is through the call chain
>
>   ppp_ioctl() or isdn_ppp_ioctl()
>   --> sk_unattached_filter_create()
>       --> __sk_prepare_filter()
>           --> sk_chk_filter()
>
> The first call from within get_filter() should be deleted as get_filter() is
> called just before calling sk_unattached_filter_create() later on, which
> eventually calls sk_chk_filter() anyway.
>
> For 3.15.x, this proposed change is a bugfix rather than a pure optimization as
> in that branch, sk_chk_filter() may replace filter codes by other codes which
> are not recognized when executing sk_chk_filter() a second time. So with
> 3.15.x, if sk_chk_filter() is called twice, the second invocation may yield
> EINVAL (this depends on the filter codes found in the filter to be set, but
> because the replacement is done for frequently used codes, this is almost
> always the case). The net effect is that setting pass and/or active PPP filters
> does not work anymore, since sk_unattached_filter_create() always returns
> EINVAL due to the second call to sk_chk_filter(), regardless whether the filter
> was originally sane or not.
>
> Signed-off-by: Christoph Schulz <develop@kristov.de>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Thank you for fixing it.
