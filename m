From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH] ipip, sit: fix ipv4_{update_pmtu,redirect} calls
Date: Sat, 7 Jun 2014 19:54:12 +0400
Message-ID: <20140607195412.94b079a97a6e1452e539037f@qrator.net>
References: <20140606231921.2ff39106ac54216fd9170fae@qrator.net>
	<CAHA+R7NUVPz47AKCTk7nYBkZXK=93vJOO8f6FTkyU0UkU6Q30Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Fan Du <fan.du@windriver.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	trivial@kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7NUVPz47AKCTk7nYBkZXK=93vJOO8f6FTkyU0UkU6Q30Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 6 Jun 2014 17:45:44 -0700
Cong Wang <cwang@twopensource.com> wrote:

> I think vti (v4 and v6) tunnel needs to fix as well?

1) vti:
Well, probably it needs a fix, but:
a) I don't know a scenario when vti4_err would be called, ah4/esp4/ipcomp4
should handle icmp errors. vti_err was removed in aba826958830 but (don't know
why, maybe someone can explain?) vti4_err was introduced back in df3893c176e9.
b) vti uses complex routing through xfrm, see pt. 2).

2) ah4/esp/ipcomp:
They probably have a problem with ipv4_{update_pmtu,redirect} too, because
ah4/esp/ipcomp use xfrm policies for correct routing, but ipv4_{update_pmtu,
redirect} implementation do not xfrm_lookup. Moreover, the whole 
ipv4_*_{update_pmtu, redirect} family looks like using __ip_route_output_key 
which doesn't do xfrm_lookup, except ipv4_sk_update_pmtu which does it through
ip_route_output_flow. I also do not understand ideas behind it, but I am not
so familiar with xfrm stuff, so feel free to correct me.
Also ah4/esp/ipcomp use oif=0 for ipv4_{update_pmtu,redirect} which should work 
well with most setups (and wrong oif !=0 like in ipip/sit doesn't work), so I
don't think it's a big problem.

3) gre:
There are 2 gre protocols in kernel: pptp(drivers/net/ppp/pptp.c) and 
cisco/ipgre(net/ipv4/gre_demux.c).
Pptp simply ignores ICMP errors, I'd simply let it be. 
ipgre is a framework for subprotos which doesn't work with tunnel devices by
itself (see net/ipv4/gre_demux.c:gre_cisco_err). Although it uses 
skb->dev->ifindex for ipv4_{update_pmtu,redirect} which might be wrong for hosts
with asymmetric routing, this is not a big deal, because tunnels bound to device 
will not work with asymmetric routing anyway. So I think it is okay.
