From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: A bug in team driver
Date: Wed, 05 Oct 2016 12:08:48 +0900
Message-ID: <1475636928.28155.196.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3444639.ILgt5kU9OR@zbook>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35404 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbcJEDIx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 23:08:53 -0400
Received: by mail-pf0-f172.google.com with SMTP id s13so82414455pfd.2
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 20:08:53 -0700 (PDT)
In-Reply-To: <3444639.ILgt5kU9OR@zbook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-04 at 18:30 -0400, Alex Sidorenko wrote:
> The problem was found on RHEL7.2 but is still present in the latest
> upstream kernel (according to visual sources inspection).
> 
> While using roundrobin runner we have noticed that after sending on
> team0 about 2.1 billion packets we started seeing 50% packet drop on
> team0 
> (according to 'netstat -i'). This number suggested 'signed int'
> overflow and indeed, inspecting the sources I have noticed the
> following in 
> 
> drivers/net/team/team_mode_roundrobin.c
> ---------------------------------------
> struct rr_priv {
> 	unsigned int sent_packets;                        <--------- unsigned
> int
> };
> 
> static struct rr_priv *rr_priv(struct team *team)
> {
> 	return (struct rr_priv *) &team->mode_priv;
> }
> 
> static bool rr_transmit(struct team *team, struct sk_buff *skb)
> {
> 	struct team_port *port;
> 	int port_index;
> 
> 	port_index = team_num_to_port_index(team,
> 					    rr_priv(team)->sent_packets++);
> ---
> 
> 
> we have 'unsigned int sent_packets' but we call team_num_to_port_index
> where 'num' is 'int'
> 
> include/linux/if_team.h
> -----------------------
> static inline int team_num_to_port_index(struct team *team, int num)
> <-- signed int
> {
> 	int en_port_count = ACCESS_ONCE(team->en_port_count);
> 
> 	if (unlikely(!en_port_count))
> 		return 0;
> 	return num % en_port_count;
> }
> 
> 
> As soon as sent_packets becomes larger than MAXINT (=2**31-1),
> team_num_to_port_index() can return negative number as num becomes
> negative and remainder 
> (num % en_port_count) is either 0 or negative. This leads to looking
> up incorrect hash-bucket and dropping packets.
> 
> We have easily duplicated this in roundrobin mode with two ports.
> After reaching 2**31 packets sent on team0 every second packet was
> dropped.
> 
> Rebuilding the kernel after changing 
> 
> team_num_to_port_index(struct team *team, int num) ->
> team_num_to_port_index(struct team *team, unsigned int num)
> 
> and running the test again does not show packet drop anymore.
> 
> The same subroutine is used in
> team_mode_loadbalance.c:lb_hash_select_tx_port but we pass 'unsigned
> char hash' to team_num_to_port_index(), so there should be no
> overflow. I did not test that mode in my tests.

Good catch ! Can you send an official patch to fix this ?

Thanks.

> 
