From: David Newall <davidn@davidnewall.com>
Subject: Re: Bad checksum on bridge with IP options
Date: Tue, 13 May 2014 09:16:47 +0930
Message-ID: <53715D67.8020803@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com>,<5370CB47.4010400@davidnewall.com> <DUB123-W514EA0A4A29F520778F2FFED350@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, "fw@strlen.de" <fw@strlen.de>
To: Lukas Tribus <luky-37@hotmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Bandan Das <bandan.das@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:47504 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbaELXyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 19:54:36 -0400
In-Reply-To: <DUB123-W514EA0A4A29F520778F2FFED350@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/05/14 04:24, Lukas Tribus wrote:
> Looks like your testcase:
> - works in 2.6.36 and older
> - crashes starting with 2.6.37 (-rc1), likely due to Bandan's commit 462fb2af9788a82 (bridge : Sanitize skb before it enters the IP stack) [1]
> - crash fix is in 2.6.38.4, likely due to Eric's commit f8e9881c2aef1e9 (bridge: reset IPCB in br_parse_ip_options) [2]
> - doesn't work post-crashfix
>
>
>
> [1]http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=462fb2af9788a82a534f8184abfde31574e1cfa0
> [2]http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f8e9881c2aef1e982e5abc25c046820cd0b7cf64
>   		 	   		
Thanks, Lukas, for researching those changes.  It explains why 
ip_options_compile() is being called.

Discussion for [1] starts at https://lkml.org/lkml/2010/8/30/391. 
Briefly, "if we recieve (sic) a packet greater in size than the 
bridge device MTU, we call ip_fragment which in turn will lead to 
icmp_send calling ip_options_echo if the DF flag is set."

Eric Dumazet said (in that discussion), "once again, the IP stack -> 
bridge -> IP stack flow bites us."  Such enduring insight. He also said, 
"we can correct every bug we find ... or just make bridge not touch IPCB."

Assuming now is not the time to stop bridge from touching IPCB, 
recalculating the checksum would seem appropriate, but insufficient as 
at least the RR and TS options aren't being set correctly; perhaps 
others.  I think calling ip_forward_options will fix that, and, 
conveniently, will also recalculate the checksum if the options changed.

I'm thinking that the following changes might do the trick (but haven't 
yet tested them; the complete kernel needs to be recompiled, and my 
machine is still grinding away):

--- br_netfilter.c.orig 2014-05-12 22:10:59.809988125 +0930
+++ br_netfilter.c      2014-05-13 08:08:48.330396347 +0930
@@ -312,6 +312,9 @@
                         goto drop;
         }

+       if (unlikely(opt->is_changed && opt->optlen))
+               ip_forward_options(skb);
+
         return 0;

  inhdr_error:
--- ../ipv4/ip_options.c.orig   2014-05-13 05:40:10.408914495 +0930
+++ ../ipv4/ip_options.c        2014-05-13 08:29:01.482130038 +0930
@@ -601,6 +601,7 @@
                 ip_send_check(ip_hdr(skb));
         }
  }
+EXPORT_SYMBOL(ip_forward_options);

  int ip_options_rcv_srr(struct sk_buff *skb)
  {
