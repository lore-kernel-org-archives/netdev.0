From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [stable] regression in iptables: recent filter
Date: Fri, 12 Sep 2008 07:11:32 +0400
Message-ID: <20080912031132.GA6443@x200.localdomain>
References: <ejijc4dc92n75s2el334e7dgdanngs7qv3@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Grant Coady <gcoady.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:40070 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbYILDJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:09:40 -0400
Received: by gv-out-0910.google.com with SMTP id e6so418146gvc.37
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:09:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ejijc4dc92n75s2el334e7dgdanngs7qv3@4ax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2008 at 11:53:35AM +1000, Grant Coady wrote:
> Last known good kernel: 2.6.24.7
> 
> # iptables -N calmrate
> # iptables -A calmrate -p tcp -m state --state NEW \
> 	-m recent --name listrate --update --rttl \
> 	--seconds 60 --hitcount 60 -j DROP
> iptables: Unknown error 4294967295
> 
> Fails for 2.6.25.17 and 2.6.26.5
> 
> dmesg + config: http://bugsplatter.id.au/kernel/boxen/deltree/

You were einvaled by the following commit:

Reloading module with ip_pkt_list_tot=60 should fix it.

commit d0ebf133590abdc035af6e19a6568667af0ab3b0
Author: Daniel Hokka Zakrisson <daniel@hozac.com>
Date:   Thu Mar 20 15:07:10 2008 -0700

    [NETFILTER]: ipt_recent: sanity check hit count
    
    If a rule using ipt_recent is created with a hit count greater than
    ip_pkt_list_tot, the rule will never match as it cannot keep track
    of enough timestamps. This patch makes ipt_recent refuse to create such
    rules.
    
    With ip_pkt_list_tot's default value of 20, the following can be used
    to reproduce the problem.
    
    nc -u -l 0.0.0.0 1234 &
    for i in `seq 1 100`; do echo $i | nc -w 1 -u 127.0.0.1 1234; done
    
    This limits it to 20 packets:
    iptables -A OUTPUT -p udp --dport 1234 -m recent --set --name test \
             --rsource
    iptables -A OUTPUT -p udp --dport 1234 -m recent --update --seconds \
             60 --hitcount 20 --name test --rsource -j DROP
    
    While this is unlimited:
    iptables -A OUTPUT -p udp --dport 1234 -m recent --set --name test \
             --rsource
    iptables -A OUTPUT -p udp --dport 1234 -m recent --update --seconds \
             60 --hitcount 21 --name test --rsource -j DROP
    
    With the patch the second rule-set will throw an EINVAL.
    
    Reported-by: Sean Kennedy <skennedy@vcn.com>
    Signed-off-by: Daniel Hokka Zakrisson <daniel@hozac.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/netfilter/ipt_recent.c b/net/ipv4/netfilter/ipt_recent.c
index 68cbe3c..8e8f042 100644
--- a/net/ipv4/netfilter/ipt_recent.c
+++ b/net/ipv4/netfilter/ipt_recent.c
@@ -252,6 +252,8 @@ recent_mt_check(const char *tablename, const void *ip,
 	if ((info->check_set & (IPT_RECENT_SET | IPT_RECENT_REMOVE)) &&
 	    (info->seconds || info->hit_count))
 		return false;
+	if (info->hit_count > ip_pkt_list_tot)
+		return false;
 	if (info->name[0] == '\0' ||
 	    strnlen(info->name, IPT_RECENT_NAME_LEN) == IPT_RECENT_NAME_LEN)
 		return false;
