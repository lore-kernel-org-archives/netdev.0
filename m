From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [Question]: reqsk table size limited to 16?
Date: Fri, 2 Oct 2009 08:25:32 +0200
Message-ID: <20091002062532.GA15755@gerrit.erg.abdn.ac.uk>
References: <20091002061134.GC5646@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57150 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756731AbZJBGZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 02:25:34 -0400
Received: from laptev.erg.abdn.ac.uk (Debian-exim@ra-gerrit.erg.abdn.ac.uk [139.133.204.38])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id n926PWSs013089
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 2 Oct 2009 07:25:33 +0100 (BST)
Received: from gerrit by laptev.erg.abdn.ac.uk with local (Exim 4.69)
	(envelope-from <gerrit@laptev.erg.abdn.ac.uk>)
	id 1Mtba8-0006Bt-OY
	for netdev@vger.kernel.org; Fri, 02 Oct 2009 08:25:32 +0200
Content-Disposition: inline
In-Reply-To: <20091002061134.GC5646@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please forget the posting, this is correct; the clamping is

  8 <= nr_table_entries <=  sysctl_max_syn_backlog,

i.e. the minimum table size is 16.

Quoting Gerrit:
| Can someone please have a look, it may be that I am missing something?
| 
| It seems that in the following the maximum number of table entries is set
| to always 16, despite sysctl_max_syn_backlog (tcp_max_syn_backlog), 
| overriding the 'backlog' parameter to listen(2).
| 
| net/core/request_sock.c
| -----------------------
| 
| int reqsk_queue_alloc(struct request_sock_queue *queue,
|                       unsigned int nr_table_entries)
| {
|         size_t lopt_size = sizeof(struct listen_sock);
|         struct listen_sock *lopt;
| 
| 	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
|         nr_table_entries = max_t(u32, nr_table_entries, 8);
|         nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
| 
| 	//...
| 	for (lopt->max_qlen_log = 3;
|              (1 << lopt->max_qlen_log) < nr_table_entries;
|              lopt->max_qlen_log++);
| 
|  	//...
| 	lopt->nr_table_entries = nr_table_entries;
| 	
| 	//...
| 	return 0
| }
| 
| The function is called with an argument 'nr_table_entries', which is then clamped as
| 
|    sysctl_max_syn_backlog <= nr_table_entries <= 8
| 
| If nr_table_entries = 8, then round_pow_of_two(8 + 1) = 16.
| 
| The sysctl value is set to a much higher value (default 128 or 1024, net/ipv4/tcp.c).
| 
| The reqsk_queue_alloc() gets 'nr_table_entries' passed directly from inet_csk_listen_start(),
| which in turn gets its 'nr_table_entries' as the 'backlog' argument to listen(2) via
|  * net/dccp/proto.c   (dccp_listen_start) or
|  * net/ipv4/af_inet.c (inet_listen).

-- 
