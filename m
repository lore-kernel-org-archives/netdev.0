From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express	adapters
 -	Take #2
Date: Mon, 23 Jul 2007 11:52:38 -0700
Message-ID: <46A4F8F6.3010008@hp.com>
References: <E35F4F4D7F6C9E4E826FEC1F86CEF58304330045@orsmsx412.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	arjan@linux.intel.com, akpm@linux-foundation.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hch@infradead.org,
	shemminger@linux-foundation.org, nhorman@tuxdriver.com,
	inaky@linux.intel.com, mb@bu3sch.de
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:36792 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756983AbXGWS7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 14:59:47 -0400
In-Reply-To: <E35F4F4D7F6C9E4E826FEC1F86CEF58304330045@orsmsx412.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> 
> Bidirectional test.
> 87380  65536  65536    60.01   7809.57   28.66    30.02    2.405   2.519
> TX
> 87380  65536  65536    60.01   7592.90   28.66    30.02    2.474   2.591
> RX
> ------------------------------
> 87380  65536  65536    60.01  7629.73   28.32    29.64    2.433   2.546
> RX
> 87380  65536  65536    60.01  7926.99   28.32    29.64    2.342   2.450
> TX
> 
> Signle netperf stream between 2 quad-core Xeon based boxes. Tested on
> 2.6.20 and 2.6.22 kernels. Driver uses NAPI and LRO.

The bidirectional looks like a two concurrent stream (TCP_STREAM + TCP_MAERTS) 
test right?

If you want a single-stream bidirectional test, then with the top of trunk 
netperf you can use:

./configure --enable-burst
make install # yadda yadda
netperf -t TCP_RR -H <remote> -f m -v 2 -l 60 -c -C -- -r 64K -b 12

which will cause netperf to have 13, 64K transactions in flight at one time on 
the connection, which for a 64K request size has been sufficient, thusfar 
anyway, to saturate things.  As there is no select/poll/whatever call in netperf 
TCP_RR it might be necessary to include test-specific -s and -S options to make 
sure the socket buffer (SO_SNDBUF) is large enough that none of those send() 
calls ever block, lest both ends end-up blocked in a send() call.

The -f m will switch the output from transactions/s to megabits per second and 
is the part requiring the top of trunk netperf.  The -v 2 stuff causes extra 
stuff to give bitrates in each direction and transaction/s rate as well as 
computed average latency.  That is also in top of trunk, otherwise, for 2.4.3 
you can skip that and do the math to conver to megabits/s yourself and not get 
all the other derived values.

rick jones
