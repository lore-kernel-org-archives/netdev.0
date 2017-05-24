From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 0/4] arp: always override existing neigh entries with
 gratuitous ARP
Date: Wed, 24 May 2017 23:57:37 +0200
Message-ID: <CAK8P3a0AcshP-2L2icLwW+DHrn-0w+YsdOjob_34k0N-EHKGTQ@mail.gmail.com>
References: <cover.1495136258.git.ihrachys@redhat.com> <CAK8P3a162_RdXHLCPzg47+F7yadRGMDgFG_z5R6v65-heY1KAw@mail.gmail.com>
 <23f8a3fa-3e7a-339a-2deb-76d20fe6483b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, ja@ssi.bg,
        Networking <netdev@vger.kernel.org>
To: Ihar Hrachyshka <ihrachys@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35968 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1036130AbdEXV5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:57:38 -0400
Received: by mail-oi0-f67.google.com with SMTP id w138so34796896oiw.3
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 14:57:38 -0700 (PDT)
In-Reply-To: <23f8a3fa-3e7a-339a-2deb-76d20fe6483b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 24, 2017 at 11:32 PM, Ihar Hrachyshka <ihrachys@redhat.com> wrote:
> On 05/23/2017 01:56 PM, Arnd Bergmann wrote:
>>
>> This seems to have caused a build warning:
>>
>> net/ipv4/arp.c:880:35: warning: 'addr_type' may be used uninitialized
>> in this function [-Wmaybe-uninitialized]
>>
> Not sure. How do you reproduce it? I just did 'make net' in the latest tree
> that includes the patch, and it doesn't trigger the failure. Also the code
> logic prevents it to be uninitialized (it's always set to -1 or the actual
> type value).

I saw it reported by the kernelci build bot:

https://kernelci.org/build/id/5925b81859b514fb106b9590/logs/

It happened on arm64 with 'make allmodconfig', but none of the other
architectures or the other configurations on that architecture.

This kind of warning can be a real pain to shut up when the compiler
gets it wrong. I haven't tested the latest kernel with your patch on my
own build box yet, so I also haven't been able to reproduce it.
Most likely, gcc gets confused when it needs to track the state of
too many variables here (I certainly get confused when I read it too).

My first attempt to resolve it would be:

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ae96e6f3e0cb..39f26980a565 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -663,6 +663,8 @@ static bool arp_is_garp(struct net *net, struct
net_device *dev,
                *addr_type = inet_addr_type_dev_table(net, dev, sip);
                if (*addr_type != RTN_UNICAST)
                        is_garp = false;
+       } else {
+               *addr_type = -1;
        }
        return is_garp;
 }
@@ -864,7 +866,6 @@ static int arp_process(struct net *net, struct
sock *sk, struct sk_buff *skb)
        n = __neigh_lookup(&arp_tbl, &sip, dev, 0);

        if (n || IN_DEV_ARP_ACCEPT(in_dev)) {
-               addr_type = -1;
                is_garp = arp_is_garp(net, dev, &addr_type, arp->ar_op,
                                      sip, tip, sha, tha);
        }

but this clearly needs a lot of build testing to see if it's sufficient. Moving
the initialization of addr_type=1 to the start of the function would
certainly avoid the warning, but I suspect this would be incorrect here.

        Arnd
