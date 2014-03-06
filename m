From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH net-next 0/5] net_sched: Adjust qdisc_change() for
 command "#tc qdisc change/replace ..."
Date: Fri, 7 Mar 2014 06:08:18 +0900
Message-ID: <20140307060818.fa549a2981b601bcec517227@gmail.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org, eric.dumazet@gmail.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:40495 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbaCFVIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:08:22 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so3171039pab.24
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 13:08:21 -0800 (PST)
In-Reply-To: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Mar 2014 21:08:36 +0800
Yang Yingliang <yangyingliang@huawei.com> wrote:

> Current commands "#tc qdisc replace..." and "#tc qdisc change..."
> are not doing what they're supposed to do.
> 
> E.g.
> 
> With "#tc qdisc replace ...", it won't clear old option if not specified in
> qdisc of netem.
> 
>    # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
>    # tc qdisc show
>      qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit
> 
>    # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
>    # tc qdisc show
>      qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit
> The old option "rate" is still there.

It looks like you are trying to replace existing qdisc 1: with
the same qdisc 1:. So the effect is the same as change.
If you want to do replace the existing qdisc, you should specify
other handle or different qdisc.

> With "#tc qdisc change ... ", it will clear old options if not specified in
> qdisc of tbf.
> 
>   # tc qdisc add dev eth4 handle 1: root tbf rate 10mbit burst 10kb latency 50ms mtu 64kb peakrate 20mbit
>   # tc qdisc show
>     qdisc tbf 1: dev eth4 root refcnt 2 rate 10Mbit burst 10Kb peakrate 20Mbit minburst 64Kb lat 50.0ms
>   # tc qdisc change dev eth4 handle 1: root tbf rate 20mbit burst 10kb latency 50ms
>   # tc qdisc show
>     qdisc tbf 1: dev eth4 root refcnt 2 rate 20Mbit burst 10Kb lat 50.0ms
> The old peakrate and minburst are cleared.

You are assumed to implicitly specify "peakrate 0" at change.
It seems that you are arguing the tc command, not kernel code.
There would exist userland commmand whose rate and peakrate
command options are always mandatory.
How they support its command options is up to userland I think.

> This patchset adds a flag parameter in qdisc_change and a replace func in struct Qdisc_ops.
> If the flag has NLM_F_REPLACE, we call the replace function, or call the change function in
> qdisc_change(). And, add tbf_replace() and netem_replace() needed by tbf and netem.
> 
> Yang Yingliang (5):
>   net_sched: add flag parameter in qdisc_change
>   net_sched: add replace func in struct Qdisc_ops
>   sch_tbf: change name "tbf_change" to "tbf_replace"
>   sch_tbf: add tbf_change for #tc qdisc change ...
>   sch_netem: add netem_replace for #tc qdisc replace ...
> 
>  include/net/sch_generic.h |   1 +
>  net/sched/sch_api.c       |  16 ++++--
>  net/sched/sch_netem.c     | 127 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/sched/sch_tbf.c       | 120 ++++++++++++++++++++++++++++++++++++++++++-
>  4 files changed, 258 insertions(+), 6 deletions(-)
> 
> -- 
> 1.8.0
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
