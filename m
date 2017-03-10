From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for
 tcp and udp
Date: Thu, 09 Mar 2017 20:25:36 -0800
Message-ID: <1489119936.28631.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33894 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753876AbdCJEZj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:25:39 -0500
Received: by mail-pf0-f194.google.com with SMTP id o126so9412243pfb.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 20:25:38 -0800 (PST)
In-Reply-To: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-09 at 20:31 -0700, Subash Abhinov Kasiviswanathan wrote:
> Certain system process significant unconnected UDP workload.
> It would be preferrable to disable UDP early demux for those systems
> and enable it for TCP only.

> +void tcp_v4_early_demux_configure(int enable)
> +{
> +	if (enable)
> +		tcp_protocol.early_demux = tcp_v4_early_demux;
> +	else
> +		tcp_protocol.early_demux = NULL;
> +}
> +
> +void udp_v4_early_demux_configure(int enable)
> +{
> +	if (enable)
> +		udp_protocol.early_demux = udp_v4_early_demux;
> +	else
> +		udp_protocol.early_demux = NULL;
> +}
> +


Well, then you need to make sure ipprot->early_demux is read once in the
callers, like ip_rcv_finish(), otherwise compiler could read it twice
and we could deref a NULL pointer.

ipprot = rcu_dereference(inet_protos[protocol]);
if (ipprot && ipprot->early_demux) {
    ipprot->early_demux(skb);   // crash
