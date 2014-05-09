From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Fri, 9 May 2014 22:02:58 +0100
Message-ID: <536D4282.9070309@citrix.com>
References: <395225650.20140430124506@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12158 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757131AbaEIVDC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 17:03:02 -0400
In-Reply-To: <395225650.20140430124506@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry for the long silence on this issue, I was busy trying to figure 
out what went wrong. Fun facts:

- commenting out that _pskb_pull_tail from tx_submit which 
unconditionally pulls up the linear area to 128 bytes seems to solve the 
problem
- I could repro the problem only when the sending guest had a 64 bit 
kernel, but then even with 3.2. On the other hand, with 32 bit sending 
guest it works fine. More exactly I think it boils down to the actual 
config, I used XenServer Dom0 config files, see them here:
https://github.com/xenserver/linux-3.x.pg/blob/master/master/kernel-configuration
- with 64 bit Debian 7 kernel as sender it also works, so I guess it's 
not about 32/64 bit, but something in the config
- the receiving guest, where wget ran, doesn't matter.
- the "more than MAX_SKB_FRAGS slots" thing was a red herring. A typical 
skb layout (on the sender's xenvif_start_xmit) which gets corrupted:
linear area: 66 bytes
0. frag: 52 bytes
1. frag: 1200 bytes
- so I guess the problem is when that pull_tail pulls the whole first 
frag into the linear area
- a corrupt packet on the receiver side looks like the following:
   - linear buffer: 128 bytes, content is OK
   - the content of the frag area is shifted back 4096 bytes in the
TCP stream. So instead of the Nth byte it starts with the (N-4096)th byte
   - the length is the same as on the sender side, I've checked by 
looking at the IP id fields
   - otherwise the stream content looks ok (I used a continuously 
incrementing pattern)
   - the next packet starts at the right place
- the pulling itself doesn't cause the corruption, I've printed out the 
first frag after that, and it still looks OK
- ftrace_printk("%*ph") seems to have problems when the pointer points 
to a grant mapped page. I have the impression that it tries to 
dereference it when I read the trace buffer, at which point the mapping 
and the content is long gone.

I'll continue to look into this next week

Zoli
