From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: must lock the socket in udp_disconnect()
Date: Thu, 20 Oct 2016 19:09:29 -0700
Message-ID: <1477015769.7065.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <31cb3583-5620-de3f-784d-300df3fda0a4@gmail.com>
         <CAM_iQpVExpqdOXZp0Lw+4Nr2_9W24P2dQFdM=EoYwBkHtwDoPw@mail.gmail.com>
         <05f766db-4a8c-933e-9d73-6daada21f491@gmail.com>
         <1476944754.7065.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <1476981580.7065.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVG-L=ZCDnOpDjpyDWuyPFY378JbQ5qhu9_bhzOGc9BuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Baozeng Ding <sploving1@gmail.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33747 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753043AbcJUCJb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 22:09:31 -0400
Received: by mail-pf0-f196.google.com with SMTP id i85so7095140pfa.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 19:09:31 -0700 (PDT)
In-Reply-To: <CAM_iQpVG-L=ZCDnOpDjpyDWuyPFY378JbQ5qhu9_bhzOGc9BuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-20 at 18:12 -0700, Cong Wang wrote:

> If this is the cause of the hashlist corruption (I am still unsure about this),
> then why only UDP? Don't all of those using ip4_datagram_connect()
> as ->connect() and using udp_disconnect() as ->disconnect() need this fix?
> 
> For example, after your patch,
> 
>         .connect =      ip4_datagram_connect,
> -       .disconnect =   udp_disconnect,
> +       .disconnect =   __udp_disconnect,
> 
> Ping socket still doesn't have sock lock for ->disconnect() but has it for
> ->connect()? I must miss something...

ping is less complex, it is protected by a single ping_table.lock

While UDP has to maintain two hash chains with may locks, and has to
handle rehash(), because autobind happens before full 4-tuple is setup.
