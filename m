From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: =?utf-8?Q?net=2Fnetfilter=2Fnf=5Fconnt?=
	=?utf-8?B?cmFja19wcm90b190Y3AuYzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZf?=
	=?utf-8?B?cHJvdG9fbmV04oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYdXNlcuKAmQ==?=
Date: Tue, 12 Jun 2012 18:03:04 +0200
Message-ID: <20120612160304.GA31427@1984>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
 <20120611221521.GA27239@1984>
 <20120611.152344.1072167705198124284.davem@davemloft.net>
 <20120612002655.GA28155@1984>
 <4FD69F5E.3060900@cn.fujitsu.com>
 <20120612092940.GB30080@1984>
 <4FD72203.9090005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wfg@linux.intel.com,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60074 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab2FLQDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 12:03:12 -0400
Content-Disposition: inline
In-Reply-To: <4FD72203.9090005@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 12, 2012 at 07:03:31PM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8812=E6=97=A5 17:29, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
>=20
> >> nf_proto_net.users has different meaning when SYSCTL enabled or di=
sabled.
> >>
> >> when SYSCTL enabled,it means if both tcpv4 and tcpv6 register the =
sysctl,
> >> it is increased when register sysctl success and decreased when un=
register sysctl.
> >> we can regard it as the refcnt of ctl_table.
> >>
> >> when SYSCTL disabled,it just used to identify if the proto's perne=
t data
> >> has been initialized.
> >=20
> > We have to use two different counters for this. The conditional
> > meaning of that variable is really confusing.
> >=20
> Hi David & Pablo
>=20
> Please have a look at this patch and tell me if it's OK.
> it base on Pable's patch.

I think we have to merge those tcpv4_init_net and tcpv6_init_net
functions into one single function tcp_init_net. Then, we can pass
l4proto->l3proto to init_net:

        if (proto->init_net) {
                ret =3D proto->init_net(net, l4proto->l3proto);
                if (ret < 0)
                        return ret;
        }

Thus, we can check if this is IPv4 or IPv6 and initialize the compat
part accordingly.

Still, we have that pn->users thing:

        if (!pn->users++) {
                for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
                        tn->timeouts[i] =3D tcp_timeouts[i];

                tn->tcp_loose =3D nf_ct_tcp_loose;
                tn->tcp_be_liberal =3D nf_ct_tcp_be_liberal;
                tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
        }

Define some pn->initialized boolean. Set it to true at the end of
the new tcp_init_net.

Similar thing for other protocol trackers.

Let me know if you are going to send me patches. In that case, please
do it on top of the current tree.

Once that has been cleaned up, we can prepare follow-up patches to
move the sysctl code to nf_conntrack_proto_*_sysctl.c to reduce the
ifdef pollution.
