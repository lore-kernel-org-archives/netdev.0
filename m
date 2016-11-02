From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 0/2] Fixes for raw diag sockets handling
Date: Wed, 2 Nov 2016 09:36:55 -0600
Message-ID: <ec9f3fbe-c95c-6e07-1263-29784d9ba361@cumulusnetworks.com>
References: <20161102123630.784612652@openvz.org>
 <2a540f59-4495-573c-7dda-0303f1810e6e@cumulusnetworks.com>
 <20161102152900.GC1852@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36544 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755864AbcKBPg6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:36:58 -0400
Received: by mail-pf0-f175.google.com with SMTP id 189so13884773pfz.3
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:36:58 -0700 (PDT)
In-Reply-To: <20161102152900.GC1852@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/16 9:29 AM, Cyrill Gorcunov wrote:
> On Wed, Nov 02, 2016 at 09:10:32AM -0600, David Ahern wrote:
>>> @__dif != 0 the match may return socket where sk_bound_dev_if = 0
>>> instead of completely matching one. Isn't it?
>>
>> yes. I recently added an exact_dif to the lookup for listener sockets
>> (see compute_score). Something like that could be added to INET_MATCH.
> 
> Seem so. I need to revisit this moment. Because with current lookup code
> iproute2 patches I made and been testing do not kill all sockets bound
> to particular device in one pass (because request from userspace asks
> for index 15 in my case but kernel return one with index 0). At first
> I thought I made a mistake in userspace code but once I added printk's
> into kernel I found that here some strange results over lookup.

Limited to raw sockets or are you looking at multiple spec options (dev, address, port)?

I have not seen issues with tcp or udp. Running:

    ss -aK 'dev == red' 

drops all sockets bound to device 'red' (or at least signaling the socket failure for the app to handle):

root@jessie4:~# ss -ap 'dev == red'
Netid  State      Recv-Q Send-Q     Local Address:Port                      Peer Address:Port
udp    UNCONN     0      0                  *%red:12345                                *:*                     users:(("vrf-test",pid=765,fd=3))
tcp    LISTEN     0      1                  *%red:12345                                *:*                     users:(("vrf-test",pid=766,fd=3))
tcp    ESTAB      0      0         10.100.1.4%red:ssh                       10.100.1.254:60298                 users:(("sshd",pid=738,fd=3))

root@jessie4:~# ss -aKp 'dev == red'
Netid State      Recv-Q Send-Q                      Local Address:Port                                       Peer Address:Port
udp   UNCONN     0      0                                   *%red:12345                                                 *:*                     users:(("vrf-test",pid=765,fd=3))
tcp   LISTEN     0      1                                   *%red:12345                                                 *:*                     users:(("vrf-test",pid=766,fd=3))
tcp   ESTAB      0      0                          10.100.1.4%red:ssh                                        10.100.1.254:60298                 users:(("sshd",pid=738,fd=3))

root@jessie4:~# ss -ap 'dev == red'
Netid State      Recv-Q Send-Q                      Local Address:Port                                       Peer Address:Port
