From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 1/1] net sched actions: Add support for user
 cookies
Date: Sun, 22 Jan 2017 10:13:28 -0800
Message-ID: <11da08ed-32b3-2a9f-8ba4-54b346cabecc@gmail.com>
References: <1485089498-6673-1-git-send-email-jhs@emojatatu.com>
 <1485089498-6673-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33133 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdAVSNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 13:13:34 -0500
Received: by mail-wm0-f67.google.com with SMTP id r144so20750144wme.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 10:13:33 -0800 (PST)
In-Reply-To: <1485089498-6673-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/22/2017 04:51 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Introduce optional 128-bit action cookie.
> Like all other cookie schemes in the networking world (eg in protocols
> like http or existing kernel fib protocol field, etc) the idea is to save
> user state that when retrieved serves as a correlator. The kernel
> _should not_ intepret it.  The user can store whatever they wish in the
> 128 bits.
> 
> Sample exercise(showing variable length use of cookie)
> 
> .. create an accept action with cookie a1b2c3d4
> sudo $TC actions add action ok index 1 cookie a1b2c3d4
> 
> .. dump all gact actions..
> sudo $TC -s actions ls action gact
> 
>     action order 0: gact action pass
>      random type none pass val 0
>      index 1 ref 1 bind 0 installed 5 sec used 5 sec
>     Action statistics:
>     Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
>     cookie a1b2c3d4
> 
> .. bind the accept action to a filter..
> sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
> u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 1
> 
> ... send some traffic..
> $ ping 127.0.0.1 -c 3
> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.020 ms
> 64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.027 ms
> 64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.038 ms
> 
> --- 127.0.0.1 ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 2109ms
> rtt min/avg/max/mdev = 0.020/0.028/0.038/0.008 ms 1
> 
> ... show some stats
> $ sudo $TC -s actions get action gact index 1
> 
>     action order 1: gact action pass
>      random type none pass val 0
>      index 1 ref 2 bind 1 installed 204 sec used 5 sec
>     Action statistics:
>         Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
>     cookie a1b2c3d4
> 
> .. try longer cookie...
> $ sudo $TC actions replace action ok index 1 cookie 1234567890abcdef
> .. dump..
> $ sudo $TC -s actions ls action gact
> 
>     action order 1: gact action pass
>      random type none pass val 0
>      index 1 ref 2 bind 1 installed 204 sec used 5 sec
>     Action statistics:
>         Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
>     cookie 1234567890abcdef
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

> +		a->act_cookie->data = nla_memdup(tb[TCA_ACT_COOKIE],
> +						 GFP_KERNEL);
> +		if (!a->act_cookie->data) {
> +			err = -ENOMEM;
> +			tcf_hash_release(a, bind);
> +			goto err_mod;
> +		}

Are not you leaking a->act_cookie here in case nla_memdup() fails here?
-- 
Florian
