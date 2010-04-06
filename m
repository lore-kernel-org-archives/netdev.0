From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: Re: [Bugme-new] [Bug 15682] New: XFRM is not updating RTAX_ADVMSS
	metric
Date: Tue, 6 Apr 2010 16:02:12 -0300
Message-ID: <y2jb7b22e81004061202uac6ef8eeodc70d6deb65f7699@mail.gmail.com>
References: <bug-15682-10286@https.bugzilla.kernel.org/>
	 <20100405125055.cdc1e279.akpm@linux-foundation.org>
	 <1270561240.7198.3.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:64286 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab0DFTCO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 15:02:14 -0400
Received: by fxm27 with SMTP id 27so242974fxm.28
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 12:02:12 -0700 (PDT)
In-Reply-To: <1270561240.7198.3.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My intention is only to report a problem that I have faced. The
solution proposed isn't (I know that) probably the best one to adopt
as I'm not a kernel specialist, it is more illustrative to allow you
guys understanding what I'm meaning and solve that on the better way
(hence I haven't submited a patch).

Regards,
Eduardo Panisset.

On Tue, Apr 6, 2010 at 10:40 AM, jamal <hadi@cyberus.ca> wrote:
>
> Herbert would give better answers. I dont think what Eduardo is
> doing is correct. You cant just start factoring in tcp headers
> at the xfrm level - and besides, the mtu calculation
> already takes care tunnel headers - so tcp should be able to
> compute correct MSS.
>
> cheers,
> jamal
>
> On Mon, 2010-04-05 at 12:50 -0700, Andrew Morton wrote:
>> (switched to email. =A0Please respond via emailed reply-to-all, not =
via the
>> bugzilla web interface).
>>
>> On Fri, 2 Apr 2010 17:34:35 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>> > https://bugzilla.kernel.org/show_bug.cgi?id=3D15682
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0Summary: XFRM is not updating RTAX_ADVMSS m=
etric
>> > =A0 =A0 =A0 =A0 =A0 =A0Product: Networking
>> > =A0 =A0 =A0 =A0 =A0 =A0Version: 2.5
>> > =A0 =A0 Kernel Version: 2.6.28-2
>> > =A0 =A0 =A0 =A0 =A0 Platform: All
>> > =A0 =A0 =A0 =A0 OS/Version: Linux
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 Tree: Mainline
>> > =A0 =A0 =A0 =A0 =A0 =A0 Status: NEW
>> > =A0 =A0 =A0 =A0 =A0 Severity: normal
>> > =A0 =A0 =A0 =A0 =A0 Priority: P1
>> > =A0 =A0 =A0 =A0 =A0Component: Other
>> > =A0 =A0 =A0 =A0 AssignedTo: acme@ghostprotocols.net
>> > =A0 =A0 =A0 =A0 ReportedBy: eduardo.panisset@gmail.com
>> > =A0 =A0 =A0 =A0 Regression: No
>> >
>> >
>> > I have been testing DSMIPv6 code which uses all kind of advanced
>> > features of XFRM framework and I believe I have found a bug relate=
d to
>> > update RTAX_ADVMSS route metric.
>> > The XFRM code on net/xfrm/xfrm_policy.c by its functions
>> > xfrm_init_pmtu and xfrm_bundle_ok updates RTAX_MTU route caching
>> > metric however I believe it must update RTAX_ADVMSS as this later =
is
>> > used by tcp connect function for adverting the MSS value on SYN
>> > messages.
>> >
>> > As MSS is not being updated by XFRM the TCP SYN messages (e.g.
>> > originated from a internet browser) =A0is erroneously informing it=
s MSS
>> > (without taking into account the overhead added to IP packet size =
by
>> > XFRM transformations). =A0One result of that is the browser gets
>> > "frozen" after starts a TCP connection because TCP messages sent b=
y
>> > TCP server will never get to it (TCP server is sending too large
>> > segments to browser).
>> >
>> > Below I describe the changes I have done (on xfrm_init_pmtu and
>> > xfrm_bundle_ok) and that seem to fix this problem:
>> >
>> > xfrm_init_pmtu:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.
>> >
>> > =A0 =A0 =A0 =A0 dst->metrics[RTAX_MTU-1] =3D pmtu; // original cod=
e, below my changes
>> >
>> > =A0 =A0 =A0 =A0 if (dst->xfrm->props.mode =3D=3D XFRM_MODE_TUNNEL)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (dst->xfrm->props.family=
)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case AF_INET:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dst->metrics[RTAX_ADVMSS-1] =3D=
 max_t(unsigned int,
>> > pmtu - sizeof(struct iphdr) - sizeof(struct tcphdr), 256);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case AF_INET6:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dst->metrics[RTAX_ADVMSS-1] =3D=
 max_t(unsigned int,
>> > pmtu - sizeof(struct ipv6hdr) - sizeof(struct tcphdr),
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_net(ds=
t->dev)->ipv6.
>> > sysctl.ip6_rt_min_advmss);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >
>> > xfrm_bundle_ok:
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.
>> >
>> > =A0 =A0 =A0 =A0 dst->metrics[RTAX_MTU-1] =3D mtu; // original code=
, below my changes
>> >
>> > =A0 =A0 =A0 =A0 if (dst->xfrm->props.mode =3D=3D XFRM_MODE_TUNNEL)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (dst->xfrm->props.family)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case AF_INET:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst->metrics[RTAX_=
ADVMSS-1] =3D max_t(unsigned
>> > int, mtu - sizeof(struct iphdr) - sizeof(struct tcphdr), 256);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case AF_INET6:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst->metrics[RTAX_=
ADVMSS-1] =3D max_t(unsigned
>> > int, mtu - sizeof(struct ipv6hdr) - sizeof(struct tcphdr),
>> >
>> > dev_net(dst->dev)->ipv6.sysctl.ip6_rt_min_advmss);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
