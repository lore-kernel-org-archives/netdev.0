From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: speedup tcp_fixup_rcvbuf()
Date: Thu, 16 May 2013 00:11:16 -0700
Message-ID: <1368688276.3301.24.camel@edumazet-glaptop>
References: <1368681955.3301.11.camel@edumazet-glaptop>
	 <1697330.SmXeaasf9r@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:37566 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238Ab3EPHLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 03:11:18 -0400
Received: by mail-da0-f45.google.com with SMTP id w3so1472573dad.32
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 00:11:17 -0700 (PDT)
In-Reply-To: <1697330.SmXeaasf9r@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 09:06 +0200, Christoph Paasch wrote:

> just out of curiosity, how do you run 200 concurrent netperfs?
> Is there an option as in iperf (-P) ?
> I did not find anything like this in the netperf-code.

I am pretty sure there are some scripts in the netperf tree, but I am so
lazy ;)

I use the following shell script : (OK even with old netperf versions)

$ ./super_netperf 200 -t TCP_CRR

$ cat super_netperf 
#!/bin/bash

run_netperf() {
	loops=$1
	shift
	for ((i=0; i<loops; i++)); do
		netperf -s 2 $@ | awk '/Min/{
			if (!once) {
				print;
				once=1;
			}
		}
		{
			if (NR == 6)
				save = $NF
			else if (NR==7) {
				if (NF > 0)
					print $NF
				else
					print save
			} else if (NR==11) {
				print $0
			}
		}' &
	done
	wait
	return 0
}

run_netperf $@ | awk '{if (NF==7) {print $0; next}} {sum += $1} END
{print sum}'
