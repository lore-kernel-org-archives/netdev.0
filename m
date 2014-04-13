From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking
 send_redirects
Date: Sun, 13 Apr 2014 17:57:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404131746100.1423@ja.home.ssi.bg>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com> <20140408.164356.557108616710530006.davem@davemloft.net> <CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com> <20140408.172343.917107273854891906.davem@davemloft.net>
 <CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com> <alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg> <CAM_iQpXNf9rBCtZ2ipiHr2i2Kk4r0QtewiNC-qW8RzR0ChoWqA@mail.gmail.com> <alpine.LFD.2.11.1404091027460.1435@ja.home.ssi.bg>
 <CAM_iQpWrWgOBkGFBRsqMriDoM4Ph=L_dUNti4wKtBydkdbo+Qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54725 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751413AbaDMO6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2014 10:58:42 -0400
In-Reply-To: <CAM_iQpWrWgOBkGFBRsqMriDoM4Ph=L_dUNti4wKtBydkdbo+Qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 11 Apr 2014, Cong Wang wrote:

> On Wed, Apr 9, 2014 at 1:03 AM, Julian Anastasov <ja@ssi.bg> wrote:
> >
> >         I'm still not sure that it is valid to process
> > input route on loopback device. There is also a case
> > of broadcasts/multicasts that should preserve their local output
> > route while being looped in ip_mc_output(). In this
> > case device is not loopback. I need more time to check
> > the code again...

	It looks like LOOPBACK_IFINDEX is used only for
flowi4_iif. Users can distinguish input from output route
lookups by 'ip rule ... iif lo' matching. This trick works
because the lo interface was never used for input routes.
This is documented in iproute2/doc/ip-cref.tex, look for
'iif NAME' for the ip rules.

	As result, input routes are not expected on loopback.
Not sure if you can configure your setup in different way.
We still can solve it by fixing another problem, read below.

	Considering how flowi_iif is matched in fib_rule_match(),
it is wrong to provide 0 for the flowi4_iif field in
__fib_validate_source(). By this way, users can not match
this reverse flow with 'ip rule ... iif lo'. Of course,
such rules are rarely used.

	There are other places that need to provide
LOOPBACK_IFINDEX instead of 0:

- include/net/flow.h flowi4_init_output()
- net/ipv4/ipmr.c reg_vif_xmit(): skb->skb_iif ? : LOOPBACK_IFINDEX;
- net/ipv4/netfilter/ipt_rpfilter.c rpfilter_mt()

	Simply, flowi4_iif must not contain 0, it does not
look logical to ignore all ip rules with specified iif.

	So, we can implement such changes:

- all places that provide LOOPBACK_IFINDEX to fib_validate_source()
should be changed to provide 0 for oif. By this way the
'dev->ifindex != oif' check will work for your setup.

- then __fib_validate_source() will use:

	-	fl4.flowi4_iif = oif;
	+	fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;

	What we achieve is:

- correct 'ip rule ... iif lo' matching for rp_filter checks

- fib_validate_source() will not call __fib_validate_source()
for loopback interface (when rp_filter is 0).

	By this way we do not add extra check in fib_validate_source(),
it goes in __fib_validate_source. The special semantic for
'lo' is coded at the right place, just for flowi4_iif.

Regards

--
Julian Anastasov <ja@ssi.bg>
