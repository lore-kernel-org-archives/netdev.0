From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 3/5] tcp/dccp: Consolidate common code for RFC 3390
	conversion
Date: Wed, 1 Sep 2010 07:23:55 +0200
Message-ID: <20100901052355.GA5379@gerrit.erg.abdn.ac.uk>
References: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-2-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-3-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-4-git-send-email-gerrit@erg.abdn.ac.uk> <alpine.DEB.2.00.1008301557590.31318@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:56388 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751132Ab0IAFYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 01:24:10 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008301557590.31318@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > This patch consolidates initial-window code common to TCP and CCID-2:
| >  * TCP uses RFC 3390 in a packet-oriented manner (tcp_input.c) and
| >  * CCID-2 uses RFC 3390 in packet-oriented manner (RFC 4341).
...
| > +static inline u32 rfc3390_bytes_to_packets(const u32 smss)
| > +{
| > +	return smss <= 1095 ? 4 : (smss > 1460 ? 2 : 3);
| > +}
| > +
...
| 
| What is spelled out in tcp_select_initial_window might also need to follow 
| the same logic?
| 
Thank you for paying attention, can you please have a look at the subsequent
patch. I went through this yesterday and found that in 4 different places 
there are 4 different interpretations of what RFC 3390 means.

Having asked someone more familiar with IETF issues, it seems that the RFC 5681
interpretation of RFC 3390 is now the 'official' one.

+------------+--------------------+--------------------+--------------------+--------------------+
| Condition  |     RFC 2414       |        Linux       |       Linux        |     RFC 5681       |
|            |     RFC 3390       |      tcp_input     |     tcp_output     |                    |
+------------+--------------------+--------------------+--------------------+--------------------+
| 2 segments | 2190 < MSS         | 1460 < MSS         | 4380 < MSS         | 2190 < MSS         |
| 3 segments | 1095 < MSS <= 1460 | 1095 < MSS <= 1460 | 1460 < MSS <= 4380 | 1095 < MSS <= 2190 |
| 4 segments |        MSS <= 1095 |        MSS <= 1095 |        MSS <= 1460 |        MSS <= 1095 |
+------------+--------------------+--------------------+--------------------+--------------------+
