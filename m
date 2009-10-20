From: Anirban Sinha <asinha@zeugmasystems.com>
Subject: Re: Kernel oops when clearing bgp neighbor info with TCP MD5SUM
 enabled
Date: Mon, 19 Oct 2009 17:56:07 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0910191745050.20086@sleet.zeugmasystems.local>
References: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local>
 <20091008.155429.02850661.davem@davemloft.net>
 <Pine.LNX.4.64.0910081622400.18315@sleet.zeugmasystems.local>
 <20091008.175703.83006470.davem@davemloft.net>
 <Pine.LNX.4.64.0910171035340.2364@sleet.zeugmasystems.local>
 <4ADA7EDC.5010402@anirban.org> <4ADB7856.7000803@anirban.org>
 <20091019121327.GA11423@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Anirban Sinha <ani@anirban.org>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeugmasystems.com ([70.79.96.174]:25008 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932396AbZJTA4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 20:56:03 -0400
In-Reply-To: <20091019121327.GA11423@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I'd suppose that this unbalance comes from inet_twdr_hangman() pathes.
>
> Could you verify this?


Yes, I have now verified this. There is indeed an issue with one of the
functions called by inet_twdr_hangman(). The call sequence is:

inet_twdr_hangman() -> inet_twdr_do_twkill_work() -> inet_twsk_put() ->
twsk_destructor().

In this case, the destructor callback is tcp_twsk_destructor() (installed
from line 1208 in net/ipv4/tcp_ipv4.c and line 906 in net/ipv6/tcp_ipv6.c) .
Without the TCP_MD5SUM compiled in, the function is a no-op. However, with the MD5SUM
compiled in, it calls tcp_put_md5_sig_pool() (when keylen is non zero) which
does an unbalanced put_cpu(). I did a grep across the entire tree.
tcp_put_md5_sig_pool() is a matching function for tcp_get_md5_sig_pool() and
in all other TCP IPV4 cases, it is called from net/ipv4/tcp_ipv4.c from
functions tcp_v4_md5_hash_hdr() and

