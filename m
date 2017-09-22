From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next 2/2] ifb: add device MTU validation check
Date: Fri, 22 Sep 2017 11:35:28 +0800
Message-ID: <00b501d33353$d6888650$839992f0$@cmss.chinamobile.com>
References: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>       <1506000722-40095-3-git-send-email-zhangshengju@cmss.chinamobile.com> <20170921081010.4d6f5731@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <willemb@google.com>,
        <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:57440 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdIVDfd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 23:35:33 -0400
In-Reply-To: <20170921081010.4d6f5731@xeon-e3>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: 2017Äê9ÔÂ21ÈÕ 23:10
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Cc: davem@davemloft.net; willemb@google.com; netdev@vger.kernel.org
> Subject: Re: [net-next 2/2] ifb: add device MTU validation check
> 
> On Thu, 21 Sep 2017 21:32:02 +0800
> Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:
> 
> > Currently, any mtu value can be assigned when adding a new ifb device:
> > [~]# ip link add name ifb2 mtu 100000 type ifb [~]# ip link show ifb2
> > 18: ifb2: <BROADCAST,NOARP> mtu 100000 qdisc noop state DOWN mode
> DEFAULT group default qlen 32
> >     link/ether 7a:bf:f4:63:da:d1 brd ff:ff:ff:ff:ff:ff
> >
> > This patch adds device MTU validation check.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  drivers/net/ifb.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> >
> > diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c index
> > 8870bd2..ce84ad2 100644
> > --- a/drivers/net/ifb.c
> > +++ b/drivers/net/ifb.c
> > @@ -282,6 +282,14 @@ static int ifb_validate(struct nlattr *tb[], struct
> nlattr *data[],
> >  		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
> >  			return -EADDRNOTAVAIL;
> >  	}
> > +
> > +	if (tb[IFLA_MTU]) {
> > +		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
> > +
> > +		if (mtu < ETH_MIN_MTU || mtu > ETH_DATA_LEN)
> > +			return -EINVAL;
> > +	}
> > +
> >  	return 0;
> >  }
> >
> 
> What about running ifb with packets coming from devices with jumbo frames?
> Also since ifb is an input only device, MTU doesn't matter.

Actually ifb_setup() function setup ifb valid MTU range: [68, 1500], and
this will be check at dev_set_mtu() function. 
You can't setup mtu out of this range after creation, but you can set any
value when adding new ifb device.
This is inconsistent, and I think we should add this check at creation time 

BRs,
ZSJ
