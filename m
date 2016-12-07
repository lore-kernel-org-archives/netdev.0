From: Kirila Adamova <kia@open.ch>
Subject: nfct_query hangs after multiple requests
Date: Wed, 7 Dec 2016 17:27:07 +0000
Message-ID: <DB6PR0501MB2405C30CE23567587FC3C072A8850@DB6PR0501MB2405.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.open.ch ([213.156.227.108]:47480 "EHLO mx1.open.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752956AbcLGR1L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 12:27:11 -0500
Received: from mx1.open.ch (localhost [127.0.0.1])
        by mx1.open.ch (Mission Control Email Shield, 616) with SMTP id 3tYlmY68Z0z4XYJ
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 18:27:09 +0100 (MET)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01lp0215.outbound.protection.outlook.com [213.199.154.215])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.open.ch (Mission Control Email Shield, 616) with ESMTPS id 3tYlmY3HQCz4XHX
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 18:27:09 +0100 (MET)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi     =20
         =20
I am using nfct_query (libnetfilter_conntrack library) to get a connection =
from the conntrack table and then to update its connmark. This was working =
ok in a development environment, but when testing it in production with a l=
ot of traffic, after around a minute, the daemon hangs on nfct_query and do=
es not process any more data.     =20
         =20
Some background:     =20
- I am sending packets via NFLOG to the daemon (and setting a connmark 0x2/=
0x2)
- the daemon polls the NFLOG group and handles the packets via nflog_handle=
_packet     =20
- the callback registered with the nflog handle extracts the conntrack info=
rmation from the packet header (L4 proto, src/dst ip, src/dst port)     =20
- an nf_conntrack pointer is created with this information     =20
- (calling another library which calls another callback)     =20
- if certain conditions are met     =20
-- register nfct callback -- nfct_callback_register(h, NFCT_T_ALL, my_nfct_=
callback, h)     =20
-- nfct_query with NFCT_Q_GET  to get the conntrack connection based on the=
 ct data     =20
-- (in the nfct callback) check the connmark of the connection and run nfct=
 query with NFCT_Q_UPDATE to update the connmark of that same connection   =
  =20

The nfct_handle is opened at the start of the daemon and closed via signal =
handling at termination.     =20

After placing some debug prints in the code, I discovered that at some poin=
t nfct_query for NFCT_Q_GET is called, but it never enters the callback fun=
ction.     =20

Debugging with strace showed the following:     =20
...     =20
recvfrom(4,"$\0\0\0\2\0\0\0h\4IX\22(\0\0\0\0\0\0\304\0\0\0\0\1\5\0h\4IX"...=
, 8192, 0, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, [12]) =3D =
36     =20
sendto(4,"", 0, 0, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12=
) =3D 0     =20
recvfrom(4,
---  and is hanging here.     =20

I am writing to this mailing list, hoping that somebody would have an idea =
how to proceed with debugging and what the issue might be. Obviously, it's =
the amount of connections. But there must be a way to handle them for longe=
r than a minute. Once it hangs, it never resumes.     =20

Please let me know if you need any further information or part of the code.=
     =20

Versions used:     =20
libnetfilter_conntrack - 1.0.4     =20
libnetfilter_log  - 1.0.1     =20

Best regards     =20
Kirila=
