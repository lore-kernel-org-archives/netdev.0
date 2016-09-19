From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net v2] qed: Fix stack corruption on probe
Date: Mon, 19 Sep 2016 17:24:46 +0000
Message-ID: <BL2PR07MB23066CD6432BBDE74937E6E08DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474296461-22558-1-git-send-email-Yuval.Mintz@qlogic.com>,<063D6719AE5E284EB5DD2968C1650D6DB0103817@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: David Laight <David.Laight@ACULAB.COM>,
        'Yuval Mintz' <Yuval.Mintz@qlogic.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0048.outbound.protection.outlook.com ([104.47.34.48]:8352
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752796AbcISRYt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 13:24:49 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0103817@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Commit fe56b9e6a8d95 ("qed: Add module with basic common support")
> > has introduced a stack corruption during probe, where filling a
> > local struct with data to be sent to management firmware is incorrectly
> > filled; The data is written outside of the struct and corrupts
> > the stack.
> >=20
> > @@ -1153,8 +1153,8 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
> >=A0=A0=A0=A0=A0=A0=A0 p_drv_version =3D &union_data.drv_version;
> >=A0=A0=A0=A0=A0=A0=A0 p_drv_version->version =3D p_ver->version;
> >=20
> > -=A0=A0=A0=A0 for (i =3D 0; i < MCP_DRV_VER_STR_SIZE - 1; i +=3D 4) {
> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 val =3D cpu_to_be32(p_ver->name[i=
]);
> > +=A0=A0=A0=A0 for (i =3D 0; i < (MCP_DRV_VER_STR_SIZE - 4) / sizeof(u32=
); i++) {
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 val =3D cpu_to_be32(*((u32 *)&p_v=
er->name[i * sizeof(u32)]));
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 *(__be32 *)&p_drv_version-=
>name[i * sizeof(u32)] =3D val;
> >=A0=A0=A0=A0=A0=A0=A0 }
>=20
> Or the much simpler:
>=A0=A0=A0=A0=A0 /* Byteswap driver name */
> =A0=A0=A0=A0=A0=A0=A0 for (i =3D 0; i < MCP_DRV_VER_STR_SIZE; i++)
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 p_drv_version->name[i ^ 3] =
=3D p_ver->name[i];

You're suggesting an unconditional swap; This will break
the message on a big endian machine [we'll swap needlessly].
    =
