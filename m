From: Alexandre Ferrieux <alexandre.ferrieux@gmail.com>
Subject: Using HTB and FQ on the same interface
Date: Thu, 8 Jun 2017 19:22:54 +0200
Message-ID: <CAKYWH0SjoSHX+qgRj77bo=3L7iy9Gfwd8NNA3fQm2jqM1m5VLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33636 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdFHRXQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 13:23:16 -0400
Received: by mail-qt0-f178.google.com with SMTP id u12so49459150qth.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 10:23:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, I need to use simultaneously on the same interface the classful
qdisc HTB and the classless qdisc FQ. The rationale is:

   - I need to send properly shaped UDP streams to a few remote IP
addresses. For this I'm using htb classes and u32 filters.

   - for a few other remote peers I need FQ to be available since I
activated BBR congestion control (ip route change ... congctl bbr)

Questions:

  (1) can this be done at all ?

  (2)  if yes, what are the recommended hierarchy and parameters so
that things go smoothly in the limit of low traffic (neither qdisc
needing a significant fraction of the 1Gbps line rate) ?

I was thinking about

    # HTB as root
    root@foo:~# tc qdisc add dev eth1 handle 1: root htb
    # FQ in a line-rate class
    root@foo:~# tc class add dev eth1 parent 1: classid 1:42 htb rate 1gbit
    root@foo:~# tc qdisc add dev eth1 parent 1:42 fq
    # "n" HTB classes with appropriate rates and individual u32 filters
    root@foo:~# tc class add dev eth1 parent 1: classid $id htb rate $rate
    root@foo:~# tc filter add dev eth1 parent 1: protocol ip prio
$prio u32 match ip protocol 17 0xff match ip dst $IP/32 flowid $id

Thanks for amending.

  (3) In detail, how do the models interact (the token buckets on one
side, and the regular interval timers on the other) ? What happens to
subsequent packets in a paced FQ flow if some get delayed due to
contention: does FQ "catch up" or do packets get offset in the future
?

Thanks in advance,

-Alex
