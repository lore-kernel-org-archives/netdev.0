From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv4: route: fix inet_rtm_getroute induced crash
Date: Sun, 13 Aug 2017 22:34:43 -0600
Message-ID: <17031977-3e7a-9a7f-e53c-538cb030e496@gmail.com>
References: <20170813225258.16001-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35412 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdHNEep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 00:34:45 -0400
Received: by mail-pg0-f48.google.com with SMTP id v189so39184382pgd.2
        for <netdev@vger.kernel.org>; Sun, 13 Aug 2017 21:34:45 -0700 (PDT)
In-Reply-To: <20170813225258.16001-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/13/17 4:52 PM, Florian Westphal wrote:
> "ip route get $daddr iif eth0 from $saddr" causes:
>  BUG: KASAN: use-after-free in ip_route_input_rcu+0x1535/0x1b50
>  Call Trace:
>   ip_route_input_rcu+0x1535/0x1b50
>   ip_route_input_noref+0xf9/0x190
>   tcp_v4_early_demux+0x1a4/0x2b0
>   ip_rcv+0xbcb/0xc05
>   __netif_receive_skb+0x9c/0xd0
>   netif_receive_skb_internal+0x5a8/0x890
> 
> Problem is that inet_rtm_getroute calls either ip_route_input_rcu (if an
> iif was provided) or ip_route_output_key_hash_rcu.
> 
> But ip_route_input_rcu, unlike ip_route_output_key_hash_rcu, already
> associates the dst_entry with the skb.  This clears the SKB_DST_NOREF
> bit (i.e. skb_dst_drop will release/free the entry while it should not).
> 
> Thus only set the dst if we called ip_route_output_key_hash_rcu().
> 
> I tested this patch by running:
>  while true;do ip r get 10.0.1.2;done > /dev/null &
>  while true;do ip r get 10.0.1.2 iif eth0  from 10.0.1.1;done > /dev/null &
> ... and saw no crash or memory leak.
> 
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: David Ahern <dsahern@gmail.com>
> Fixes: ba52d61e0ff ("ipv4: route: restore skb_dst_set in inet_rtm_getroute")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Have looked at the change in detail, but are you sure that is the
correct Fixes?

Running these:
  while true;do ip r get 10.1.1.3;done > /dev/null &
  while true;do ip r get 10.1.1.3 iif eth0  from 192.16.1.1;done >
/dev/null &

at various commits:
  ffe95ecf3a2 - KASAN backtraces
  374d801522f - works fine
  ba52d61e0ff - negative refcnt messages
  a5e2ee5da47 - works fine
