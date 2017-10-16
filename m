From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [patch net v2 3/4] selftests: Introduce a new script to generate
 tc batch file
Date: Mon, 16 Oct 2017 12:24:56 -0400
Message-ID: <CAMDBHY+sCMJOta=5Sn+t2zaRN3C92TD7DrTWO7KY5K+qMp-9AA@mail.gmail.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com> <1508152718-28726-4-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:45314 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754368AbdJPQZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:25:17 -0400
Received: by mail-wm0-f46.google.com with SMTP id q124so5126199wmb.0
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:25:17 -0700 (PDT)
In-Reply-To: <1508152718-28726-4-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 7:18 AM, Chris Mi <chrism@mellanox.com> wrote:
>   # ./tdc_batch.py -h
>   usage: tdc_batch.py [-h] [-n NUMBER] [-o] [-s] [-p] device file
>
>   TC batch file generator
>
>   positional arguments:
>     device                device name
>     file                  batch file name
>
>   optional arguments:
>     -h, --help            show this help message and exit
>     -n NUMBER, --number NUMBER
>                           how many lines in batch file
>     -o, --skip_sw         skip_sw (offload), by default skip_hw
>     -s, --share_action    all filters share the same action
>     -p, --prio            all filters have different prio
>
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Lucas Bates <lucasb@mojatatu.com>

> ---
>  tools/testing/selftests/tc-testing/tdc_batch.py | 62 +++++++++++++++++++++++++
>  1 file changed, 62 insertions(+)
>  create mode 100755 tools/testing/selftests/tc-testing/tdc_batch.py
>
> diff --git a/tools/testing/selftests/tc-testing/tdc_batch.py b/tools/testing/selftests/tc-testing/tdc_batch.py
> new file mode 100755
> index 0000000..707c6bf
> --- /dev/null
> +++ b/tools/testing/selftests/tc-testing/tdc_batch.py
> @@ -0,0 +1,62 @@
> +#!/usr/bin/python3
> +
> +"""
> +tdc_batch.py - a script to generate TC batch file
> +
> +Copyright (C) 2017 Chris Mi <chrism@mellanox.com>
> +"""
> +
> +import argparse
> +
> +parser = argparse.ArgumentParser(description='TC batch file generator')
> +parser.add_argument("device", help="device name")
> +parser.add_argument("file", help="batch file name")
> +parser.add_argument("-n", "--number", type=int,
> +                    help="how many lines in batch file")
> +parser.add_argument("-o", "--skip_sw",
> +                    help="skip_sw (offload), by default skip_hw",
> +                    action="store_true")
> +parser.add_argument("-s", "--share_action",
> +                    help="all filters share the same action",
> +                    action="store_true")
> +parser.add_argument("-p", "--prio",
> +                    help="all filters have different prio",
> +                    action="store_true")
> +args = parser.parse_args()
> +
> +device = args.device
> +file = open(args.file, 'w')
> +
> +number = 1
> +if args.number:
> +    number = args.number
> +
> +skip = "skip_hw"
> +if args.skip_sw:
> +    skip = "skip_sw"
> +
> +share_action = ""
> +if args.share_action:
> +    share_action = "index 1"
> +
> +prio = "prio 1"
> +if args.prio:
> +    prio = ""
> +    if number > 0x4000:
> +        number = 0x4000
> +
> +index = 0
> +for i in range(0x100):
> +    for j in range(0x100):
> +        for k in range(0x100):
> +            mac = ("%02x:%02x:%02x" % (i, j, k))
> +            src_mac = "e4:11:00:" + mac
> +            dst_mac = "e4:12:00:" + mac
> +            cmd = ("filter add dev %s %s protocol ip parent ffff: flower %s "
> +                   "src_mac %s dst_mac %s action drop %s" %
> +                   (device, prio, skip, src_mac, dst_mac, share_action))
> +            file.write("%s\n" % cmd)
> +            index += 1
> +            if index >= number:
> +                file.close()
> +                exit(0)
> --
> 1.8.3.1
>
