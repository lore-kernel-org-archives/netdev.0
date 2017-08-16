From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Wed, 16 Aug 2017 12:06:36 -0700
Message-ID: <599497BC.6010205@gmail.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>        <20170816.112819.1162151697604053267.davem@davemloft.net> <20170816.113501.1961184995639656444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: 8bit
Cc: daniel@iogearbox.net, ast@fb.com, tgraf@suug.ch,
        netdev@vger.kernel.org, tom@herbertland.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37921 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbdHPTHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 15:07:10 -0400
Received: by mail-pg0-f65.google.com with SMTP id 123so5969611pga.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 12:07:10 -0700 (PDT)
In-Reply-To: <20170816.113501.1961184995639656444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2017 11:35 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 16 Aug 2017 11:28:19 -0700 (PDT)
> 
>> From: John Fastabend <john.fastabend@gmail.com>
>> Date: Tue, 15 Aug 2017 22:30:15 -0700
>>
>>> This series implements a sockmap and socket redirect helper for BPF
>>> using a model similar to XDP netdev redirect.
>>
>> Series applied, thanks John.
>>
> 
> We get a legit warning from gcc due to these changes:
> 
> kernel/bpf/sockmap.c: In function ¡smap_state_change¢:
> kernel/bpf/sockmap.c:156:21: warning: ¡psock¢ may be used uninitialized in this function [-Wmaybe-uninitialized]
>   struct smap_psock *psock;
> 
> It's the default switch case in this function, psock is not initialized
> for sure at this point.
> 

I missed this with older gcc4 it seems. Fixed now and compiling without errors
now with gcc4/5. Below is the diff and all verifier/sockmap tests pass. Want a
v2 I presume?

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 792f0ad..f7e5e6c 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -188,6 +188,9 @@ static void smap_state_change(struct sock *sk)
                        smap_release_sock(sk);
                break;
        default:
+               psock = smap_psock_sk(sk);
+               if (unlikely(!psock))
+                       break;
                smap_report_sk_error(psock, EPIPE);
                break;
        }
