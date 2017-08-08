From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next v1] net: ipv6: avoid overhead when no custom FIB rules
 are installed
Date: Tue, 8 Aug 2017 14:51:32 +0200
Message-ID: <20170808125132.GE1853@nanopsycho>
References: <20170808115121.21283-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        David Ahern <dsa@cumulusnetworks.com>
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34707 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdHHMvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 08:51:35 -0400
Received: by mail-wr0-f194.google.com with SMTP id o33so2374422wrb.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 05:51:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170808115121.21283-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 08, 2017 at 01:51:21PM CEST, vincent@bernat.im wrote:
>If the user hasn't installed any custom rules, don't go through the
>whole FIB rules layer. This is pretty similar to f4530fa574df (ipv4:
>Avoid overhead when no custom FIB rules are installed).
>
>Using a micro-benchmark module [1], timing ip6_route_output() using
>get_cycles(), on my laptop with performance governor (so, subject to
>some caution due to thermal throttling), with 40,000 routes in the main
>routing table, before this patch:
>
>    min=603 max=12477 count=627 average=1926 95th=4518 90th=3661 50th=1600 mad=724
>    table=254 avgdepth=21.8 maxdepth=39
>        value │                         ┊                            count
>          600 │▒▒▒▒▒▒▒▒▒▒                                              134
>          860 │▒▒▒▒▒▒▒░░░░░░░░░░                                        91
>         1120 │▒▒▒░░░░░░░░░░░░░░░░░░                                    39
>         1380 │▒▒▒▒░░░░░░░░░░░░░░░░░░░░░                                58
>         1640 │▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░                           57
>         1900 │▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                       58
>         2160 │▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                   46
>         2420 │▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                 26
>         2680 │▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░               27
>         2940 │▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░              15
>         3200 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░              8
>         3460 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░             8
>         3720 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░           12
>         3980 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░            9
>         4240 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░           7
>         4500 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░           6
>
>After:
>
>    min=486 max=12390 count=627 average=1715 95th=4365 90th=3352 50th=1324 mad=631
>    table=254 avgdepth=21.8 maxdepth=39
>        value │                         ┊                            count
>          480 │▒▒▒▒▒▒▒▒▒▒▒▒                                            153
>          730 │▒▒▒▒▒▒▒░░░░░░░░░░░░                                      88
>          980 │▒▒▒▒░░░░░░░░░░░░░░░░░░░                                  57
>         1230 │▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░                             56
>         1480 │▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░                          43
>         1730 │▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                      50
>         1980 │▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                   31
>         2230 │▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                  23
>         2480 │▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                15
>         2730 │▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░               23
>         2980 │▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░             20
>         3230 │▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░            14
>         3480 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░            4
>         3730 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░            8
>         3980 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░           9
>         4230 │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░           4

Cool graphs!


>
>At the frequency of the laptop during the bench (~ 2.3 GHz), this is
>about a 130 ns difference on the median value and 50 ns on the minimal
>value.
>
>A next step would be to collapse local and main tables, as in
>0ddcf43d5d4a (ipv4: FIB Local/MAIN table collapse).
>
>[1]: https://github.com/vincentbernat/network-lab/blob/master/lab-routes-ipv6/kbench_mod.c
>
>Signed-off-by: Vincent Bernat <vincent@bernat.im>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
