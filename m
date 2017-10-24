From: Chris Mi <chrism@mellanox.com>
Subject: RE: [Patch net 14/15] selftests: Introduce a new script to generate
 tc batch file
Date: Tue, 24 Oct 2017 04:56:38 +0000
Message-ID: <VI1PR0501MB21432E8BF498C06F8C142E2EAB470@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
 <20171023220304.2268-15-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0077.outbound.protection.outlook.com ([104.47.1.77]:17488
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750886AbdJXE4l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 00:56:41 -0400
In-Reply-To: <20171023220304.2268-15-xiyou.wangcong@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Cong Wang [mailto:xiyou.wangcong@gmail.com]
> Sent: Tuesday, October 24, 2017 6:03 AM
> To: netdev@vger.kernel.org
> Cc: paulmck@linux.vnet.ibm.com; jhs@mojatatu.com;
> john.fastabend@gmail.com; Chris Mi <chrism@mellanox.com>; Cong Wang
> <xiyou.wangcong@gmail.com>
> Subject: [Patch net 14/15] selftests: Introduce a new script to generate =
tc
> batch file
>=20
> From: Chris Mi <chrism@mellanox.com>
>=20
> From: Chris Mi <chrism@mellanox.com>
>=20
>   # ./tdc_batch.py -h
>   usage: tdc_batch.py [-h] [-n NUMBER] [-o] [-s] [-p] device file
>=20
>   TC batch file generator
>=20
>   positional arguments:
>     device                device name
>     file                  batch file name
>=20
>   optional arguments:
>     -h, --help            show this help message and exit
>     -n NUMBER, --number NUMBER
>                           how many lines in batch file
>     -o, --skip_sw         skip_sw (offload), by default skip_hw
>     -s, --share_action    all filters share the same action
>     -p, --prio            all filters have different prio
>=20
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Acked-by: Lucas Bates <lucasb@mojatatu.com>
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  tools/testing/selftests/tc-testing/tdc_batch.py | 62
> +++++++++++++++++++++++++
>  1 file changed, 62 insertions(+)
>  create mode 100644 tools/testing/selftests/tc-testing/tdc_batch.py
>=20
> diff --git a/tools/testing/selftests/tc-testing/tdc_batch.py
> b/tools/testing/selftests/tc-testing/tdc_batch.py
> new file mode 100644
File mode should be 755.
> index 000000000000..707c6bfef689
> --- /dev/null
> +++ b/tools/testing/selftests/tc-testing/tdc_batch.py
> @@ -0,0 +1,62 @@
> +#!/usr/bin/python3
> +
> +"""
> +tdc_batch.py - a script to generate TC batch file
> +
> +Copyright (C) 2017 Chris Mi <chrism@mellanox.com> """
> +
> +import argparse
> +
> +parser =3D argparse.ArgumentParser(description=3D'TC batch file generato=
r')
> +parser.add_argument("device", help=3D"device name")
> +parser.add_argument("file", help=3D"batch file name")
> +parser.add_argument("-n", "--number", type=3Dint,
> +                    help=3D"how many lines in batch file")
> +parser.add_argument("-o", "--skip_sw",
> +                    help=3D"skip_sw (offload), by default skip_hw",
> +                    action=3D"store_true") parser.add_argument("-s",
> +"--share_action",
> +                    help=3D"all filters share the same action",
> +                    action=3D"store_true") parser.add_argument("-p",
> +"--prio",
> +                    help=3D"all filters have different prio",
> +                    action=3D"store_true") args =3D parser.parse_args()
> +
> +device =3D args.device
> +file =3D open(args.file, 'w')
> +
> +number =3D 1
> +if args.number:
> +    number =3D args.number
> +
> +skip =3D "skip_hw"
> +if args.skip_sw:
> +    skip =3D "skip_sw"
> +
> +share_action =3D ""
> +if args.share_action:
> +    share_action =3D "index 1"
> +
> +prio =3D "prio 1"
> +if args.prio:
> +    prio =3D ""
> +    if number > 0x4000:
> +        number =3D 0x4000
> +
> +index =3D 0
> +for i in range(0x100):
> +    for j in range(0x100):
> +        for k in range(0x100):
> +            mac =3D ("%02x:%02x:%02x" % (i, j, k))
> +            src_mac =3D "e4:11:00:" + mac
> +            dst_mac =3D "e4:12:00:" + mac
> +            cmd =3D ("filter add dev %s %s protocol ip parent ffff: flow=
er %s "
> +                   "src_mac %s dst_mac %s action drop %s" %
> +                   (device, prio, skip, src_mac, dst_mac, share_action))
> +            file.write("%s\n" % cmd)
> +            index +=3D 1
> +            if index >=3D number:
> +                file.close()
> +                exit(0)
> --
> 2.13.0
