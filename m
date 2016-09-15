From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 14:54:57 -0600
Message-ID: <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
 <20160915202219.GB1867@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34539 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752197AbcIOUzA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:55:00 -0400
Received: by mail-pa0-f45.google.com with SMTP id wk8so19171231pab.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:54:59 -0700 (PDT)
In-Reply-To: <20160915202219.GB1867@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/16 2:22 PM, Cyrill Gorcunov wrote:
>> ss -K is not working. Socket lookup fails to find a match due to a protocol mismatch.
>>
>> haven't had time to track down why there is a mismatch since the kill uses the socket returned
>> from the dump. Won't have time to come back to this until early next week.
> 
> Have you ran iproute2 patched? I just ran ss -K and all sockets get closed
> (including raw ones), which actually kicked me off the testing machine sshd :/
> 


This is the patch I applied to iproute2; the change in your goo.gl link plus a debug to confirm the kill action is initiated by ss:

diff --git a/misc/ss.c b/misc/ss.c
index 3b268d999426..4d98411738ea 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2334,6 +2334,10 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
        if (diag_arg->f->f && run_ssfilter(diag_arg->f->f, &s) == 0)
                return 0;

+       if (diag_arg->f->kill) {
+printf("want to kill:\n");
+       err = inet_show_sock(h, &s, diag_arg->protocol);
+       }
        if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
                if (errno == EOPNOTSUPP || errno == ENOENT) {
                        /* Socket can't be closed, or is already closed. */
@@ -2631,6 +2635,10 @@ static int raw_show(struct filter *f)

        dg_proto = RAW_PROTO;

+if (!getenv("PROC_NET_RAW") && !getenv("PROC_ROOT") &&
+inet_show_netlink(f, NULL, IPPROTO_RAW) == 0)
+return 0;
+
        if (f->families&(1<<AF_INET)) {
                if ((fp = net_raw_open()) == NULL)
                        goto outerr;
